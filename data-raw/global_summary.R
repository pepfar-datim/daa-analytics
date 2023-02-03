# Code to prepare the global summary spreadsheet goes here

if(!exists("combined_data")){ combined_data <- readRDS("support_files/combined_data.rds") } #nolint
if(!exists("import_history")){ import_history <- readRDS("support_files/import_history.rds") } #nolint

output_folder <- Sys.getenv("OUTPUT_FOLDER")

summary_data <- daa.analytics::global_summary(combined_data) |>
  dplyr::filter(!is.na(OU)) |>
  dplyr::left_join(dplyr::select(import_history,
                                 OU,
                                 period,
                                 indicator,
                                 CourseOrFine = has_disag_mapping,
                                 DataOrMapping = has_mapping_result_data),
                   by = c("OU", "period", "indicator")) |>

  dplyr::mutate(DataOrMapping = ifelse((is.na(MOH_Results_Total) | MOH_Results_Total == "None") & CourseOrFine == "Coarse" & period < 2022, "Mapping Coarse",
                                ifelse((is.na(MOH_Results_Total) | MOH_Results_Total == "None") & CourseOrFine == "Fine" & period < 2022, "Mapping Fine",
                                ifelse((is.na(CourseOrFine) | CourseOrFine == "None" | CourseOrFine == "NA") & period < 2022, "No Mapping",
                                ifelse(!is.na(MOH_Results_Total) & CourseOrFine == "Fine" & period < 2022, "Data Fine",
                                ifelse(!is.na(MOH_Results_Total) & CourseOrFine == "Coarse" & period < 2022, "Data Coarse", DataOrMapping))))))

write.csv(summary_data, paste0(output_folder, "global_summary.csv"))
