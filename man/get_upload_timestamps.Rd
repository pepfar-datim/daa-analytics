% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get-upload-timestamps.R
\name{get_upload_timestamps}
\alias{get_upload_timestamps}
\title{Fetch Import Timestamps from GeoAlign}
\usage{
get_upload_timestamps(
  geo_session = dynGet("d2_default_session", inherits = TRUE)
)
}
\arguments{
\item{geo_session}{R6 session object specifically for a DHIS2 GeoAlign session.}
}
\value{
A dataframe of country names with columns for each DAA mapping and
import step with timestamp data for the completion of each step.
}
\description{
Extracts all data for all countries and activity years from GeoAlign
regarding whether a country has completed each step of the DAA process
with timestamps for completion.
}
