## Bottom `n` performing sites by country

if (!exists("combined_data")) { load("support_files/combined_data.rda") } #nolint

df <- combined_data |>
  dplyr::filter(period == 2021) |>
  dplyr::group_by(namelevel3uid, indicator) |>
  dplyr::slice_max(order_by = level3_weighting - level3_concordance, n = 15)

write.csv(df, "top15_discordant.csv")
