## code to prepare `combined_data` dataset goes here

# nolint start: open_curly_linter
if (!exists("daa_indicator_data")) { load("support_files/daa_indicator_data.Rda") }
if (!exists("pvls_emr")) { load("support_files/pvls_emr.Rda") }
#nolint end

combined_data <- daa.analytics::combine_data(daa_indicator_data = daa_indicator_data,
                                             pvls_emr = pvls_emr)
save(combined_data, file = "support_files/combined_data.rda")
