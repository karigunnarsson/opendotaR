#' Fetch the games from the opendota API.
#'
#' @description Takes a vector of numerical value match ID's of dota2 replays, and attempts to
#' fetch them from the opendota API only parsed matches are output.
#'
#' @param game_vec Numeric vector of match ID's
#' @param wait_time how long to wait (in seconds) between each API call, default is 1 sec (opendota
#'     asks you not to send more than 1 call per second)
#' @param output Defaulted to "all", which will extract entire JSON, if not all, it should have the
#'     path to an R file that will be sourced and create some output, not the R file must also
#'     output to output_list()
#' @param verbose Give live information on status of parsing, if FALSE no text is output to console.
#'
#' @return Returns a list of objects, if output == "all" it's a list of JSON outputs.
#' @export
#'
#' @examples
#' \dontrun{
#' match_ids <- get_game_list(num_matches = 100,
#' from_time = "20170101",
#' to_time = "20170423",
#' min_mmr = 4000)
#' get_games(match_ids)
#' }
get_games <- function(game_vec,
                      wait_time = 1.00,
                      output = "all",
                      verbose = TRUE) {
  # Check that input is of correct format
  if (!(is.vector(game_vec) & is.numeric(game_vec))) {
    stop("game_vec input must be a numeric vector containing match IDs")
  }

  if (output != "all") {
    # Check if output != "all", that it does point to an actual file.
    if (!file.exists(output)) {
      stop(paste("Output must either be 'all' or a file, file '",
                 output,
                 "' does not exist.", sep =""))
    }
  }

  # Make sure the match ID's are unique to avoid double work
  game_vec <- unique(game_vec)

  # Initialize the dataframe and count variables
  parsed_count <- 1
  not_parsed_count <- 0
  error_count <- 0
  output_list <- list()

  num_rows <- length(game_vec)
  # Iterate through all the games we have
  for (i in 1:num_rows) {
    if (verbose == TRUE) {
      cat(paste("\rParsing game", i, "of", num_rows))
    }
    match_id <- game_vec[i]

    start_time <- proc.time()[3]

    # Read the JSON (using error handling)
    read_json <- tryCatch(
      jsonlite::fromJSON(paste("https://api.opendota.com/api/matches/", match_id, sep = "")),
      error = function (e) {"error"}
    )

    # Check if we got HTTP error, if so, go to next match_id after an API delay
    if (read_json == "error") {
      error_count <- error_count + 1
      api_delay(start_time, wait_time)
      next
    }

    # If no cosmetics are shown, we assume it's not parsed and go to the next one after an API delay
    if (is.null(read_json$cosmetics)) {
      not_parsed_count <- not_parsed_count + 1
      api_delay(start_time, wait_time)
      next
    }

    # If output == all then we take the entire JSON from the API and output it without modification
    if (output == "all") {
      output_list[[parsed_count]] <- read_json
    } else {
      # If output is not all, it's a file to be sourced and run, the sourced file (should) subset
      # the data, only fetch what the user wants, and output it to the output_list.
      source(output, local = TRUE)
    }

    # Finalize the loop and run the API delay
    parsed_count <- parsed_count + 1
    api_delay(start_time, wait_time)
  }
  # Print some aggregated information on how many games were parsed
  if (verbose == TRUE) {
    cat(paste("\nTotal matches:", num_rows, "\n"),
        paste("Total parsed:", parsed_count, "\n"),
        paste("Total not-parsed:", not_parsed_count, "\n"),
        paste("Total errors:", error_count, "\n"))
  }

  # Return the full list of games
  return(output_list)
}
