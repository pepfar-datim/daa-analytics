## code to prepare `daa_indicator_data` dataset goes here

# nolint start: commented_code_linter open_curly_linter
# Uncomment this code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("datim.json")
# datimutils::loginToDATIM(secrets)
# d2_session <- d2_default_session
# nolint end

if(!exists("ou_hierarchy")){
  ou_hierarchy <- readRDS("support_files/ou_hierarchy.rds")
}
if(!exists("pvls_emr")){
  pvls_emr <- readRDS("support_files/pvls_emr.rds")
}

daa_countries <- daa.analytics::daa_countries
my_function <- function(x) {
  print(datimutils::getOrgUnits(x))
  daa.analytics::get_daa_data(ou_uid = x,
              fiscal_year = c(2018, 2019, 2020, 2021, 2022, 2023),
              d2_session = d2_session)
}

daa_indicator_raw <- lapply(daa_countries[["OU_UID"]], my_function)

daa_indicator_raw <- dplyr::bind_rows(daa_indicator_raw)

# Get the indices of the matching values
indices <- which(daa_indicator_raw$org_unit %in% datimutils::getOrgUnitGroups(
  "nwQbMeALRjL",
  fields = "organisationUnits[id,name]")$id)

# Check if there are any matching values
if(length(indices) > 0) {
  # Create a new data frame with only the non-matching values
  daa_indicator_raw <- subset(daa_indicator_raw, !(org_unit %in% daa_indicator_raw$org_unit[indices]))

} else {
  print("No matching values found")
}

saveRDS(daa_indicator_raw, file = "support_files/daa_indicator_raw.rds")

daa_indicator_data <-
  daa_indicator_raw |>
  daa.analytics::adorn_daa_data(include_coc = FALSE, d2_session = d2_session) |>
  daa.analytics::adorn_weights(ou_hierarchy = ou_hierarchy, weights_list = c("OU", "SNU1", "SNU2", "EMR"), pvls_emr = pvls_emr)

saveRDS(daa_indicator_data, file = "support_files/daa_indicator_data.rds")


