#' @export
#' @title Get DAA Indicator Data
#'
#' @description
#' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' country.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return Dataframe of unadorned PEPFAR and the MOH DAA indicator data.
#'
get_daa_data <- function(ou_uid, d2_session) {

  indicator_uids <- daa.analytics::daa_indicators$uid

  period_list <-
    paste(paste0(2017:(daa.analytics::current_fiscal_year()), "Oct"),
          collapse = ";")

  # TODO Make this into a tryCatch to future proof against large OUs timing out
  # Breaks the query into multiple parts for Nigeria to prevent timeout
  df <- tryCatch({
      datimutils::getAnalytics(
        paste0("dimension=SH885jaRe0o:mXjFJEexCHJ;t6dWOH7W5Ml&",
               "displayProperty=SHORTNAME&outputIdScheme=UID"),
        dx = paste(indicator_uids, collapse = ";"),
        pe = period_list,
        ou = paste0("OU_GROUP-POHZmzofoVx;", ou_uid),
        d2_session = d2_session,
        retry = 2
      )
    },
    # If error is thrown, then try again splitting query into multiple parts.
    error = function(e) {
      # TODO log this in a log file.
      # Prints an error message.
      print(
        paste0("Error: Timeout was reached after 60 seconds with 0 bytes",
               "received. Trying again with query broken into smaller chunks.")
      )
      # Pulls data for each indicator as an individual query to shrink size
      indicator_uids %>%
        # Makes queries for each group of indicators
        lapply(function(x) {
          datimutils::getAnalytics(
            paste0("dimension=SH885jaRe0o:mXjFJEexCHJ;t6dWOH7W5Ml&",
                   "displayProperty=SHORTNAME&outputIdScheme=UID"),
            dx = x,
            pe = period_list,
            ou = paste0("OU_GROUP-POHZmzofoVx;", ou_uid),
            d2_session = d2_session
          )
        }) %>%
        # Binds all of the component dataframes together
        dplyr::bind_rows()
    }
  )
  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }
  # Returns dataframe
  return(df)
}

#' @export
#' @title Adorn DAA Indicator Data
#'
#' @description
#' Cleans and adorns a dataframe of DAA data containing UIDs with indicator
#' names, fiscal years, and weighted concordance and discordance information,
#' as well as other information.
#'
#' @param df Dataframe containing DAA data indicator data to be adorned.
#'
#' @return Dataframe of DAA indicator data for both PEPFAR and the MOH as well
#' as both discordance and concordance metrics.
#'
adorn_daa_data <- function(df) {
  # Returns null if delivered an empty dataset
  if (is.null(df)) {
    return(NULL)
  }
  # Cleans data and prepares it for export
  df %<>%
    # Pivots MOH and PEPFAR data out into separate columns
    tidyr::pivot_wider(names_from = .data$`Funding Mechanism`,
                       values_from = .data$`Value`) %>%

    # Cleans Period data from the form `2018Oct` to `2019`
    dplyr::mutate(period =
                    as.numeric(stringr::str_sub(.data$`Period`, 0, 4)) + 1) %>%

    # Renames MOH and PEPFAR columns and converts them to numeric data types
    dplyr::mutate(moh = as.numeric(.data$`mXjFJEexCHJ`)) %>%
    dplyr::mutate(pepfar = as.numeric(.data$`t6dWOH7W5Ml`)) %>%

    # Filtering out HTS_TST data from indicators V6hxDYUZFBq and BRalYZhcHpi
    # to only FY2020 to prevent duplication
    dplyr::filter((.data$Data %in% c("V6hxDYUZFBq", "BRalYZhcHpi"))
                  & .data$period >= 2020 |
                    !(.data$Data %in% c("V6hxDYUZFBq", "BRalYZhcHpi"))) %>%

    # TODO Filter this data out before the data call or figure
    # out how to present it to the user effectively
    # Filters out indicator LZbeWYZEkYL to prevent duplication of TB_PREV data
    dplyr::filter(.data$Data != "LZbeWYZEkYL") %>%

    # Generates human-readable indicator names
    dplyr::mutate(Data = get_indicator_name(.data$Data)) %>%

    # Summarizes MOH and PEPFAR data up from coarse and fine disaggregates
    dplyr::group_by(.data$Data, .data$`Organisation unit`, .data$period) %>%
    dplyr::summarise(moh =
                       sum(.data$moh, na.rm = any(!is.na(.data$moh))),
                     pepfar =
                       sum(.data$pepfar, na.rm = any(!is.na(.data$pepfar)))) %>%
    dplyr::ungroup() %>%

    # Creates summary data about reporting institutions and figures
    dplyr::mutate(reported_by =
                    ifelse(!is.na(.data$moh),
                           ifelse(!is.na(.data$pepfar), "Both", "MOH"),
                           ifelse(!is.na(.data$pepfar),
                                  "PEPFAR", "Neither"))) %>%

    # Reorganizes table for export
    dplyr::select(facilityuid = .data$`Organisation unit`,
                  indicator = .data$`Data`,
                  .data$period,
                  .data$moh,
                  .data$pepfar,
                  .data$reported_by)

  return(df)
}


