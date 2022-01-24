# Save CSV files of all country data
# library(magrittr)

output_folder <- Sys.getenv("OUTPUT_FOLDER")
date <- base::format(Sys.time(), "%Y%m%d")

if(!exists("combined_data")){ load("data/combined_data.Rda") }

daa.analytics::daa_countries %>%
  dplyr::arrange(country_name) %>%
  .$country_uid %>%
  lapply(., function(x){
    ou_name <- daa.analytics::get_ou_name(x)
    print(ou_name)
    file = paste0(output_folder, paste(date, ou_name, "raw_data", sep = "_"), ".csv")
    combined_data %>%
      dplyr::filter(namelevel3uid == x) %>%
      write.csv(file = file, na = "", row.names = FALSE)
  })

# Creates and writes Global Summary file
global_filename <-
  paste0(output_folder, paste(date, "global_summary", sep = "_"), ".csv")
daa.analytics::global_summary(combined_data) %>%
  write.csv(file = global_filename, na = "", row.names = FALSE)
