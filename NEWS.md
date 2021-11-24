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

