## code to prepare `import_history` dataset goes here

# Uncomment this section of code if you are running this script by itself
# datimutils::loginToDATIM("~/.secrets/geoalign.json")
# geo_session <- d2_default_session

import_history <- daa.analytics::get_import_history(geo_session = geo_session)
try(expr = {
  waldo::compare(daa.analytics::import_history, import_history)
}, silent = TRUE)
save(import_history, file = "support_files/import_history.rda")
