## code to prepare `de_metadata` dataset goes here

# Uncomment this section if you are only running this script
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

de_metadata <- daa.analytics::get_de_metadata(s3 = s3,
                                              aws_s3_bucket = aws_s3_bucket,
                                              last_update = NULL)
usethis::use_data(de_metadata, overwrite = TRUE)
