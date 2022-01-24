# Fetch or update metadata files from S3

# library(magrittr)
# library(usethis)
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

datasets <- c(
  "de_metadata",   #1
  "coc_metadata",	 #2
  "ou_metadata",	 #3
  "pe_metadata"    #4
)

datasets %>%
  lapply(function(x){
    print(paste0("Getting the ", x, " dataset."))
    try(expr = { assign(x = old_data, value = as.name(x)) }, silent = TRUE) #nolint
    new_data <- daa.analytics::get_s3_data(s3 = s3,
                                           aws_s3_bucket = aws_s3_bucket,
                                           dataset_name = x,
                                           folder = "data-raw")
    assign(x = x, value = new_data)
    do.call(usethis::use_data, list(as.name(x), overwrite = TRUE))

    ## Compare old and new datasets
    try(expr = { waldo::compare(old_data, new_data) }, silent = TRUE) #nolint
  })

## code to prepare `ou_hierarchy` dataset
if(!exists("ou_metadata")){ load("data/ou_metadata.Rda") }
ou_hierarchy <- daa.analytics::create_hierarchy(ou_metadata)
try(expr = {
  waldo::compare(daa.analytics::ou_hierarchy, ou_hierarchy)
}, silent = TRUE)
usethis::use_data(ou_hierarchy, overwrite = TRUE)

