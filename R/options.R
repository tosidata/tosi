#' Configure your `tosi` options
#'
#' Set your service URL and access token before retrieving data. You can also
#' choose your preferred languages. Settings apply to subsequent calls in the
#' current R session.
#'
#' You only need to supply the settings you want to change. For example,
#' changing your language preference leaves your connection settings alone.
#'
#' @param url The HTTPS service URL provided with your TosiData access details.
#'   If no scheme is supplied, `https://` is added.
#' @param token Your access token. Treat it like a password: do not include a
#'   real token in code you share or commit to version control.
#' @param language_preference Language codes in order of preference. For
#'   example, `c("fi", "en")` requests Finnish when available, then English.
#'   When no preference is set or none of the preferred languages is available,
#'   the service uses the source's first language. This is a default, not a
#'   restriction: see [tosi()] for choosing a language for an individual call.
#'
#' @param cache_memory_size,cache_disk_size Cache size budgets in bytes.
#'   Defaults are 256 MiB in memory and 1 GiB on disk. `NULL` restores the
#'   corresponding default. Changing a size discards cached results on the
#'   next table request.
#'
#' @section Table cache:
#' Only table results from [tosi()] and [tosi_data()] are cached, using memory
#' and temporary disk storage for this R session. Each layer keeps results for
#' about five minutes; a disk hit restarts the memory lifetime.
#' Call [tosi_cache_clear()] before requesting fresh data. Cache size budgets
#' do not limit total R memory use.
#'
#' @section Connecting safely:
#' Use a service you trust. Your token is sent to the configured service for
#' both requests and result downloads. Results are restored as native R
#' objects, so receiving them requires trusting the service as well.
#'
#' @section Changing and clearing settings:
#' Call `tosi_options()` again with just the setting you want to change.
#' Use `language_preference = NULL` to clear your language preference.
#' Similarly, `url = NULL` or `token = NULL` clears that connection setting;
#' an environment variable may still provide its value (see below).
#' Calling `tosi_options()` with no arguments changes nothing.
#'
#' @section Environment variables and R options:
#' For persistent setup or automated scripts, you can supply the connection
#' details through `TOSI_URL` and `TOSI_TOKEN` environment variables. For
#' example, add these lines with your own values to `~/.Renviron` and restart R:
#'
#' ```text
#' TOSI_URL=https://service.example.invalid
#' TOSI_TOKEN=your-access-token
#' ```
#'
#' Values set with `tosi_options()` take priority over environment variables.
#' Clearing a URL or token setting with `NULL` makes the package use the
#' corresponding environment variable again; it does not revoke your token.
#' Without a URL from either source, requests cannot proceed.
#'
#' The settings are stored as the R options `tosi.url`, `tosi.token`,
#' `tosi.language_preference`, `tosi.cache_memory_size`, and
#' `tosi.cache_disk_size`. They are read when you make a request. The function
#' does not change environment variables or write files, so settings made with
#' it do not carry over when you restart R. There are no environment variables
#' for language preferences or cache sizes.
#'
#' @return Invisible `NULL`. The function changes settings without displaying
#'   them or returning your token.
#' @examples
#' \dontrun{
#' # Connect using the details provided to you (placeholders shown here).
#' tosi_options(
#'   url = "https://service.example.invalid",
#'   token = "<your-access-token>"
#' )
#'
#' # Prefer Finnish, then English, without changing the connection.
#' tosi_options(language_preference = c("fi", "en"))
#'
#' # Let the service choose the language again.
#' tosi_options(language_preference = NULL)
#' }
#' @export
tosi_options <- function(
  url = NULL,
  token = NULL,
  language_preference = NULL,
  cache_memory_size = NULL,
  cache_disk_size = NULL
) {
  if (!missing(url)) {
    if (!is.null(url) && nzchar(url) && !str_detect(url, "://")) {
      url <- paste0("https://", url)
    }
    options(tosi.url = url)
  }
  if (!missing(token)) {
    options(tosi.token = token)
  }
  if (!missing(language_preference)) {
    options(tosi.language_preference = language_preference)
  }
  if (!missing(cache_memory_size)) {
    options(tosi.cache_memory_size = cache_memory_size)
  }
  if (!missing(cache_disk_size)) {
    options(tosi.cache_disk_size = cache_disk_size)
  }
  invisible(NULL)
}
