#' Adorn DAA Indicator Data with Weighted Metrics for All Levels
#'
#' @param daa_indicator_data Dataframe containing DAA indicator data.
#' @param ou_hierarchy Dataframe containing the Organisational hierarchy.
#' @param pvls_emr Dataframe containing TX_PVLS and EMR data. Only needed if
#' \code{adorn_emr} is TRUE.
#' @param adorn_level6 Boolean indicating whether to adorn weights for
#' SNU level 6 for countries with facilities at level 7.
#' @param adorn_emr Boolean indicating whether to adorn weights based
#' on whether EMR is or is not present at a site.
#'
#' @return A dataframe of DAA Indicator data with weightings and weighted
#' concordance calculated for levels 3 through 5.
#' @export
#'
adorn_weights <- function(daa_indicator_data = NULL,
                          ou_hierarchy = NULL,
                          pvls_emr = NULL,
                          adorn_level6 = FALSE,
                          adorn_emr = FALSE) {

  df <- daa_indicator_data |>
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(unique(dplyr::select(ou_hierarchy, facilityuid, paste0("namelevel", 3:7, "uid"))),
                     by = c("facilityuid"))

  misaligned_sites <- dplyr::filter(df, reported_by != "Both")

  aligned_sites <- dplyr::filter(df, reported_by == "Both") |>

    # Calculates Level 3 weighted concordance
    dplyr::group_by(indicator,
                    period,
                    namelevel3uid) |>
    dplyr::mutate(level3_weighting = pepfar / sum(pepfar)) |>
    dplyr::rowwise() |>
    dplyr::mutate(level3_concordance =
                    daa.analytics::weighted_concordance(
                      moh = moh,
                      pepfar = pepfar,
                      weighting = level3_weighting)
    ) |>
    dplyr::ungroup() |>

    # Calculates Level 4 weighted concordance
    dplyr::group_by(indicator,
                    period,
                    namelevel4uid) |>
    dplyr::mutate(level4_weighting = pepfar / sum(pepfar)) |>
    dplyr::rowwise() |>
    dplyr::mutate(level4_concordance =
                    daa.analytics::weighted_concordance(
                      moh = moh,
                      pepfar = pepfar,
                      weighting = level4_weighting)
    ) |>
    dplyr::ungroup() |>

    # Calculates Level 5 weighted concordance
    dplyr::group_by(indicator,
                    period,
                    namelevel5uid) |>
    dplyr::mutate(level5_weighting = pepfar / sum(pepfar)) |>
    dplyr::rowwise() |>
    dplyr::mutate(level5_concordance =
                    daa.analytics::weighted_concordance(
                      moh = moh,
                      pepfar = pepfar,
                      weighting = level5_weighting)
    ) |>
    dplyr::ungroup()

  if (adorn_level6 && any(!is.na(aligned_sites$namelevel7uid))) {
    aligned_sites <-
      # Calculates Level 6 weighted concordance
      dplyr::group_by(aligned_sites,
                      indicator,
                      period,
                      namelevel6uid) |>
      dplyr::mutate(level6_weighting = pepfar / sum(pepfar)) |>
      dplyr::rowwise() |>
      dplyr::mutate(level6_concordance =
                      daa.analytics::weighted_concordance(
                        moh = moh,
                        pepfar = pepfar,
                        weighting = level6_weighting)
      ) |>
      dplyr::ungroup()
  }

  if (adorn_emr) {
    # Clean pvls_emr and ou_hierarchy datasets to avoid
    # duplication of facilities with multiple organisationunitid numbers
    pvls_emr <-
      dplyr::left_join(pvls_emr,
                       dplyr::select(ou_hierarchy, organisationunitid, facilityuid),
                       by = c("organisationunitid"),
                       keep = FALSE) |>
      dplyr::select(-organisationunitid)

    aligned_sites <-
      aligned_sites |>
      # Joins PVLS and EMR datasets
      dplyr::left_join(pvls_emr,
                       by = c("facilityuid", "period", "indicator")) |>
      # Calculates EMR weighted concordance
      dplyr::group_by(indicator,
                      period,
                      namelevel3uid,
                      emr_present) |>
      dplyr::mutate(emr_weighting = pepfar / sum(pepfar)) |>
      dplyr::rowwise() |>
      dplyr::mutate(emr_concordance =
                      daa.analytics::weighted_concordance(
                        moh = moh,
                        pepfar = pepfar,
                        weighting = emr_weighting)
      ) |>
      dplyr::ungroup()
  }

  df <-
    dplyr::bind_rows(misaligned_sites, aligned_sites) |>
    # Selects rows for export
    dplyr::select(-dplyr::starts_with("namelevel"),
                  -emr_present,
                  -dplyr::starts_with("tx_pvls"))

  df
}
