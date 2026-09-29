#' Source-reference card
#'
#' `TosiSourceReference` is a compact card for a source document, included in
#' [tosi_metadata()] and [tosi_index_document()] results. It holds a labelled
#' URI and optional description, not the document body. To retrieve a supported
#' reference's text, use [tosi_source_reference()], which returns a
#' [TosiSourceDocument]. Fields are read-only; direct and nested replacement
#' fails.
#'
#' @field uri Single HTTP(S) or platform source-reference URI.
#' @field title Single human-readable label.
#' @field relationship Relationship between the source object and reference.
#' @field lang Optional natural-language code for the label card.
#' @field description Optional short description.
#' @keywords internal
#' @export
TosiSourceReference <- R6Class(
  "TosiSourceReference",
  portable = FALSE,
  public = list(
    #' @description Construct a compact source-reference card.
    #' @param uri Single HTTP(S) or platform source-reference URI.
    #' @param title Single human-readable label.
    #' @param relationship Relationship between the source object and reference.
    #' @param lang Optional natural-language code for the label card.
    #' @param description Optional short description.
    #' @return A new `TosiSourceReference` object.
    initialize = function(
      uri,
      title,
      relationship,
      lang = NULL,
      description = NULL
    ) {
      validate_source_reference_uri(uri)
      validate_scalar_string(title, arg = "title")
      relationship <- validate_source_reference_relationship(relationship)
      if (!is.null(lang)) {
        validate_natural_language(lang, "lang")
      }
      validate_scalar_string(
        description,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "description"
      )

      private$.uri <- uri
      private$.title <- title
      private$.relationship <- relationship
      private$.lang <- lang
      private$.description <- description

      invisible(self)
    },

    #' @description Return the card fields as a named list.
    #' @return A named list containing the card fields.
    as_list = function() {
      list(
        uri = self$uri,
        title = self$title,
        relationship = self$relationship,
        lang = self$lang,
        description = self$description
      )
    },

    #' @description Format a concise card summary.
    #' @param ... Reserved for future formatting options; currently ignored.
    #' @return A character vector containing the card summary.
    format = function(...) {
      lang <- if (!is.null(self$lang)) glue(", lang: {self$lang}") else ""
      c(
        glue("<TosiSourceReference> {self$relationship}{lang}"),
        glue("Title: {self$title}"),
        glue("URI: {self$uri}"),
        if (!is.null(self$description)) {
          glue("Description: {self$description}")
        }
      )
    },

    #' @description Print the concise card summary.
    #' @param ... Arguments passed to `$format()`.
    #' @return The `TosiSourceReference` object, invisibly.
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
    .description = NULL
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
    description = function(value) {
      if (!missing(value)) {
        cli_abort("{.field description} is read-only.")
      }
      private$.description
    }
  )
)

validate_source_reference_relationship <- function(relationship) {
  rlang::arg_match(
    relationship,
    c(
      "methodology",
      "concepts",
      "classification",
      "quality",
      "notes",
      "contact",
      "source",
      "license",
      "other"
    )
  )
}

validate_source_reference_uri <- function(uri) {
  validate_scalar_string(uri, arg = "uri")
  parsed <- tryCatch(
    curl::curl_parse_url(uri),
    error = function(e) {
      cli_abort(
        c("Invalid source-reference URI: {.val {uri}}", "i" = e$message),
        parent = e,
        call = NULL
      )
    }
  )

  if (parsed$scheme %in% c("http", "https")) {
    return(invisible(uri))
  }
  if (!identical(parsed$scheme, "tosi")) {
    cli_abort(
      "{.field uri} must use HTTP(S) or {.val tosi://source-reference/...}."
    )
  }
  if (!identical(parsed$host, "source-reference")) {
    cli_abort(paste0(
      "Platform source-reference URIs must start with ",
      "{.val tosi://source-reference/}."
    ))
  }

  parts <- str_remove(parsed$path %||% "", "^/") |>
    str_split_1("/")
  parts <- parts[nzchar(parts)]
  if (length(parts) < 2L) {
    cli_abort(paste0(
      "Platform source-reference URIs must include ",
      "connector_id and reference_id."
    ))
  }
  connector_id(parts[[1L]])

  params <- parsed$params
  if (length(params) > 0L) {
    keys <- names(params)
    if (is.null(keys)) {
      keys <- rep("", length(params))
    }
    unknown <- unique(keys[is.na(keys) | !nzchar(keys) | keys != "lang"])
    if (length(unknown) > 0L) {
      cli_abort(c(
        paste(
          "Platform source-reference URIs only support the {.arg lang}",
          "query parameter."
        ),
        "x" = "Unsupported query parameter{?s}: {.val {unknown}}"
      ))
    }
  }
  if (length(params) > 0L && !is.null(names(params))) {
    uri_lang <- params[names(params) == "lang"]
    if (length(uri_lang) > 0L) {
      validate_natural_language(unname(uri_lang[[1L]]), "lang")
    }
  }
  invisible(uri)
}
