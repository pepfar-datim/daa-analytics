## Updates all datasets in the `data` folder

library(magrittr)

source("data-raw/daa_countries.R")
source("data-raw/daa_indicators.R")

datimutils::loginToDATIM("~/.secrets/datim.json")
d2_session <- d2_default_session
source("data-raw/attribute_data.R")
source("data-raw/daa_indicator_data.R")

datimutils::loginToDATIM("~/.secrets/geoalign.json")
geo_session <- d2_default_session
source("data-raw/data_availability.R")

s3 <- paws::s3()
aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
source("data-raw/coc_metadata.R")
source("data-raw/pe_metadata.R")
source("data-raw/de_metadata.R")
source("data-raw/ou_metadata.R")
devtools::load_all()
source("data-raw/ou_hierarchy.R")
devtools::load_all()
source("data-raw/pvls_emr.R")

devtools::load_all()
source("data-raw/combined_data.R")
