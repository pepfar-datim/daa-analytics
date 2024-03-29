
#' @export
#' @title Adorn PVLS and EMR indicator data with metadata.
#'
#' @description
#' Takes in an unadorned dataframe of PVLS and EMR data in the format exported
#' by the `get_pvls_emr_table()` function and adorns it with all of the
#' appropriate metadata for Data Elements, Category Option Combos,
#' Organisation unit names and UIDs, Organisation unit hierarchy, and periods.
#' Users must provide either a valid aws_s3_bucket argument and have their
#' S3 credentials stored in an .Rprofile file or provide a cache folder where
#' all the appropriate metadata can be found.
#'
#' @inheritParams daa_analytics_params
#'
#' @return Dataframe containing adorned PVLS and EMR indicator data.
#'
#'
adorn_pvls_emr <- function(pvls_emr_raw = NULL,
                           coc_metadata = NULL,
                           de_metadata = NULL,
                           pe_metadata = NULL,
                           aws_s3_bucket = Sys.getenv("AWS_S3_BUCKET"),
                           cache_folder = NULL) {

  # Check that either all datasets or S3 bucket or cache folder was provided
  stopifnot(
    "ERROR: Must provide either all datasets or an S3 Bucket address or a cache folder!" =
      (!is.null(coc_metadata) && !is.null(de_metadata) && !is.null(pe_metadata)) ||
      aws_s3_bucket != "" || !missing(cache_folder))

  # Retrieve metadata from S3 or from cache if no direct file provided
  if (is.null(coc_metadata)) {
    coc_metadata <- get_s3_data(aws_s3_bucket = aws_s3_bucket,
                                dataset_name = "coc_metadata",
                                cache_folder = cache_folder)
  }
  if (is.null(de_metadata)) {
    de_metadata <- get_s3_data(aws_s3_bucket = aws_s3_bucket,
                               dataset_name = "de_metadata",
                               cache_folder = cache_folder)
  }
  if (is.null(pe_metadata)) {
    pe_metadata <- get_s3_data(aws_s3_bucket = aws_s3_bucket,
                               dataset_name = "pe_metadata",
                               cache_folder = cache_folder)
  }



  # Check if all metadata retrieve and throw an error if not available
  stopifnot(
    "ERROR: Could not retrieve category option combo metadata!" =
      !is.null(coc_metadata),
    "ERROR: Could not retrieve data element metadata!" =
      !is.null(de_metadata),
    "ERROR: Could not retrieve period metadata!" =
      !is.null(pe_metadata))

  pvls_emr <- pvls_emr_raw |>
    # Joins to period data and cleans and filters periods
    dplyr::left_join(pe_metadata, by = "periodid") |>

    # Filters for only Calendar Q3 / Fiscal Q4 results
    dplyr::filter(substring(iso, 5, 6) == "Q3") |>
    dplyr::mutate(period = as.numeric(substring(iso, 1, 4))) |>

    # Joins to Data Element, Category Option Combo, and Attribute Metadata
    dplyr::left_join(de_metadata, by = "dataelementid") |>
    dplyr::left_join(coc_metadata, by = "categoryoptioncomboid")|>
    # Drops a number of columns before continuing on
    dplyr::select(-iso, -periodid, -attributeoptioncomboid,
                  -dataelementid, -categoryoptioncomboid) |>

    # Cleans indicator names and pivots data
    dplyr::mutate(indicator = dplyr::case_when(
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - Care and Treatment" ~ "emr_tx",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - HIV Testing Services" ~ "emr_hts",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - ANC and/or Maternity" ~ "emr_anc",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - HIV/TB" ~ "emr_tb",
      TRUE ~ NA_character_
    )) |>

    # TODO Clean and bring categoryOptionCombos into the rest of the app
    dplyr::select(-dataelementname, -categoryoptioncomboname) |>
    tidyr::pivot_wider(names_from = indicator,
                       values_from = value,
                       values_fn = list(value = list)) |>
    dplyr::rowwise() |>
    dplyr::mutate(
      emr_TX_CURR = any(as.logical(unlist(emr_tx))),
      emr_TX_NEW = any(as.logical(unlist(emr_tx))),
      emr_HTS_TST = any(as.logical(unlist(emr_hts))),
      emr_PMTCT_STAT = any(as.logical(unlist(emr_anc))),
      emr_PMTCT_ART = any(as.logical(unlist(emr_anc))),
      emr_TB_PREV = any(as.logical(unlist(emr_tb))),
    ) |>
    dplyr::select(-emr_tx, -emr_hts,
                  -emr_anc, -emr_tb) |>

    dplyr::mutate_at(dplyr::vars(starts_with("emr_")), ~ifelse(is.na(.), FALSE, .)) |>

    # Pivots EMR data back to long data format and replaces NAs with FALSE
    tidyr::pivot_longer(cols = tidyr::starts_with("emr_"),
                        names_to = "indicator",
                        names_prefix = "emr_",
                        values_to = "emr_present") |>

    dplyr::mutate(
      indicator = dplyr::case_when(
      indicator == "TB_PREV" & period < 2020 ~ "TB_PREV_LEGACY",
      indicator == "TB_PREV" & period >= 2020 ~ "TB_PREV",
      TRUE ~ indicator
      )
    ) |>

    # Organizes columns for export
    dplyr::select(
      organisationunitid = sourceid, period, indicator,
      emr_present
    )

  pvls_emr
}
