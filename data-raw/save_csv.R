# Save CSV files of all country data

folder <- "C:/Users/cnemarich002/OneDrive - Guidehouse/Documents/project_DAA/raw_country_data/"

if(!exists("combined_data")){ load("data/combined_data.Rda") }

daa.analytics::daa_countries$country_uid |>
  lapply(function(x){
    date <- base::format(Sys.time(), "%Y%m%d")
    ou_name <- datimutils::getOrgUnits(x)
    print(ou_name)
    file = paste0(folder, paste(date, ou_name, "raw_data", sep = "_"), ".csv")
    combined_data |>
      dplyr::filter(namelevel3uid == x) |>
      write.csv(file = file, na = "", row.names = FALSE)
  })
