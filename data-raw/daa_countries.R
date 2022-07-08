## code to prepare `daa_countries` dataset goes here
## Updates list of DAA participant countries

# nolint start: commented_code_linter
# Uncomment this section of code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("geoalign.json")
# datimutils::loginToDATIM(secrets)
# d2_session <- d2_default_session
# nolint end

daa_countries <- daa.analytics::get_daa_countries(geo_session = geo_session)
usethis::use_data(daa_countries, overwrite = TRUE)
