#' @export
#' @title Combine DAA datasets together.
#'
#' @description
#' Combines DAA Indicator, PVLS and EMR data, and Site attribute data together
#' and exports them as a single dataframe.
#'
#' @param daa_indicator_data Dataframe containing DAA indicator data.
#' @param ou_hierarchy Dataframe containing the Organisational hierarchy.
#' @param pvls_emr Dataframe of PVLS and EMR data joined with metadata.
#' @param attribute_data Dataframe of site attribute data.
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
  pvls_emr %<>%
    dplyr::left_join(ou_hierarchy %>%
                       dplyr::select(.data$organisationunitid,
                                     .data$facilityuid),
                     by = c("organisationunitid"),
                     keep = FALSE)

  ou_hierarchy %<>%
    dplyr::select(.data$facilityuid, .data$namelevel3, .data$namelevel4,
                  .data$namelevel5, .data$namelevel6, .data$namelevel7) %>%
    unique()

  df <- daa_indicator_data %>%
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(ou_hierarchy, by = c("facilityuid")) %>%

    # Joins PVLS and EMR datasets
    dplyr::left_join(pvls_emr, by = c("facilityuid", "period", "indicator")) %>%

    # Joins site attribute data
    dplyr::left_join(attribute_data %>%
                       dplyr::filter(!is.na(.data$moh_id)),
                     by = c("facilityuid")) %>%

    # Selects rows for export
    dplyr::select(.data$facilityuid, dplyr::starts_with("namelevel"),
                  .data$indicator, .data$period, .data$moh, .data$pepfar,
                  .data$reported_by, dplyr::starts_with("level"),
                  dplyr::everything(), -.data$name, -.data$organisationunitid)

  return(df)
}
