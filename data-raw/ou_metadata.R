## code to prepare `ou_metadata` dataset goes here

# Uncomment this section if you are only running this script
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

ou_metadata <- daa.analytics::get_ou_metadata(s3 = s3,
                                              aws_s3_bucket = aws_s3_bucket,
                                              last_update = NULL)
usethis::use_data(ou_metadata, overwrite = TRUE)
