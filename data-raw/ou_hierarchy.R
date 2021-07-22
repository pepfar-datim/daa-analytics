## code to prepare `ou_hierarchy` dataset goes here
ou_hierarchy <- daa.analytics::create_hierarchy()
usethis::use_data(ou_hierarchy, overwrite = TRUE)
