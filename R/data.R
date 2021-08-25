# TODO Update number of rows in the DAA indicator dataset
# when FY22 indicators are out.

#' Site attribute data.
#'
#' A dataset containing the site attribute data for DAA countries.
#'
#' @format A data frame with 5 variables:
#' \describe{
#'   \item{name}{The name of the facility.}
#'   \item{facilityuid}{The UID used by PEPFAR to identify the facility.}
#'   \item{moh_id}{The UID used by the MOH to identify the facility.}
#'   \item{longitude}{Longitude of the facility as recorded in DATIM.}
#'   \item{latitude}{Latitude of the facility as recorded in DATIM.}
#' }
#' @source \url{http://www.datim.org/}
"attribute_data"

#' Category Option Combo metadata.
#'
#' A dataset containing the metadata for category option combinations.
#'
#' @format A data frame with 2 variables:
#' \describe{
#'   \item{categoryoptioncomboid}{The numeric code used to identify
#'   the Category Option Combination in DATIM.}
#'   \item{categoryoptioncomboname}{The name of the Category Option
#'   Combination in DATIM.}
#'   ...
#' }
#' @source \url{http://www.datim.org/}
"coc_metadata"

#' Period metadata.
#'
#' A dataset containing the metadata for periods.
#'
#' @format A data frame with 2 variables:
#' \describe{
#'   \item{periodid}{The numeric ID used in DATIM for the time period.}
#'   \item{iso}{The ISO date/time value for the period.}
#'   ...
#' }
#' @source \url{http://www.datim.org/}
"pe_metadata"

#' Data Element metadata.
#'
#' A dataset containing the metadata for DATIM data elements.
#'
#' @format A data frame with 2 variables:
#' \describe{
#'   \item{dataelementid}{The numeric ID associated with the
#'   data element in DATIM.}
#'   \item{dataelementname}{The name of the Data Element in DATIM.}
#'   ...
#' }
#' @source \url{http://www.datim.org/}
"de_metadata"

#' Organisation Unit metadata.
#'
#' A dataset containing the metadata for DATIM organisation units.
#'
#' @format A data frame with 4 variables:
#' \describe{
#'   \item{organisationunitid}{The numeric ID associated with the organisation
#'   unit in DATIM.}
#'   \item{path}{The UIDs for each organisation unit hierarchy level from
#'   Global to the specific organisation unit separated by forward slashes.}
#'   \item{name}{The name of the organisation unit.}
#'   \item{uid}{The alphanumeric UID associated with the organisation unit
#'   in DATIM.}
#' }
#' @source \url{http://www.datim.org/}
"ou_metadata"

#' DAA country list.
#'
#' A dataset containing the names, abbreviations, and IDs of DAA countries.
#'
#' @format A data frame with 23 rows and 4 variables:
#' \describe{
#'   \item{country_name}{The name of the country.}
#'   \item{country_uid}{The alphanumeric UID associated with the country in
#'   DATIM.}
#'   \item{country_code}{The three letter acronym for the country.}
#'   \item{facility_level}{The organisation unit hierarchy level at which
#'   facilities are located for the particular country.}
#' }
#' @source \url{http://www.datim.org/}
"daa_countries"

#' DAA indicator list.
#'
#' A dataset containing the indicator names and IDs for the DAA.
#'
#' @format A data frame with 14 rows and 3 variables:
#' \describe{
#'   \item{uid}{The alphanumeric UID associated with the indicator in DATIM.}
#'   \item{indicator}{The short name of the indicator.}
#'   \item{notes}{Notes on years and disaggregates relevant to the DAA.}
#' }
#' @source \url{http://www.datim.org/}
"daa_indicators"

