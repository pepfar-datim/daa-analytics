# Code to prepare the global summary spreadsheet goes here

if(!exists("combined_data")){ load("combined_data") }

globalSummary <- daa.analytics::global_summary(combined_data)
write.csv(globalSummary, "global_summary.csv")
