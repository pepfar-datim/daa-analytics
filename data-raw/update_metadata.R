# Fetch or update metadata files from S3

aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

datasets <- c(
  "de_metadata",   #1
  "coc_metadata",	 #2
  "ou_metadata",	 #3
  "pe_metadata"    #4
)

datasets |>
  lapply(function(x) {
    print(paste0("Getting the ", x, " dataset."))
    daa.analytics::get_s3_data(aws_s3_bucket = aws_s3_bucket,
                               dataset_name = x,
                               cache_folder = "support_files")
  })

## code to prepare `ou_hierarchy` dataset
if (!exists("ou_metadata")) { load("support_files/ou_metadata.Rda") } #nolint
ou_hierarchy <- daa.analytics::create_hierarchy(ou_metadata)
saveRDS(ou_hierarchy, file = "support_files/ou_hierarchy.rds")
