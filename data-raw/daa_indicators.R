## code to prepare `daa_indicators` dataset goes here
daa_indicators <-
  tibble::tribble(
    ~uid, ~indicator, ~notes,
    "xNTzinnVgba", "HTS_TST", "2018-2019",                                  #1
    "V6hxDYUZFBq", "HTS_TST", "2020-2021 (filter)",                         #2
    "BRalYZhcHpi", "HTS_TST", "2020-2021 (filter)",                         #3
    "yEQ5FoXJWAx", "PMTCT_ART", "2018-2021 (ARVs)",                         #4
    "I2GezpUpSUK", "PMTCT_ART", "2021 (Age/NewExistingArt/Sex/HIVStatus)",  #5
    "aeCf1jJWE1x", "PMTCT_STAT", "2018-2019",                               #6
    "qFWmLNueTPF", "PMTCT_STAT", "2020-2021",                               #7
    "iDf461nJDJr", "PMTCT_STAT", "2020-2021",                               #8
    "sdarqD1J8fb", "TX_CURR", "2018-2021",                                  #9
    "GxUQu72i38n", "TX_CURR", "2018-2021",                                  #10
    "Mon8vQgC9qg", "TX_NEW", "2018-2021",                                   #11
    "l697bKzFRSv", "TX_NEW", "2018-2021",                                   #12
    "J1E7eh1CyA0", "TB_PREV_LEGACY", "2018-2019 (Age/Sex/HIVStatus)",       #13
    "LZbeWYZEkYL", "TB_PREV_LEGACY", "2018-2019 (Therapy Type)",            #14
    "oFFlA4vaSWD", "TB_PREV", "2020-2021"                                   #15
  )
usethis::use_data(daa_indicators, overwrite = TRUE)
