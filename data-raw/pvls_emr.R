## code to prepare `pvls_emr` dataset goes here

# Uncomment this section if you are only running this script
# library(magrittr)
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

pvls_emr <- get_pvls_emr_table(s3, aws_s3_bucket) %>%
  adorn_pvls_emr(.)
usethis::use_data(pvls_emr, overwrite = TRUE)
