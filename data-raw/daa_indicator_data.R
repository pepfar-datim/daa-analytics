## code to prepare `daa_indicator_data` dataset goes here

# nolint start: commented_code_linter open_curly_linter
# Uncomment this code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("datim.json")
# datimutils::loginToDATIM(secrets)
# d2_session <- d2_default_session
# nolint end

if(!exists("ou_hierarchy")){
  ou_hierarchy <- load("support_files/ou_hierarchy.rda")
}
if(!exists("pvls_emr")){
  pvls_emr <- load("support_files/pvls_emr.rda")
}

daa_indicator_raw <-
  daa.analytics::daa_countries[["country_uid"]] |>
  lapply(function(x) {
    print(datimutils::getOrgUnits(x))
    daa.analytics::get_daa_data(ou_uid = x,
                                fiscal_year = c(2018, 2019, 2020, 2021),
                                d2_session = d2_session)
  }) |>
  dplyr::bind_rows() |>
  ## Filter out military sites
  dplyr::filter(!org_unit %in% datimutils::getOrgUnitGroups(
    "nwQbMeALRjL",
    fields = "organisationUnits[id,name]"))

save(daa_indicator_raw, file = "support_files/daa_indicator_raw.rda")

daa_indicator_data <-
  daa_indicator_filtered |>
  daa.analytics::adorn_daa_data(include_coc = FALSE, d2_session = d2_session) |>
  daa.analytics::adorn_weights(ou_hierarchy = ou_hierarchy,
                               pvls_emr = pvls_emr,
                               adorn_level6 = FALSE,
                               adorn_emr = TRUE)

save(daa_indicator_data, file = "support_files/daa_indicator_data.rda")
