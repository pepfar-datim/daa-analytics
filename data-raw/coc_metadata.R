## code to prepare `coc_metadata` dataset goes here

# Uncomment this section if you are only running this script
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

coc_metadata <- getCOCMetadata(s3, aws_s3_bucket)
usethis::use_data(coc_metadata, overwrite = TRUE)
