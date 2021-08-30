#' @export
#' @importFrom magrittr %>% %<>%
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
#' @importFrom magrittr %>% %<>%
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
