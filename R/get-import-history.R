#' @export
#' @title Fetch Indicator Mapping and Data Availability from GeoAlign
#'
#' @description
#' Extracts all data for all countries and activity years from GeoAlign
#' regarding whether countries have provided indicator mappings, the
#' disaggregation level, and whether data was imported for that indicator.
#'
#' @inheritParams daa_analytics_params
#'
#' @return A dataframe of indicator mapping, disaggregation level, and data
#' availability organized by activity year and country.
#'
get_import_history <- function(geo_session = dynGet("d2_default_session",
                                                    inherits = TRUE)) {

  end_point <- "dataStore/MOH_country_indicators"

  # Fetches data from the server
  ls <- datimutils::getMetadata(end_point = "dataStore/MOH_country_indicators",
                                d2_session = geo_session)
  args <- ls[!ls %in% c("config", "DAA_2021", "CS_2021")]

  if (is.null(df)) {
    return(NULL)
  }

  # Loops through all available years to pull data availability from GeoAlign
  df <- args |>
    lapply(function(x) {
      tryCatch({
        args2 <- list(end_point = paste0(end_point, "/", x),
                      d2_session = geo_session)
        df2 <- purrr::exec(datimutils::getMetadata, !!!args2)

        if(x %in% c(2022, 2021)){
          df2<-as.data.frame(do.call(rbind, lapply(df2$DAA, as.data.frame)))
          rownames(df2) <- c(1:nrow(df2))
          colnames(df2) <- colnames(df2) |> lapply(function(i){ return (gsub('indicatorMapping.', '', i))})
          df2 <- df2 |> dplyr::select(-code) |>
                        dplyr::rename("CountryCode" = "countryCode", "CountryName" = "countryName", "TX_NEW_hasMappingData" = "TX_NEW", "HTS_TST_hasMappingData" = "HTS_TST", "TB_PREV_hasMappingData" = "TB_PREV", "TX_CURR_hasMappingData" = "TX_CURR", "PMTCT_ART_hasMappingData" = "PMTCT_ART", "PMTCT_STAT_hasMappingData" = "PMTCT_STAT", "TX_PVLSDEN_hasMappingData" = "TX_PVLS_DEN", "TX_PVLSNUM_hasMappingData" = "TX_PVLS_NUM")
        }


        df2 <- df2 |>
          dplyr::mutate(period = x)
        return(df2)
      }, error = function(e) {
        return(NA)
      })
    }) |>
    remove_missing_dfs() |>
    dplyr::bind_rows() |>
    dplyr::mutate(period = stringr::str_sub(period,
                                            start = -4, end = -1)) |>
    tidyr::pivot_longer(-c(period, CountryName,
                           CountryCode, generated),
                        names_sep = "_(?=[^_]*$)",
                        names_to = c("indicator", ".value")) |>
    dplyr::rowwise() |>
    dplyr::mutate(indicator = ifelse(indicator == "TX_PVLSNUM", "TX_PVLS_NUM", indicator),
                  indicator = ifelse(indicator == "TX_PVLSDEN", "TX_PVLS_DEN", indicator),
                  ) |>
    dplyr::mutate(indicator =
                    ifelse(indicator == "TB_PREV" &&
                             as.numeric(period) < 2020,
                           "TB_PREV_LEGACY", indicator),
                  period = as.numeric(period),
                  has_disag_mapping = ifelse(hasDisagMapping %in%
                                               c("No", "NA", NA),
                                             "None",
                                             hasDisagMapping)) |>
    dplyr::mutate(has_results_data =
                    ifelse(period == max(period),
                           hasResultsData,
                           NA_character_)) |>

    dplyr::mutate(has_mapping_result_data =
                    ifelse(hasMappingData %in% c("No", "NA", NA)&& as.numeric(period) > 2020, "None",
                           hasMappingData)) |>
    dplyr::ungroup() |>
    dplyr::select(OU = CountryName, period, indicator,
                  has_disag_mapping, has_results_data, has_mapping_result_data)

  df
}
