#' Connector help article
#'
#' [tosi_help()] returns a `TosiHelp` article with English Markdown instructions
#' for a connector, or the default help index. The six fields are read-only.
#' Use `$content` for the full text or `$as_list()` for a named list of fields.
#'
#' `$format()` returns the unchanged Markdown. `$print()` writes the complete
#' Markdown to the terminal, retaining link destinations and fenced examples.
#' `$format("html")` returns HTML text using the optional `commonmark` package.
#' These methods never open a browser or Viewer and never evaluate examples.
#' Content uses ordinary Markdown headings, lists, links and fenced code;
#' raw HTML, scripts and executable document chunks are outside this subset.
#'
#' @field connector_id Requested help topic (`"index"` for the default),
#'   or the connector identifier for connector help.
#' @field title Human-readable help title.
#' @field lang Help language, always `"en"`.
#' @field content_type Content media type, always `"text/markdown"`.
#' @field content Complete Markdown document.
#' @field core_version Producing core package version as a string.
#' @importFrom rlang is_installed
#' @keywords internal
#' @export
TosiHelp <- R6Class(
  "TosiHelp",
  portable = FALSE,
  public = list(
    #' @description Construct a help result without loading help resources.
    #' @param connector_id Requested topic (`"index"` for the default).
    #' @param title Human-readable help title.
    #' @param content Complete English Markdown document.
    #' @param core_version Producing core package version as a string.
    #' @return A new `TosiHelp` object.
    initialize = function(connector_id, title, content, core_version) {
      private$.connector_id <- connector_id
      private$.title <- title
      private$.content <- content
      private$.core_version <- core_version
      invisible(self)
    },

    #' @description Return the help fields as a named list.
    #' @return A named list containing the six help fields.
    as_list = function() {
      list(
        connector_id = self$connector_id,
        title = self$title,
        lang = self$lang,
        content_type = self$content_type,
        content = self$content,
        core_version = self$core_version
      )
    },

    #' @description Return Markdown or convert it to HTML without evaluation.
    #' @param format Output format: `"markdown"` (default) or `"html"`.
    #'   HTML requires the optional `commonmark` package.
    #' @return A single string containing Markdown or HTML text.
    format = function(format = c("markdown", "html")) {
      format <- rlang::arg_match(format)
      if (format == "markdown") {
        return(self$content)
      }
      if (!is_installed("commonmark")) {
        cli_abort(c(
          "Package {.pkg commonmark} is required for HTML conversion.",
          "i" = 'Install it with {.code install.packages("commonmark")}.',
          "i" = "Markdown formatting and printing work without it."
        ))
      }
      commonmark::markdown_html(self$content)
    },

    #' @description Print the complete Markdown without rendering or evaluation.
    #' @param ... Unused; printing always writes Markdown to the terminal.
    #' @return The `TosiHelp` object, invisibly.
    print = function(...) {
      cat(self$content, sep = "\n")
      invisible(self)
    }
  ),
  private = list(
    .connector_id = NULL,
    .title = NULL,
    .lang = "en",
    .content_type = "text/markdown",
    .content = NULL,
    .core_version = NULL
  ),
  active = list(
    connector_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field connector_id} is read-only.")
      }
      private$.connector_id
    },
    title = function(value) {
      if (!missing(value)) {
        cli_abort("{.field title} is read-only.")
      }
      private$.title
    },
    lang = function(value) {
      if (!missing(value)) {
        cli_abort("{.field lang} is read-only.")
      }
      private$.lang
    },
    content_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field content_type} is read-only.")
      }
      private$.content_type
    },
    content = function(value) {
      if (!missing(value)) {
        cli_abort("{.field content} is read-only.")
      }
      private$.content
    },
    core_version = function(value) {
      if (!missing(value)) {
        cli_abort("{.field core_version} is read-only.")
      }
      private$.core_version
    }
  )
)
