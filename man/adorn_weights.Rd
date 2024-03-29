% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/adorn-weights.R
\name{adorn_weights}
\alias{adorn_weights}
\title{Adorn DAA Indicator Data with Weighted Metrics for All Levels}
\usage{
adorn_weights(
  daa_indicator_data = NULL,
  weights_list = c("OU", "SNU1", "SNU2")
)
}
\arguments{
\item{daa_indicator_data}{Dataframe containing DAA indicator data.}

\item{weights_list}{A list containing the levels at which concordance
metrics should be calculated. \code{OU} level is the default, calculating
sites as a share of the overall country. SNU levels 1-3 are supported,
as well as \code{EMR}, which groups by whether or not a facility has an EMR.}
}
\value{
A dataframe of DAA Indicator data with weightings and weighted
concordance calculated fo all requested levels.
}
\description{
Adorn DAA Indicator Data with Weighted Metrics for All Levels
}
