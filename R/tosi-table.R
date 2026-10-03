## -- tosi_table S3 class -----------------------------------------------------
##
## A tosi_table is a tibble subclass with a top-level TosiSchema object and
## artifact metadata stored as attributes. The package makes no metadata
## guarantee after callers wrangle the table.

## -- Constructor --------------------------------------------------------------

#' Construct a schema-composed tosi_table
#'
#' This package-owned boundary validates the data-frame carrier shape, physical
#' column names, result scope, provenance, and presentation metadata. It stores
#' the supplied `TosiSchema` and artifact metadata as tibble attributes.
#' Connector producers establish delivered-column/schema correspondence before
#' construction.
#'
#' @param x A data frame or tibble in initial physical column order.
#' @param schema A genuine package-produced `TosiSchema`.
#' @param col_mode Column naming mode for the physical table columns.
#' @param title Optional artifact presentation title.
#' @param source_label Optional artifact source label.
#' @param provenance Optional [TosiProvenance].
#' @param result_scope Whether the returned rows are `"complete"` for the
#'   normalized request or an intentionally bounded `"preview"`.
#'
#' @return A `tosi_table` tibble.
#' @keywords internal
#' @noRd
new_tosi_table <- function(
  x,
  schema,
  col_mode,
  title = NULL,
  source_label = NULL,
  provenance = NULL,
  result_scope = "complete"
) {
  if (!is.data.frame(x)) {
    cli_abort("{.arg x} must be a data frame.")
  }
  if (!inherits(schema, "TosiSchema")) {
    cli_abort("{.arg schema} must be a genuine {.cls TosiSchema} object.")
  }

  physical_names <- names(x)
  valid_physical_names <- is.character(physical_names) &&
    !anyNA(physical_names) &&
    all(nzchar(physical_names)) &&
    !anyDuplicated(physical_names)
  if (!valid_physical_names) {
    cli_abort(
      "Physical table column names must be non-missing, non-empty, and unique."
    )
  }

  validate_scalar_string(title, allow_null = TRUE)
  validate_scalar_string(source_label, allow_null = TRUE)

  if (!is.null(provenance) && !has_tosi_provenance_identity(provenance)) {
    cli_abort(
      "{.arg provenance} must be a {.cls TosiProvenance} or {.code NULL}."
    )
  }
  result_scope <- as.character(result_scope)
  if (!isTRUE(result_scope %in% c("complete", "preview"))) {
    cli_abort(
      "{.arg result_scope} must be exactly {.val complete} or {.val preview}."
    )
  }
  attributes(result_scope) <- NULL

  # Rebuild from the delivered columns so parser-only attributes cannot become
  # a second metadata authority on the artifact.
  tibble::new_tibble(
    as.list(x),
    schema = schema,
    col_mode = col_mode,
    title = title,
    source_label = source_label,
    provenance = provenance,
    result_scope = result_scope,
    class = "tosi_table"
  )
}

## -- Predicates & accessors ---------------------------------------------------

#' Retrieved tables
#'
#' A `tosi_table` is a tibble with a schema, title, source label, provenance,
#' and `result_scope` stored as attributes. `result_scope = "complete"` means
#' the table contains all rows for the normalized request, not necessarily
#' every row in the source. `result_scope = "preview"` means the result is
#' intentionally limited and may need a source filter for complete data.
#' Result scope is not a table column or schema component.
#'
#' @param x Any R object.
#' @return `TRUE` if `x` inherits from `"tosi_table"`, `FALSE` otherwise.
#' @export
#' @rdname tosi_table
is_tosi_table <- function(x) inherits(x, "tosi_table")


## -- Tibble conversion --------------------------------------------------------

#' @param ... Arguments passed to [tibble::as_tibble()].
#' @param drop_replaced If `TRUE`, omit delivered source columns identified by
#'   schema components' `replaces_id`. Names are derived from the complete
#'   embedded schema using the table's stored column mode.
#' @return `as_tibble()` returns an ordinary tibble. Conversion retains ordinary
#'   tibble metadata behavior; the schema is not reduced or rebuilt, and no
#'   metadata guarantee is made after conversion.
#' @rdname tosi_table
#' @export
#' @importFrom tibble as_tibble
as_tibble.tosi_table <- function(x, ..., drop_replaced = FALSE) {
  if (drop_replaced) {
    schema <- attr(x, "schema", exact = TRUE)
    column_names <- schema$column_names(attr(x, "col_mode", exact = TRUE))
    replaced_ids <- unlist(
      map(schema$components, \(component) component$replaces_id),
      use.names = FALSE
    )
    x <- x[!names(x) %in% unname(column_names[replaced_ids])]
  }
  NextMethod()
}

## -- Print method -------------------------------------------------------------

#' @importFrom pillar tbl_sum
#' @export
tbl_sum.tosi_table <- function(x, ...) {
  schema <- attr(x, "schema", exact = TRUE)
  preview_guidance <- paste(
    "PREVIEW (incomplete);",
    "add a source filter for complete data."
  )
  preview <- if (identical(attr(x, "result_scope", exact = TRUE), "preview")) {
    c("result scope" = preview_guidance)
  }

  c(
    preview,
    tosi_table = paste(schema$connector_id, schema$object_id, sep = "/"),
    title = attr(x, "title", exact = TRUE),
    source = attr(x, "source_label", exact = TRUE),
    data_version = format(schema$data_version, "%Y-%m-%d %H:%M:%S %Z"),
    if (!is.null(schema$frequency)) {
      c("frequency" = paste(schema$frequency, collapse = ", "))
    },
    NextMethod()
  )
}
