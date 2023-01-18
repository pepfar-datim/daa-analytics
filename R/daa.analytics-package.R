#' @keywords internal
"_PACKAGE"

utils::globalVariables(
  c("Concordance",
    "ConcordanceOfFacilitiesWithEMR",
    "ConcordanceOfFacilitiesWithOutEMR",
    "Country",
    "CountryCode",
    "CountryName",
    "MOH_Results_FacilitiesReportedByBoth",
    "MOH_Results_Total",
    "PEPFAR_Results_FacilitiesReportedByBoth",
    "PEPFAR_Results_Total",
    "Pct_MOH_Facilities_SupportedBy_PEPFAR",
    "Pct_PEPFAR_Facilities_ReportedBy_Both_WithEMR",
    "Pct_PEPFAR_Facilities_WithEMR",
    "Pct_PEPFAR_Reported_Facilities_ReportedBy_MOH",
    "attribute.name",
    "attribute_option_combo",
    "attributeoptioncomboid",
    "categoryoptioncomboid",
    "categoryoptioncomboname",
    "coc_name",
    "code",
    "country_name",
    "dataelementid",
    "dataelementname",
    "emr_anc",
    "emr_concordance",
    "emr_hts",
    "emr_present",
    "emr_tb",
    "emr_tx",
    "emr_weighting",
    "facility",
    "facilityuid",
    "generated",
    "geometry.coordinates",
    "geometry.type",
    "hasDisagMapping",
    "hasResultsData",
    "has_disag_mapping",
    "has_results_data",
    "id",
    "indicator",
    "iso",
    "latitude",
    "level3_concordance",
    "level3_weighting",
    "level4_weighting",
    "level5_weighting",
    "level6_weighting",
    "longitude",
    "moh",
    "moh_id",
    "name",
    "namelevel3",
    "namelevel3uid",
    "namelevel4",
    "namelevel4uid",
    "namelevel5",
    "namelevel5uid",
    "namelevel6",
    "namelevel6uid",
    "namelevel7",
    "namelevel7uid",
    "org_unit",
    "organisationunitid",
    "path",
    "pepfar",
    "period",
    "periodid",
    "reported_by",
    "sourceid",
    "tx_pvls_d",
    "tx_pvls_n",
    "uid",
    "value")
)

#' @title Standardized package function parameter definitions
#'
#' @param aggregate_indicators Indicates whether indicators should be rolled up
#' across "Age" and "Age Aggregate" data elements. Also will filter out
#' certain data elements from 2017 and 2018 that would cause duplication.
#' @param aws_s3_bucket The URL for the particular bucket being accessed.
#' @param cache_path Path to the cached file to be checked.
#' @param coc_metadata Dataframe containing category option combination
#' metadata.
#' @param combined_data Dataframe containing adorned DAA indicator data combined with PVLS & EMR data.
#' @param d2_session R6 session object.
#' @param daa_indicator_data Dataframe containing DAA indicator data.
#' @param dataset_name The name of the dataset to be returned from S3.
#' @param de_metadata Dataframe containing data element metadata.
#' @param df Dataframe containing data to be adorned.
#' @param fiscal_year List of fiscal years starting in October to be included.
#' @param geo_session R6 session object specifically for a DHIS2 GeoAlign session.
#' @param grouping_columns A list of columns on which weighting
#' groups should be based.
#' @param include_coc Boolean indicating whether Category Option Combo data
#' should be kept or removed from returned dataset.
#' @param max_cache_age Maximum age at which the cache is considered "fresh".
#' @param ou_hierarchy Dataframe containing DATIM organisation unit hierarchy.
#' @param ou_metadata Dataframe containing organisation unit metadata.
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#' @param pe_metadata Dataframe containing period metadata.
#' @param pvls_emr Dataframe of PVLS and EMR data joined with metadata.
#' @param pvls_emr_raw Unadorned dataframe of PVLS and EMR indicator data.
#' @param weighting_name Name to be given to weighting column.
#' @param weights_list A list containing the levels at which concordance
#' metrics should be calculated. `OU` level is the default, calculating
#' sites as a share of the overall country. SNU levels 1-3 are supported,
#' as well as `EMR`, which groups by whether or not a facility has an EMR.
#' @param ... Additional arguments to pass.
#'
#' @family parameter-helpers
#'
#' @return list of all parameters of this constructor function
daa_analytics_params <- function(aggregate_indicators,
                                 aws_s3_bucket,
                                 cache_path,
                                 coc_metadata,
                                 combined_data,
                                 d2_session,
                                 daa_indicator_data,
                                 dataset_name,
                                 de_metadata,
                                 df,
                                 fiscal_year,
                                 geo_session,
                                 grouping_columns,
                                 include_coc,
                                 max_cache_age,
                                 ou_hierarchy,
                                 ou_metadata,
                                 ou_uid,
                                 pe_metadata,
                                 pvls_emr,
                                 pvls_emr_raw,
                                 weighting_name,
                                 weights_list,
                                 ...) {

  rlang::fn_fmls_names(fn = daa_analytics_params)
}
