## Updates all datasets in the `data` folder

library(magrittr)

source("data-raw/daa_indicators.R")

s3 <- paws::s3()
aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
source("data-raw/update_metadata.R")
source("data-raw/pvls_emr.R")

datim_secret <- Sys.getenv("DATIM_SECRET")
datimutils::loginToDATIM(datim_secret)
d2_session <- d2_default_session
source("data-raw/attribute_data.R")
source("data-raw/daa_indicator_data.R")

geo_secret <- Sys.getenv("GEO_SECRET")
datimutils::loginToDATIM(geo_secret)
geo_session <- d2_default_session
source("data-raw/daa_countries.R")
source("data-raw/import_history.R")

source("data-raw/combined_data.R")

source("data-raw/save_csv.R")
