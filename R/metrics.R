#' @export
#' @importFrom magrittr %>% %<>%
#' @title Calculate Weighted Concordance.
#'
#' @description
#' Calculates the weighted concordance for a given site using the total
#' number of patients reported by the MOH and PEPFAR as well as the
#' weighting factor.
#'
#' @param MOH The number of patients reported by the MOH at the site.
#' @param PEPFAR The number of patients reported by PEPFAR at the site.
#' @param Weighting The weighting factor given to the site.
#'
#' @return A single value for the weighted concordance of the site.
#'
weighted_concordance <- function(MOH, PEPFAR, Weighting){
  if(!is.na(Weighting)){
    n <- Weighting * (((MOH + PEPFAR) - abs(MOH - PEPFAR)) / (MOH + PEPFAR))
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
#' @param MOH The number of patients reported by the MOH at the site.
#' @param PEPFAR The number of patients reported by PEPFAR at the site.
#' @param Weighting The weighting factor given to the site.
#'
#' @return A single value for the weighted discordance of the site.
#'
weighted_discordance <- function(MOH, PEPFAR, Weighting){
  if(!is.na(Weighting)){
    n <- Weighting * abs(MOH - PEPFAR) / mean(c(MOH, PEPFAR))
  } else{
    n <- NA
  }
  return(n)
}
