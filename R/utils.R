#' @export
#' @title Return current FY based on system date.
#'
#' @return Current FY as numeric.
#'
current_fiscal_year <- function() {
  current_year <- Sys.Date() |>
    format("%Y") |>
    as.numeric()

  current_month <- Sys.Date() |>
    format("%m") |>
    as.numeric()

  curr_fy <- ifelse(current_month > 9, current_year + 1, current_year)

  return(curr_fy)
}


#' @export
#'
#' @title Prints message if session is interactive.
#'
#' @description
#' Supplied a message, will print it only if the session is
#' currently interactive.
#'
#' @param x Message to print.
#'
#' @return Printed message, \code{x}.
#'
interactive_print <- function(x) {
  if (rlang::is_interactive()) {
    print(x)
  }
}


#' @title Remove missing data
#'
#' @description
#' Takes in a list of dataframes and removes any that are missing.
#'
#' @param my_list A list of dataframes.
#'
#' @return A list of dataframes with missing dataframes removed.
#'
#' @noRd
#'
remove_missing_dfs <- function(my_list) {
  new_list <- my_list[which(!is.na(my_list))]
  return(new_list)
}


#' Check for availability and freshness of cached dataset
#'
#' @inheritParams daa_analytics_params
#'
#' @return cache Returns the cached dataset if it is available and
#' fresh, otherwise returns NULL.
#' @export
check_cache <- function(cache_path, max_cache_age = NULL) {

  # Checks arguments ####
  stopifnot("ERROR: Must provide path to cache file!" =
              !rlang::is_missing(cache_path))

  # Checks if cache file exists and can be read ####
  if (!file.exists(cache_path)) { return(NULL) } # nolint
  if (file.access(cache_path, 4) != 0) { return(NULL )} # nolint

  # Check whether cache is stale ####
  if (!is.null(max_cache_age)) {
    is_lt <- function(x, y)  x < y
    cache_age_dur <- lubridate::as.duration(
      lubridate::interval(file.info(cache_path)$mtime, Sys.time()))
    max_cache_age_dur <- lubridate::duration(max_cache_age)
    is_fresh <- is_lt(cache_age_dur, max_cache_age_dur)
    if (!is_fresh) {
      cat("Cache is stale. \n")
      return(NULL)
    } # nolint
  }

  # If file exists, can be read, and is fresh, loads and returns cache ####
  interactive_print("Loading cache file")
  cache <- readRDS(cache_path)

  # Returns cache object ####
  cache
}

#get recent timestamp
#' @export
get_last_modified <- function(bucket_name, prefix) {

  bucket_name <- Sys.getenv("AWS_S3_BUCKET")
  prefix <- "datim/www.datim.org/moh_daa_data_value_emr_pvls/data.csv.gz"
  # Create an S3 client
  s3_client <- paws::s3()

  # List objects in the S3 bucket with the specified prefix
  s3_objects <- s3_client$list_objects(Bucket = bucket_name, Prefix = prefix)


  if (!is.null(s3_objects$Contents) && length(s3_objects$Contents) > 0) {
    last_modified <- s3_objects$Contents[[1]]$LastModified
    return(last_modified)
  } else {
    return("Unknown")
  }
}

#Zimbabwe facilities with MOH data
# data <- read.csv("/Users/58771/Desktop/DAA/daa-analytics/OUTPUT_FOLDER/raw_country_data/20240423_Zimbabwe_raw_data.csv")
# filtered_data <- data %>% filter(Facility_UID %in% c("XCuGjkFY1oy", "JBrHjCgtk1U", "oCiaPRzzlpQ", "ExkPrlU2JL0", "usnQnNvOVYO",
#                                                      "fhbHedZcFX3", "KIGDYbxhWWf", "SxuooDiEkIq", "Sss3M30PqRD") & !is.na(moh))
#
# print(filtered_data)
# write.csv(filtered_data, "zimbabwe_filtered_data.csv", row.names = FALSE)

country_summary <- function(combined_data, import_history) {
  df <- combined_data %>%
    dplyr::group_by(OU, indicator, period) %>%
    dplyr::select(-Facility, -Facility_UID, -reported_by, -OU_UID, -OU_Concordance, -OU_weighting, -SNU1, -SNU1_UID, -SNU2,
                  -SNU2_UID, -SNU3, - SNU3_UID, -SNU1_Concordance, -SNU2_Concordance, -EMR_Concordance, -emr_present, -moh_id,
                  -longitude, -latitude, -absolute_difference) %>%
    dplyr::ungroup() %>%
    dplyr::left_join(., import_history,
                     by = c("OU", "period", "indicator")) %>%
    dplyr::mutate(indicator_disaggregation = dplyr::case_when(
      !is.na(has_disag_mapping) & has_disag_mapping != "None" ~ has_disag_mapping,
      is.na(has_disag_mapping) | has_disag_mapping == "None" ~ has_mapping_result_data,
      TRUE ~ NA_character_  # Catch-all for any other cases
    )) %>%
    dplyr::select(-has_disag_mapping, -has_mapping_result_data, -has_results_data)

  return(df)
}









