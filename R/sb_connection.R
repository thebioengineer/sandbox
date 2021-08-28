
#' sb connection: minimal
#'
#' The minimal test reporter provides the absolutely minimum amount of
#' information: whether each expectation has succeeded, failed or experienced
#' an error.  If you want to find out what the failures and errors actually
#' were, you'll need to run a more informative test reporter.
#'
#' @export
#' @family reporters
#' @importFrom R6
sb_connection <- R6::R6class(
  classname = "sb_connection",
  public = list(
    open_connection = function(){},
    close_connection = function(){},
    connection = function(){con}
  ),
  
  
    intern
    
)