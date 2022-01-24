## code to prepare `daa_indicator_data` dataset goes here

# Uncomment this code if you are running this script by itself
# library(magrittr)
# datimutils::loginToDATIM("~/.secrets/datim.json")
# d2_session <- d2_default_session

if(!exists("ou_hierarchy")){ load("data/ou_hierarchy.Rda") }
if(!exists("pvls_emr")){ load("data/pvls_emr.Rda") }

daa_indicator_data <- daa.analytics::daa_countries %>%
  dplyr::filter(country_uid != "YM6xn5QxNpY") %>%
  dplyr::arrange(country_name) %>%
  .$country_uid %>%
  lapply(., function(x){
    print(paste0("Fetching indicator data for ", daa.analytics::get_ou_name(x)))
    daa.analytics::get_daa_data(x, d2_session = d2_session) %>%
      daa.analytics::adorn_daa_data() %>%
      daa.analytics::adorn_weights(ou_hierarchy = ou_hierarchy,
                                   pvls_emr = pvls_emr,
                                   adorn_level6 = TRUE,
                                   adorn_emr = TRUE)
  }) %>%
  dplyr::bind_rows()
try(expr = {
  waldo::compare(daa.analytics::daa_indicator_data, daa_indicator_data)
}, silent = TRUE)
usethis::use_data(daa_indicator_data, overwrite = TRUE)
