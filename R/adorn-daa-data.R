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
  df <- df |>
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
