## code to prepare `combined_data` dataset goes here

# nolint start: open_curly_linter
if (!exists("daa_indicator_data")) { daa_indicator_data <- readRDS(file = "support_files/daa_indicator_data.rds") }
if (!exists("pvls_emr")) { pvls_emr <- readRDS(file = "support_files/pvls_emr.rds") }
if (!exists("attribute_data")) { attribute_data <- readRDS(file = "support_files/attribute_data.rds") }
if (!exists("ou_hierarchy")) { ou_hierarchy <- readRDS(file = "support_files/ou_hierarchy.rds") }
#nolint end

combined_data <- daa.analytics::combine_data(daa_indicator_data = daa_indicator_data,
                                             ou_hierarchy = ou_hierarchy,
                                             pvls_emr = pvls_emr, attribute_data = attribute_data)
saveRDS(combined_data, file = "support_files/combined_data.rds")
