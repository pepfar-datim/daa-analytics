## code to prepare `data_availability` dataset goes here

# nolint start: commented_code_linter
# Uncomment this section of code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("geoalign.json")
# datimutils::loginToDATIM(secrets)
# geo_session <- d2_default_session
# nolint end

import_history <- daa.analytics::get_import_history(geo_session = geo_session)
save(import_history, file = "support_files/import_history.rda")