#' Data availability.
#'
#' A dataset containing information regarding whether a country provided
#' an mapping and data for DAA indicators in each year of the activity.
#'
#' @format A data frame with 5 variables:
#' \describe{
#'   \item{namelevel3}{The name of the country participating in the DAA.}
#'   \item{period}{The reporting period for the DAA.}
#'   \item{indicator}{The reporting indicator for the DAA.}
#'   \item{has_disag_mapping}{The disaggregate mapping provided by the country
#'   for the indicator in the given reporting period. Values can either be
#'   'Fine', 'Coarse', or 'Total'. Countries that did not provide a mapping are
#'   marked as 'No'.}
#'   \item{has_results_data}{Indicates whether a country reported data for the
#'   associated indicator during the most recent reporting period. Values are
#'   recorded as 'Yes' or 'No'. Periods prior to the most recent reporting
#'   period are recorded as 'NA'.}
#' }
#' @source \url{http://www.geoalign.org/}
"data_availability"

#' Organisation Unit Hierarchy.
#'
#' A dataset containing the organisation unit hierarchies of all DAA countries.
#'
#' @format A data frame with 7 variables:
#' \describe{
#'   \item{organisationunitid}{The numeric ID used to identify the organisation
#'   unit in DATIM.}
#'   \item{facilityuid}{The alphanumeric UID used to identify the facility in
#'   DATIM.}
#'   \item{namelevel3}{The name of the parent organisation unit at hierarchy
#'   level 3 to the given facility.}
#'   \item{namelevel4}{The name of the parent organisation unit at hierarchy
#'   level 4 to the given facility.}
#'   \item{namelevel5}{The name of the parent organisation unit at hierarchy
#'   level 5 to the given facility.}
#'   \item{namelevel6}{For countries with their facility level at hierarchy
#'   level 6, this will represent the name of the facility. For countries with
#'   their facility level at hierarchy level 7, this will represent the parent
#'   organisation unit at hierarchy level 6 to the given facility.}
#'   \item{namelevel7}{For countries with their facility level at hierarchy
#'   level 7, this will represent the name of the facility. For countries with
#'   their facility level at hierarchy level 6, this value will be 'NA'.}
#' }
#' @source \url{http://www.datim.org/}
"ou_hierarchy"

#' Viral Load Suppression and Electronic Medical Records data.
#'
#' A dataset containing information on the PVLS and EMR indicators for
#' DAA countries.
#'
#' @format A data frame with 9 variables:
#' \describe{
#'   \item{organisationunitid}{The numeric ID used to identify the organisation
#'   unit in DATIM.}
#'   \item{period}{The fiscal year reporting period.}
#'   \item{emr_hts}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   Testing Services.}
#'   \item{emr_tx}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   care and treatment services.}
#'   \item{emr_anc}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   antenatal care and/or maternity services.}
#'   \item{emr_eid}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with early
#'   infant diagnosis services.}
#'   \item{emr_tb}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with
#'   Tuberculosis treatment and testing services for HIV patients.}
#'   \item{tx_pvls_n}{The numerator for TX_PVLS, representing the number of
#'   patients with suppressed viral load test results documented in a given
#'   period.}
#'   \item{tx_pvls_d}{The denominator for TX_PVLS, representing the number of
#'   patients with a viral load test result documented in a given period.}
#' }
#' @source \url{http://www.datim.org/}
"pvls_emr"

#' DAA Indicator Data.
#'
#' A dataset containing the data for DAA indicators for all DAA countries
#' for each year of the activity.
#'
#' @format A data frame with 11 variables:
#' \describe{
#'   \item{facilityuid}{The alphanumeric UID used to identify the facility in
#'   DATIM.}
#'   \item{indicator}{The reporting indicator for the DAA.}
#'   \item{period}{The fiscal year reporting period.}
#'   \item{moh}{The results provided for the given indicator by the MOH during
#'   the associated reporting period.}
#'   \item{pepfar}{The results provided for the given indicator by PEPFAR during
#'   the associated reporting period.}
#'   \item{reported_by}{A text value indicating whether results were reported
#'   by just the MOH, just PEPFAR, or both entities at the given site for the
#'   given indicator during the reporting period.}
#'   \item{count_of_matched_sites}{The number of facilities in a country for the
#'   particular indicator and reporting period for which results were reported
#'   by both the MOH and PEPFAR.}
#'   \item{pepfar_sum_at_matched_sites}{The total results reported by PEPFAR
#'   at all facilities in a country for the particular indicator and reporting
#'   period.}
#'   \item{weighting}{The PEPFAR results at the particular facility divided by
#'   the total results reported by PEPFAR at all facilities for the given
#'   indicator and reporting period. This figure provides the weighting value
#'   for concordance and discordance metrics.}
#'   \item{weighted_discordance}{The weighted discordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average discordance.}
#'   \item{weighted_concordance}{The weighted concordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average concordance.}
#' }
#' @source \url{http://www.datim.org/}
"daa_indicator_data"

