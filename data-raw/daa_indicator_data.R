## code to prepare `daa_indicator_data` dataset goes here

# Uncomment this code if you are running this script by itself
# secrets <- Sys.getenv("SECRETS_FOLDER") |> paste0("datim.json")
# datimutils::loginToDATIM(secrets)
# d2_session <- d2_default_session

if(!exists("ou_hierarchy")){ load("support_files/ou_hierarchy.Rda") }
if(!exists("pvls_emr")){ load("support_files/pvls_emr.Rda") }

daa_indicator_raw <-
  daa.analytics::daa_countries[["country_uid"]] |>
  daa.analytics::get_daa_data(fiscal_year = c(2018, 2019, 2020, 2021), d2_session = d2_session)

save(daa_indicator_raw, file = "support_files/daa_indicator_raw.rda")

daa_indicator_filtered <-
  daa_indicator_raw |>
  dplyr::select(data_element, period, org_unit, category_option_combo, attribute_option_combo, value) |>
  ## Aggregate categoryOptionCombo data for now
  dplyr::group_by(data_element, period, org_unit, attribute_option_combo) |>
  dplyr::summarise(value = sum(as.numeric(value))) |>
  dplyr::ungroup() |>
  ## Filter out unwanted indicators
  dplyr::filter(!period %in% c("2017Oct", "2018Oct") |
                  !data_element %in% c("BRalYZhcHpi", "V6hxDYUZFBq", "xwVNaDjMe9z", "IXkZ7eWtFHs")) |>
  ## Filter out military sites
  dplyr::filter(!org_unit %in% {
    dplyr::filter(
      tidyr::unnest(
        dplyr::rename(
          datimutils::getOrgUnits(unique(daa_indicator_raw$org_unit),
                                  fields = c("id", "name", "organisationUnitGroups[id,name]")),
        ou_id = id, ou_name = name),
      cols = "organisationUnitGroups"), id == "nwQbMeALRjL")[["ou_id"]]
    })

daa_indicator_data <-
  daa_indicator_filtered |>
  daa.analytics::adorn_daa_data(include_coc = FALSE, d2_session = d2_session) |>
  daa.analytics::adorn_weights(ou_hierarchy = ou_hierarchy,
                               pvls_emr = pvls_emr,
                               adorn_level6 = FALSE,
                               adorn_emr = TRUE)

save(daa_indicator_data, file = "support_files/daa_indicator_data.rda")
