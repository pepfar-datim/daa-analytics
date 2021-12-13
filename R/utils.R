#' @export
#' @title Return current FY based on system date.
#'
#' @return Current FY as numeric.
#'
current_fiscal_year <- function() {
  current_year <- Sys.Date() %>%
    format("%Y") %>%
    as.numeric()

  current_month <- Sys.Date() %>%
    format("%m") %>%
    as.numeric()

  curr_fy <- ifelse(current_month > 9, current_year + 1, current_year)

  return(curr_fy)
}


}

#' @export
#' @title Get Organisation Unit Name from UID.
#'
#' @description
#' Returns the country name based on the organisation unit UID.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#'
#' @return A string containing the country name.
#'
get_ou_name <- function(ou_uid) {
  ou_name <- daa.analytics::daa_countries %>%
    dplyr::filter(.data$country_uid == ou_uid) %>%
    dplyr::select(.data$country_name) %>%
    toString()

  # Returns OU name
  return(ou_name)
}

#'
#'



}
