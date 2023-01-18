#' @export
#' @title Get Data Set UIDs
#'
#' @inheritParams daa_analytics_params
#'
#' @return Filtered dataframe of fiscal years and dataSets
#' for DAA indicator data.
#'
get_dataset_uids <- function(fiscal_year = NULL) {
  dataset_uids <- data.frame(
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

  # Filter dataset_uids if fiscal years provided
  if (!is.null(fiscal_year)) {
    dataset_uids <- dataset_uids[dataset_uids$fiscal_year %in% fiscal_year, ]
  }

  # Provide warning if no valid fiscal years provided
  if (NROW(dataset_uids) == 0) {
    warning("No dataSet UIDs available for the given fiscal years!")
  }

  # Return dataset_uids object
  dataset_uids
}


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
                         fiscal_year,
                         d2_session = dynGet("d2_default_session",
                                             inherits = TRUE)) {

  lapply(fiscal_year,
         function(x) {
           key_value_pairs <- rbind(
             data.frame(keys = "dataSet", values = get_dataset_uids(x)$dataSet),
             data.frame(keys = "orgUnit", values = ou_uid),
             data.frame(keys = "period", values = paste0(x - 1, "Oct")),
             data.frame(keys = c("children",
                                 "categoryOptionComboIdScheme",
                                 "attributeOptionComboIdScheme",
                                 "includeDeleted"),
                        values = c("true",
                                   "code",
                                   "code",
                                   "false")))

           datimutils::getDataValueSets(
             variable_keys = key_value_pairs$keys,
             variable_values = key_value_pairs$values,
             d2_session = d2_session)
         }
  ) |>
    dplyr::bind_rows() |>
    dplyr::select(data_element = dataElement,
                  period,
                  org_unit = orgUnit,
                  category_option_combo = categoryOptionCombo,
                  attribute_option_combo = attributeOptionCombo,
                  value)

}
