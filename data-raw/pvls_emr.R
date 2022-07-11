## code to prepare `pvls_emr` dataset goes here

# nolint start: commented_code_linter
# Uncomment this section if you are running this script alone
# aws_s3_bucket <- Sys.getenv("AWS_S3_BUCKET")
# nolint end

if(!exists("coc_metadata")){
  coc_metadata <- readRDS("support_files/coc_metadata.rds")
  }
if(!exists("de_metadata")){
  de_metadata <- readRDS("support_files/de_metadata.rds")
  }
if(!exists("pe_metadata")){
  pe_metadata <- readRDS("support_files/pe_metadata.rds")
  }

pvls_emr_raw <- daa.analytics::get_s3_data(aws_s3_bucket = aws_s3_bucket,
                                           dataset_name = "pvls_emr_raw",
                                           folder = "data-raw")
pvls_emr <- daa.analytics::adorn_pvls_emr(pvls_emr_raw = pvls_emr_raw,
                                          coc_metadata = coc_metadata,
                                          de_metadata = de_metadata,
                                          pe_metadata = pe_metadata)

save(pvls_emr, file = "support_files/pvls_emr.rda")
