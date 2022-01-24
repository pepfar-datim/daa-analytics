# daa.analytics v0.5.0

## Bug fixes
* Fixes minor bugs in `get_ou_name` and `adorn_pvls_emr`.

## Breaking changes
* Renames `emr_at_site_for_indicator` column to `emr_present` in relevant
  datasets.
* Renames `data_availability` dataset to `import_history`
  
## New features
* Creates `global_summary` function to generate a summary table of DAA results
  across all countries, indicators, and fiscal years of the activity.

## Minor improvements and fixes
* Moves document output folder from variable defined in each `data_raw` file
  to an environmental variable, `OUTPUT_FOLDER`.
* Updates `data_raw` scripts for `attribute_data` and `daa_indicator_data`
  datasets so countries are fetched in alphabetical order and country names
  are printed as each query is made to DATIM.
* The `save_csv` file in `data_raw` has been updated to fetch the new
  `global_summary` dataset and save it to a CSV.

# daa.analytics v0.4.0

## Bug fixes
* Fixes minor bug with how `adorn_weights` and `combine_data` handle
  Organization Units with duplicative UIDs.

## Breaking changes
* Deprecates `get_coc_metadata`, `get_de_metadata`, `get_ou_metadata`,
  `get_pe_metadata`, and `get_pvls_emr_data` for a single function called
  `get_s3_data` which takes in an argument named `dataset_name` to indicate
  which file to update.
* Renames `get_data_availability` to `get_import_history`.
* Renames `weighting_levels` to `adorn_weights`.
  
## New features
* `get_s3_data` and `fetch_s3_files` now both allow the user to only update
  files if the data has changed on S3 since the last time a file was grabbed.

## Minor improvements and fixes
* Updates R from version 3.6.3 to version 4.1.1
* Updates versions of several required and suggested packages
* New `data-raw` files added for updating data for a single OU and
  for saving CSVs with country data.

# daa.analytics v0.3.0

## Breaking changes
* `adorn_daa_data` now no longer exports columns `county_of_matched_sites`,
  `pepfar_sum_at_matched_sites`, `weighting`, `weighted_discordance`,
  or `weighted_concordance`.
  - `count_of_matched_sites` and `pepfar_sum_at_matched_sites` will now no
    longer be supported.
  - `weighting`, `weighted_discordance`, and `weighted_concordance` will be
    replaced by weights and metrics calculated at each level of the organisation
    hierarchy going forward and will be calculated using the `weighting_levels`
    function.

## Experimental features
* `weighting_levels` is a new function that calculates weightings as well as
  concordance and discordance metrics for DAA indicators at all levels of the
  organisation hierarchy.
  
## Minor improvements and fixes
* Adds UIDs for each organisation hierarchy level to `ou_hierarchy` dataset
* Documentation updates
* Adds `NEWS.md` file

