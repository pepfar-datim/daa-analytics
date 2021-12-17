# Save CSV files of all country data

output_folder <- Sys.getenv("OUTPUT_FOLDER")

if(!exists("combined_data")){ load("data/combined_data.Rda") }

daa.analytics::daa_countries$country_uid %>%
  lapply(., function(x){
    date <- base::format(Sys.time(), "%Y%m%d")
    ou_name <- daa.analytics::get_ou_name(x)
    print(ou_name)
    file = paste0(output_folder, paste(date, ou_name, "raw_data", sep = "_"), ".csv")
    combined_data %>%
      dplyr::filter(namelevel3uid == x) %>%
      write.csv(file = file, na = "", row.names = FALSE)
  })
