#' @export
#' @title Generates Organisation Unit Hierarchy
#'
#' @description
#' Uses the Organisation unit metadata file to generate a wide datatable of the
#' organisation unit hierarchy from Level 3 to Level 7.
#'
#' @param ou_metadata Dataframe containing organisation unit metadata.
#'
#' @return Dataframe containing wide format organisation unit hierarchy from
#' Level 3 to Level 7.
#'
create_hierarchy <- function(ou_metadata) {

  ou_uid_names <- ou_metadata %>%
    dplyr::select(.data$uid, .data$name)

  # Cleans and creates OU Hierarchy from levels 3 to 7 with names
  ou_hierarchy <- ou_metadata %>%
    dplyr::select(.data$organisationunitid, .data$path) %>%
    tidyr::separate(col = .data$path,
                    into = c(rep(NA, 3), paste0("namelevel", 3:7, "uid"),
                             rep(NA, 2)), # Drops first three and last two cols
                    sep = "/",
                    fill = "right") %>%
    dplyr::filter(!is.na(.data$namelevel6uid)) %>%
    dplyr::mutate(facilityuid = ifelse(is.na(.data$namelevel7uid),
                                       .data$namelevel6uid,
                                       .data$namelevel7uid)) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel3 = .data$name),
                     by = c("namelevel3uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel4 = .data$name),
                     by = c("namelevel4uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel5 = .data$name),
                     by = c("namelevel5uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel6 = .data$name),
                     by = c("namelevel6uid" = "uid"), keep = FALSE) %>%
    dplyr::left_join(ou_uid_names %>% dplyr::rename(namelevel7 = .data$name),
                     by = c("namelevel7uid" = "uid"), keep = FALSE) %>%
    dplyr::select(.data$organisationunitid,
                  .data$facilityuid,
                  dplyr::everything())

  return(ou_hierarchy)
}
