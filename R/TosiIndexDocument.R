#' Metadata and schema for indexing a source object
#'
#' [tosi_index_document()] returns a `TosiIndexDocument` containing one native
#' [TosiMetadata] and one [TosiSchema] for the same natural language, source
#' identity and version. The models retain their ordinary methods, source
#' references, attributes, units and domains.
#'
#' Fields are read-only. Language, identity and version are derived from the
#' contained schema. `$as_list()` recursively projects the models to ordinary R
#' data.
#'
#' @field metadata A genuine [TosiMetadata] object.
#' @field schema A genuine [TosiSchema] object.
#' @field lang Natural language, derived from the schema.
#' @field connector_id Canonical connector identity, derived from the schema.
#' @field object_id Canonical object identity, derived from the schema.
#' @field data_version Source version, derived from the schema.
#' @export
TosiIndexDocument <- R6Class(
  "TosiIndexDocument",
  portable = FALSE,
  public = list(
    #' @description
    #' Compose metadata and schema with matching identity, version and language.
    #' Agreement does not promise an atomic source snapshot. Construction never
    #' rewrites a contained version to make independently acquired models agree.
    #' @param metadata A genuine `TosiMetadata` object.
    #' @param schema A genuine `TosiSchema` object.
    #' @return A new `TosiIndexDocument` object.
    initialize = function(metadata, schema) {
      if (
        !inherits(metadata, "TosiMetadata") || !inherits(schema, "TosiSchema")
      ) {
        cli_abort(
          "Index models must be genuine {.cls TosiMetadata} and {.cls TosiSchema} objects."
        )
      }
      # The contained constructors own individual model validity. This boundary
      # only establishes agreement across those already constructed models.
      if (!identical(metadata$lang, schema$lang)) {
        cli_abort("Index models must share the same natural language.")
      }
      if (
        !identical(metadata$connector_id, schema$connector_id) ||
          !identical(metadata$object_id, schema$object_id)
      ) {
        cli_abort("Index models must share canonical source identity.")
      }
      if (metadata$data_version != schema$data_version) {
        cli_abort("Index models must share the same source version.")
      }
      private$.metadata <- metadata
      private$.schema <- schema
      invisible(self)
    },
    #' @description Recursively project the contained models to ordinary R data.
    #' @return A named list with derived flat identity and language, metadata and schema.
    as_list = function() {
      list(
        connector_id = self$connector_id,
        object_id = self$object_id,
        data_version = self$data_version,
        lang = self$lang,
        metadata = self$metadata$as_list(),
        schema = self$schema$as_list()
      )
    },
    #' @description Format a concise summary without retrieving source data.
    #' @param ... Reserved for formatting options; currently ignored.
    #' @return A character vector containing the summary.
    format = function(...) {
      c(
        glue("<TosiIndexDocument> {self$connector_id}/{self$object_id}"),
        glue("Language: {self$lang}")
      )
    },
    #' @description Print a concise summary.
    #' @param ... Arguments passed to `$format()`.
    #' @return This index document, invisibly.
    print = function(...) {
      cat(self$format(...), sep = "\n")
      invisible(self)
    }
  ),
  private = list(.metadata = NULL, .schema = NULL),
  active = list(
    metadata = function(value) {
      if (!missing(value)) {
        cli_abort("{.field metadata} is read-only.")
      }
      private$.metadata
    },
    schema = function(value) {
      if (!missing(value)) {
        cli_abort("{.field schema} is read-only.")
      }
      private$.schema
    },
    lang = function(value) {
      if (!missing(value)) {
        cli_abort("{.field lang} is read-only.")
      }
      private$.schema$lang
    },
    connector_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field connector_id} is read-only.")
      }
      private$.schema$connector_id
    },
    object_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field object_id} is read-only.")
      }
      private$.schema$object_id
    },
    data_version = function(value) {
      if (!missing(value)) {
        cli_abort("{.field data_version} is read-only.")
      }
      private$.schema$data_version
    }
  )
)
