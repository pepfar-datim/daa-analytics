# Code to prepare the global summary spreadsheet goes here

if(!exists("combined_data")){ combined_data <- readRDS("support_files/combined_data.rds") } #nolint
if(!exists("import_history")){ import_history <- readRDS("support_files/import_history.rds") } #nolint

output_folder <- Sys.getenv("OUTPUT_FOLDER")

summary_data <- daa.analytics::global_summary(combined_data) |>
  dplyr::left_join(dplyr::select(import_history,
                                 OU,
                                 period,
                                 indicator,
                                 CourseOrFine = has_disag_mapping,
                                 DataOrMapping = has_mapping_result_data),
                   by = c("OU", "period", "indicator"))
write.csv(summary_data, paste0(output_folder, "global_summary.csv"))
