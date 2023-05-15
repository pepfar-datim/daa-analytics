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

  namespace <- "MOH_country_indicators"


  # Fetches data from the server
  ls <- datimutils::getDataStoreNamespaceKeys(namespace = "MOH_country_indicators",
                                d2_session = geo_session)
  args <- ls[!ls %in% c("config", "2021", "CS_2021", "2022")]

  if (is.null(df)) {
    return(NULL)
  }
  #separate code to handle 2022 data format
  df_2022 <- tryCatch({
    x <- 2022

    args2 <- list(namespace = paste0(namespace, "/", x),
                  d2_session = geo_session)
    df2 <- purrr::exec(datimutils::getDataStoreNamespaceKeys, !!!args2)

    if (length(df2$DAA) > 0) {
      df2 <- as.data.frame(do.call(rbind, lapply(df2$DAA, as.data.frame)))
      rownames(df2) <- c(1:nrow(df2))
      colnames(df2) <- colnames(df2) |> lapply(function(i) {
        return(gsub('indicatorMapping.', '', i))
      })
      df2 <- df2 |>
        dplyr::select(-code) |>
        dplyr::rename("CountryCode" = "countryCode",
                      "CountryName" = "countryName",
                      "TX_NEW_hasMappingData" = "TX_NEW",
                      "HTS_TST_hasMappingData" = "HTS_TST",
                      "TB_PREV_hasMappingData" = "TB_PREV",
                      "TX_CURR_hasMappingData" = "TX_CURR",
                      "PMTCT_ART_hasMappingData" = "PMTCT_ART",
                      "PMTCT_STAT_hasMappingData" = "PMTCT_STAT",
                      "TX_PVLSDEN_hasMappingData" = "TX_PVLS_DEN",
                      "TX_PVLSNUM_hasMappingData" = "TX_PVLS_NUM")
      df2 <- df2 |>
        dplyr::mutate(period = as.character(x))
    }

    df2
  }, error = function(e) {
    NA
  })


  #working code for rest of years
  df_rest_of_years <- args |>
    lapply(function(x) {
      tryCatch({
        args2 <- list(namespace = paste0(namespace, "/", x),
                      d2_session = geo_session)
        df2 <- purrr::exec(datimutils::getDataStoreNamespaceKeys, !!!args2)
        df2 <- df2 |>
          purrr::map_dfr(as.data.frame) |>
          dplyr::mutate(period = x)

        return(df2)
      }, error = function(e) {
        return(NA)
      })
    }) |> remove_missing_dfs()

  #then bind both and proceed
  df <- dplyr::bind_rows(df_2022, df_rest_of_years) |>
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
                             as.numeric(period) < 2021,
                           "TB_PREV_LEGACY", indicator),
                  period = as.numeric(period),
                  has_disag_mapping = ifelse(hasDisagMapping %in%
                                               c("No", "NA", NA),
                                             "None",
                                             hasDisagMapping)) |>
    dplyr::mutate(has_disag_mapping = stringr::str_to_title(has_disag_mapping)) |>
    dplyr::mutate(has_results_data =
                    ifelse(period == max(period),
                           hasResultsData,
                           NA_character_)) |>

    dplyr::mutate(has_mapping_result_data =
                    ifelse(hasMappingData %in% c("No", "NA", NA)&& as.numeric(period) > 2020, "None",
                           hasMappingData)) |>
    dplyr::mutate(has_mapping_result_data = stringr::str_to_title(has_mapping_result_data)) |>
    dplyr::ungroup() |>
    dplyr::select(OU = CountryName, period, indicator,
                  has_disag_mapping, has_results_data, has_mapping_result_data)

  df
}
