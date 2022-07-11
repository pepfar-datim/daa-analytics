## code to prepare Data Integrity Check country datasets
## and Excel files goes here
require(openxlsx)

output_folder <- Sys.getenv("OUTPUT_FOLDER") |> paste0("data_integrity_checks/")

aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

nulls <- daa.analytics::get_s3_data(aws_s3_bucket = aws_s3_bucket,
                                    dataset_name = "null_ids",
                                    folder = "support_files")
duplicates <- daa.analytics::get_s3_data(aws_s3_bucket = aws_s3_bucket,
                                         dataset_name = "duplicate_ids",
                                         folder = "support_files")

countries <-
  rbind(dplyr::select(nulls, country_name = "level3"),
                   dplyr::select(duplicates, "country_name"))[[1]] |>
  unique() |>
  sort() |>
  lapply(., function(x) {
    date <- base::format(Sys.time(), "%Y%m%d")
    print(x)
    file <- paste0(output_folder,
                   paste(date, x, "integrity_checks", sep = "_"), ".xlsx")
    wb <- openxlsx::createWorkbook(title = paste(x, "Data Integrity Checks"))
    country_nulls <- nulls[nulls$level3 == x, ]
    country_duplicates <- duplicates[duplicates$country_name == x, ]
    if (NROW(country_nulls) > 0) {
      openxlsx::addWorksheet(wb = wb, sheet = "Null IDs")
      openxlsx::writeData(wb = wb, sheet = "Null IDs",
                          x = country_nulls)
    }
    if (NROW(country_duplicates) > 0) {
      openxlsx::addWorksheet(wb = wb, sheet = "Duplicate IDs")
      openxlsx::writeData(wb = wb, sheet = "Duplicate IDs",
                          x = country_duplicates)
    }
    openxlsx::saveWorkbook(wb = wb, file = file, overwrite = TRUE)
  })
