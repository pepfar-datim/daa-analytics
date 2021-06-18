## code to prepare `daa_countries` dataset goes here
## Updates list of DAA participant countries
## If you've made any edits to the participant list,
## then run this code below.
daa_countries <- read.csv("./inst/extdata/daa_countries.csv",
                          stringsAsFactors = FALSE)
usethis::use_data(daa_countries, overwrite = TRUE)
