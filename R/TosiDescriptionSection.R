#' Source-backed description section
#'
#' A read-only section contains plain source text, an optional source heading
#' and an optional language-independent semantic type. [TosiMetadata] contains
#' an ordinary ordered list of sections and owns their language and complete
#' text extraction through `$description_text()`. No classification, translation
#' or source retrieval is performed.
#'
#' Types form an extensible vocabulary, not a closed enumeration. Conventions
#' are `description` for an explicit general description, `interpretation` for
#' source guidance, `limitations` for source cautions, and `notes` for other
#' explanatory notices. Use a type only when a source field or heading supports
#' it. Unfamiliar types are retained; `NULL` means unclassified text and does not
#' imply that interpretation or limitations are absent. An unfamiliar heading
#' may retain its title without a type.
#'
#' Fields reject direct and nested replacement. Section instances use ordinary
#' R6 reference semantics; metadata retains them without cloning.
#'
#' @field text Plain section text.
#' @field title Optional source heading.
#' @field type Optional language-independent semantic type.
#' @export
#' @examples
#' section <- TosiDescriptionSection$new(
#'   "Survey estimates.", title = "Methods", type = "interpretation"
#' )
#' section$text
#' section$as_list()
TosiDescriptionSection <- R6Class(
  "TosiDescriptionSection",
  portable = FALSE,
  public = list(
    #' @description Construct a source-backed description section.
    #' @param text Plain section text.
    #' @param title Optional source heading.
    #' @param type Optional language-independent semantic type. No type is inferred.
    #' @return A new `TosiDescriptionSection` object.
    initialize = function(text, title = NULL, type = NULL) {
      private$.text <- text
      private$.title <- title
      private$.type <- type
      invisible(self)
    },
    #' @description Project the section to ordinary R data.
    #' @return A named list containing text and any supplied title and type.
    as_list = function() {
      discard(
        list(text = self$text, title = self$title, type = self$type),
        is.null
      )
    }
  ),
  private = list(.text = NULL, .title = NULL, .type = NULL),
  active = list(
    text = function(value) {
      if (!missing(value)) {
        cli_abort("{.field text} is read-only.")
      }
      private$.text
    },
    title = function(value) {
      if (!missing(value)) {
        cli_abort("{.field title} is read-only.")
      }
      private$.title
    },
    type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field type} is read-only.")
      }
      private$.type
    }
  )
)
