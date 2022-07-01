#' @export
#' @title Adorn DAA Indicator Data
#'
#' @description
#' Cleans and adorns a dataframe of DAA data containing UIDs with indicator
#' names, fiscal years, and weighted concordance and discordance information,
#' as well as other information.
#'
#' @param df Dataframe containing DAA data indicator data to be adorned.
#' @param d2_session R6 session object.
#'
#' @return Dataframe of DAA indicator data for both PEPFAR and the MOH as well
#' as both discordance and concordance metrics.
#'
adorn_daa_data <- function(df, include_coc = FALSE, d2_session = dynGet("d2_default_session", inherits = TRUE)) {
  # Returns null if delivered an empty dataset
  if (is.null(df)) {
    return(NULL)
  }

  # Grab metadata for data elements
  de_meta <-
    datimutils::getDataElements(unique(df$data_element),
                                fields = c("id", "name"),
                                d2_session = d2_session) |>
    dplyr::mutate(indicator = stringr::str_extract(name, "\\w*(?=\\s)"))

  # Cleans data and prepares it for export
  df <- df |>
    # Recasts values as numeric
    dplyr::mutate(value = as.numeric(`value`)) |>

    # Pivots MOH and PEPFAR data out into separate columns
    tidyr::pivot_wider(names_from = `attribute_option_combo`,
                       values_from = `value`) |>

    # Cleans Period data from the form `2018Oct` to `2019`
    dplyr::mutate(period =
                    as.numeric(stringr::str_sub(`period`, 0, 4)) + 1) |>

    # Adorn indicator names
    dplyr::left_join(de_meta, by = c("data_element" = "id")) |>
    dplyr::mutate(indicator = ifelse(indicator == "TB_PREV" && period < 2020, "TB_PREV_LEGACY", indicator))

  if (include_coc == TRUE) {
    # Grab metadata for category option combos
    coc_metadata <-
      datimutils::getCatOptionCombos(unique(df$category_option_combo),
                                     fields = c("id", "name")) |>
      dplyr::rename(coc_id = id, coc_name = name)

    # Adorn category option combo metadata
    df <- df |>
      dplyr::left_join(coc_metadata,
                       by = c("category_option_combo" = "coc_id"),
                       keep = FALSE) |>

      # Summarise indicator data across Age & Age Agg
      dplyr::group_by(org_unit, indicator, coc_name) |>
      dplyr::mutate(moh = sum(`00100`), pepfar = sum(`00200`)) |>
      dplyr::ungroup() |>

      # Creates summary data about reporting institutions and figures
      dplyr::mutate(reported_by =
                      ifelse(!is.na(moh),
                             ifelse(!is.na(pepfar), "Both", "MOH"),
                             ifelse(!is.na(pepfar), "PEPFAR", "Neither"))) |>

      # Reorganizes table for export
      dplyr::select(facilityuid = `org_unit`,
                    indicator,
                    categoryOptionCombo = `coc_name`,
                    period,
                    moh,
                    pepfar,
                    reported_by)

  } else {
    df <- df |>
      # Summarise indicator data across Age & Age Agg
      dplyr::group_by(org_unit, indicator, period) |>
      dplyr::summarise(moh = sum(`00100`), pepfar = sum(`00200`)) |>
      dplyr::ungroup() |>

      # Creates summary data about reporting institutions and figures
      dplyr::mutate(reported_by =
                      ifelse(!is.na(moh),
                             ifelse(!is.na(pepfar), "Both", "MOH"),
                             ifelse(!is.na(pepfar), "PEPFAR", "Neither"))) |>

      # Reorganizes table for export
      dplyr::select(facilityuid = `org_unit`,
                    indicator,
                    period,
                    moh,
                    pepfar,
                    reported_by)
  }

  return(df)
}
