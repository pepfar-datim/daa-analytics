## code to prepare `pvls_emr` dataset goes here

# Uncomment this section if you are only running this script
# library(magrittr)
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

if(!exists("coc_metadata")){ load("data/coc_metadata.Rda") }
if(!exists("de_metadata")){ load("data/de_metadata.Rda") }
if(!exists("pe_metadata")){ load("data/pe_metadata.Rda") }
pvls_emr <- daa.analytics::get_pvls_emr_table(s3 = s3,
                                              aws_s3_bucket = aws_s3_bucket,
                                              last_update = NULL) %>%
  adorn_pvls_emr(pvls_emr = .,
                 coc_metadata = coc_metadata,
                 de_metadata = de_metadata,
                 pe_metadata = pe_metadata)
usethis::use_data(pvls_emr, overwrite = TRUE)
