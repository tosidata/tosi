#' Retrieved source document
#'
#' Supported [tosi_source_reference()] calls return a `TosiSourceDocument`
#' containing a document's text, language, title, and source details. Unlike
#' the compact [TosiSourceReference] cards, this object contains the document
#' body in `$content`. Fields are read-only; direct and nested replacement
#' fails. `$format()` and `$print()` show a summary without the body.
#'
#' @field uri Single HTTP(S) or platform source-reference URI.
#' @field title Single human-readable document title.
#' @field relationship Relationship between the source object and document.
#' @field lang Natural-language code for the resolved document.
#' @field available_languages Available natural-language document codes.
#' @field content Resolved textual document body.
#' @field content_type Media type of the resolved document body.
#' @field source Optional human-readable source label.
#'
#' @export
TosiSourceDocument <- R6Class(
  "TosiSourceDocument",
  portable = FALSE,
  public = list(
    #' @description
    #' Construct a resolved source-document result.
    #'
    #' @param uri Single HTTP(S) or platform source-reference URI.
    #' @param title Single human-readable document title.
    #' @param relationship Relationship between the source object and document.
    #' @param lang Natural-language code for the resolved document.
    #' @param available_languages Available natural-language document codes.
    #' @param content Resolved textual document body.
    #' @param content_type Media type of the resolved document body.
    #' @param source Optional human-readable source label.
    #'
    #' @return A new `TosiSourceDocument` object.
    initialize = function(
      uri,
      title,
      relationship,
      lang,
      available_languages,
      content,
      content_type,
      source
    ) {
      validate_source_reference_uri(uri)
      validate_scalar_string(title, arg = "title")
      relationship <- validate_source_reference_relationship(relationship)
      validate_natural_language(lang, "lang")
      validate_natural_languages(
        available_languages,
        "available_languages"
      )
      if (!lang %in% available_languages) {
        cli_abort(
          "{.field lang} must be present in {.field available_languages}."
        )
      }
      validate_scalar_string(content, arg = "content")
      validate_scalar_string(content_type, arg = "content_type")
      validate_scalar_string(
        source,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "source"
      )

      private$.uri <- uri
      private$.title <- title
      private$.relationship <- relationship
      private$.lang <- lang
      private$.available_languages <- available_languages
      private$.content <- content
      private$.content_type <- content_type
      private$.source <- source

      invisible(self)
    },

    #' @description
    #' Return the document fields, including the body, as a named list.
    #'
    #' @return A named list containing the document fields.
    as_list = function() {
      list(
        uri = self$uri,
        title = self$title,
        relationship = self$relationship,
        lang = self$lang,
        available_languages = self$available_languages,
        content = self$content,
        content_type = self$content_type,
        source = self$source
      )
    },

    #' @description
    #' Format a concise document summary without the document body.
    #'
    #' @param ... Reserved for future formatting options; currently ignored.
    #'
    #' @return A character vector containing the document summary.
    format = function(...) {
      c(
        glue(
          "<TosiSourceDocument> {self$relationship} ",
          "[lang: {self$lang}, type: {self$content_type}]"
        ),
        glue("Title: {self$title}"),
        glue("URI: {self$uri}")
      )
    },

    #' @description
    #' Print the concise document summary without the document body.
    #'
    #' @param ... Arguments passed to `$format()`.
    #'
    #' @return The `TosiSourceDocument` object, invisibly.
    print = function(...) {
      cat(self$format(...), sep = "\n")
      invisible(self)
    }
  ),
  private = list(
    .uri = NULL,
    .title = NULL,
    .relationship = NULL,
    .lang = NULL,
    .available_languages = NULL,
    .content = NULL,
    .content_type = NULL,
    .source = NULL
  ),
  active = list(
    uri = function(value) {
      if (!missing(value)) {
        cli_abort("{.field uri} is read-only.")
      }
      private$.uri
    },
    title = function(value) {
      if (!missing(value)) {
        cli_abort("{.field title} is read-only.")
      }
      private$.title
    },
    relationship = function(value) {
      if (!missing(value)) {
        cli_abort("{.field relationship} is read-only.")
      }
      private$.relationship
    },
    lang = function(value) {
      if (!missing(value)) {
        cli_abort("{.field lang} is read-only.")
      }
      private$.lang
    },
    available_languages = function(value) {
      if (!missing(value)) {
        cli_abort("{.field available_languages} is read-only.")
      }
      private$.available_languages
    },
    content = function(value) {
      if (!missing(value)) {
        cli_abort("{.field content} is read-only.")
      }
      private$.content
    },
    content_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field content_type} is read-only.")
      }
      private$.content_type
    },
    source = function(value) {
      if (!missing(value)) {
        cli_abort("{.field source} is read-only.")
      }
      private$.source
    }
  )
)
