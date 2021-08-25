#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
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
        d2_session = d2_session
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
#' @importFrom magrittr %>% %<>%
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
    dplyr::mutate(Data = get_indicator_name(.data$`Data`)) %>%

    # Summarizes MOH and PEPFAR data up from coarse and fine disaggregates
    dplyr::group_by(.data$`Data`, .data$`Organisation unit`, .data$`period`) %>%
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

    # Groups rows by indicator and calculates indicator-specific summaries
    dplyr::group_by(.data$Data, .data$period) %>%
    dplyr::mutate(count_of_matched_sites =
                    sum(ifelse(.data$reported_by == "Both", 1, 0))) %>%
    dplyr::mutate(pepfar_sum_at_matched_sites =
                    sum(ifelse(.data$reported_by == "Both",
                               .data$pepfar, 0))) %>%
    dplyr::ungroup() %>%

    # Calculates weighting variables
    dplyr::mutate(weighting =
                    ifelse(.data$reported_by == "Both",
                           .data$pepfar / .data$pepfar_sum_at_matched_sites,
                           NA)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(weighted_discordance =
                    daa.analytics::weighted_discordance(.data$moh,
                                                        .data$pepfar,
                                                        .data$weighting)) %>%
    dplyr::mutate(weighted_concordance =
                    daa.analytics::weighted_concordance(.data$moh,
                                                        .data$pepfar,
                                                        .data$weighting)) %>%
    dplyr::ungroup() %>%

    # Reorganizes table for export
    dplyr::select(facilityuid = .data$`Organisation unit`,
                  indicator = .data$`Data`,
                  .data$period,
                  .data$moh, .data$pepfar, .data$reported_by,
                  .data$count_of_matched_sites,
                  .data$pepfar_sum_at_matched_sites, .data$weighting,
                  .data$weighted_discordance, .data$weighted_concordance)
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
