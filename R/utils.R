#' @export
#' @title Return current FY based on system date.
#'
#' @return Current FY as numeric.
#'
current_fiscal_year <- function() {
  current_year <- Sys.Date() |>
    format("%Y") |>
    as.numeric()

  current_month <- Sys.Date() |>
    format("%m") |>
    as.numeric()

  curr_fy <- ifelse(current_month > 9, current_year + 1, current_year)

  return(curr_fy)
}


#' @export
#'
#' @title Prints message if session is interactive.
#'
#' @description
#' Supplied a message, will print it only if the session is currently interactive.
#'
#' @param x Message to print.
#'
#' @return Printed message, \code{x}.
#'
interactive_print <- function(x) {
  if (rlang::is_interactive()) {
    print(x)
  }
}


#' @title Remove missing data
#'
#' @description
#' Takes in a list of dataframes and removes any that are missing.
#'
#' @param my_list A list of dataframes.
#'
#' @return A list of dataframes with missing dataframes removed.
#'
#' @noRd
#'
remove_missing_dfs <- function(my_list) {
  new_list <- my_list[which(!is.na(my_list))]
  return(new_list)
}


#' @export
#' @title Calculate Weighted Concordance.
#'
#' @description
#' Calculates the weighted concordance for a given site using the total
#' number of patients reported by the MOH and PEPFAR as well as the
#' weighting factor.
#'
#' @param moh The number of patients reported by the MOH at the site.
#' @param pepfar The number of patients reported by PEPFAR at the site.
#' @param weighting The weighting factor given to the site.
#'
#' @return A single value for the weighted concordance of the site.
#'
weighted_concordance <- function(moh, pepfar, weighting) {
  if (!is.na(weighting)) {
    n <- weighting * (((moh + pepfar) - abs(moh - pepfar)) / (moh + pepfar))
  } else{
    n <- NA
  }
  return(n)
}


#' @export
#' @title Calculate Weighted Discordance.
#'
#' @description
#' Calculates the weighted discordance for a given site using the total
#' number of patients reported by the MOH and PEPFAR as well as the
#' weighting factor.
#'
#' @param moh The number of patients reported by the MOH at the site.
#' @param pepfar The number of patients reported by PEPFAR at the site.
#' @param weighting The weighting factor given to the site.
#'
#' @return A single value for the weighted discordance of the site.
#'
weighted_discordance <- function(moh, pepfar, weighting) {
  if (!is.na(weighting)) {
    n <- weighting * abs(moh - pepfar) / mean(c(moh, pepfar))
  } else{
    n <- NA
  }
  return(n)
}
