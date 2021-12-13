#' @export
#' @title Get DAA Indicator Data
#'
#' @description
#' Fetches DAA indicator data for both PEPFAR and the MOH partner for a single
#' country.
#'
#' @param ou_uid UID for the Operating Unit whose data is being queried.
#' @param d2_session DHIS2 Session id for the DATIM session.
#'
#' @return Dataframe of unadorned PEPFAR and the MOH DAA indicator data.
#'
get_daa_data <- function(ou_uid, d2_session) {

  indicator_uids <- daa.analytics::daa_indicators$uid

  period_list <-
    paste(paste0(2017:(daa.analytics::current_fiscal_year()), "Oct"),
          collapse = ";")

  # TODO Make this into a tryCatch to future proof against large OUs timing out
  # Breaks the query into multiple parts for Nigeria to prevent timeout
  df <- tryCatch({
      datimutils::getAnalytics(
        paste0("dimension=SH885jaRe0o:mXjFJEexCHJ;t6dWOH7W5Ml&",
               "displayProperty=SHORTNAME&outputIdScheme=UID"),
        dx = paste(indicator_uids, collapse = ";"),
        pe = period_list,
        ou = paste0("OU_GROUP-POHZmzofoVx;", ou_uid),
        d2_session = d2_session,
        retry = 2
      )
    },
    # If error is thrown, then try again splitting query into multiple parts.
    error = function(e) {
      # TODO log this in a log file.
      # Prints an error message.
      print(
        paste0("Error: Timeout was reached after 60 seconds with 0 bytes",
               "received. Trying again with query broken into smaller chunks.")
      )
      # Pulls data for each indicator as an individual query to shrink size
      indicator_uids %>%
        # Makes queries for each group of indicators
        lapply(function(x) {
          datimutils::getAnalytics(
            paste0("dimension=SH885jaRe0o:mXjFJEexCHJ;t6dWOH7W5Ml&",
                   "displayProperty=SHORTNAME&outputIdScheme=UID"),
            dx = x,
            pe = period_list,
            ou = paste0("OU_GROUP-POHZmzofoVx;", ou_uid),
            d2_session = d2_session
          )
        }) %>%
        # Binds all of the component dataframes together
        dplyr::bind_rows()
    }
  )
  # Returns null if API returns nothing
  if (is.null(df)) {
    return(NULL)
  }
  # Returns dataframe
  return(df)
}
