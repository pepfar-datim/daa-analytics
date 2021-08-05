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
#' @param last_update The date and time the dataset was last updated.
#'
#' @return A dataframe of the data located in the specified S3 sub-bucket.
#'
fetch_s3_files <- function(s3, aws_s3_bucket, key,
                           folder = "data-raw", file_name, last_update = NULL) {
  # TODO remove the need for `folder` and `file_name` arguments
  tryCatch({
    s3_object <-
      s3$get_object(Bucket = aws_s3_bucket,
                    # IfModifiedSince = last_update,
                    Key = paste0(key, "/data.csv.gz"))
    s3_object_body <- s3_object$Body

    # TODO remove the need to save a temporary file to access data
    file_name2 <- paste0(folder, "/", file_name, ".csv.gz")
    if (file.exists(file_name2)) {
      unlink(file_name2)
    }
    writeBin(s3_object_body, con = file_name2)
    data <- data.table::fread(file_name2)
    if(!file.exists(file_name2)) {stop("Could not retreive support file.")}
  },
  error = function(e){
    # If file was not updated, retrieves the latest data from the data folder
    file_name2 <- paste0(folder, "/", file_name, ".csv.gz")
    data <- data.table::fread(file_name2)
    flog.info(paste0("S3 file for ", file_name,
                     " was not updated. Used data from ", file_name, ".csv.gz"))
  })

  return(data)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @title Get Organisation Unit Name from UID.
#'
#' @description
#' Returns the country name based on the organisation unit UID.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#'
#' @return A string containing the country name.
#'
get_ou_name <- function(ou_uid) {
  ou_name <- daa.analytics::daa_countries %>%
    dplyr::filter(countryUID == ou_uid) %>%
    dplyr::select(countryName) %>%
    toString(.)

  # Returns OU name
  return(ou_name)
}

#' @export
#' @title Return current FY based on system date.
#'
#' @return Current FY as numeric.
#'
currentFY <- function() {
  current_year <- Sys.Date() %>%
    format("%Y") %>%
    as.numeric()

  current_month <- Sys.Date() %>%
    format("%m") %>%
    as.numeric()

  current_FY <- ifelse(current_month > 9, current_year + 1, current_year)

  return(current_FY)
}
