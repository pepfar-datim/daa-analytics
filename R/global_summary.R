#' Prepare Global Summary Table of DAA Data
#'
#' @param combined_data The combined dataset of DAA data for processing into a
#' summary file.
#'
#' @return Summary table dataframe
#' @export
#'
global_summary <- function(combined_data) {
  df <-
    combined_data %>%
    dplyr::group_by(namelevel3, period, indicator) %>%
    dplyr::summarize(
      CountOfFacilities_ReportedBy_Both =
        length(.data$facilityuid[.data$reported_by == "Both"]),
      CountOfFacilities_ReportedBy_MOH =
        length(.data$facilityuid[.data$reported_by %in% c("Both", "MOH")]),
      CountOfFacilities_ReportedBy_PEPFAR =
        length(.data$facilityuid[.data$reported_by %in% c("Both", "PEPFAR")]),
      CountOfFacilities_ReportedBy_PEPFAROnly =
        length(.data$facilityuid[.data$reported_by == "PEPFAR"]),
      Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH =
        length(.data$facilityuid[.data$reported_by == "Both"]) /
        length(.data$facilityuid[.data$reported_by %in% c("Both", "PEPFAR")]),
      Pct_MOH_Facilities_SupportedBy_PEPFAR =
        length(.data$facilityuid[.data$reported_by == "Both"]) /
        length(.data$facilityuid[.data$reported_by %in% c("Both", "MOH")]),
      Pct_PEPFAR_Facilities_WithEMR =
        length(.data$facilityuid[.data$emr_present == TRUE &
                                   !is.na(.data$emr_present) &
                                   .data$reported_by %in% c("PEPFAR", "Both")]) /
        length(.data$facilityuid[.data$reported_by %in% c("PEPFAR", "Both")]),
      Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR =
        length(.data$facilityuid[.data$emr_present == TRUE &
                                   !is.na(.data$emr_present) &
                                   .data$reported_by == "Both"]) /
        length(.data$facilityuid[.data$reported_by == "Both"]),
      MOH_Results_Total =
        sum(.data$moh[.data$reported_by %in% c("Both", "MOH")], na.rm = TRUE),
      PEPFAR_Results_Total =
        sum(.data$pepfar[.data$reported_by %in% c("Both", "PEPFAR")], na.rm = TRUE),
      MOH_Results_FacilitiesReportedByBoth =
        sum(.data$moh[.data$reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedByBoth =
        sum(.data$pepfar[.data$reported_by == "Both"], na.rm = TRUE),
      PEPFAR_Results_FacilitiesReportedBy_PEPFAROnly =
        sum(.data$pepfar[.data$reported_by == "PEPFAR"], na.rm = TRUE),
      Concordance =
        sum(.data$level3_concordance[.data$reported_by == "Both"], na.rm = TRUE),
      ConcordanceOfFacilitiesWithEMR =
        sum(.data$emr_concordance[.data$reported_by == "Both" &
                                    .data$emr_present == TRUE &
                                    !is.na(.data$emr_present)], na.rm = TRUE),
      ConcordanceOfFacilitiesWithOutEMR =
        sum(.data$emr_concordance[.data$reported_by == "Both" &
                                    .data$emr_present == FALSE &
                                    !is.na(.data$emr_present)], na.rm = TRUE)
    ) %>%
    dplyr::mutate(
      across(c(.data$MOH_Results_FacilitiesReportedByBoth,
               .data$PEPFAR_Results_FacilitiesReportedByBoth,
               .data$Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR,
               .data$Concordance,
               .data$ConcordanceOfFacilitiesWithEMR,
               .data$ConcordanceOfFacilitiesWithOutEMR),
             ~ ifelse(.data$CountOfFacilities_ReportedBy_Both == 0, NA, .x))) %>%
    dplyr::mutate(
      across(c(.data$Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH,
               .data$Pct_MOH_Facilities_SupportedBy_PEPFAR),
             ~ ifelse(.data$CountOfFacilities_ReportedBy_PEPFAR == 0 |
                        .data$CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) %>%
    dplyr::mutate(
      ConcordanceOfFacilitiesWithEMR =
        ifelse(.data$Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR == 0,
               NA, .data$ConcordanceOfFacilitiesWithEMR),
      ConcordanceOfFacilitiesWithOutEMR =
        ifelse(.data$Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR == 1,
               NA, .data$ConcordanceOfFacilitiesWithOutEMR)
    ) %>%
    dplyr::mutate(
      across(c(.data$MOH_Results_Total,
               .data$MOH_Results_FacilitiesReportedByBoth),
             ~ ifelse(.data$CountOfFacilities_ReportedBy_MOH == 0, NA, .x))) %>%
    dplyr::mutate(
      across(c(.data$PEPFAR_Results_Total,
               .data$PEPFAR_Results_FacilitiesReportedByBoth,
               .data$Pct_PEPFAR_Facilities_WithEMR),
             ~ ifelse(.data$CountOfFacilities_ReportedBy_PEPFAR == 0, NA, .x)))

  return(df)
}
