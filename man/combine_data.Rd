% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/combine-data.R
\name{combine_data}
\alias{combine_data}
\title{Combine DAA datasets together.}
\usage{
combine_data(
  daa_indicator_data = NULL,
  ou_hierarchy = NULL,
  pvls_emr = NULL,
  cache_folder = NULL
)
}
\arguments{
\item{daa_indicator_data}{Dataframe containing DAA indicator data.}

\item{ou_hierarchy}{Dataframe containing DATIM organisation unit hierarchy.}

\item{pvls_emr}{Dataframe of PVLS and EMR data joined with metadata.}
}
\value{
A dataframe containing the DAA indicator data, PVLS and EMR indicator
data, and the site attribute data for a single country.
}
\description{
Combines DAA Indicator, PVLS and EMR data, and Site attribute data together
and exports them as a single dataframe.
}
