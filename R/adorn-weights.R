#' @export
#' @title Calculate Weighted Concordance.
#'
#' @description
#' Calculates the weighted concordance for a given site using the total
#' number of patients reported by the MOH and PEPFAR as well as the
#' weighting factor.
#'
#' @inheritParams daa_analytics_params
#'
#' @return A single value for the weighted concordance of the site.
#'
weighted_concordance <- function(df, weighting_name, grouping_columns) {
  df <- df |>
    dplyr::group_by(indicator, period, !!!rlang::syms(grouping_columns)) |>
    dplyr::mutate("{weighting_name}" :=
                    (pepfar / sum(pepfar)) * # Multiplies the weighting factor...
                    (((moh + pepfar) - abs(moh - pepfar)) /
                       (moh + pepfar))) |> # by the concordance value
    dplyr::ungroup()

  if(weighting_name == "OU_Concordance"){
    df <- df |>
      dplyr::group_by(indicator, period, !!!rlang::syms(grouping_columns)) |>
      dplyr::mutate(OU_weighting :=
                      (pepfar / sum(pepfar))) |>  # Multiplies the weighting factor...

      dplyr::ungroup()
  }

  df

}



#' Adorn DAA Indicator Data with Weighted Metrics for All Levels
#'
#' @inheritParams daa_analytics_params
#'
#' @return A dataframe of DAA Indicator data with weightings and weighted
#' concordance calculated fo all requested levels.
#' @export
#'
adorn_weights <- function(daa_indicator_data = NULL, ou_hierarchy,
                          weights_list = c("OU", "SNU1", "SNU2"), pvls_emr = NULL) {

  # Creates reference table for looking up which columns to group by
  group_ref <- rbind(
    data.frame(ref = "OU", col = c("OU")),
    data.frame(ref = "SNU1", col = c("OU", "SNU1")),
    data.frame(ref = "SNU2", col = c("OU", "SNU1", "SNU2")),
    data.frame(ref = "SNU3", col = c("OU", "SNU1", "SNU2", "SNU3")),
    data.frame(ref = "EMR", col = c("OU","EMR"))
  )

  daa_indicator_data <- daa_indicator_data |>
    # Joins DAA Indicator data to OU hierarchy metadata
    dplyr::left_join(ou_hierarchy |>
                       dplyr::select(-organisationunitid) |>
                       unique(),
                     by = c("Facility_UID"))

  misaligned_sites <- dplyr::filter(daa_indicator_data, reported_by != "Both")

  aligned_sites <- dplyr::filter(daa_indicator_data, reported_by == "Both")

  #check whether weight_list has EMR or not

  adorn_emr <- "EMR"%in%weights_list

  if (adorn_emr) {

    stopifnot("If EMR option is provided, pvls_emr should not be NULL!" =
                !is.null(pvls_emr))
    # Clean pvls_emr and ou_hierarchy datasets to avoid
    # duplication of facilities with multiple organisationunitid numbers

    pvls_emr <- pvls_emr |>
      dplyr::left_join(ou_hierarchy |>
                         dplyr::select(organisationunitid,
                                       Facility_UID),
                       by = c("organisationunitid"),
                       keep = FALSE) |>
                      dplyr::mutate(EMR = ifelse(is.na(emr_present), FALSE, emr_present))

    aligned_sites <- aligned_sites |>
      # Joins PVLS and EMR datasets
      dplyr::left_join(pvls_emr,
                       by = c("Facility_UID", "period", "indicator")) |>
      dplyr::select(-dplyr::starts_with("tx_pvls"), -emr_present, -organisationunitid)

  }

  for (x in weights_list) {
    aligned_sites <-
      weighted_concordance(df = aligned_sites,
                           weighting_name = paste0(x, "_Concordance"),
                           grouping_columns = group_ref[group_ref$ref == x, ][["col"]])
  }


  df <- dplyr::bind_rows(aligned_sites, misaligned_sites)

  df
}
