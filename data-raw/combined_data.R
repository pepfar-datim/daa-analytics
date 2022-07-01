## code to prepare `combined_data` dataset goes here
if(!exists("daa_indicator_data")){ load("support_files/daa_indicator_data.Rda") }
if(!exists("ou_hierarchy")){ load("support_files/ou_hierarchy.Rda") }
if(!exists("pvls_emr")){ load("support_files/pvls_emr.Rda") }
if(!exists("attribute_data")){ load("support_files/attribute_data.Rda") }
combined_data <- daa.analytics::combine_data(
  daa_indicator_data = daa_indicator_data,
  ou_hierarchy = ou_hierarchy,
  pvls_emr = pvls_emr,
  attribute_data = attribute_data)
save(combined_data, file = "support_files/combined_data.rda")
