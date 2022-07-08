## Updates all datasets in the `data` folder

ou_uid <- "HfVjCurKxh2"
output_folder <- Sys.getenv("OUTPUT_FOLDER") |> paste0("raw_country_data/")

s3 <- paws::s3()
aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
source("data-raw/update_metadata.R")
source("data-raw/pvls_emr.R")

secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("datim.json")
datimutils::loginToDATIM(secrets)
d2_session <- d2_default_session

country_attributes <-
  daa.analytics::get_attribute_table(ou_uid, d2_session = d2_session)

country_daa_data <-
  daa.analytics::get_daa_data(ou_uid, d2_session = d2_session) |>
  daa.analytics::adorn_daa_data() |>
  daa.analytics::weighting_levels(ou_hierarchy = ou_hierarchy,
                                  pvls_emr = pvls_emr,
                                  adorn_level6 = TRUE,
                                  adorn_emr = TRUE)

combined_country_data <- daa.analytics::combine_data(
  daa_indicator_data = country_daa_data,
  ou_hierarchy = ou_hierarchy,
  pvls_emr = pvls_emr,
  attribute_data = country_attributes)

# Writes CSV
date <- base::format(Sys.time(), "%Y%m%d")
ou_name <- datimutils::getOrgUnits(ou_uid)
file <- paste0(output_folder,
               paste(date, ou_name, "raw_data", sep = "_"), ".csv")
write.csv(combined_country_data, file = file, na = "")
