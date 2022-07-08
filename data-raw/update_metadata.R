# Fetch or update metadata files from S3

s3 <- paws::s3()
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
    data <- daa.analytics::get_s3_data(s3 = s3,
                                       aws_s3_bucket = aws_s3_bucket,
                                       dataset_name = x,
                                       folder = "data-raw")
    assign(x = x, value = data)
    save(list = x, file = paste0("support_files/", {x}, ".rda")) #nolint
  })

## code to prepare `ou_hierarchy` dataset
if (!exists("ou_metadata")) { load("support_files/ou_metadata.Rda") } #nolint
ou_hierarchy <- daa.analytics::create_hierarchy(ou_metadata)
save(ou_hierarchy, file = "support_files/ou_hierarchy.rda")
