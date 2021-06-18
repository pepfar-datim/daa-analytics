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

  # TODO Fix the usage of Datimutils package in this section
  df2 <- df %>%
    lapply(.,
           function(x) {
             paste0(end_point, "/", x) %>%
               datimutils::getMetadata(., d2_session = geo_session) %>%
               as.data.frame(.) %>%
               dplyr::mutate(period = x)
           }) %>%
    dplyr::bind_rows(.) %>% # TODO Remove the use of `plyr` package
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
    dplyr::select(CountryName, period, indicator,
                  hasDisagMapping, hasResultsData)

  return(df)
}
