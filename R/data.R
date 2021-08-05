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
#'   \item{MOH ID}{The UID used by the MOH to identify the facility.}
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
#'   \item{countryName}{The name of the country.}
#'   \item{countryUID}{The alphanumeric UID associated with the country in
#'   DATIM.}
#'   \item{countryCode}{The three letter acronym for the country.}
#'   \item{facilityLevel}{The organisation unit hierarchy level at which
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
#'   \item{Period}{The reporting period for the DAA.}
#'   \item{Indicator}{The reporting indicator for the DAA.}
#'   \item{hasDisagMapping}{The disaggregate mapping provided by the country
#'   for the indicator in the given reporting period. Values can either be
#'   'Fine', 'Coarse', or 'Total'. Countries that did not provide a mapping are
#'   marked as 'No'.}
#'   \item{hasResultsData}{Indicates whether a country reported data for the
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
#'   \item{Period}{The fiscal year reporting period.}
#'   \item{EMR - HIV Testing Services}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   Testing Services.}
#'   \item{EMR - Care and Treatment}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   care and treatment services.}
#'   \item{EMR - ANC and/or Maternity}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   antenatal care and/or maternity services.}
#'   \item{EMR - EID}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with early
#'   infant diagnosis services.}
#'   \item{EMR - HIV/TB}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with
#'   Tuberculosis treatment and testing services for HIV patients.}
#'   \item{TX_PVLS_N}{The numerator for TX_PVLS, representing the number of
#'   patients with suppressed viral load test results documented in a given
#'   period.}
#'   \item{TX_PVLS_D}{The denominator for TX_PVLS, representing the number of
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
#'   \item{Indicator}{The reporting indicator for the DAA.}
#'   \item{Period}{The fiscal year reporting period.}
#'   \item{MOH}{The results provided for the given indicator by the MOH during
#'   the associated reporting period.}
#'   \item{PEPFAR}{The results provided for the given indicator by PEPFAR during
#'   the associated reporting period.}
#'   \item{Reported by}{A text value indicating whether results were reported
#'   by just the MOH, just PEPFAR, or both entities at the given site for the
#'   given indicator during the reporting period.}
#'   \item{Count of matched sites}{The number of facilities in a country for the
#'   particular indicator and reporting period for which results were reported
#'   by both the MOH and PEPFAR.}
#'   \item{PEFPAR sum at matched sites}{The total results reported by PEPFAR
#'   at all facilities in a country for the particular indicator and reporting
#'   period.}
#'   \item{Weighting}{The PEPFAR results at the particular facility divided by
#'   the total results reported by PEPFAR at all facilities for the given
#'   indicator and reporting period. This figure provides the weighting value
#'   for concordance and discordance metrics.}
#'   \item{Weighted discordance}{The weighted discordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average discordance.}
#'   \item{Weighted concordance}{The weighted concordance between the PEPFAR
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
#'   \item{Indicator}{The reporting indicator for the DAA.}
#'   \item{Period}{The fiscal year reporting period.}
#'   \item{MOH}{The results provided for the given indicator by the MOH during
#'   the associated reporting period.}
#'   \item{PEPFAR}{The results provided for the given indicator by PEPFAR during
#'   the associated reporting period.}
#'   \item{Reported by}{A text value indicating whether results were reported
#'   by just the MOH, just PEPFAR, or both entities at the given site for the
#'   given indicator during the reporting period.}
#'   \item{Count of matched sites}{The number of facilities in a country for the
#'   particular indicator and reporting period for which results were reported
#'   by both the MOH and PEPFAR.}
#'   \item{PEFPAR sum at matched sites}{The total results reported by PEPFAR
#'   at all facilities in a country for the particular indicator and reporting
#'   period.}
#'   \item{Weighting}{The PEPFAR results at the particular facility divided by
#'   the total results reported by PEPFAR at all facilities for the given
#'   indicator and reporting period. This figure provides the weighting value
#'   for concordance and discordance metrics.}
#'   \item{Weighted discordance}{The weighted discordance between the PEPFAR
#'   and MOH reported results at the particular facility. Can be summed across
#'   facilities grouped by country, indicator, and period to calculate the
#'   weighted average discordance.}
#'   \item{Weighted concordance}{The weighted concordance between the PEPFAR
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
#'   \item{EMR - HIV Testing Services}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   Testing Services.}
#'   \item{EMR - Care and Treatment}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   care and treatment services.}
#'   \item{EMR - ANC and/or Maternity}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with HIV
#'   antenatal care and/or maternity services.}
#'   \item{EMR - EID}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with early
#'   infant diagnosis services.}
#'   \item{EMR - HIV/TB}{Boolean value indicating whether a
#'   facility has an electronic medical records system associated with
#'   Tuberculosis treatment and testing services for HIV patients.}
#'   \item{TX_PVLS_N}{The numerator for TX_PVLS, representing the number of
#'   patients with suppressed viral load test results documented in a given
#'   period.}
#'   \item{TX_PVLS_D}{The denominator for TX_PVLS, representing the number of
#'   patients with a viral load test result documented in a given period.}
#'   \item{MOH ID}{The UID used by the MOH to identify the facility.}
#'   \item{longitude}{Longitude of the facility as recorded in DATIM.}
#'   \item{latitude}{Latitude of the facility as recorded in DATIM.}
#' }
#' @source \url{http://www.datim.org/}
"combined_data"
