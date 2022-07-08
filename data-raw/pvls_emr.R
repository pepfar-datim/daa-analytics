## code to prepare `pvls_emr` dataset goes here

# nolint start: commented_code_linter open_curly_linter
# Uncomment this section if you are only running this script
# s3 <- paws::s3()
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")

if(!exists("coc_metadata")){ load("support_files/coc_metadata.Rda") }
if(!exists("de_metadata")){ load("support_files/de_metadata.Rda") }
if(!exists("pe_metadata")){ load("support_files/pe_metadata.Rda") }
# nolint end

pvls_emr_raw <- daa.analytics::get_s3_data(s3 = s3,
                                           aws_s3_bucket = aws_s3_bucket,
                                           dataset_name = "pvls_emr_raw",
                                           folder = "data-raw")
pvls_emr <- daa.analytics::adorn_pvls_emr(pvls_emr_raw = pvls_emr_raw,
                                          coc_metadata = coc_metadata,
                                          de_metadata = de_metadata,
                                          pe_metadata = pe_metadata)

save(pvls_emr, file = "support_files/pvls_emr.rda")
