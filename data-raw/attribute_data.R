## code to prepare `attribute_data.R` dataset goes here

# Uncomment this code if you are running this script by itself
# library(magrittr)
# datimutils::loginToDATIM("~/.secrets/datim.json")
# d2_session <- d2_default_session

attribute_data <- daa.analytics::daa_countries$country_uid |>
  lapply(function(x){
    print(paste0("Fetching attribute data for ", x))
    daa.analytics::get_attribute_table(x, d2_session = d2_session)
  }) |>
  dplyr::bind_rows()
save(attribute_data, file = "support_files/attribute_data.rda")
