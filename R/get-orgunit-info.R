#' @export
#' @title Get Organisation Unit Information from DATIM.
#'
#' @description
#' Fetches Organisation Unit data for a particular country, including the
#' organisation hierarchy levels for the country and facility, as well as the
#' ISO3 country code.
#'
#' @param ou_name Name for the Operating Unit whose data is being queried.
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return A list object containing the DATIM country level, DATIM facility
#' level, and the ISO3 country code.
#'
get_org_unit_info <- function(ou_name, d2_session) {

  # TODO replace this function with a getDataStore call when that function is
  # added to the datimutils package
  df <- datimutils::getMetadata("dataStore/dataSetAssignments/orgUnitLevels")

  if (is.null(df)) {
    return(NULL)
  }

  # TODO see if this can be simplified with a dplyr function
  df <- do.call(rbind,
                lapply(df,
                       function(x) {
                         data.frame(x, stringsAsFactors = FALSE)
                       }))

  # Returns list with country level, facility level, and abbreviation
  org_unit_info <- list(
    country_level = df[ou_name, "country"],
    facility_level = df[ou_name, "facility"],
    abbreviation = df[ou_name, "iso3"]
  )

  return(org_unit_info)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @title Get Organisation Unit Name from UID.
#'
#' @description
#' Returns the country name based on the organisation unit UID.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#'
#' @return A string containing the country name.
#'
get_ou_name <- function(ou_uid) {

  load("data/daa_countries.rda")

  ou_name <- daa_countries$countryName[daa_countries$countryUID == ou_uid] %>%
    toString(.)

  # Returns OU name
  return(ou_name)
}
