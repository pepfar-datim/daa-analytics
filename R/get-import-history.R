#' @export
#' @title Fetch Indicator Mapping and Data Availability from GeoAlign
#'
#' @description
#' Extracts all data for all countries and activity years from GeoAlign
#' regarding whether countries have provided indicator mappings, the
#' disaggregation level, and whether data was imported for that indicator.
#'
#' @param geo_session DHIS2 Session id for the GeoAlign session.
#'
#' @return A dataframe of indicator mapping, disaggregation level, and data
#' availability organized by activity year and country.
#'
get_import_history <- function(geo_session = geo_session) {

  end_point <- "dataStore/MOH_country_indicators"

  # Fetches data from the server
  ls <- datimutils::getMetadata(end_point = "dataStore/MOH_country_indicators",
                                d2_session = geo_session)
  args <- ls[ls != "CS_2021"]

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df <- args %>%
    lapply(function(x) {
      tryCatch({
        args2 <- list(end_point = paste0(end_point, "/", x),
                     d2_session = geo_session)
        df2 <- purrr::exec(datimutils::getMetadata, !!!args2) %>%
          dplyr::mutate(period = x)
        return(df2)
      }, error = function(e) {
        return(NA)
      })
    }) %>%
    remove_missing_dfs() %>%
    dplyr::bind_rows() %>%
    dplyr::mutate(period = stringr::str_sub(.data$period,
                  start = -4, end = -1)) %>%
    tidyr::pivot_longer(-c(.data$period, .data$CountryName,
                           .data$CountryCode, .data$generated),
                        names_sep = "_(?=[^_]*$)",
                        names_to = c("indicator", ".value")) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(indicator =
                    ifelse(.data$indicator == "TB_PREV" &&
                             as.numeric(.data$period) < 2020,
                           "TB_PREV_LEGACY", .data$indicator),
                  period = as.numeric(.data$period),
                  has_disag_mapping = ifelse(.data$hasDisagMapping %in%
                                               c("No", "NA", NA),
                                             "None",
                                             .data$hasDisagMapping)) %>%
    dplyr::mutate(has_results_data =
                    ifelse(.data$period == max(.data$period),
                           .data$hasResultsData,
                           NA_character_)) %>%
    dplyr::ungroup() %>%
    dplyr::select(namelevel3 = .data$CountryName, .data$period, .data$indicator,
                  .data$has_disag_mapping, .data$has_results_data)

  return(df)
}
