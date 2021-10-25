#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetch List of Participating Countries from GeoAlign
#'
#' @description
#' Extracts list of all countries that participate in the DAA, including
#' name, UID, three-letter acronym, and facility level.
#'
#' @param geo_session DHIS2 Session id for the GeoAlign session.
#'
#' @return A dataframe of DAA country names, UIDs, three-letter acronyms,
#' and facility level.
#'
get_daa_countries <- function(geo_session) {
  # TODO figure out how to handle 2021 datasets
  # Fetches data from the server
  df <- datimutils::getMetadata(end_point = "dataStore/ou_levels/orgUnitLevels",
                                d2_session = geo_session)

  if (is.null(df)) {
    return(NULL)
  }

  df %<>%
    dplyr::bind_rows(.id = "Country") %>%
    dplyr::rename(country_name = .data$Country,
                  country_uid = .data$uid,
                  country_code = .data$code,
                  facility_level = .data$facility) %>%
    dplyr::filter(.data$country_name != "demo_country")

  return(df)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
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
get_data_availability <- function(geo_session = geo_session) {

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

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetch Import Timestamps from GeoAlign
#'
#' @description
#' Extracts all data for all countries and activity years from GeoAlign
#' regarding whether a country has completed each step of the DAA process
#' with timestamps for completion.
#'
#' @param geo_session DHIS2 Session id for the GeoAlign session.
#'
#' @return A dataframe of country names with columns for each DAA mapping and
#' import step with timestamp data for the completion of each step.
#'
get_upload_timestamps <- function(geo_session) {

  end_point <- "dataStore/MOH_imports_status"

  # Fetches data from the server
  df <- datimutils::getMetadata(end_point = "dataStore/MOH_imports_status",
                                d2_session = geo_session)

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df %<>%
    lapply(function(x) {
      args <- list(end_point = paste0(end_point, "/", x),
                   geo_session = geo_session)
      df2 <- purrr::exec(datimutils::getMetadata, !!!args) %>%
        dplyr::mutate(period = x)
      return(df2)
    }) %>%
    dplyr::bind_rows() %>%
    dplyr::mutate(dplyr::across(dplyr::ends_with("Date"), lubridate::ymd_hms))

  # TODO rename all columns to be in snake case before returning
  return(df)
}

# Helper functions ------------------------------------------
#' @title Remove missing data
#'
#' @description
#' Takes in a list of dataframes and removes any that are missing.
#'
#' @param my_list A list of dataframes.
#'
#' @return A list of dataframes with missing dataframes removed.
#'
#' @noRd
#'
remove_missing_dfs <- function(my_list) {
  new_list <- my_list[which(!is.na(my_list))]
  return(new_list)
}
