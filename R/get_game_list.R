#' Get list of games / Match ID's
#'
#' @description  Create an SQL query to opendotas API and extracts a list of games from the
#' public_matches table. This is only a sample of matches, not all are included here. Returns a
#' vector of match ID's ready for use in the get_games() function.
#'
#' @param num_matches Number of matches you want to extract
#' @param from_time Earliest time of match in YMD text format.
#' @param to_time Latest start time of the match in YMD text format.
#' @param min_mmr Minimum average MMR of the match (defaulted to 1)
#' @param min_duration Minium match duration in seconds, defaulted to 1200 (20 minutes)
#' @param num_open_profile Minium number of open profiles in the game. Higher number here gives
#'     higher percentage of games that are actually parsed.
#'
#' @return Returns data frame of results fulfilling the parameters input.
#' @export
#'
#' @examples
#' \dontrun{
#' match_ids <- get_game_list(num_matches = 100,
#' from_time = "20170101" ,
#' to_time = "20170423",
#' min_mmr = 4000)
#' }
get_game_list <- function(num_matches,
                          from_time,
                          to_time,
                          min_mmr = 1,
                          min_duration = 1200,
                          num_open_profile = 0) {

  # Work with the from and to time, set to epoch date
  from_time <- as.integer(lubridate::ymd(from_time, tz = "gmt"))
  to_time <- as.integer(lubridate::ymd(to_time, tz = "gmt"))

  # Need to set a high scientific notation penalty, or the paste function will make
  # the sql query with scientific numbers
  options("scipen"=10)

  # Create SQL query text
  sql_query <- paste("select * from public_matches where",
                     "start_time >", from_time, "AND",
                     "start_time <", to_time, "AND",
                     "duration >", min_duration, "AND",
                     "num_mmr >=", num_open_profile, "AND",
                     "avg_mmr >", min_mmr,
                     "limit", num_matches)

  # Execute query on opendota API
  game_list <- jsonlite::fromJSON(paste("https://api.opendota.com/api/explorer?sql=",
                                        utils::URLencode(sql_query),
                                        sep=""))

  # Extract the relevant table and convert to dataframe
  game_list_df <- game_list$rows

  # Output the DF
  return(game_list_df)
}
