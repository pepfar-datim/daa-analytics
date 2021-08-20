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
#' NULL, saves to the `data` folder in the working directory.
#'
#' @return Dataframe containing raw PVLS and EMR data.
#'
get_pvls_emr_table <- function(s3,
                               aws_s3_bucket,
                               last_update = NULL,
                               folder = NULL) {

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
#' NULL, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Data Element IDs to DATIM codes.
#'
get_de_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = NULL) {

  de_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/data_element",
      folder = folder,
      file_name = "de_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(dataelementid, "dataelementname" = shortname)

  return(de_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
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
#' NULL, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Category Option Combo IDs to DATIM codes.
#'
get_coc_metadata <- function(s3,
                             aws_s3_bucket,
                             last_update = NULL,
                             folder = NULL) {

  coc_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/category_option_combo",
      folder = folder,
      file_name = "coc_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(categoryoptioncomboid, categoryoptioncomboname = name)

  return(coc_metadata)
}

#' @export
#' @importFrom magrittr %>% %<>%
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
#' NULL, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Organisation Unit IDs to DATIM codes.
#'
get_ou_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = NULL) {

  ou_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/organisation_unit",
      folder = folder,
      file_name = "ou_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(organisationunitid, path, name = shortname, uid)

  return(ou_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
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
#' NULL, saves to the `data` folder in the working directory.
#'
#' @return Datatable relating Period IDs to DATIM codes.
#'
get_pe_metadata <- function(s3,
                            aws_s3_bucket,
                            last_update = NULL,
                            folder = NULL) {

  pe_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      aws_s3_bucket = aws_s3_bucket,
      key = "datim/www.datim.org/moh_daa_period_structure",
      folder = folder,
      file_name = "pe_metadata",
      last_update = last_update
    ) %>%
    dplyr::select(periodid, iso)

  return(pe_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
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

  ou_uid_names <- ou_metadata %>% dplyr::select(uid, name)

  # Cleans and creates OU Hierarchy from levels 3 to 7 with names
  ou_hierarchy <- ou_metadata %>%
    dplyr::select(organisationunitid, path) %>%
    tidyr::separate(col = path,
                    into = c(rep(NA, 3), paste0("namelevel", 3:7, "uid"),
                             rep(NA, 2)), # Drops first three and last two cols
                    sep = "/",
                    fill = "right") %>%
    dplyr::filter(!is.na(namelevel6uid)) %>%
    dplyr::mutate(facilityuid = ifelse(is.na(namelevel7uid),
                                       namelevel6uid, namelevel7uid)) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel3 = name),
                     by = c("namelevel3uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel4 = name),
                     by = c("namelevel4uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel5 = name),
                     by = c("namelevel5uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel6 = name),
                     by = c("namelevel6uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel7 = name),
                     by = c("namelevel7uid" = "uid"), keep = FALSE) %>%
    dplyr::select(organisationunitid, facilityuid, paste0("namelevel", 3:7))

  return(ou_hierarchy)
}


#' @export
#' @importFrom magrittr %>% %<>%
#' @title Adorn PVLS and EMR indicator data with metadata.
#'
#' @description
#' Takes in an unadorned dataframe of PVLS and EMR data in the format exported
#' by the `get_pvls_emr_table()` function and adorns it with all of the
#' appropriate metadata for Data Elements, Category Option Combos,
#' Organisation unit names and UIDs, Organisation unit hierarchy, and periods.
#'
#' @param pvls_emr Unadorned dataframe of PVLS and EMR indicator data.
#' @param coc_metadata Dataframe containing category option combination metadata.
#' @param de_metadata Dataframe containing data element metadata.
#' @param pe_metadata Dataframe containing period metadata.
#'
#' @return Dataframe containing adorned PVLS and EMR indicator data.
#'
adorn_pvls_emr <- function(pvls_emr, coc_metadata, de_metadata, pe_metadata) {

  pvls_emr %<>%
    # Joins to period data and cleans and filters periods
    dplyr::left_join(., pe_metadata, by = "periodid") %>%

    # Filters for only Calendar Q3 / Fiscal Q4 results
    dplyr::filter(substring(iso, 5, 6) == "Q3") %>%
    dplyr::mutate(Period = as.numeric(substring(iso, 1, 4))) %>%

    # Joins to Data Element, Category Option Combo, and Attribute Metadata
    dplyr::left_join(., de_metadata, by = "dataelementid") %>%
    dplyr::left_join(., coc_metadata, by = "categoryoptioncomboid") %>%
    # dplyr::left_join(.,
    #                  coc_metadata %>%
    #                    dplyr::select(categoryoptioncomboid,
    #                                  attributename = categoryoptioncomboname),
    #                  by = c("attributeoptioncomboid" =
    #                           "categoryoptioncomboid")) %>%

    # Drops a number of columns before continuing on
    dplyr::select(-dataelementid, -periodid,
                  -categoryoptioncomboid, -attributeoptioncomboid, -iso) %>%

    # Cleans indicator names and pivots data
    dplyr::mutate(indicator = dplyr::case_when(
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - Care and Treatment" ~ "EMR_TX",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - HIV Testing Services" ~ "EMR_HTS",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - ANC and/or Maternity" ~ "EMR_ANC",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - Early Infant Diagnosis (not Ped ART)" ~
        "EMR_EID",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname == "Service Delivery Area - HIV/TB" ~ "EMR_TB",
      substring(dataelementname, 1, 10) == "TX_PVLS (N" ~ "TX_PVLS_N",
      substring(dataelementname, 1, 10) == "TX_PVLS (D" ~ "TX_PVLS_D",
      TRUE ~ NA_character_
    )) %>%

    # TODO Clean and bring categoryOptionCombos into the rest of the app
    dplyr::select(-dataelementname, -categoryoptioncomboname) %>%
    tidyr::pivot_wider(.,
                       names_from = indicator,
                       values_from = value,
                       values_fn = list(value = list)) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      EMR_TX = any(as.logical(unlist(EMR_TX))),
      EMR_HTS = any(as.logical(unlist(EMR_HTS))),
      EMR_ANC = any(as.logical(unlist(EMR_ANC))),
      EMR_EID = any(as.logical(unlist(EMR_EID))),
      EMR_TB = any(as.logical(unlist(EMR_TB))),
      TX_PVLS_N = sum(as.numeric(unlist(TX_PVLS_N))),
      TX_PVLS_D = sum(as.numeric(unlist(TX_PVLS_D)))
    ) %>%

    # Organizes columns for export
    dplyr::select(
      organisationunitid = sourceid, Period,
      EMR_HTS, EMR_TX, EMR_ANC, EMR_EID, EMR_TB,
      TX_PVLS_N,TX_PVLS_D
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
#     lubridate::parse_date_time(., "YmdHMS") %>%
#     as.POSIXct(.) %>%
#     format(., tz = "UTC", usetz = TRUE)
#
#   return(tm)
# }
