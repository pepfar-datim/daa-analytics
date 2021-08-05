## code to prepare `daa_countries` dataset goes here
## Updates list of DAA participant countries

# Uncomment this section of code if you are running this script by itself
# datimutils::loginToDATIM("~/.secrets/geoalign.json")
# geo_session <- d2_default_session

daa_countries <- daa.analytics::get_daa_countries(geo_session = geo_session)
usethis::use_data(daa_countries, overwrite = TRUE)
