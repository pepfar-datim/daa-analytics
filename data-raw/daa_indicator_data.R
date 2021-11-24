## code to prepare `daa_indicator_data` dataset goes here

# Uncomment this code if you are running this script by itself
# library(magrittr)
# datimutils::loginToDATIM("~/.secrets/datim.json")
# d2_session <- d2_default_session

if(!exists("ou_hierarchy")){ load("data/ou_hierarchy.Rda") }

daa_indicator_data <- daa.analytics::daa_countries$country_uid %>%
  {.[!. %in% "YM6xn5QxNpY"]} %>%
  lapply(., function(x){
    print(daa.analytics::get_ou_name(x))
    daa.analytics::get_daa_data(x, d2_session = d2_session) %>%
      daa.analytics::adorn_daa_data() %>%
      daa.analytics::weighting_levels(ou_hierarchy = ou_hierarchy)
  }) %>%
  dplyr::bind_rows()
usethis::use_data(daa_indicator_data, overwrite = TRUE)
