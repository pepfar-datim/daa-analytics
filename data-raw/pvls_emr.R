## code to prepare `pvls_emr` dataset goes here

# nolint start: commented_code_linter
# Uncomment this section if you are running this script alone
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
# nolint end

pvls_emr <- daa.analytics::get_s3_data(aws_s3_bucket = aws_s3_bucket,
                                       dataset_name = "pvls_emr_raw",
                                       cache_folder = "support_files") |>
  daa.analytics::adorn_pvls_emr()

saveRDS(pvls_emr, file = "support_files/pvls_emr.rds")
