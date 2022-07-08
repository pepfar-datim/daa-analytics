## code to prepare `attribute_data.R` dataset goes here

# nolint start: commented_code_linter
# Uncomment this code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("datim.json")
# datimutils::loginToDATIM(secrets)
# d2_session <- d2_default_session
# nolint end

attribute_data <- daa.analytics::daa_countries$country_uid |>
  lapply(function(x) {
    print(paste0("Fetching attribute data for ", x))
    daa.analytics::get_attribute_table(x, d2_session = d2_session)
  }) |>
  dplyr::bind_rows()
save(attribute_data, file = "support_files/attribute_data.rda")
