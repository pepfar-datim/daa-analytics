#' @export
#' @importFrom magrittr %>% %<>%
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
get_daa_countries <- function(geo_session){
  end_point <- "dataStore/ou_levels/orgUnitLevels"

  # Fetches data from the server
  df <- datimutils::getMetadata(end_point = "dataStore/ou_levels/orgUnitLevels",
                                d2_session = geo_session)

  if (is.null(df)) {
    return(NULL)
  }

  df %<>%
    dplyr::bind_rows(.id = "Country") %>%
    dplyr::rename("countryName" = "Country", "countryUID" = "uid",
                  "countryCode" = "code", "facilityLevel" = "facility")

  return(df)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @title Fetch Indicator Mapping and Data Availability from GeoAlign
#'
#' @description
#' Extracts all data for all countries and activity years from GeoAlign regarding
#' whether countries have provided indicator mappings, the disaggregation
#' level, and whether data was imported for that indicator.
#'
#' @param geo_session DHIS2 Session id for the GeoAlign session.
#'
#' @return A dataframe of indicator mapping, disaggregation level, and data
#' availability organized by activity year and country.
#'
get_geoalign_table <- function(geo_session = geo_session) {

  end_point <- "dataStore/MOH_country_indicators"

  # Fetches data from the server
  df <- datimutils::getMetadata(end_point = "dataStore/MOH_country_indicators",
                                d2_session = geo_session)

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df %<>%
    lapply(.,
           function(x) {
             paste0(end_point, "/", x) %>%
               list(end_point = ., geo_session = geo_session) %>%
               purrr::exec(datimutils::getMetadata, !!!.) %>%
               dplyr::mutate(period = x)
           }) %>%
    dplyr::bind_rows(.) %>%
    tidyr::pivot_longer(-c(period, CountryName, CountryCode, generated),
                        names_sep = "_(?=[^_]*$)",
                        names_to = c("indicator", ".value")) %>%
    dplyr::mutate(period = as.numeric(period),
                  hasDisagMapping = ifelse(hasDisagMapping %in%
                                             c("No", "NA", NA),
                                           "No",
                                           hasDisagMapping)) %>%
    dplyr::mutate(hasResultsData =
                    ifelse(period == max(period),
                           hasResultsData,
                           NA_character_)) %>%
    dplyr::select(namelevel3 = CountryName, Period = period,
                  Indicator = indicator, hasDisagMapping, hasResultsData)

  return(df)
}

#' @export
#' @importFrom magrittr %>% %<>%
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
get_upload_timestamps <- function(geo_session){

  end_point <- "dataStore/MOH_imports_status"

  # Fetches data from the server
  df <- datimutils::getMetadata(end_point = "dataStore/MOH_imports_status",
                                d2_session = geo_session)

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df %<>%
    lapply(.,
           function(x) {
             paste0(end_point, "/", x) %>%
               list(end_point = ., geo_session = geo_session) %>%
               purrr::exec(datimutils::getMetadata, !!!.) %>%
               dplyr::mutate(period = x)
           }) %>%
    dplyr::bind_rows(.) %>%
    dplyr::mutate(across(ends_with("Date"), lubridate::ymd_hms))

  return(df)
}