#' Combined DAA Dataset.
#'
#' A dataset containing all data for the DAA activity as well as additional
#' indicator data from DATIM.
#'
#' @format A data frame with 26 variables:
#' \describe{
#'   \item{facilityuid}{The alphanumeric UID used to identify the facility in
#'   DATIM.}
#'   \item{indicator}{The reporting indicator for the DAA.}
#'   \item{period}{The fiscal year reporting period.}
#'   \item{moh}{The results provided for the given indicator by the MOH during
#'   the associated reporting period.}
#'   \item{pepfar}{The results provided for the given indicator by PEPFAR during
#'   the associated reporting period.}
#'   \item{reported_by}{A text value indicating whether results were reported
#'   by just the MOH, just PEPFAR, or both entities at the given site for the
#'   given indicator during the reporting period.}
#'   \item{count_of_matched_sites}{The number of facilities in a country for the
#'   particular indicator and reporting period for which results were reported
#'   by both the MOH and PEPFAR.}
#'   \item{pepfar_sum_at_matched_sites}{The total results reported by PEPFAR
#'   at all facilities in a country for the particular indicator and reporting
#'   period.}
#'   \item{weighting}{The PEPFAR results at the particular facility divided by
#'   the total results reported by PEPFAR at all facilities for the given
#'   indicator and reporting period. This figure provides the weighting value
#'   for concordance and discordance metrics.}
#'   \item{weighted_discordance}{The weighted discordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average discordance.}
#'   \item{weighted_concordance}{The weighted concordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average concordance.}
#'   \item{namelevel3}{The name of the parent organisation unit at hierarchy
#'   level 3 to the given facility.}
#'   \item{namelevel4}{The name of the parent organisation unit at hierarchy
#'   level 4 to the given facility.}
#'   \item{namelevel5}{The name of the parent organisation unit at hierarchy
#'   level 5 to the given facility.}
#'   \item{namelevel6}{For countries with their facility level at hierarchy
#'   level 6, this will represent the name of the facility. For countries with
#'   their facility level at hierarchy level 7, this will represent the parent
#'   organisation unit at hierarchy level 6 to the given facility.}
#'   \item{namelevel7}{For countries with their facility level at hierarchy
#'   level 7, this will represent the name of the facility. For countries with
#'   their facility level at hierarchy level 6, this value will be 'NA'.}
#'   \item{emr_hts}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   Testing Services.}
#'   \item{emr_tx}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   care and treatment services.}
#'   \item{emr_anc}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   antenatal care and/or maternity services.}
#'   \item{emr_eid}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with early
#'   infant diagnosis services.}
#'   \item{emr_tb}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with
#'   Tuberculosis treatment and testing services for HIV patients.}
#'   \item{tx_pvls_n}{The numerator for TX_PVLS, representing the number of
#'   patients with suppressed viral load test results documented in a given
#'   period.}
#'   \item{tx_pvls_d}{The denominator for TX_PVLS, representing the number of
#'   patients with a viral load test result documented in a given period.}
#'   \item{moh_id}{The UID used by the MOH to identify the facility.}
#'   \item{longitude}{Longitude of the facility as recorded in DATIM.}
#'   \item{latitude}{Latitude of the facility as recorded in DATIM.}
#' }
#' @source \url{http://www.datim.org/}
"combined_data"
