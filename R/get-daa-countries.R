#' @export
#' @title Fetch List of Participating Countries from GeoAlign
#'
#' @description
#' Extracts list of all countries that participate in the DAA, including
#' name, UID, three-letter acronym, and facility level.
#'
#' @inheritParams daa_analytics_params
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

  df |>
    dplyr::bind_rows(.id = "Country") |>
    dplyr::rename(country_name = Country,
                  country_uid = uid,
                  country_code = code,
                  facility_level = facility) |>
    dplyr::filter(country_name != "demo_country")
}
