# Save CSV files of all country data

output_folder <- Sys.getenv("OUTPUT_FOLDER") |> paste0("raw_country_data/")

if (!exists("combined_data")) { load("support_files/combined_data.Rda") } #nolint

daa.analytics::daa_countries$country_uid |>
  lapply(function(x) {
    date <- base::format(Sys.time(), "%Y%m%d")
    ou_name <- datimutils::getOrgUnits(x)
    print(ou_name)
    file <- paste0(output_folder,
                   paste(date, ou_name, "raw_data", sep = "_"), ".csv")
    combined_data |>
      dplyr::filter(Facility_UID == x) |>
      write.csv(file = file, na = "", row.names = FALSE)
  })
