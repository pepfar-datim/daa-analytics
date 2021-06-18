## code to prepare `daa_indicators` dataset goes here
daa_indicators <- read.csv("./inst/extdata/daa_indicators.csv",
                           stringsAsFactors = FALSE)
usethis::use_data(daa_indicators, overwrite = TRUE)
