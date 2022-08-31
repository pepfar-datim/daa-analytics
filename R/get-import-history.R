#' @export
#' @title Fetch Indicator Mapping and Data Availability from GeoAlign
#'
#' @description
#' Extracts all data for all countries and activity years from GeoAlign
#' regarding whether countries have provided indicator mappings, the
#' disaggregation level, and whether data was imported for that indicator.
#'
#' @inheritParams daa_analytics_params
#'
#' @return A dataframe of indicator mapping, disaggregation level, and data
#' availability organized by activity year and country.
#'
get_import_history <- function(geo_session = dynGet("d2_default_session",
                                                    inherits = TRUE)) {

  end_point <- "dataStore/MOH_country_indicators"

  # Fetches data from the server
  ls <- datimutils::getMetadata(end_point = "dataStore/MOH_country_indicators",
                                d2_session = geo_session)
  args <- ls[ls != "CS_2021"]

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df <- args |>
    lapply(function(x) {
      tryCatch({
        args2 <- list(end_point = paste0(end_point, "/", x),
                     d2_session = geo_session)
        df2 <- purrr::exec(datimutils::getMetadata, !!!args2) |>
          dplyr::mutate(period = x)
        return(df2)
      }, error = function(e) {
        return(NA)
      })
    }) |>
    remove_missing_dfs() |>
    dplyr::bind_rows() |>
    dplyr::mutate(period = stringr::str_sub(period,
                  start = -4, end = -1)) |>
    tidyr::pivot_longer(-c(period, CountryName,
                           CountryCode, generated),
                        names_sep = "_(?=[^_]*$)",
                        names_to = c("indicator", ".value")) |>
    dplyr::rowwise() |>
    dplyr::mutate(indicator =
                    ifelse(indicator == "TB_PREV" &&
                             as.numeric(period) < 2020,
                           "TB_PREV_LEGACY", indicator),
                  period = as.numeric(period),
                  has_disag_mapping = ifelse(hasDisagMapping %in%
                                               c("No", "NA", NA),
                                             "None",
                                             hasDisagMapping)) |>
    dplyr::mutate(has_results_data =
                    ifelse(period == max(period),
                           hasResultsData,
                           NA_character_)) |>
    dplyr::ungroup() |>
    dplyr::select(namelevel3 = CountryName, period, indicator,
                  has_disag_mapping, has_results_data)

  df
}
