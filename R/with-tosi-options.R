#' Use temporary TosiData settings
#'
#' Evaluate an expression with temporary connection, language, or cache settings.
#' Previous TosiData options are restored when the expression finishes, including
#' when it raises an error. Only supplied settings are changed. Environment
#' variables are unaffected; clearing a connection setting still allows the
#' environment fallback described in [tosi_options()].
#'
#' @param code Expression to evaluate in the calling environment.
#' @param ... Named settings passed to [tosi_options()].
#' @return The value of `code`, with its visibility preserved.
#' @export
#' @examples
#' with_tosi_options(getOption("tosi.language_preference"),
#'   language_preference = c("fi", "en")
#' )
with_tosi_options <- function(code, ...) {
  option_names <- paste0("tosi.", names(formals(tosi_options)))
  previous <- options()[intersect(names(options()), option_names)]
  absent <- setdiff(option_names, names(previous))
  previous[absent] <- rep(list(NULL), length(absent))
  on.exit(options(previous), add = TRUE)
  tosi_options(...)
  force(code)
}
