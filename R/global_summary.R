#' Prepare Global Summary Table of DAA Data
#'
#' @inheritParams daa_analytics_params
#'
#' @return Summary table dataframe
#' @export
#'
global_summary <- function(combined_data) {
  #nolint start: line_length_linter
  combined_data |>
    dplyr::group_by(OU, period, indicator) |>
    dplyr::summarize(
      CountOfFacilities_ReportedBy_Both = length(Facility_UID[reported_by == "Both"]),
      CountOfFacilities_ReportedBy_MOH = length(Facility_UID[reported_by %in% c("Both", "MOH")]),
      CountOfFacilities_ReportedBy_PEPFAR = length(Facility_UID[reported_by %in% c("Both", "PEPFAR")]),
      CountOfFacilities_ReportedBy_PEPFAROnly = length(Facility_UID[reported_by == "PEPFAR"]),
      Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH = length(Facility_UID[reported_by == "Both"]) / length(Facility_UID[reported_by %in% c("Both", "PEPFAR")]),
      Pct_MOH_Facilities_SupportedBy_PEPFAR = length(Facility_UID[reported_by == "Both"]) / length(Facility_UID[reported_by %in% c("Both", "MOH")]),
      Pct_PEPFAR_Facilities_WithEMR = length(Facility_UID[emr_present == TRUE & !is.na(emr_present) & reported_by %in% c("PEPFAR", "Both")]) / length(Facility_UID[reported_by %in% c("PEPFAR", "Both")]),
      Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR = length(Facility_UID[emr_present == TRUE & !is.na(emr_present) & reported_by == "Both"]) / length(Facility_UID[reported_by == "Both"]),
      MOH_Results_Total = sum(moh[reported_by %in% c("Both", "MOH")], na.rm = TRUE),
      PEPFAR_Results_Total = sum(pepfar[reported_by %in% c("Both", "PEPFAR")], na.rm = TRUE),
      MOH_Results_FacilitiesReportedByBoth = sum(moh[reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedByBoth = sum(pepfar[reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedBy_PEPFAROnly = sum(pepfar[reported_by == "PEPFAR"], na.rm = TRUE),
      Concordance = sum(OU_Concordance[reported_by == "Both"], na.rm = TRUE),
      ConcordanceOfFacilitiesWithEMR = sum(EMR_Concordance[reported_by == "Both" & emr_present == TRUE & !is.na(emr_present)], na.rm = TRUE),
      ConcordanceOfFacilitiesWithOutEMR = sum(EMR_Concordance[reported_by == "Both" & emr_present == FALSE & !is.na(emr_present)], na.rm = TRUE)
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
