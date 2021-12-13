#' Adorn DAA Indicator Data with Weighted Metrics for All Levels
#'
#' @param daa_indicator_data Dataframe containing DAA indicator data.
#' @param ou_hierarchy Dataframe containing the Organisational hierarchy.
#'
#' @return A dataframe of DAA Indicator data with weightings and weighted
#' discordance and concordance calculated for levels 3 through 5.
#' @export
#'
adorn_weights <- function(daa_indicator_data = NULL,
                          ou_hierarchy = NULL,
                          pvls_emr = NULL,
                          adorn_level6 = FALSE,
                          adorn_emr = FALSE) {

  df <- daa_indicator_data %>%
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(ou_hierarchy %>%
                       dplyr::select(-.data$organisationunitid,
                                     -paste0("namelevel", 3:7)) %>%
                       unique(),
                     by = c("facilityuid"))

  misaligned_sites <- df %>%
    dplyr::filter(.data$reported_by != "Both")

  aligned_sites <- df %>%
    dplyr::filter(.data$reported_by == "Both") %>%

    # Calculates Level 3 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel3uid) %>%
    dplyr::mutate(level3_weighting = .data$pepfar / sum(.data$pepfar)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level3_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level3_weighting),
                  level3_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level3_weighting)
    ) %>%
    dplyr::ungroup() %>%

    # Calculates Level 4 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel4uid) %>%
    dplyr::mutate(level4_weighting = .data$pepfar / sum(.data$pepfar)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level4_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level4_weighting),
                  level4_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level4_weighting)
    )%>%
    dplyr::ungroup() %>%

    # Calculates Level 5 weighted concordance and discordance
    dplyr::group_by(.data$indicator,
                    .data$period,
                    .data$namelevel5uid) %>%
    dplyr::mutate(level5_weighting = .data$pepfar / sum(.data$pepfar)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(level5_discordance =
                    daa.analytics::weighted_discordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level5_weighting),
                  level5_concordance =
                    daa.analytics::weighted_concordance(
                      moh = .data$moh,
                      pepfar = .data$pepfar,
                      weighting = .data$level5_weighting)
    ) %>%
    dplyr::ungroup()

  if (adorn_level6 && any(!is.na(aligned_sites$namelevel7uid))) {
    aligned_sites %<>%
      # Calculates Level 6 weighted concordance and discordance
      dplyr::group_by(.data$indicator,
                      .data$period,
                      .data$namelevel6uid) %>%
      dplyr::mutate(level6_weighting = .data$pepfar / sum(.data$pepfar)) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(level6_discordance =
                      daa.analytics::weighted_discordance(
                        moh = .data$moh,
                        pepfar = .data$pepfar,
                        weighting = .data$level6_weighting),
                    level6_concordance =
                      daa.analytics::weighted_concordance(
                        moh = .data$moh,
                        pepfar = .data$pepfar,
                        weighting = .data$level6_weighting)
      ) %>%
      dplyr::ungroup()
  }

  if (adorn_emr) {
    # Clean pvls_emr and ou_hierarchy datasets to avoid
    # duplication of facilities with multiple organisationunitid numbers
    pvls_emr %<>%
      dplyr::left_join(ou_hierarchy %>%
                         dplyr::select(.data$organisationunitid,
                                       .data$facilityuid),
                       by = c("organisationunitid"),
                       keep = FALSE)

    aligned_sites %<>%
      # Joins PVLS and EMR datasets
      dplyr::left_join(pvls_emr,
                       by = c("facilityuid", "period", "indicator")) %>%
      # Calculates EMR weighted concordance and discordance
      dplyr::group_by(.data$indicator,
                      .data$period,
                      .data$emr_at_site_for_indicator) %>%
      dplyr::mutate(emr_weighting = .data$pepfar / sum(.data$pepfar)) %>%
      dplyr::rowwise() %>%
      dplyr::mutate(emr_discordance =
                      daa.analytics::weighted_discordance(
                        moh = .data$moh,
                        pepfar = .data$pepfar,
                        weighting = .data$emr_weighting),
                    emr_concordance =
                      daa.analytics::weighted_concordance(
                        moh = .data$moh,
                        pepfar = .data$pepfar,
                        weighting = .data$emr_weighting)
      ) %>%
      dplyr::ungroup()
  }

  df <-
    dplyr::bind_rows(misaligned_sites, aligned_sites) %>%
    # Selects rows for export
    dplyr::select(-dplyr::starts_with("namelevel"),
                  -.data$emr_at_site_for_indicator,
                  -dplyr::starts_with("tx_pvls"))

  return(df)
}

