#' @export
#' @title Generates Organisation Unit Hierarchy
#'
#' @description
#' Uses the Organisation unit metadata file to generate a wide datatable of the
#' organisation unit hierarchy from Level 3 to Level 7.
#'
#' @inheritParams daa_analytics_params
#'
#' @return Dataframe containing wide format organisation unit hierarchy.
#'
create_hierarchy <- function(ou_metadata = NULL,
                             aws_s3_bucket = Sys.getenv("AWS_S3_BUCKET"),
                             cache_folder = NULL) {

  # Check that either S3 bucket or cache folder was provided
  stopifnot(
    "ERROR: Must provide either a dataset, an S3 Bucket address, or a cache folder!" =
      !is.null(ou_metadata) || aws_s3_bucket != "" || !missing(cache_folder))

  # Retrieve metadata from S3 or from cache if dataset not provided
  if (is.null(ou_metadata)) {
    ou_metadata <- get_s3_data(aws_s3_bucket = aws_s3_bucket,
                               dataset_name = "ou_metadata",
                               cache_folder = cache_folder)
  }

  # Check if all metadata retrieve and throw an error if not available
  stopifnot(
    "ERROR: Could not retrieve organisation unit metadata!" =
      !is.null(ou_metadata))

  # Separate out just UIDs and Names for joining later
  ou_uid_names <- ou_metadata |>
    dplyr::select("uid", "name")

  # Cleans and creates OU Hierarchy from levels 3 to 7 with names
  facility_list <- ou_metadata |>
    dplyr::select("organisationunitid", "path") |>
    tidyr::separate(col = "path",
                    into = c(rep(NA, 3), c("OU_UID", paste0("SNU", 1:4, "_UID")),
                             rep(NA, 2)), # Drops first three and last two cols
                    sep = "/",
                    fill = "right") |>
    dplyr::filter(!is.na(SNU3_UID))

  # Ensure only facilities are included and not higher level org units
  level7_psnu_list <- dplyr::filter(facility_list, !is.na(SNU4_UID))
  level6_psnu_list <- dplyr::filter(facility_list, is.na(SNU4_UID)) |>
    dplyr::filter(!SNU3_UID %in% level7_psnu_list$SNU3_UID)

  # Generate OU Hierarchy
  ou_hierarchy <-
    rbind(level6_psnu_list, level7_psnu_list) |>
    dplyr::left_join(dplyr::rename(ou_uid_names, "OU" = "name"),
                     by = c("OU_UID" = "uid"), keep = FALSE) |>
    dplyr::left_join(dplyr::rename(ou_uid_names, "SNU1" = "name"),
                     by = c("SNU1_UID" = "uid"), keep = FALSE) |>
    dplyr::left_join(dplyr::rename(ou_uid_names, "SNU2" = "name"),
                     by = c("SNU2_UID" = "uid"), keep = FALSE) |>
    dplyr::left_join(dplyr::rename(ou_uid_names, "SNU3" = "name"),
                     by = c("SNU3_UID" = "uid"), keep = FALSE) |>
    dplyr::left_join(dplyr::rename(ou_uid_names, "SNU4" = "name"),
                     by = c("SNU4_UID" = "uid"), keep = FALSE) |>
    dplyr::rowwise() |>
    dplyr::mutate(Facility_UID = ifelse(is.na(SNU4_UID), SNU3_UID, SNU4_UID),
                  Facility = ifelse(is.na(SNU4_UID), SNU3, SNU4)) |>
    dplyr::mutate(SNU3 = ifelse(!is.na(SNU4_UID), SNU3, NA),
                  SNU3_UID = ifelse(!is.na(SNU4_UID), SNU3_UID, NA)) |>
    dplyr::ungroup() |>
    dplyr::select("organisationunitid",
                  "OU", "OU_UID",
                  "SNU1", "SNU1_UID",
                  "SNU2", "SNU2_UID",
                  "SNU3", "SNU3_UID",
                  "Facility", "Facility_UID")

  return(ou_hierarchy)
}
