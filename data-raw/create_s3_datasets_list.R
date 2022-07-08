# Creates the list of S3 datasets that are relevant for the DAA

s3_datasets <- tibble::tribble(
  ~dataset_name, ~key, ~filters,
  "pvls_emr_raw", "datim/www.datim.org/moh_daa_data_value_emr_pvls", NA, #1
  "de_metadata", "datim/www.datim.org/data_element",
  c("dataelementid" = "dataelementid", "dataelementname" = "shortname"), #2
  "coc_metadata",	"datim/www.datim.org/category_option_combo",
  c("categoryoptioncomboid" = "categoryoptioncomboid",
    "categoryoptioncomboname" = "name"),                                 #3
  "ou_metadata",	"datim/www.datim.org/organisation_unit",
  c("organisationunitid" = "organisationunitid",
    "path" = "path", "name" = "shortname", "uid" = "uid"),               #4
  "pe_metadata",	"datim/www.datim.org/moh_daa_period_structure",
  c("periodid" = "periodid", "iso" = "iso"),                             #5
  "duplicate_ids",
  "datim/www.datim.org/moh_daa_data_integrity_duplicate_ids", NA,        #6
  "null_ids", "datim/www.datim.org/moh_daa_data_integrity_null_ids", NA  #7
)

usethis::use_data(s3_datasets, overwrite = TRUE)
