#' Obtain the latest parsed games, this is a good function to use if you're not picky on which
#' dates or MMR your data is, but want fast data. The latest games will always have parsed games
#' opposed to the general game list gotten from get_game_list(), wich only contains 5 - 10% parsed
#' games.
#'
#' @param num_games Min number of games you want to obtain (could get 1-10 more)
#' @param min_duration Do you want to exclude games below a certain duration threshold? We default
#'     it to 1200seconds (20 minutes), as super short games often contain early abandons and griefers.
#' @param wait_time Wait time between API calls, default to 1.00 (which is what opendota wants you
#'     to stay below, so don¨t change unless you have a good reason and talked to opendota about it).
#' @param output Defaulted to "all", which will extract entire JSON, if not all, it should have the
#'     path to an R file that will be sourced and create some output, note the R file must also
#'     output to output_list()
#'
#' @return
#' @export
#'
#' @examples
#' \dontrun{
#' parsed_games <- get_latest_games(100)
#' }
get_latest_games <- function(num_games,
                             min_duration = 1200,
                             wait_time = 1.00,
                             output = "all") {
  # Initialize various variables
  matches_parsed <- 0
  match_id_list <- c()
  all_parsed_games <- list()

  # Run while loop for as long as needed to obtain number of matches required
  while(matches_parsed <= num_games) {

    # Use api status to obtain the 10 latest games parsed.
    api_status <- jsonlite::fromJSON("https://api.opendota.com/api/status")
    game_list <- subset(api_status$last_parsed, duration > min_duration)$match_id

    # Remove all previously parsed games (there can be duplicates if it's a slow day)
    game_list <- game_list[!(game_list %in% match_id_list)]

    # Make sure we actually have games to parse, if we have zero games, it's probably a slow day,
    # so we make the system sleep for 5 seconds before querying again.
    if (length(game_list) == 0) {
      Sys.sleep(5)
      next
    }

    # Add all new match_id's to the match_id_list
    match_id_list <- c(match_id_list, game_list)

    # Parse the games
    parsed_games <- opendotaR::get_games(game_vec = game_list,
                                         wait_time = wait_time,
                                         output = output,
                                         verbose = FALSE)

    # Create output
    all_parsed_games[(matches_parsed + 1):(matches_parsed + length(parsed_games))] <- parsed_games

    # Updated the matches_parsed number
    matches_parsed <- matches_parsed + length(parsed_games)

    cat("\rParsed", matches_parsed, "games", max(num_games - matches_parsed, 0), "to go!")
  }

  cat("\nAll done! A total of", matches_parsed, "games parsed!")
  return(all_parsed_games)
}
