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
#'
#' #' @export
#' #' @title Get DAA Indicator Data
#' #'
#' #' @description
#' #' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' #' country.
#' #'
#' #' @inheritParams daa_analytics_params
#' #'
#' #' @return Dataframe of unadorned PEPFAR and the MOH DAA indicator data.
#'

get_daa_data <- function(ou_uid,
                         fiscal_years,
                         d2_session = dynGet("d2_default_session", inherits = TRUE),
                         chunk_size = 2,
                         cache_folder = "support_files",
                         max_cache_age_days = 30) {

  # Identify the recent period to fetch
  recent_fiscal_year <- max(fiscal_years)
  historical_fiscal_years <- fiscal_years[fiscal_years < recent_fiscal_year]

  # Create a cache file path based on the organization unit
  cache_file <- file.path(cache_folder, paste0("daa_data_", ou_uid, "_2017_2022.rds"))
  historical_data <- NULL

  # Check if cached data exists
  if (file.exists(cache_file)) {
    file_info <- file.info(cache_file)
    file_age_days <- as.numeric(difftime(Sys.time(), file_info$mtime, units = "days"))
    #if file older than cache age or does not exist then fetch new
    if(file_age_days > max_cache_age_days || length(historical_fiscal_years) == 0) {
      historical_data <- get_data_for_period(ou_uid, historical_fiscal_years, d2_session, chunk_size)
      saveRDS(historical_data, cache_file)
    } else{
      # Load cached data
      historical_data <- readRDS(cache_file)
    }

  } else if (length(historical_fiscal_years) > 0) {
    # Fetch historical data if not cached
    historical_data <- get_data_for_period(ou_uid, historical_fiscal_years, d2_session, chunk_size)
    # Save to cache for future use
    saveRDS(historical_data, cache_file)
  }

  # Fetch recent data for the most recent period
  recent_data <- get_data_for_period(ou_uid, recent_fiscal_year, d2_session, chunk_size)

  # Combine historical and recent data
  combined_data <- dplyr::bind_rows(historical_data, recent_data)

  return(combined_data)
}

# Helper function to fetch data for a given period
get_data_for_period <- function(ou_uid, fiscal_years, d2_session, chunk_size) {
  fiscal_year_chunks <- split(fiscal_years, ceiling(seq_along(fiscal_years) / chunk_size))
  results <- list()

  for (chunk in fiscal_year_chunks) {
    dataset_uids_filtered <- dataset_uids[dataset_uids$fiscal_year %in% chunk, ]

    if (NROW(dataset_uids_filtered) == 0) {
      warning("No dataSet UIDs available for the given fiscal years!")
      next
    }

    key_value_pairs <- data.frame(
      keys = "dataSet",
      values = dataset_uids_filtered$dataSet
    )

    key_value_pairs <- rbind(
      key_value_pairs,
      data.frame(keys = "orgUnit", values = ou_uid),
      data.frame(keys = "period", values = paste0(as.integer(chunk) - 1, "Oct")),
      data.frame(keys = c("children", "categoryOptionComboIdScheme", "attributeOptionComboIdScheme", "includeDeleted"),
                 values = c("true", "code", "code", "false"))
    )

    result <- datimutils::getDataValueSets(
      variable_keys = key_value_pairs$keys,
      variable_values = key_value_pairs$values,
      d2_session = d2_session,
      timeout = 300
    ) |>
      dplyr::select(data_element = dataElement,
                    period,
                    org_unit = orgUnit,
                    category_option_combo = categoryOptionCombo,
                    attribute_option_combo = attributeOptionCombo,
                    value)

    results <- append(results, list(result))
  }

  combined_data <- dplyr::bind_rows(results)
  return(combined_data)
}


