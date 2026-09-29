#' Descriptive metadata
#'
#' [tosi_metadata()] returns a `TosiMetadata` containing the title, source,
#' language, version, and optional description and source-reference cards.
#' Fields are read-only; direct and nested replacement fails. `$as_list()`
#' returns the metadata as a named list.
#'
#' @field connector_id Scalar canonical connector ID vector.
#' @field object_id Scalar canonical object ID vector.
#' @field source_object_id Optional source-native object identifier.
#' @field data_version Finite non-missing scalar `POSIXct` source version.
#' @field lang Natural-language code used by scalar labels.
#' @field title Human-facing object title.
#' @field source_label Human-facing source label.
#' @field description Optional object description.
#' @field subject_area Optional subject-area label.
#' @field next_update Optional next-update date, timestamp, or string.
#' @field source_references A [TosiSourceReference] card or list of cards,
#'   not retrieved [TosiSourceDocument] objects. A single card becomes a
#'   one-element list.
#'
#' @export
TosiMetadata <- R6Class(
  "TosiMetadata",
  portable = FALSE,
  public = list(
    #' @description
    #' Construct a single-language object metadata result.
    #'
    #' @param connector_id Scalar canonical connector ID.
    #' @param object_id Scalar canonical object ID.
    #' @param data_version Finite non-missing scalar `POSIXct` source version.
    #' @param lang Natural-language code used by scalar labels.
    #' @param title Human-facing object title.
    #' @param source_label Human-facing source label.
    #' @param source_object_id Optional source-native object identifier.
    #' @param description Optional object description.
    #' @param subject_area Optional subject-area label.
    #' @param next_update Optional next-update date, timestamp, or string.
    #' @param source_references Genuine compact `TosiSourceReference` card or
    #'   list of cards.
    #'
    #' @return A new `TosiMetadata` object.
    initialize = function(
      connector_id,
      object_id,
      data_version,
      lang,
      title,
      source_label,
      source_object_id = NULL,
      description = NULL,
      subject_area = NULL,
      next_update = NULL,
      source_references = list()
    ) {
      # Validate before function-position lookup because the accepted formal
      # names shadow the canonical constructor bindings.
      validate_scalar_string(connector_id)
      validate_scalar_string(object_id)
      canonical_connector_id <- connector_id(connector_id)
      canonical_object_id <- object_id(object_id)

      validate_scalar_string(
        source_object_id,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "source_object_id"
      )
      validate_required_data_version(data_version, "data_version")
      validate_natural_language(lang, "lang")
      validate_scalar_string(title, arg = "title")
      validate_scalar_string(source_label, arg = "source_label")
      validate_scalar_string(
        description,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "description"
      )
      validate_scalar_string(
        subject_area,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "subject_area"
      )
      validate_optional_next_update(next_update, "next_update")
      if (
        R6::is.R6(source_references) &&
          inherits(source_references, "TosiSourceReference")
      ) {
        source_references <- list(source_references)
      }
      if (!is.list(source_references)) {
        cli_abort(paste0(
          "{.field source_references} must be a genuine ",
          "{.cls TosiSourceReference} or list of them."
        ))
      }
      valid_source_references <- map_lgl(
        source_references,
        \(reference) {
          R6::is.R6(reference) &&
            inherits(reference, "TosiSourceReference")
        }
      )
      if (!all(valid_source_references)) {
        cli_abort(paste0(
          "{.field source_references} must contain only genuine ",
          "{.cls TosiSourceReference} objects."
        ))
      }

      private$.connector_id <- canonical_connector_id
      private$.object_id <- canonical_object_id
      private$.source_object_id <- source_object_id
      private$.data_version <- data_version
      private$.lang <- lang
      private$.title <- title
      private$.source_label <- source_label
      private$.description <- description
      private$.subject_area <- subject_area
      private$.next_update <- next_update
      private$.source_references <- source_references

      invisible(self)
    },

    #' @description
    #' Return the metadata as a named list, with source-reference cards as
    #' named lists.
    #'
    #' @return A named list containing the metadata fields and source
    #'   references.
    as_list = function() {
      list(
        connector_id = self$connector_id,
        object_id = self$object_id,
        source_object_id = self$source_object_id,
        data_version = self$data_version,
        lang = self$lang,
        title = self$title,
        source_label = self$source_label,
        description = self$description,
        subject_area = self$subject_area,
        next_update = self$next_update,
        source_references = map(
          self$source_references,
          \(reference) reference$as_list()
        )
      )
    }
  ),
  private = list(
    .connector_id = NULL,
    .object_id = NULL,
    .source_object_id = NULL,
    .data_version = NULL,
    .lang = NULL,
    .title = NULL,
    .source_label = NULL,
    .description = NULL,
    .subject_area = NULL,
    .next_update = NULL,
    .source_references = NULL
  ),
  active = list(
    connector_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field connector_id} is read-only.")
      }
      private$.connector_id
    },
    object_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field object_id} is read-only.")
      }
      private$.object_id
    },
    source_object_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field source_object_id} is read-only.")
      }
      private$.source_object_id
    },
    data_version = function(value) {
      if (!missing(value)) {
        cli_abort("{.field data_version} is read-only.")
      }
      private$.data_version
    },
    lang = function(value) {
      if (!missing(value)) {
        cli_abort("{.field lang} is read-only.")
      }
      private$.lang
    },
    title = function(value) {
      if (!missing(value)) {
        cli_abort("{.field title} is read-only.")
      }
      private$.title
    },
    source_label = function(value) {
      if (!missing(value)) {
        cli_abort("{.field source_label} is read-only.")
      }
      private$.source_label
    },
    description = function(value) {
      if (!missing(value)) {
        cli_abort("{.field description} is read-only.")
      }
      private$.description
    },
    subject_area = function(value) {
      if (!missing(value)) {
        cli_abort("{.field subject_area} is read-only.")
      }
      private$.subject_area
    },
    next_update = function(value) {
      if (!missing(value)) {
        cli_abort("{.field next_update} is read-only.")
      }
      private$.next_update
    },
    source_references = function(value) {
      if (!missing(value)) {
        cli_abort("{.field source_references} is read-only.")
      }
      private$.source_references
    }
  )
)
