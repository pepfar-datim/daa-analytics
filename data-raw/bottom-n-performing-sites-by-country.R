## Bottom `n` performing sites by country

if (!exists("combined_data")) { combined_data <- readRDS("support_files/combined_data.rds") } #nolint

df <- combined_data |>
  dplyr::filter(period == 2021) |>
  dplyr::group_by(OU, indicator) |>
  dplyr::slice_max(order_by = OU_weighting - OU_Concordance, n = 15)

write.csv(df, "top15_discordant.csv")
