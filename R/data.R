#' DAA country list.
#'
#' A dataset containing the names, abbreviations, and IDs of DAA countries.
#'
#' @format A data frame with 23 rows and 4 variables:
#' \describe{
#'   \item{country_name}{The name of the country.}
#'   \item{country_uid}{The alphanumeric UID associated with the country in
#'   DATIM.}
#'   \item{country_code}{The three letter acronym for the country.}
#'   \item{facility_level}{The organisation unit hierarchy level at which
#'   facilities are located for the particular country.}
#' }
#' @source \url{http://www.datim.org/}
"daa_countries"


#' S3 Datasets
#'
#' A dataset containing all the relevant metadata datasets available on S3,
#' their name, S3 key, and the filters that should be applied to the dataset
#' for cleaning prior to return.
#'
#' @format A dataframe with 3 variables:
#' \describe{
#'   \item{dataset_name}{Plain english name of the dataset, as defined within
#'   the daa.analytics package.}
#'   \item{key}{The S3 location where the dataset can be found.}
#'   \item{filters}{Any filters that should be applied to the data for
#'   cleaning, if relevant.}
#' }
"s3_datasets"
