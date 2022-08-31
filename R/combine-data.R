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
combine_data <- function(daa_indicator_data,
                         ou_hierarchy,
                         pvls_emr,
                         attribute_data) {
  # Clean pvls_emr and ou_hierarchy datasets to avoid
  # duplication of facilities with multiple organisationunitid numbers
  pvls_emr <-
    dplyr::left_join(pvls_emr,
                     ou_hierarchy |>
                       dplyr::select(organisationunitid,
                                     facilityuid),
                     by = c("organisationunitid"),
                     keep = FALSE)

  df <- daa_indicator_data |>
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(ou_hierarchy, by = c("facilityuid")) |>

    # Joins PVLS and EMR datasets
    dplyr::left_join(pvls_emr, by = c("facilityuid", "period", "indicator")) |>

    # Joins site attribute data
    dplyr::left_join(attribute_data |>
                       dplyr::filter(!is.na(moh_id)),
                     by = c("facilityuid")) |>

    # Selects rows for export
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
