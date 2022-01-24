## code to prepare `data_availability` dataset goes here

# Uncomment this section of code if you are running this script by itself
# datimutils::loginToDATIM("~/.secrets/geoalign.json")
# geo_session <- d2_default_session

import_history <- daa.analytics::get_import_history(geo_session = geo_session)
usethis::use_data(import_history, overwrite = TRUE)
