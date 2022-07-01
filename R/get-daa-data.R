#' @export
#' @title Get Data Set UIDs
#'
#' @param fiscal_year List of fiscal years starting in October.
#'
#' @return Filtered dataframe of fiscal years and dataSets
#' for DAA indicator data.
#'
getDataSetUids <- function(fiscal_year = NULL) {
  dataSetUids <- data.frame(
    fiscal_year = c("2017",
                    "2018",
                    "2019",
                    "2020",
                    "2021",
                    "2022"),
    dataSet = c("FJrq7T5emEh",
                "sfk9cyQSUyi",
                "OBhi1PUW3OL",
                "QSodwF4YG9a",
                "U7qYX49krHK",
                "RGDmmG5taRt"
    ))

  # Filter dataSetUids if fiscal years provided
  if (!is.null(fiscal_year)) {
    dataSetUids <- dataSetUids[dataSetUids$fiscal_year %in% fiscal_year, ]
  }

  # Provide warning if no valid fiscal years provided
  if (NROW(dataSetUids) == 0) {
    warning("No dataSet UIDs available for the given fiscal years!")
  }

  # Return dataSetUids object
  dataSetUids
}

#' @export
#' @title Get Data Value Sets
#'
#' @param parameters Dataframe of key-value pairs that will be taken as parameters of the API call.
#' @param d2_session R6 session object
#'
#' @return Dataframe with six columns.
#'
getDataValueSets <- function(parameters, d2_session  = dynGet("d2_default_session", inherits = TRUE)) {
  parameters <- stringr::str_c(parameters$key, parameters$value, sep = "=", collapse = "&")

  url <- paste0(d2_session$base_url, "api/dataValueSets.json?", parameters, "&paging=false")

  interactive_print(url)

  df <- httr::GET(url, httr::timeout(600), handle = d2_session$handle) |>
    httr::content("text") |>
    jsonlite::fromJSON() |>
    purrr::pluck("dataValues") |>
    dplyr::rename(data_element = "dataElement",
                  org_unit = "orgUnit",
                  category_option_combo = "categoryOptionCombo",
                  attribute_option_combo = "attributeOptionCombo",
                  stored_by = "storedBy",
                  last_updated = "lastUpdated")

  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }
  # Returns dataframe
  df
}

#' @export
#' @title Get DAA Indicator Data
#'
#' @description
#' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' country.
#'
#' @param ou_uid UIDs for the Operating Units whose data are being queried.
#' @param fiscal_year Fiscal years for which data should be gathered.
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return Dataframe of unadorned PEPFAR and the MOH DAA indicator data.
#'
get_daa_data <- function(ou_uid, fiscal_year, d2_session = dynGet("d2_default_session", inherits = TRUE)) {

  interactive_print("Getting data for the following Operating Units:")
  interactive_print(datimutils::getOrgUnits(ou_uid))

  dataSetUids <- getDataSetUids(fiscal_year)

  df <- lapply(fiscal_year, function(x) {
    interactive_print(paste0("Now getting data for fiscal year ", x, "."))
    getDataValueSets(parameters = rbind(data.frame(key = "dataSet",
                                                   value = dataSetUids$dataSet[dataSetUids$fiscal_year == x]),
                                        data.frame(key = "orgUnit", value = ou_uid),
                                        data.frame(key = "period", value = paste0(x - 1, "Oct")),
                                        data.frame(key = c("children",
                                                           "categoryOptionComboIdScheme",
                                                           "includeDeleted"),
                                                   value = c("true",
                                                             "code",
                                                             "false"))),
                     d2_session = d2_session)
  }) |>
    dplyr::bind_rows()

  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }
  # Returns dataframe
  df
}
