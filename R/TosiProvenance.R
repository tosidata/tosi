has_tosi_provenance_identity <- function(x) {
  inherits(x, "TosiProvenance")
}

#' Provenance history
#'
#' `TosiProvenance` records the ordered steps used to produce and deliver a
#' data artifact. Read an artifact's history with [provenance()]. Create a
#' history with `TosiProvenance$new()`, optionally passing `parent` to copy its
#' steps and add one new step without changing the parent.
#'
#' `$steps` is read-only: direct and nested replacement fails. `$add_step()`
#' appends to this object in place, so other references to it see the new step.
#' Reading an artifact's provenance returns its live object, not a copy.
#'
#' @importFrom lubridate now
#' @export
TosiProvenance <- R6Class(
  "TosiProvenance",
  portable = FALSE,
  public = list(
    #' @field steps Read-only ordered list of plain named-list provenance steps.
    #'   Direct and nested replacement fails; append through `$add_step()`.

    #' @description
    #' Construct a provenance lineage.
    #'
    #' `parent` may be `NULL`, another `TosiProvenance`, or any carrier
    #' supported by [provenance()]. Parent steps are copied before the new step
    #' is appended.
    #'
    #' @param stage A non-empty character scalar naming the pipeline stage.
    #' @param parent The provenance parent, or `NULL` for a root lineage.
    #' @param timestamp A finite, non-missing `POSIXct` scalar.
    #' @param tosi_version Optional package-version string. The public `tosi`
    #'   package version is used by default.
    #' @param source_url Optional source URL character scalar.
    #' @param http_status Optional numeric HTTP status.
    #' @param http_headers Optional HTTP headers.
    #' @param fetched_from Optional source location: `"origin"`,
    #'   `"local_cache"`, `"cloud_cache"`, or `"stale_fallback"`.
    #' @param checksum Optional checksum character scalar.
    #' @param file_size Optional file size.
    #' @param connector_version Optional connector version.
    #' @param r_version Optional R-version string. The current R version is used
    #'   by default.
    #' @param trace_id Optional trace identifier.
    #' @param extra A named list of additional step fields.
    #' @param ... Additional named values collected into `extra`.
    initialize = function(
      stage,
      parent = NULL,
      timestamp = now("UTC"),
      tosi_version = NULL,
      source_url = NULL,
      http_status = NULL,
      http_headers = NULL,
      fetched_from = NULL,
      checksum = NULL,
      file_size = NULL,
      connector_version = NULL,
      r_version = NULL,
      trace_id = NULL,
      extra = list(),
      ...
    ) {
      parent_provenance <-
        if (is.null(parent)) {
          NULL
        } else if (inherits(parent, "TosiProvenance")) {
          parent
        } else {
          provenance(parent)
        }

      if (!is.null(parent) && !inherits(parent_provenance, "TosiProvenance")) {
        cli_abort(c(
          "Cannot extract provenance from {.cls {class(parent)[1L]}}.",
          "i" = paste(
            "Supply a {.cls TosiProvenance}, an object supported by",
            "{.fn provenance}, or {.code NULL}."
          )
        ))
      }

      private$.steps <- if (is.null(parent_provenance)) {
        list()
      } else {
        rlang::duplicate(parent_provenance$steps, shallow = FALSE)
      }
      self$add_step(
        stage = stage,
        timestamp = timestamp,
        tosi_version = tosi_version,
        source_url = source_url,
        http_status = http_status,
        http_headers = http_headers,
        fetched_from = fetched_from,
        checksum = checksum,
        file_size = file_size,
        connector_version = connector_version,
        r_version = r_version,
        trace_id = trace_id,
        extra = extra,
        ...
      )
      invisible(self)
    },

    #' @description
    #' Append one step to this provenance object in place. Ordinary aliases of
    #' this object observe the appended step.
    #'
    #' @param stage A non-empty character scalar naming the pipeline stage.
    #' @param timestamp A finite, non-missing `POSIXct` scalar.
    #' @param tosi_version Optional package-version string. The public `tosi`
    #'   package version is used by default.
    #' @param source_url Optional source URL character scalar.
    #' @param http_status Optional numeric HTTP status.
    #' @param http_headers Optional HTTP headers.
    #' @param fetched_from Optional source location: `"origin"`,
    #'   `"local_cache"`, `"cloud_cache"`, or `"stale_fallback"`.
    #' @param checksum Optional checksum character scalar.
    #' @param file_size Optional file size.
    #' @param connector_version Optional connector version.
    #' @param r_version Optional R-version string. The current R version is used
    #'   by default.
    #' @param trace_id Optional trace identifier.
    #' @param extra A named list of additional step fields.
    #' @param ... Additional named values collected into `extra`.
    #' @return This `TosiProvenance` object, invisibly.
    add_step = function(
      stage,
      timestamp = now("UTC"),
      tosi_version = NULL,
      source_url = NULL,
      http_status = NULL,
      http_headers = NULL,
      fetched_from = NULL,
      checksum = NULL,
      file_size = NULL,
      connector_version = NULL,
      r_version = NULL,
      trace_id = NULL,
      extra = list(),
      ...
    ) {
      validate_scalar_string(stage)
      validate_required_data_version(timestamp, "timestamp")

      if (!is.null(source_url)) {
        validate_scalar_string(source_url)
      }
      if (!is.null(http_status) && !is.numeric(http_status)) {
        cli_abort("{.arg http_status} must be numeric or {.code NULL}.")
      }
      if (!is.null(fetched_from)) {
        validate_scalar_string(fetched_from)
        valid_sources <- c(
          "origin",
          "local_cache",
          "cloud_cache",
          "stale_fallback"
        )
        if (!fetched_from %in% valid_sources) {
          cli_abort(
            "{.arg fetched_from} must be one of {.or {.val {valid_sources}}}."
          )
        }
      }
      if (!is.null(checksum)) {
        validate_scalar_string(checksum)
      }

      validate_named_list(extra, "extra")
      dots <- list(...)
      validate_named_list(dots, "...")
      if (length(dots) > 0L) {
        extra <- c(extra, dots)
      }

      fields <- list(
        stage = stage,
        timestamp = timestamp,
        tosi_version = tosi_version %||%
          as.character(utils::packageVersion("tosi")),
        r_version = r_version %||% R.Version()$version.string,
        source_url = source_url,
        http_status = http_status,
        http_headers = http_headers,
        fetched_from = fetched_from,
        checksum = checksum,
        file_size = file_size,
        connector_version = connector_version,
        trace_id = trace_id,
        extra = if (length(extra) > 0L) extra
      ) |>
        compact()

      private$.steps[[length(private$.steps) + 1L]] <- fields
      invisible(self)
    },

    #' @description
    #' Return a copy of the steps as named lists, with ISO-8601 timestamps.
    #'
    #' @return A list of named step lists.
    as_list = function() {
      steps <- rlang::duplicate(self$steps, shallow = FALSE)
      map(steps, function(step) {
        step$timestamp <- format(step$timestamp, "%Y-%m-%dT%H:%M:%S%z")
        step
      })
    },

    #' @description
    #' Return the steps as JSON with ISO-8601 timestamps.
    #'
    #' @param pretty Whether to format the JSON with indentation.
    #' @return A JSON string containing an ordered array of step objects.
    to_json = function(pretty = TRUE) {
      jsonlite::toJSON(
        self$as_list(),
        auto_unbox = TRUE,
        pretty = pretty,
        null = "null"
      )
    },

    #' @description
    #' Print a compact stage summary.
    #'
    #' @param ... Ignored.
    #' @return This `TosiProvenance` object, invisibly.
    print = function(...) {
      n_steps <- length(self$steps)
      stages <- map_chr(self$steps, "stage")
      cat(
        "<TosiProvenance> ",
        n_steps,
        " step",
        if (n_steps != 1L) "s" else "",
        ": ",
        paste(stages, collapse = " -> "),
        "\n",
        sep = ""
      )
      invisible(self)
    }
  ),
  private = list(
    .steps = NULL
  ),
  active = list(
    steps = function(value) {
      if (!missing(value)) {
        cli_abort("{.field steps} is read-only.")
      }
      private$.steps
    }
  )
)
