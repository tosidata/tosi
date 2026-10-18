#' Source identity and version
#'
#' `TosiDataReference` holds a canonical connector/object pair and its required
#' source data version. A [TosiSchema] owns one reference through its
#' `$reference` field. The reference contains no schema or observations.
#'
#' Fields are read-only; direct and nested replacement fails. The version's
#' shape is checked here; the producer establishes which source input it
#' describes. Equal references do not imply equal schemas, selected rows, or
#' physical representations.
#'
#' @field connector_id Scalar canonical connector ID vector.
#' @field object_id Scalar canonical object ID vector.
#' @field data_version Finite non-missing scalar `POSIXct` source version.
#' @export
TosiDataReference <- R6Class(
  "TosiDataReference",
  portable = FALSE,
  public = list(
    #' @description
    #' Construct a source reference using the canonical ID constructors and
    #' required source-version checks.
    #'
    #' @param connector_id Scalar canonical connector ID.
    #' @param object_id Scalar canonical object ID.
    #' @param data_version Finite non-missing scalar `POSIXct` source version.
    #' @return A new `TosiDataReference` object.
    initialize = function(connector_id, object_id, data_version) {
      # Validate before function-position lookup because the accepted formal
      # names shadow the canonical constructor bindings.
      validate_scalar_string(connector_id)
      validate_scalar_string(object_id)
      canonical_connector_id <- connector_id(connector_id)
      canonical_object_id <- object_id(object_id)
      validate_required_data_version(data_version, "data_version")

      private$.connector_id <- canonical_connector_id
      private$.object_id <- canonical_object_id
      private$.data_version <- data_version
    },

    #' @description
    #' Return the reference fields as a named list.
    #' @return A named list containing canonical IDs and the source version.
    as_list = function() {
      list(
        connector_id = self$connector_id,
        object_id = self$object_id,
        data_version = self$data_version
      )
    }
  ),
  private = list(
    .connector_id = NULL,
    .object_id = NULL,
    .data_version = NULL
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
    data_version = function(value) {
      if (!missing(value)) {
        cli_abort("{.field data_version} is read-only.")
      }
      private$.data_version
    }
  )
)
