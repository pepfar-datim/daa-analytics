#' @title Fetch DAA S3 Data set
#'
#' @description
#' Fetches the indicated DAA data set from S3, applies appropriate
#' naming, and returns as a dataframe.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param file_name The name of the dataset to be returned.
#' @param folder The folder extension where the output file should be saved.
#'
#' @return data A dataframe of the indicated data set.
#' @export
#'
get_s3_data <- function(s3, aws_s3_bucket, dataset_name = NULL, folder = NULL) {
  s3_datasets <- daa.analytics::s3_datasets
  key <-
    s3_datasets[s3_datasets$dataset_name == dataset_name, ][["key"]]
  filters <-
    s3_datasets[s3_datasets$dataset_name == dataset_name, ][["filters"]]

  data <- daa.analytics::fetch_s3_files(
    s3 = s3,
    aws_s3_bucket = aws_s3_bucket,
    key = key,
    folder = folder,
    file_name = dataset_name
  )

  if (!is.na(filters)) {
    data %<>% dplyr::select(unlist(filters))
  }

  return(data)
}


#' @export
#' @title Fetch data from S3 bucket.
#'
#' @description
#' Extracts data from a specific S3 bucket, saves it to a folder, and returns
#' a dataframe with the same data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param key The specific folder where the DAA data being accessed
#' is stored on S3.
#' @param folder The folder where the .csv.gz temporary file should
#' be locally stored.
#' @param file_name The file name for the .csv.gz temporary file to
#' be locally stored.
#'
#' @return A dataframe of the data located in the specified S3 sub-bucket.
#'
fetch_s3_files <- function(s3, aws_s3_bucket, key,
                           folder = "data", file_name) {
  file_path <- file.path(folder, paste0(file_name, ".csv.gz"))
  s3_object_body <- NULL
  last_update <- file.info(file_path)$ctime
  # TODO remove the need for `folder` and `file_name` arguments
  tryCatch({
    s3_object <-
      s3$get_object(Bucket = aws_s3_bucket,
                    IfModifiedSince = last_update,
                    Key = paste0(key, "/data.csv.gz"))
    s3_object_body <- s3_object$Body

    if (length(s3_object_body) > 0) {
      # TODO remove the need to save a temporary file to access data
      if (file.exists(file_path)) {
        unlink(file_path)
      }
      writeBin(s3_object_body, con = file_path)
      my_data <-
        readr::read_delim(file = file_path,
                          locale = readr::locale(encoding = "UTF-8"),
                          col_types = readr::cols(.default = "c"))
      if (!file.exists(file_path)) {
        stop("Could not retreive support file.")
      }
    } else {
      # If file was not updated, retrieves the latest data from the data folder
      my_data <-
        readr::read_delim(file = file_path,
                          locale = readr::locale(encoding = "UTF-8"),
                          col_types = readr::cols(.default = "c"))
    }
  },
  error = function(e) {
    # If there is an error, return NULL for the data.
    warning("S3 returned no data and there is no existing data file.")
    return(NULL)
  })

  return(my_data)
}
