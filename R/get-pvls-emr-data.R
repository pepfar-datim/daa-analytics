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
#'
#' @return Dataframe containing raw PVLS and EMR data.
#'
get_pvls_emr_table <- function(s3, aws_s3_bucket) {

  pvls_emr <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      Bucket = aws_s3_bucket,
      Key_1 = "datim/www.datim.org/",
      Key_2 = "moh_daa_data_value_emr_pvls"
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
#'
#' @return Datatable relating Data Element IDs to DATIM codes.
#'
getDEMetadata <- function(s3, aws_s3_bucket) {

  de_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      Bucket = aws_s3_bucket,
      Key_1 = "datim/www.datim.org/",
      Key_2 = "data_element"
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
#'
#' @return Datatable relating Category Option Combo IDs to DATIM codes.
#'
getCOCMetadata <- function(s3, aws_s3_bucket) {

  coc_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      Bucket = aws_s3_bucket,
      Key_1 = "datim/www.datim.org/",
      Key_2 = "category_option_combo"
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
#'
#' @return Datatable relating Organisation Unit IDs to DATIM codes.
#'
getOUMetadata <- function(s3, aws_s3_bucket) {

  ou_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      Bucket = aws_s3_bucket,
      Key_1 = "datim/www.datim.org/",
      Key_2 = "organisation_unit"
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
#'
#' @return Datatable relating Period IDs to DATIM codes.
#'
getDAAPEMetadata <- function(s3, aws_s3_bucket) {

  daa_pe_metadata <-
    daa.analytics::fetch_s3_files(
      s3 = s3,
      Bucket = aws_s3_bucket,
      Key_1 = "datim/www.datim.org/",
      Key_2 = "moh_daa_period_structure"
    ) %>%
    dplyr::select(periodid, iso)

  return(daa_pe_metadata)

}

#' @export
#' @importFrom magrittr %>% %<>%
#' @title Generates Organisation Unit Hierarchy
#'
#' @description
#' Uses the Organisation unit metadata file to generate a wide datatable of the
#' organisation unit hierarchy from Level 3 to Level 7.
#'
#' @return Dataframe containing wide format organisation unit hierarchy from
#' Level 3 to Level 7.
#'
createHierarchy <- function() {

  # TODO add error catching ability when this data is unavailable.
  load(file = "data/ou_metadata.rda")

  ou_uid_names <- ou_metadata %>% dplyr::select(uid, name)

  # Cleans and creates OU Hierarchy from levels 3 to 7 with names
  ou_hierarchy <- ou_metadata %>%
    tidyr::separate(.,
                    col = path,
                    into = paste0("namelevel", 0:9, "uid"),
                    sep = "/") %>%
    dplyr::left_join(.,
                     ou_uid_names %>%
                       dplyr::select(uid, namelevel3 = name),
                     by = c("namelevel3uid" = "uid")) %>%
    dplyr::left_join(.,
                     ou_uid_names %>%
                       dplyr::select(uid, namelevel4 = name),
                     by = c("namelevel4uid" = "uid")) %>%
    dplyr::left_join(.,
                     ou_uid_names %>%
                       dplyr::select(uid, namelevel5 = name),
                     by = c("namelevel5uid" = "uid")) %>%
    dplyr::left_join(.,
                     ou_uid_names %>%
                       dplyr::select(uid, namelevel6 = name),
                     by = c("namelevel6uid" = "uid")) %>%
    dplyr::left_join(.,
                     ou_uid_names %>%
                       dplyr::select(uid, namelevel7 = name),
                     by = c("namelevel7uid" = "uid")) %>%
    dplyr::select(organisationunitid,
                  namelevel6uid, namelevel7uid,
                  paste0("namelevel", 3:7)) %>%
    dplyr::filter(!is.na(namelevel6uid)) %>%
    dplyr::mutate(facilityuid = ifelse(is.na(namelevel7uid),
                                       namelevel6uid, namelevel7uid)) %>%
    dplyr::mutate("Site hierarchy" = paste0(paste(namelevel3, namelevel4,
                                                  namelevel5, namelevel6,
                                                  sep = " / "),
                                            ifelse(is.na(namelevel7), "",
                                                   paste0("/", namelevel7)))) %>%
    dplyr::select(organisationunitid, facilityuid, namelevel3, namelevel4,
                  namelevel5, namelevel6, namelevel7, `Site hierarchy`)

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
#'
#' @return Dataframe containing adorned PVLS and EMR indicator data.
#'
adorn_pvls_emr <- function(pvls_emr) {

  # TODO add error catching ability when this data is unavailable.
  load("data/de_metadata.rda")
  load("data/coc_metadata.rda")
  load("data/ou_metadata.rda")
  load("data/ou_hierarchy.rda")
  load("data/daa_pe_metadata.rda")

  pvls_emr %<>%
    # Joins to period data and cleans and filters periods
    dplyr::left_join(., daa_pe_metadata, by = "periodid") %>%

    # Filters for only Calendar Q3 / Fiscal Q4 results
    dplyr::filter(substring(iso, 5, 6) == "Q3") %>%
    dplyr::mutate(period = as.numeric(substring(iso, 1, 4))) %>%

    # Joins to Data Element, Category Option Combo, and Attribute Metadata
    dplyr::left_join(., de_metadata, by = "dataelementid") %>%
    dplyr::left_join(., coc_metadata, by = "categoryoptioncomboid") %>%
    # dplyr::left_join(.,
    #                  coc_metadata %>%
    #                    dplyr::select(categoryoptioncomboid,
    #                                  attributename = coc_name),
    #                  by = c("attributeoptioncomboid" =
    #                           "categoryoptioncomboid")) %>%

    # Drops a number of columns before continuing on
    dplyr::select(-dataelementid, -periodid,
                  -categoryoptioncomboid, -attributeoptioncomboid, -iso) %>%

    # Cleans indicator names and pivots data
    dplyr::mutate(indicator = dplyr::case_when(
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - Care and Treatment" ~
        "EMR - Care and Treatment",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - HIV Testing Services" ~
        "EMR - HIV Testing Services",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - ANC and/or Maternity" ~
        "EMR - ANC and/or Maternity",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname ==
        "Service Delivery Area - Early Infant Diagnosis (not Ped ART)" ~
        "EMR - EID",
      dataelementname == "EMR_SITE (N, NoApp, Serv Del Area)" &
        categoryoptioncomboname == "Service Delivery Area - HIV/TB" ~
        "EMR - HIV/TB",
      substring(dataelementname, 1, 10) == "TX_PVLS (N" ~ "TX_PVLS_N",
      substring(dataelementname, 1, 10) == "TX_PVLS (D" ~ "TX_PVLS_D",
      TRUE ~ NA_character_
    )) %>%

    # TODO Clean and bring categoryOptionCombos into the rest of the app
    dplyr::select(-dataelementname, -categoryoptioncomboname) %>%
    tidyr::pivot_wider(.,
                       names_from = indicator,
                       values_from = value,
                       values_fn = list) %>%
    dplyr::rowwise() %>%
    dplyr::mutate(
      `EMR - Care and Treatment` =
        any(as.logical(unlist(`EMR - Care and Treatment`))),
      `EMR - HIV Testing Services` =
        any(as.logical(unlist(`EMR - HIV Testing Services`))),
      `EMR - ANC and/or Maternity` =
        any(as.logical(unlist(`EMR - ANC and/or Maternity`))),
      `EMR - EID` =
        any(as.logical(unlist(`EMR - EID`))),
      `EMR - HIV/TB` =
        any(as.logical(unlist(`EMR - HIV/TB`))),
      TX_PVLS_N = sum(as.numeric(unlist(TX_PVLS_N))),
      TX_PVLS_D = sum(as.numeric(unlist(TX_PVLS_D)))
    ) %>%

    # Joins to Organizational hierarchy data
    dplyr::left_join(., ou_hierarchy,
                     by = c("sourceid" = "organisationunitid")) %>%

    # Organizes columns for export
    dplyr::select(
      facilityuid,
      starts_with("namelevel"),
      `Site hierarchy`,
      period,
      `EMR - HIV Testing Services`,
      `EMR - Care and Treatment`,
      `EMR - ANC and/or Maternity`,
      `EMR - EID`,
      `EMR - HIV/TB`,
      TX_PVLS_N,
      TX_PVLS_D,
      -sourceid
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
