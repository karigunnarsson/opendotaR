#' Function that controls the delay between API calls to opendota, user can specify the wait_time, but opendota asks
#' you to limit yourself to 1 call per second
#'
#' @param start_time Time of last API call
#' @param wait_time Desired wait time between API calls
#'
#' @return There is no return, it simply sleeps the system for whatever time needed to reach wait_time
#' @export
#'
#' @examples
#' \dontrun{
#' api_delay(start_time, wait_time)
#' }
api_delay <- function(start_time, wait_time = 1.00) {
  # Define end time and total time used
  end_time <- proc.time()[3]
  tot_time <- end_time - start_time

  # If total time used is greater than wait time we do nothing, if it's lower, the system sleeps until we reach it
  # and can move onto next API call without incurring the wrath of opendota
  if (tot_time <= wait_time) {
    Sys.sleep(wait_time - tot_time)
  }
}
