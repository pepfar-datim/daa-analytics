#' @export
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