#' Adorn DAA Indicator Data with Weighted Metrics for All Levels
#'
#' @param daa_indicator_data Dataframe containing DAA indicator data.
#' @param ou_hierarchy Dataframe containing the Organisational hierarchy.
#'
#' @return A dataframe of DAA Indicator data with weightings and weighted
#' discordance and concordance calculated for levels 3 through 5.
#' @export
#'
weighting_levels <- function(daa_indicator_data = NULL, ou_hierarchy = NULL) {
  ou_hierarchy %<>%
    dplyr::select(-.data$organisationunitid, -paste0("namelevel", 3:7)) %>%
    unique()

  df <- daa_indicator_data %>%
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(ou_hierarchy, by = c("facilityuid")) %>%

    # Calculates Level 3 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel3uid) %>%
    dplyr::mutate(level3_weighting =
                    ifelse(.data$reported_by == "Both",
                           .data$pepfar / sum(
                             ifelse(.data$reported_by == "Both",
                                    .data$pepfar, 0)),
                           NA)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level3_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level3_weighting),
                  level3_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level3_weighting)
    ) %>%
    dplyr::ungroup() %>%

    # Calculates Level 4 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel4uid) %>%
    dplyr::mutate(level4_weighting =
                    ifelse(.data$reported_by == "Both",
                           .data$pepfar / sum(
                             ifelse(.data$reported_by == "Both",
                                    .data$pepfar, 0)),
                           NA)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level4_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level4_weighting),
                  level4_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level4_weighting)
    )%>%
    dplyr::ungroup() %>%

    # Calculates Level 5 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel5uid) %>%
    dplyr::mutate(level5_weighting =
                    ifelse(.data$reported_by == "Both",
                           .data$pepfar / sum(
                             ifelse(.data$reported_by == "Both",
                                    .data$pepfar, 0)),
                           NA)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level5_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level5_weighting),
                  level5_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level5_weighting)
    ) %>%
    dplyr::ungroup() %>%

    # # Calculates Level 6 weighted concordance and discordance
    # dplyr::group_by(.data$indicator,
    #                 .data$period,
    #                 .data$namelevel6uid) %>%
    # dplyr::mutate(level6_weighting =
    #                 ifelse(.data$reported_by == "Both",
    #                        .data$pepfar / sum(
    #                          ifelse(.data$reported_by == "Both",
    #                                 .data$pepfar, 0)),
    #                        NA)) %>%
  # dplyr::rowwise() %>%
  # dplyr::mutate(level6_discordance = ifelse(is.na(namelevel7), NA_real_,
  #                                           daa.analytics::weighted_discordance(
  #                                             moh = .data$moh,
  #                                             pepfar = .data$pepfar,
  #                                             weighting = .data$level6_weighting)),
  #               level6_concordance = ifelse(is.na(namelevel7), NA_real_,
  #                                           daa.analytics::weighted_concordance(
  #                                             moh = .data$moh,
  #                                             pepfar = .data$pepfar,
  #                                             weighting = .data$level6_weighting))
  # ) %>%
  # dplyr::ungroup() %>%

  # Selects rows for export
  dplyr::select(-dplyr::starts_with("namelevel"))

  return(df)
}


# Helper functions ------------------------------------------
#' @title Get Indicator Name
#'
#' @description
#' Converts Indicator UID into a human-readable name.
#'
#' @param uid UID for Indicator
#'
#' @return Indicator name as a string.
#'
#' @noRd
#'
get_indicator_name <- function(uid) {
  get_name <- daa.analytics::daa_indicators$indicator
  names(get_name) <- daa.analytics::daa_indicators$uid
  indicator_name <- unname(get_name[uid])
  return(indicator_name)
}
