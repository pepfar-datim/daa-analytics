# TODO redocument parameters on all of these functions
#' @export
#' @importFrom magrittr %>% %<>%
#' @title Fetch Raw PVLS and EMR Indicator Data.
#'
#' @description
#' Fetches raw PVLS and EMR indicator data from S3. This data is encoded and
#' must be combined with the appropriate metadata to be interpreted.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param last_update The datetime when the most recent file was created. Used
#' to validate whether new data needs to be retrieved from S3. If NULL, always
#' retrieves dataset from S3 regardless of last update time.
#' @param folder The folder extension where the output file should be saved. If
#' missing, saves to the `data` folder in the working directory.
#'
#' @return Dataframe containing raw PVLS and EMR data.
#'
get_pvls_emr_table <- function(s3,
                               aws_s3_bucket,
                               last_update = NULL,
                               folder = "data") {

  pvls_emr <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/moh_daa_data_value_emr_pvls",
      folder = folder,
      file_name = "pvls_emr_raw",
      last_update = last_update
    )

  return(pvls_emr)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetches Data Element Metadata
#'
#' @description
#' Fetches data element metadata from S3. Intended to be combined with
#' PVLS and EMR indicator data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param last_update The datetime when the most recent file was created. Used
#' to validate whether new data needs to be retrieved from S3. If NULL, always
#' retrieves dataset from S3 regardless of last update time.
#' @param folder The folder extension where the output file should be saved. If
#' missing, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Data Element IDs to DATIM codes.
#'
get_de_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = "data") {

  de_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/data_element",
      folder = folder,
      file_name = "de_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(.data$dataelementid, "dataelementname" = .data$shortname)

  return(de_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetch Category Option Combo Metadata
#'
#' @description
#' Fetches category option combo metadata from S3. Intended to be combined
#' with PVLS and EMR indicator data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param last_update The datetime when the most recent file was created. Used
#' to validate whether new data needs to be retrieved from S3. If NULL, always
#' retrieves dataset from S3 regardless of last update time.
#' @param folder The folder extension where the output file should be saved. If
#' missing, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Category Option Combo IDs to DATIM codes.
#'
get_coc_metadata <- function(s3,
                             aws_s3_bucket,
                             last_update = NULL,
                             folder = "data") {

  coc_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/category_option_combo",
      folder = folder,
      file_name = "coc_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(.data$categoryoptioncomboid,
                  categoryoptioncomboname = .data$name)

  return(coc_metadata)
}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetches Organsation Unit Metadata
#'
#' @description
#' Fetches organisation unit metadata from S3. Intended to be combined with
#' PVLS and EMR indicator data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param last_update The datetime when the most recent file was created. Used
#' to validate whether new data needs to be retrieved from S3. If NULL, always
#' retrieves dataset from S3 regardless of last update time.
#' @param folder The folder extension where the output file should be saved. If
#' missing, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Organisation Unit IDs to DATIM codes.
#'
get_ou_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = "data") {

  ou_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/organisation_unit",
      folder = folder,
      file_name = "ou_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(.data$organisationunitid, .data$path,
                  name = .data$shortname, .data$uid)

  return(ou_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Fetches Period Metadata
#'
#' @description
#' Fetches period metadata from S3. Intended to be combined with PVLS and EMR
#' indicator data.
#'
#' @param s3 The s3 object created by the paws package containing
#' user credentials.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param last_update The datetime when the most recent file was created. Used
#' to validate whether new data needs to be retrieved from S3. If NULL, always
#' retrieves dataset from S3 regardless of last update time.
#' @param folder The folder extension where the output file should be saved. If
#' missing, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Period IDs to DATIM codes.
#'
get_pe_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = "data") {

  pe_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/moh_daa_period_structure",
      folder = folder,
      file_name = "pe_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(.data$periodid, .data$iso)

  return(pe_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Generates Organisation Unit Hierarchy
#'
#' @description
#' Uses the Organisation unit metadata file to generate a wide datatable of the
#' organisation unit hierarchy from Level 3 to Level 7.
#'
#' @param ou_metadata Dataframe containing organisation unit metadata.
#'
#' @return Dataframe containing wide format organisation unit hierarchy from
#' Level 3 to Level 7.
#'
create_hierarchy <- function(ou_metadata) {

  ou_uid_names <- ou_metadata %>% dplyr::select(.data$uid, .data$name)

  # Cleans and creates OU Hierarchy from levels 3 to 7 with names
  ou_hierarchy <- ou_metadata %>%
    dplyr::select(.data$organisationunitid, .data$path) %>%
    tidyr::separate(col = .data$path,
                    into = c(rep(NA, 3), paste0("namelevel", 3:7, "uid"),
                             rep(NA, 2)), # Drops first three and last two cols
                    sep = "/",
                    fill = "right") %>%
    dplyr::filter(!is.na(.data$namelevel6uid)) %>%
    dplyr::mutate(facilityuid = ifelse(is.na(.data$namelevel7uid),
                                       .data$namelevel6uid,
                                       .data$namelevel7uid)) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel3 = .data$name),
                     by = c("namelevel3uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel4 = .data$name),
                     by = c("namelevel4uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel5 = .data$name),
                     by = c("namelevel5uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel6 = .data$name),
                     by = c("namelevel6uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel7 = .data$name),
                     by = c("namelevel7uid" = "uid"), keep = FALSE) %>%
    dplyr::select(.data$organisationunitid,
                  .data$facilityuid,
                  paste0("namelevel", 3:7))

  return(ou_hierarchy)
}


#' @export
#' @importFrom magrittr %>% %<>%
#' @importFrom rlang .data
#' @title Adorn PVLS and EMR indicator data with metadata.
#'
#' @description
#' Takes in an unadorned dataframe of PVLS and EMR data in the format exported
#' by the `get_pvls_emr_table()` function and adorns it with all of the
#' appropriate metadata for Data Elements, Category Option Combos,
#' Organisation unit names and UIDs, Organisation unit hierarchy, and periods.
#'
#' @param pvls_emr Unadorned dataframe of PVLS and EMR indicator data.
#' @param coc_metadata Dataframe containing category option combination
#' metadata.
#' @param de_metadata Dataframe containing data element metadata.
#' @param pe_metadata Dataframe containing period metadata.
#'
#' @return Dataframe containing adorned PVLS and EMR indicator data.
#'
adorn_pvls_emr <- function(pvls_emr, coc_metadata, de_metadata, pe_metadata) {

  pvls_emr %<>%
    # Joins to period data and cleans and filters periods
    dplyr::left_join(pe_metadata, by = "periodid") %>%

    # Filters for only Calendar Q3 / Fiscal Q4 results
    dplyr::filter(substring(.data$iso, 5, 6) == "Q3") %>%
    dplyr::mutate(period = as.numeric(substring(.data$iso, 1, 4))) %>%

    # Joins to Data Element, Category Option Combo, and Attribute Metadata
    dplyr::left_join(de_metadata, by = "dataelementid") %>%
    dplyr::left_join(coc_metadata, by = "categoryoptioncomboid") %>%
    # dplyr::left_join(coc_metadata %>%
    #                    dplyr::select(.data$categoryoptioncomboid,
    #                                  attributename =
    #                                    .data$categoryoptioncomboname),
    #                  by = c("attributeoptioncomboid" =
    #                           "categoryoptioncomboid")) %>%

    # Drops a number of columns before continuing on
    dplyr::select(-.data$iso, -.data$periodid, -.data$attributeoptioncomboid,
                  -.data$dataelementid, -.data$categoryoptioncomboid) %>%

    # Cleans indicator names and pivots data
    dplyr::mutate(indicator = dplyr::case_when(
      .data$dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        .data$categoryoptioncomboname ==
        "Service Delivery Area - Care and Treatment" ~ "emr_tx",
      .data$dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        .data$categoryoptioncomboname ==
        "Service Delivery Area - HIV Testing Services" ~ "emr_hts",
      .data$dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        .data$categoryoptioncomboname ==
        "Service Delivery Area - ANC and/or Maternity" ~ "emr_anc",
      .data$dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        .data$categoryoptioncomboname ==
        "Service Delivery Area - Early Infant Diagnosis (not Ped ART)" ~
        "emr_eid",
      .data$dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        .data$categoryoptioncomboname ==
        "Service Delivery Area - HIV/TB" ~ "emr_tb",
      substring(.data$dataelementname, 1, 10) == "TX_PVLS (N" ~ "tx_pvls_n",
      substring(.data$dataelementname, 1, 10) == "TX_PVLS (D" ~ "tx_pvls_d",
      TRUE ~ NA_character_
    )) %>%

    # TODO Clean and bring categoryOptionCombos into the rest of the app
    dplyr::select(-.data$dataelementname, -.data$categoryoptioncomboname) %>%
    tidyr::pivot_wider(names_from = .data$indicator,
                       values_from = .data$value,
                       values_fn = list(value = list)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      emr_tx = any(as.logical(unlist(.data$emr_tx))),
      emr_hts = any(as.logical(unlist(.data$emr_hts))),
      emr_anc = any(as.logical(unlist(.data$emr_anc))),
      emr_eid = any(as.logical(unlist(.data$emr_eid))),
      emr_tb = any(as.logical(unlist(.data$emr_tb))),
      tx_pvls_n = sum(as.numeric(unlist(.data$tx_pvls_n))),
      tx_pvls_d = sum(as.numeric(unlist(.data$tx_pvls_d)))
    ) %>%

    # Organizes columns for export
    dplyr::select(
      organisationunitid = .data$sourceid, .data$period,
      .data$emr_hts, .data$emr_tx, .data$emr_anc, .data$emr_eid, .data$emr_tb,
      .data$tx_pvls_n, .data$tx_pvls_d
    )

  return(pvls_emr)
}

# pvls_emr_timestamp <- function() {
#   file_name <- "data.csv.gz"
#
#   s3_bucket <- base::getOption("s3_bucket")
#   s3_ext <- base::getOption("s3_ext")
#   bucket_ext <- paste0(s3_bucket, s3_ext)
#
#   tm <- aws.s3::get_bucket_df(s3_bucket) %>%
#     dplyr::filter(Key == paste0(s3_ext,
#                                 "moh_daa_data_value_emr_pvls/",
#                                 file_name)) %>%
#     dplyr::select("LastModified") %>%
#     .[[1]] %>%
#     lubridate::parse_date_time("YmdHMS") %>%
#     as.POSIXct() %>%
#     format(tz = "UTC", usetz = TRUE)
#
#   return(tm)
# }
