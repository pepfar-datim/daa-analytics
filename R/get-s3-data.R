#' @title Fetch DAA S3 Data set
#'
#' @description
#' Fetches the indicated DAA data set from S3, applies appropriate
#' naming, and returns as a dataframe. If no S3 Bucket is provided
#' but a cache_folder is, then will attempt to retrieve a cache file.
#' If no cache_folder is provided, then will not check for an existing
#' cache and will not save a copy of the retrieved datset to a new or
#' updated cache file.
#'
#' @inheritParams daa_analytics_params
#'
#' @return data A dataframe of the indicated data set.
#' @export
#'
get_s3_data <- function(aws_s3_bucket = Sys.getenv("AWS_S3_BUCKET"),
                        dataset_name = NULL,
                        cache_folder = NULL) {
  stopifnot(
    "ERROR: Must provide either an S3 Bucket address or a cache folder!" =
      aws_s3_bucket != "" || !is.null(cache_folder),
    "ERROR: Must provide the name of the dataset to retrieve!" =
      !is.null(dataset_name))

  s3_data <- daa.analytics::s3_datasets
  key <- s3_data[s3_data$dataset_name == dataset_name, ][["key"]]
  filters <- s3_data[s3_data$dataset_name == dataset_name, ][["filters"]]

  # Check freshness of cache ####
  if (!is.null(cache_folder)) {
    cache_path <- file.path(cache_folder, paste0(dataset_name, ".rds"))
    cached_data <- check_cache(cache_path, "1 day")
  }

  # Check if fresh cache was returned ####
  if (exists("cached_data") && !is.null(cached_data)) {
    # If fresh cache was found, return that dataset ####
    return(cached_data)
  } else if (!missing(aws_s3_bucket)) {
    # If no fresh cache, pull dataset from DATIM ####
    data <- tryCatch(
      expr = {
        x <- aws.s3::get_object(bucket = aws_s3_bucket,
                                object = paste0(key, "/data.csv.gz"))
        x |>
          rawConnection() |>
          gzcon() |>
          readr::read_delim(delim = "|",
                            escape_double = FALSE,
                            trim_ws = TRUE,
                            col_names = TRUE)
      },
      error = function(e) {
        NULL
      }
    )
    print(head (data))
    data
  } else {
    data <- NULL
  }

  # If no data returned from S3 and no cache provided, return error ####
  if (is.null(data) && is.null(cache_folder)) {
    stop("ERROR: No cache folder provided and no data retrieved from S3!")
  }

  # If no data returned from S3 and cache provided, try to retrieve cache ####
  if (is.null(data)) {
    cache_data <- check_cache(cache_path, max_cache_age = NULL)
    if (!is.null(cache_data)) {
      return(cache_data)
    } else {
      stop("ERROR: No data retrieved from S3 and cache could not be found!")
    }
  }

  # If there are filters provided, applies them here ####
  if (!is.na(filters)) {
    data <- dplyr::select(data, unlist(filters))
  }

  # Saves new cache file if cache folder provided ####
  if (!is.null(cache_folder)) {
    interactive_print("Saving an updated cache file...")
    saveRDS(data, file = cache_path)
  }

  data
}
