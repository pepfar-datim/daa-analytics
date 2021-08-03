## code to prepare `ou_hierarchy` dataset goes here
if(!exists("ou_metadata")){ load("data/ou_metadata.Rda") }
ou_hierarchy <- daa.analytics::create_hierarchy(ou_metadata)
usethis::use_data(ou_hierarchy, overwrite = TRUE)
