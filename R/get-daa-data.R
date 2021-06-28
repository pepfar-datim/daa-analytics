#' @export
#' @importFrom magrittr %>% %<>%
#' @title Get DAA Indicator Data
#'
#' @description
#' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' country.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return Dataframe of DAA indicator data for both PEPFAR and the MOH as well
#' as both discordance and concordance metrics.
#'
get_daa_data <- function(ou_uid, d2_session) {

  indicator_list <- paste(daa.analytics::daa_indicators$uid, collapse = ";")

  period_list <- paste(paste0(2017:(daa.analytics::currentFY() - 1), "Oct"),
                       collapse = ";")

  df <- datimutils::getAnalytics(
    paste0(
      "dimension=SH885jaRe0o:mXjFJEexCHJ;t6dWOH7W5Ml&",
      "displayProperty=SHORTNAME&",
      "outputIdScheme=UID"
    ),
    dx = indicator_list,
    pe = period_list,
    ou = paste0("OU_GROUP-POHZmzofoVx;", ou_uid),
    d2_session = d2_session
  )

  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }
  # Returns dataframe
  return(df)
}

adorn_daa_data <- function(df){
  # Cleans data and prepares it for export
  df %<>%
    # Pivots MOH and PEPFAR data out into separate columns
    tidyr::pivot_wider(., names_from = `Funding Mechanism`,
                       values_from = `Value`) %>%

    # Cleans Period data from the form `2018Oct` to `2018`
    dplyr::mutate(Period = as.numeric(stringr::str_sub(`Period`, 0, 4))) %>%

    # Renames MOH and PEPFAR columns and converts them to numeric data types
    dplyr::mutate("MOH" = as.numeric(`mXjFJEexCHJ`)) %>%
    dplyr::mutate("PEPFAR" = as.numeric(`t6dWOH7W5Ml`)) %>%

    # Filtering out HTS_TST data from indicators V6hxDYUZFBq and BRalYZhcHpi
    # to only FY2020 to prevent duplication
    dplyr::filter((Data %in% c("V6hxDYUZFBq", "BRalYZhcHpi"))
                  & Period >= 2020 |
                    !(Data %in% c("V6hxDYUZFBq", "BRalYZhcHpi"))) %>%

    # TODO Filter this data out before the data call or figure
    # out how to present it to the user effectively
    # Filters out indicator LZbeWYZEkYL to prevent duplication of TB_PREV data
    dplyr::filter(Data != "LZbeWYZEkYL") %>%

    # Generates human-readable indicator names
    dplyr::mutate(Data = get_indicator_name(`Data`)) %>%

    # Summarizes MOH and PEPFAR data up from coarse and fine disaggregates
    dplyr::group_by(`Data`, `Organisation unit`, `Period`) %>%
    dplyr::summarise(MOH = sum(MOH, na.rm = any(!is.na(MOH))),
                     PEPFAR = sum(PEPFAR, na.rm = any(!is.na(PEPFAR)))) %>%
    dplyr::ungroup() %>%

    # Creates summary data about reporting institutions and figures
    dplyr::mutate("Reported by" =
                    ifelse(!is.na(MOH),
                           ifelse(!is.na(PEPFAR), "Both", "MOH"),
                           ifelse(!is.na(PEPFAR), "PEPFAR", "Neither"))) %>%
    # dplyr::mutate("Difference" =
    #                 ifelse(`Reported by` == "Both", MOH - PEPFAR, NA)) %>%

    # TODO Determine if this column can be removed
    # dplyr::mutate("Reported higher" = dplyr::case_when(
    #   is.na(MOH) ~ "Only PEPFAR reported",
    #   is.na(PEPFAR) ~ "Only MOH reported",
    #   Difference > 0 ~ "MOH reported higher",
    #   Difference < 0 ~ "PEPFAR reported higher",
    #   Difference == 0 ~ "Same result reported",
    #   TRUE ~ "Neither reported"
    # ))

    # Groups rows by indicator and calculates indicator-specific summaries
    dplyr::group_by(Data, Period) %>%
    dplyr::mutate("Count of matched sites" =
                    sum(ifelse(`Reported by` == "Both", 1, 0))) %>%
    dplyr::mutate("PEPFAR sum at matched sites" =
                    sum(ifelse(`Reported by` == "Both", PEPFAR, 0))) %>%
    dplyr::ungroup() %>%

    # Calculates weighting variables
    dplyr::mutate("Weighting" =
                    ifelse(`Reported by` == "Both",
                           PEPFAR / `PEPFAR sum at matched sites`,
                           NA)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate("Weighted discordance" =
                    daa.analytics::weighted_discordance(MOH,
                                                        PEPFAR,
                                                        Weighting)) %>%
    dplyr::mutate("Weighted concordance" =
                    daa.analytics::weighted_concordance(MOH,
                                                        PEPFAR,
                                                        Weighting)) %>%
    dplyr::ungroup() %>%

  # Reorganizes table for export
    dplyr::select(`Organisation unit`, Indicator = `Data`, Period,
                  MOH, PEPFAR, `Reported by`, `Count of matched sites`,
                  `PEPFAR sum at matched sites`, `Weighting`,
                  `Weighted discordance`, `Weighted concordance`)
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
get_indicator_name <- function(uid){
  get_name <- daa.analytics::daa_indicators$indicator
  names(get_name) <- daa.analytics::daa_indicators$uid
  indicator_name <- unname(get_name[uid])
  return(indicator_name)
}
