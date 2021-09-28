#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetch MOH ID and attributes from DATIM
#'
#' @description
#' Gets data on site attributes for a specific operating unit from DATIM or
#' DATIM4U, including site name, id, MOH ID, longitude, and latitude.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return A dataframe of OU site-level attributes including name, id,
#' MOH ID, and longitude and latitude of the site.
#'
get_attribute_table <- function(ou_uid, d2_session = d2_session) {

  # Fetches data from the server
  df <- datimutils::getMetadata(
    end_point = "organisationUnits",
    values = paste0("path:like:", ou_uid),
    fields = "id,name,geometry,attributeValues[attribute[id,name],value]",
    d2_session = d2_session,
    retry = 4
  )

  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }

  df %<>%
    data.frame(stringsAsFactors = FALSE) %>%
    # Unnests and filters the data from the site attributes column
    tidyr::unnest(cols = "attributeValues") %>%
    dplyr::filter(.data$`attribute.name` == "MOH ID") %>%

    # Cleans the geometry data
    dplyr::mutate(`geometry.coordinates` =
                    ifelse(.data$`geometry.type` == "Point",
                           as.character(.data$`geometry.coordinates`) %>%
                             stringr::str_extract("(?<=\\()(.*?)(?=\\))"),
                           NA)) %>%
    tidyr::separate(col = .data$`geometry.coordinates`,
                    into = c("longitude", "latitude"),
                    sep = ",",
                    convert = TRUE) %>%

    # Selects only the correct columns to be used
    dplyr::select(.data$name, facilityuid = .data$id, moh_id = .data$value,
                  .data$longitude, .data$latitude)

  return(df)
}
