## code to prepare `combined_data` dataset goes here
# TODO This probably needs to be fixed to not reference package datasets
# but instead the recently created ones.
combined_data <- daa.analytics::combine_data(daa.analytics::daa_indicator_data,
                                             daa.analytics::ou_hierarchy,
                                             daa.analytics::pvls_emr,
                                             daa.analytics::attribute_data)
usethis::use_data(combined_data, overwrite = TRUE)
