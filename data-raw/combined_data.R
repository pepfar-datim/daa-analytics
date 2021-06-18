## code to prepare `combined_data` dataset goes here
combined_data <- combine_data(daa.analytics::daa_indicator_data,
                              daa.analytics::pvls_emr,
                              daa.analytics::attribute_data)
usethis::use_data(combined_data, overwrite = TRUE)
