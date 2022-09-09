#' @export
#' @title Combine DAA datasets together.
#'
#' @description
#' Combines DAA Indicator, PVLS and EMR data, and Site attribute data together
#' and exports them as a single dataframe.
#'
#' @inheritParams daa_analytics_params
#'
#' @return A dataframe containing the DAA indicator data, PVLS and EMR indicator
#' data, and the site attribute data for a single country.
#'
combine_data <- function(daa_indicator_data = NULL,
                         ou_hierarchy = NULL,
                         pvls_emr = NULL,
                         cache_folder = NULL) {

  # Check for either presence of all datasets or cache folder ####
  stopifnot("You must either provide all datasets or the location of a cache folder!" =
              (!is.null(daa_indicator_data) && !is.null(ou_hierachy) && !is.null(pvls_emr)) ||
              !is.null(cache_folder))

  # Checks for cache files if data not provided directly ####
  if (is.null(daa_indicator_data)) {
    daa_indicator_data <- check_cache(paste0(cache_folder, "daa_indicator_data.rda"))
    if (is.null(daa_indicator_data)) stop("No DAA indicator data provided and no cache available!")
  }
  if (is.null(ou_hierarchy)) {
    ou_hierachy <- daa.analytics::create_hierarchy(cache_folder = cache_folder)
  }
  if (is.null(pvls_emr)) {
    pvls_emr <- check_cache(paste0(cache_folder, "pvls_emr.rda"))
    if (is.null(pvls_emr)) stop("No PVLS & EMR data provided and no cache available!")
  }

  # Clean pvls_emr and ou_hierarchy datasets to avoid
  # duplication of facilities with multiple organisationunitid numbers
  pvls_emr <-
    dplyr::left_join(pvls_emr,
                     ou_hierarchy |>
                       dplyr::select(organisationunitid,
                                     Facility_UID),
                     by = c("organisationunitid"),
                     keep = FALSE)

  df <- daa_indicator_data |>
    ## Joins DAA Indicator data to OU hierarchy metadata ####
    dplyr::left_join(ou_hierarchy, by = c("Facility_UID")) |>

    ## Joins PVLS and EMR datasets ####
    dplyr::left_join(pvls_emr, by = c("Facility_UID", "period", "indicator")) |>

    ## Joins site attribute data ####
    dplyr::left_join(attribute_data |>
                       dplyr::filter(!is.na(moh_id)),
                     by = c("Facility_UID")) |>

    ## Selects rows for export ####
    dplyr::select(facilityuid,
                  dplyr::starts_with("namelevel"),
                  indicator,
                  period,
                  moh,
                  pepfar,
                  reported_by,
                  dplyr::starts_with("level"),
                  dplyr::starts_with("emr"),
                  tx_pvls_n,
                  tx_pvls_d,
                  moh_id,
                  longitude,
                  latitude)

  return(df)
}
