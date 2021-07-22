## code to prepare `daa_pe_metadata` dataset goes here

# Uncomment this section if you are only running this script
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

pe_metadata <- daa.analytics::get_pe_metadata(s3, aws_s3_bucket)
usethis::use_data(pe_metadata, overwrite = TRUE)
