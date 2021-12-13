## Updates all datasets in the `data` folder

ou_uid <- "HfVjCurKxh2"
folder <- "C:/Users/cnemarich002/OneDrive - Guidehouse/Documents/project_DAA/raw_country_data/"

library(magrittr)

source("data-raw/daa_indicators.R")

s3 <- paws::s3()
aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
source("data-raw/update_metadata.R")
source("data-raw/pvls_emr.R")

datim_secret <- Sys.getenv("DATIM_SECRET")
datimutils::loginToDATIM(datim_secret)
d2_session <- d2_default_session

country_attributes <-
  daa.analytics::get_attribute_table(ou_uid, d2_session = d2_session)

country_daa_data <-
  daa.analytics::get_daa_data(ou_uid,
                              d2_session = d2_session) %>%
  daa.analytics::adorn_daa_data() %>%
  daa.analytics::weighting_levels(ou_hierarchy = ou_hierarchy,
                                  pvls_emr = pvls_emr,
                                  adorn_level6 = TRUE,
                                  adorn_emr = TRUE)

combined_country_data <-
  daa.analytics::combine_data(
    daa_indicator_data = country_daa_data,
    ou_hierarchy = ou_hierarchy,
    pvls_emr = pvls_emr,
    attribute_data = country_attributes)

# Writes CSV
date <- base::format(Sys.time(), "%Y%m%d")
ou_name <- daa.analytics::get_ou_name(ou_uid)
file = paste0(folder, paste(date, ou_name, "raw_data", sep = "_"), ".csv")
combined_country_data %>%
  write.csv(file = file, na = "")
