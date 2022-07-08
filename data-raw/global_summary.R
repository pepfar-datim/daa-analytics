# Code to prepare the global summary spreadsheet goes here

if(!exists("combined_data")){ load("support_files/combined_data.rda") }
if(!exists("import_history")){ load("support_files/import_history.rda") }

output_folder <- Sys.getenv("OUTPUT_FOLDER")

globalSummary <- daa.analytics::global_summary(combined_data) |>
  dplyr::left_join(dplyr::select(import_history, namelevel3, period, indicator, CourseOrFine = has_disag_mapping),
                   by = c("namelevel3", "period", "indicator"))
write.csv(globalSummary, paste0(output_folder, "global_summary.csv"))
