#' @export
#' @title Fetch MOH ID and attributes from DATIM
#'
#' @description
#' Gets data on site attributes for a specific operating unit from DATIM or
#' DATIM4U, including site name, id, MOH ID, longitude, and latitude.
#'
#' @inheritParams daa_analytics_params
#'
#' @return A dataframe of OU site-level attributes including name, id,
#' MOH ID, and longitude and latitude of the site.
#'
get_attribute_table <- function(ou_uid,
                                d2_session = dynGet("d2_default_session",
                                                    inherits = TRUE)) {

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

  df |>
    data.frame(stringsAsFactors = FALSE) |>
    # Unnests and filters the data from the site attributes column
    tidyr::unnest(cols = "attributeValues") |>
    dplyr::filter(`attribute.name` == "MOH ID") |>

    # Cleans the geometry data
    dplyr::mutate(`geometry.coordinates` =
                    ifelse(`geometry.type` == "Point",
                           as.character(`geometry.coordinates`) |>
                             stringr::str_extract("(?<=\\()(.*?)(?=\\))"),
                           NA)) |>
    tidyr::separate(col = `geometry.coordinates`,
                    into = c("longitude", "latitude"),
                    sep = ",",
                    convert = TRUE) |>

    # Selects only the correct columns to be used
    dplyr::select(name,
                  facilityuid = id,
                  moh_id = value,
                  longitude,
                  latitude)
}
