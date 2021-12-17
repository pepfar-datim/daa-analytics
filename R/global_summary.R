#' Prepare Global Summary Table of DAA Data
#'
#' @param combined_data
#'
#' @return
#' @export
#'
global_summary <- function(combined_data) {
  df <-
    combined_data %>%
    dplyr::group_by(namelevel3, period, indicator) %>%
    dplyr::summarize(
      CountOfFacilities_ReportedBy_Both = length(facilityuid[reported_by == "Both"]),
      CountOfFacilities_ReportedBy_MOH = length(facilityuid[reported_by %in% c("Both", "MOH")]),
      CountOfFacilities_ReportedBy_PEPFAR = length(facilityuid[reported_by %in% c("Both", "PEPFAR")]),
      CountOfFacilities_ReportedBy_PEPFAROnly = length(facilityuid[reported_by == "PEPFAR"]),
      Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH = length(facilityuid[reported_by == "Both"]) / length(facilityuid[reported_by %in% c("Both", "PEPFAR")]),
      Pct_MOH_Facilities_SupportedBy_PEPFAR = length(facilityuid[reported_by == "Both"]) / length(facilityuid[reported_by %in% c("Both", "MOH")]),
      Pct_PEPFAR_Facilities_WithEMR = length(facilityuid[emr_at_site_for_indicator == TRUE & reported_by %in% c("PEPFAR", "Both")]) / length(facilityuid[reported_by %in% c("PEPFAR", "Both")]),
      Pct_PEPFAR_Facilities_WithEMR_ReportedBy_Both = length(facilityuid[emr_at_site_for_indicator == TRUE & reported_by == "Both"]) / length(facilityuid[reported_by == "Both"]),
      MOH_Results_Total = sum(moh[reported_by %in% c("Both", "MOH")], na.rm = TRUE),
      PEPFAR_Results_Total = sum(pepfar[reported_by %in% c("Both", "PEPFAR")], na.rm = TRUE),
      MOH_Results_FacilitiesReportedByBoth = sum(moh[reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedByBoth = sum(pepfar[reported_by == "Both"], na.rm = TRUE),
      Concordance = sum(level3_concordance[reported_by == "Both"], na.rm = TRUE),
      ConcordanceOfFacilitiesWithEMR = sum(emr_concordance[reported_by == "Both" & emr_at_site_for_indicator == TRUE], na.rm = TRUE),
      ConcordanceOfFacilitiesWithOutEMR = sum(emr_concordance[reported_by == "Both" & emr_at_site_for_indicator == FALSE], na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      across(c(MOH_Results_FacilitiesReportedByBoth,
               PEPFAR_Results_FacilitiesReportedByBoth,
               Pct_PEPFAR_Facilities_WithEMR_ReportedBy_Both,
               Concordance,
               ConcordanceOfFacilitiesWithEMR,
               ConcordanceOfFacilitiesWithOutEMR),
             ~ ifelse(CountOfFacilities_ReportedBy_Both == 0, NA, .x))) %>%
    dplyr::mutate(
      across(c(Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH,
               Pct_MOH_Facilities_SupportedBy_PEPFAR),
             ~ ifelse(CountOfFacilities_ReportedBy_PEPFAR == 0 |
                        CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) %>%
    dplyr::mutate(
      ConcordanceOfFacilitiesWithEMR =
        ifelse(Pct_PEPFAR_Facilities_WithEMR_ReportedBy_Both == 0,
               NA, ConcordanceOfFacilitiesWithEMR),
      ConcordanceOfFacilitiesWithOutEMR =
        ifelse(Pct_PEPFAR_Facilities_WithEMR_ReportedBy_Both == 1,
               NA, ConcordanceOfFacilitiesWithOutEMR)
    ) %>%
    dplyr::mutate(
      across(c(MOH_Results_Total, MOH_Results_FacilitiesReportedByBoth),
             ~ ifelse(CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) %>%
    dplyr::mutate(
      across(c(PEPFAR_Results_Total,
               PEPFAR_Results_FacilitiesReportedByBoth,
               Pct_PEPFAR_Facilities_WithEMR),
             ~ ifelse(CountOfFacilities_ReportedBy_PEPFAR == 0, NA, .x)))

  return(df)
}
