#' Prepare Global Summary Table of DAA Data
#'
#' @param combined_data The combined dataset of DAA data for processing into a
#' summary file.
#'
#' @return Summary table dataframe
#' @export
#'
global_summary <- function(combined_data) {
  #nolint start: line_length_linter
  combined_data |>
    dplyr::group_by(namelevel3, period, indicator) |>
    dplyr::summarize(
      CountOfFacilities_ReportedBy_Both = length(facilityuid[reported_by == "Both"]),
      CountOfFacilities_ReportedBy_MOH = length(facilityuid[reported_by %in% c("Both", "MOH")]),
      CountOfFacilities_ReportedBy_PEPFAR = length(facilityuid[reported_by %in% c("Both", "PEPFAR")]),
      CountOfFacilities_ReportedBy_PEPFAROnly = length(facilityuid[reported_by == "PEPFAR"]),
      Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH = length(facilityuid[reported_by == "Both"]) / length(facilityuid[reported_by %in% c("Both", "PEPFAR")]),
      Pct_MOH_Facilities_SupportedBy_PEPFAR = length(facilityuid[reported_by == "Both"]) / length(facilityuid[reported_by %in% c("Both", "MOH")]),
      Pct_PEPFAR_Facilities_WithEMR = length(facilityuid[emr_present == TRUE & !is.na(emr_present) & reported_by %in% c("PEPFAR", "Both")]) / length(facilityuid[reported_by %in% c("PEPFAR", "Both")]),
      Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR = length(facilityuid[emr_present == TRUE & !is.na(emr_present) & reported_by == "Both"]) / length(facilityuid[reported_by == "Both"]),
      MOH_Results_Total = sum(moh[reported_by %in% c("Both", "MOH")], na.rm = TRUE),
      PEPFAR_Results_Total = sum(pepfar[reported_by %in% c("Both", "PEPFAR")], na.rm = TRUE),
      MOH_Results_FacilitiesReportedByBoth = sum(moh[reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedByBoth = sum(pepfar[reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedBy_PEPFAROnly = sum(pepfar[reported_by == "PEPFAR"], na.rm = TRUE),
      Concordance = sum(level3_concordance[reported_by == "Both"], na.rm = TRUE),
      ConcordanceOfFacilitiesWithEMR = sum(emr_concordance[reported_by == "Both" & emr_present == TRUE & !is.na(emr_present)], na.rm = TRUE),
      ConcordanceOfFacilitiesWithOutEMR = sum(emr_concordance[reported_by == "Both" & emr_present == FALSE & !is.na(emr_present)], na.rm = TRUE)
    ) |>
    dplyr::mutate(
      dplyr::across(
        c(MOH_Results_FacilitiesReportedByBoth,
          PEPFAR_Results_FacilitiesReportedByBoth,
          Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR,
          Concordance,
          ConcordanceOfFacilitiesWithEMR,
          ConcordanceOfFacilitiesWithOutEMR),
        ~ ifelse(CountOfFacilities_ReportedBy_Both == 0, NA, .x))) |>
    dplyr::mutate(
      dplyr::across(
        c(Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH,
          Pct_MOH_Facilities_SupportedBy_PEPFAR),
        ~ ifelse(CountOfFacilities_ReportedBy_PEPFAR == 0 | CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) |>
    dplyr::mutate(
      ConcordanceOfFacilitiesWithEMR = ifelse(Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR == 0, NA, ConcordanceOfFacilitiesWithEMR),
      ConcordanceOfFacilitiesWithOutEMR = ifelse(Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR == 1, NA, ConcordanceOfFacilitiesWithOutEMR)
    ) |>
    dplyr::mutate(
      dplyr::across(c(MOH_Results_Total,
               MOH_Results_FacilitiesReportedByBoth),
             ~ ifelse(CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) |>
    dplyr::mutate(
      dplyr::across(c(PEPFAR_Results_Total,
               PEPFAR_Results_FacilitiesReportedByBoth,
               Pct_PEPFAR_Facilities_WithEMR),
             ~ ifelse(CountOfFacilities_ReportedBy_PEPFAR == 0, NA, .x)))
  # nolint end
}
