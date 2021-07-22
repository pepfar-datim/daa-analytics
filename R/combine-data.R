#' @export
#' @importFrom magrittr %>% %<>%
#' @title Combine DAA datasets together.
#'
#' @description
#' Combines DAA Indicator, PVLS and EMR data, and Site attribute data together
#' and exports them as a single dataframe.
#'
#' @param indicators Dataframe containing DAA indicator data.
#' @param pvls_emr Dataframe of PVLS and EMR data joined with metadata.
#' @param attribute_data Dataframe of site attribute data.
#'
#' @return A dataframe containing the DAA indicator data, PVLS and EMR indicator
#' data, and the site attribute data for a single country.
#'
# TODO figure out how to properly filter out duplicative organisation unit IDs
# during the joins here.
combine_data <- function(indicators, ou_hierarchy, pvls_emr, attribute_data) {
  df <- indicators %>%
    dplyr::left_join(ou_hierarchy, by = c("facilityuid")) %>%
    dplyr::left_join(pvls_emr, by = c("organisationunitid", "Period")) %>%
    dplyr::left_join(attribute_data, by = c("facilityuid")) %>%
    dplyr::select(-name, -organisationunitid)
  return(df)
}
