#' @export
#' @title Fetch data from S3 bucket.
#'
#' @description
#' Extracts data from a specific S3 bucket, saves it to a folder, and returns
#' a dataframe with the same data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param bucket The URL for the particular bucket being accessed.
#' @param Key_1 The folder extension where the DAA folders are stored.
#' @param Key_2 The specific folder where the DAA data being accessed is stored.
#'
#' @return A dataframe of the data located in the specified S3 sub-bucket.
#'
fetch_s3_files <- function(s3, Bucket, Key_1, Key_2) {

  s3_object <-
    s3$get_object(Bucket = Bucket,
                  Key = paste0(Key_1, Key_2, "/data.csv.gz"))
  s3_object_body <- s3_object$Body

  # TODO remove the need to save a temporary file to access data
  file_name2 <- paste0("data-raw/", Key_2, ".csv.gz")
  if (file.exists(file_name2)) {
    unlink(file_name2)
  }

  writeBin(s3_object_body, con = file_name2)
  data <- data.table::fread(file_name2)
  if(!file.exists(file_name2)) {stop("Could not retreive support file.")}

  return(data)
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
