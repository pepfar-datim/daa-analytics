#' Adorn Indicator Metadata
#'
#' @inheritParams daa_analytics_params
#'
#' @return df An adorned dataframe
#' @export
adorn_indicators <- function(df,
                             aggregate_names,
                             d2_session = dynGet("d2_default_session",
                                                 inherits = TRUE)) {
  # Grab metadata for data elements
  de_meta <-
    datimutils::getDataElements(unique(df$data_element),
                                fields = c("id", "name"),
                                d2_session = d2_session)

  if (aggregate_names == TRUE) {
    de_meta <- dplyr::mutate(de_meta, indicator = gsub(" \\(.*", "", name))
    ## Filter out unwanted indicators
    df <- dplyr::filter(df,
                        !period %in% c("2017Oct", "2018Oct") |
                          !data_element %in% c("BRalYZhcHpi",
                                               "V6hxDYUZFBq",
                                               "xwVNaDjMe9z",
                                               "IXkZ7eWtFHs"))
  }

  df <-
    # Adorn indicator names
    dplyr::left_join(df, de_meta, by = c("data_element" = "id")) |>
      dplyr::rowwise() |>
      dplyr::mutate(indicator =
                      ifelse(grepl("TB_PREV", indicator) && period < 2020,
                             sub("TB_PREV", "TB_PREV_LEGACY", indicator),
                             indicator)) |>

    #for denominator for TX_PVLS the are; LZjX8KhIujF and V90qY58Tqmi
    # for numerator TX_PVLS they are: bISVJGjG2Pa and WxSk9gth9z0
    dplyr::mutate(indicator =
                    ifelse(grepl("TX_PVLS", indicator) &&
                             (data_element %in% c("LZjX8KhIujF", "V90qY58Tqmi")),
                           sub("TX_PVLS", "TX_PVLS_DEN", indicator),
                           indicator)) |>
    dplyr::mutate(indicator =
                    ifelse(grepl("TX_PVLS", indicator) &&
                             (data_element %in% c("bISVJGjG2Pa", "WxSk9gth9z0")),
                           sub("TX_PVLS", "TX_PVLS_NUM", indicator),
                           indicator)) |>
      dplyr::ungroup()

  if (aggregate_names == TRUE) {
    df <-
      # Aggregate site data across coarse and fine indicators
      dplyr::group_by(df, across(-c(value, data_element, name))) |>
      dplyr::summarise(value = sum(as.numeric(value))) |>
      dplyr::ungroup()
  }

  df
}

#' Adorn Category Option Combo Metadata
#'
#' @inheritParams daa_analytics_params
#'
#' @return df An adorned dataframe
#' @export
adorn_category_option_combos <- function(df,
                                         d2_session = dynGet("d2_default_session",
                                                             inherits = TRUE)) {
  # Grab metadata for category option combos
  coc_metadata <-
    datimutils::getCatOptionCombos(unique(df$category_option_combo),
                                   fields = c("id", "name"), d2_session = d2_session) |>
    dplyr::rename("coc_id" = "id", "coc_name" = "name")

  # Adorn category option combo metadata
  df <- dplyr::left_join(df, coc_metadata,
                         by = c("category_option_combo" = "coc_id"),
                         keep = FALSE) |>
    dplyr::rename("categoryOptionCombo" = "coc_name")

  df
}

#' @export
#' @title Adorn DAA Indicator Data
#'
#' @description
#' Cleans and adorns a dataframe of DAA data containing UIDs with indicator
#' names, fiscal years, and weighted concordance and discordance information,
#' as well as other information.
#'
#' @inheritParams daa_analytics_params
#'
#' @return df An adorned dataframe.
adorn_daa_data <- function(df,
                           include_coc = FALSE,
                           aggregate_indicators = TRUE,
                           d2_session = dynGet("d2_default_session",
                                               inherits = TRUE)) {
  # Returns null if delivered an empty dataset
  if (is.null(df)) {
    return(NULL)
  }

  stopifnot("ERROR: Dataframe has incorrect column names!" =
              all(c("org_unit", "data_element", "period", "value") %in% colnames(df)),
            "ERROR: Must include category_option_combo column in dataframe if intending to include that data" = # nolint
              "category_option_combo" %in% colnames(df))

  if (include_coc == TRUE) {
    my_vars <- c("data_element",
                 "org_unit",
                 "period",
                 "category_option_combo",
                 "attribute_option_combo",
                 "value")
  } else {
    my_vars <- c("data_element",
                 "org_unit",
                 "period",
                 "attribute_option_combo",
                 "value")
  }

  # Cleans data and prepares it for export
  df <- df |>
    # Selects appropriate variables
    dplyr::select(my_vars) |>
    dplyr::rename("Facility_UID" = "org_unit") |>

    # Recasts values as numeric
    dplyr::mutate(value = as.numeric(`value`)) |>

    adorn_indicators(aggregate_names = aggregate_indicators, d2_session = d2_session) |>

    # Pivots MOH and PEPFAR data out into separate columns
    dplyr::mutate(attribute_option_combo = dplyr::case_when(
      attribute_option_combo == "00100" ~ "moh",
      attribute_option_combo == "00200" ~ "pepfar")) |>
    tidyr::pivot_wider(names_from = `attribute_option_combo`,
                       values_from = `value`) |>

    # Cleans Period data from the form `2018Oct` to `2019`
    dplyr::mutate(period =
                    as.numeric(stringr::str_sub(`period`, 0, 4)) + 1)

  if (include_coc == TRUE) {
    df <- adorn_category_option_combos(df, d2_session = d2_session)
  }

  # Creates summary data about reporting institutions and figures
  df <- df |> dplyr::mutate(reported_by =
                  ifelse(!is.na(moh),
                         ifelse(!is.na(pepfar), "Both", "MOH"),
                         ifelse(!is.na(pepfar), "PEPFAR", "Neither")))
  df
}
