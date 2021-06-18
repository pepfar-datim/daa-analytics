
source("data-raw/daa_countries.R")
source("data-raw/daa_indicators.R")

datimutils::loginToDATIM("C:/Users/cnemarich001/.secrets/datim.json")
d2_session <- d2_default_session
source("data-raw/attribute_data.R")
source("data-raw/daa_indicator_data.R")

datimutils::loginToDATIM("C:/Users/cnemarich001/.secrets/geoalign.json")
geo_session <- d2_default_session
source("data-raw/data_availability.R")

s3 <- paws::s3()
aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
source("data-raw/coc_metadata.R")
source("data-raw/daa_pe_metadata.R")
source("data-raw/de_metadata.R")
source("data-raw/ou_metadata.R")
source("data-raw/ou_hierarchy.R")
source("data-raw/pvls_emr.R")

source("data-raw/combined-data.R")
