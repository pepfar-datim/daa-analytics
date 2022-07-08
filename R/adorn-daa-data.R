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

  # Set grouping variables
  group_vars <- if (include_coc == TRUE) {
    c("org_unit", "indicator", "category_option_combo", "period")
  } else {
    c("org_unit", "indicator", "period")
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

    # Adorn indicator names
    dplyr::left_join(de_meta, by = c("data_element" = "id")) |>
    dplyr::rowwise() |>
    dplyr::mutate(indicator = ifelse(indicator == "TB_PREV" && period < 2020, "TB_PREV_LEGACY", indicator)) |>
    dplyr::ungroup() |>

    # Aggregate site data across coarse and fine indicators
    dplyr::group_by(!!!rlang::syms(group_vars), attribute_option_combo) |>
    dplyr::summarise(value = sum(value)) |>
    dplyr::ungroup() |>

    # Pivots MOH and PEPFAR data out into separate columns
    dplyr::mutate(attribute_option_combo = dplyr::case_when(attribute_option_combo == "00100" ~ "moh",
                                                            attribute_option_combo == "00200" ~ "pepfar")) |>
    tidyr::pivot_wider(names_from = `attribute_option_combo`,
                       values_from = `value`) |>

    # Cleans Period data from the form `2018Oct` to `2019`
    dplyr::mutate(period =
                    as.numeric(stringr::str_sub(`period`, 0, 4)) + 1)

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
      dplyr::rename(categoryOptionCombo = `coc_name`)
  }

  df |>
    # Creates summary data about reporting institutions and figures
    dplyr::mutate(reported_by =
                    ifelse(!is.na(moh),
                           ifelse(!is.na(pepfar), "Both", "MOH"),
                           ifelse(!is.na(pepfar), "PEPFAR", "Neither"))) |>

    # Reorganizes table for export
    dplyr::select(!!!rlang::syms(group_vars), moh, pepfar, reported_by) |>
    dplyr::rename(facilityuid = `org_unit`)

}
