#' @export
#' @title Get Data Set UIDs
#'
#' @inheritParams daa_analytics_params
#'
#' @return Filtered dataframe of fiscal years and dataSets
#' for DAA indicator data.
#'
# Precompute dataset UIDs once
dataset_uids <- data.frame(
  fiscal_year = c("2017", "2018", "2019", "2020", "2021", "2022", "2023"),
  dataSet = c("FJrq7T5emEh", "sfk9cyQSUyi", "OBhi1PUW3OL", "QSodwF4YG9a", "U7qYX49krHK", "RGDmmG5taRt", "nPEPnHrNsnP")
)

#' @export
#' @title Get DAA Indicator Data
#'
#' @description
#' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' country.
#'
#' @inheritParams daa_analytics_params
#'
#' @return Dataframe of unadorned PEPFAR and the MOH DAA indicator data.
#'
get_daa_data <- function(ou_uid,
                         fiscal_years,
                         d2_session = dynGet("d2_default_session", inherits = TRUE)) {

  # Filter dataset_uids if fiscal years provided
  dataset_uids_filtered <- dataset_uids[dataset_uids$fiscal_year %in% fiscal_years, ]

  # Provide warning if no valid fiscal years provided
  if (NROW(dataset_uids_filtered) == 0) {
    warning("No dataSet UIDs available for the given fiscal years!")
    return(NULL)
  }

  key_value_pairs <- data.frame(
    keys = "dataSet",
    values = dataset_uids_filtered$dataSet
  )

  key_value_pairs <- rbind(
    key_value_pairs,
    data.frame(keys = "orgUnit", values = ou_uid),
    data.frame(keys = "period", values = paste0(as.integer(fiscal_years) - 1, "Oct")),
    data.frame(keys = c("children", "categoryOptionComboIdScheme", "attributeOptionComboIdScheme", "includeDeleted"),
               values = c("true", "code", "code", "false"))
  )

  datimutils::getDataValueSets(
    variable_keys = key_value_pairs$keys,
    variable_values = key_value_pairs$values,
    d2_session = d2_session
  ) |>
    dplyr::select(data_element = dataElement,
                  period,
                  org_unit = orgUnit,
                  category_option_combo = categoryOptionCombo,
                  attribute_option_combo = attributeOptionCombo,
                  value)
}
