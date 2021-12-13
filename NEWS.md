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

