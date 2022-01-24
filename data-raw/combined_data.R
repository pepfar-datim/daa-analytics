## code to prepare `combined_data` dataset goes here
if(!exists("daa_indicator_data")){ load("data/daa_indicator_data.Rda") }
if(!exists("ou_hierarchy")){ load("data/ou_hierarchy.Rda") }
if(!exists("pvls_emr")){ load("data/pvls_emr.Rda") }
if(!exists("attribute_data")){ load("data/attribute_data.Rda") }
combined_data <- daa.analytics::combine_data(
  daa_indicator_data = daa_indicator_data,
  ou_hierarchy = ou_hierarchy,
  pvls_emr = pvls_emr,
  attribute_data = attribute_data)
try(expr = {
  waldo::compare(daa.analytics::combined_data, combined_data)
}, silent = TRUE)
usethis::use_data(combined_data, overwrite = TRUE)
