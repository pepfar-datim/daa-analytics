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
