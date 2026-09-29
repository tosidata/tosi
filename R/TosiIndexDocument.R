#' Search-index document
#'
#' [tosi_index_document()] returns a `TosiIndexDocument` for indexing an object
#' in search. It includes identity, language-specific metadata, a schema
#' summary, value domains, coverage, and source-reference cards. Metadata and
#' schema sections are named lists, not [TosiMetadata] or [TosiSchema] objects.
#' Fields are read-only; direct and nested replacement fails.
#'
#' @field document_type Fixed index-document type.
#' @field schema_version Index-document contract version.
#' @field generated_at Finite non-missing scalar `POSIXct` generation time.
#' @field connector_id Canonical connector identity.
#' @field object_id Canonical object identity.
#' @field object_type Object type: `"table"`, `"series"`, or `"list"`.
#' @field source_object_id Optional source-native object identifier.
#' @field data_version Finite non-missing scalar `POSIXct` source version.
#' @field languages Natural languages represented in the document.
#' @field metadata Language-keyed metadata entries.
#' @field schema Schema summary as a named list.
#' @field value_domains Language-keyed source-dimension value domains.
#' @field coverage Coverage summary.
#' @field source_references List of compact [TosiSourceReference] cards, not
#'   retrieved [TosiSourceDocument] objects.
#' @field extensions Named connector-specific index extensions.
#'
#' @export
TosiIndexDocument <- R6Class(
  "TosiIndexDocument",
  portable = FALSE,
  public = list(
    #' @description
    #' Construct a normalized search-index document.
    #'
    #' @param identity Named list containing `connector_id`, `object_id`,
    #'   `object_type`, and `data_version`, with optional `source_object_id`.
    #' @param languages Natural-language codes represented in normalized
    #'   sections.
    #' @param metadata Language-keyed normalized metadata entries.
    #' @param schema Portable normalized schema summary.
    #' @param value_domains Language-keyed source-dimension value domains.
    #' @param coverage Connector-supplied coverage summary.
    #' @param source_references List of genuine live compact
    #'   `TosiSourceReference` cards.
    #' @param extensions Named list of connector-specific index extensions.
    #'
    #' @return A new `TosiIndexDocument` object.
    initialize = function(
      identity,
      languages,
      metadata,
      schema,
      value_domains,
      coverage,
      source_references = list(),
      extensions = list()
    ) {
      portable_payload <- list(
        identity = identity,
        languages = languages,
        metadata = metadata,
        schema = schema,
        value_domains = value_domains,
        coverage = coverage,
        extensions = extensions
      )
      if (any(map_lgl(portable_payload, private$contains_live_r6))) {
        cli_abort(paste(
          "Index documents must store normalized portable payload sections",
          "without live R6 objects; {.field source_references} is the sole",
          "live-object collection."
        ))
      }

      private$validate_index_identity(identity)
      validate_natural_languages(languages, "languages")
      private$validate_index_metadata(metadata, languages)
      private$validate_index_schema(schema, languages)
      private$validate_index_value_domains(value_domains, languages)
      private$validate_index_coverage(coverage)

      if (!is.list(source_references)) {
        cli_abort("{.field source_references} must be a list.")
      }
      valid_references <- map_lgl(source_references, function(reference) {
        R6::is.R6(reference) && inherits(reference, "TosiSourceReference")
      })
      if (!all(valid_references)) {
        cli_abort(paste0(
          "{.field source_references} must contain only genuine ",
          "{.cls TosiSourceReference} objects."
        ))
      }

      validate_named_list(extensions, "extensions")
      validate_extension_names(extensions)

      private$.document_type <- "tosi_index_document"
      private$.schema_version <- "0.2.0"
      private$.generated_at <- now()
      private$.connector_id <- identity$connector_id
      private$.object_id <- identity$object_id
      private$.object_type <- identity$object_type
      private$.source_object_id <- identity$source_object_id
      private$.data_version <- identity$data_version
      private$.languages <- languages
      private$.metadata <- metadata
      private$.schema <- schema
      private$.value_domains <- value_domains
      private$.coverage <- coverage
      private$.source_references <- source_references
      private$.extensions <- extensions

      invisible(self)
    },

    #' @description
    #' Return the document's object identity as a named list.
    #'
    #' @return A named list containing `connector_id`, `object_id`,
    #'   `object_type`, and `data_version`, plus `source_object_id` when
    #'   present.
    identity = function() {
      out <- list(
        connector_id = self$connector_id,
        object_id = self$object_id
      )
      if (!is.null(self$source_object_id)) {
        out$source_object_id <- self$source_object_id
      }
      out$object_type <- self$object_type
      out$data_version <- self$data_version
      out
    },

    #' @description
    #' Return the index document as a named list. Source-reference cards are
    #' included as named lists rather than R6 objects.
    #'
    #' @return A named list containing the index sections.
    as_list = function() {
      list(
        document_type = self$document_type,
        schema_version = self$schema_version,
        generated_at = self$generated_at,
        identity = self$identity(),
        languages = self$languages,
        metadata = self$metadata,
        schema = self$schema,
        value_domains = self$value_domains,
        coverage = self$coverage,
        source_references = map(
          self$source_references,
          \(reference) reference$as_list()
        ),
        extensions = self$extensions
      )
    },

    #' @description
    #' Format a concise index-document summary.
    #'
    #' @param ... Reserved for future formatting options; currently ignored.
    #'
    #' @return A character vector containing the index-document summary.
    format = function(...) {
      c(
        glue(
          "<TosiIndexDocument> ",
          "{self$connector_id}/{self$object_id} ",
          "[{self$object_type}]"
        ),
        glue("Languages: {paste(self$languages, collapse = ', ')}"),
        glue("Dimensions: {length(self$schema$dimensions)}"),
        glue("Value domains: {length(self$value_domains)}"),
        glue("Source references: {length(self$source_references)}")
      )
    },

    #' @description
    #' Print the concise index-document summary.
    #'
    #' @param ... Arguments passed to `$format()`.
    #'
    #' @return The `TosiIndexDocument` object, invisibly.
    print = function(...) {
      cat(self$format(...), sep = "\n")
      invisible(self)
    }
  ),
  private = list(
    .document_type = NULL,
    .schema_version = NULL,
    .generated_at = NULL,
    .connector_id = NULL,
    .object_id = NULL,
    .object_type = NULL,
    .source_object_id = NULL,
    .data_version = NULL,
    .languages = NULL,
    .metadata = NULL,
    .schema = NULL,
    .value_domains = NULL,
    .coverage = NULL,
    .source_references = NULL,
    .extensions = NULL,

    contains_live_r6 = function(x) {
      if (R6::is.R6(x)) {
        return(TRUE)
      }
      if (!is.list(x)) {
        return(FALSE)
      }
      any(map_lgl(x, private$contains_live_r6))
    },

    validate_platform_serialized = function(
      platform,
      field = "platform",
      call = caller_env()
    ) {
      validate_named_list(platform, field)
      required <- c("time", "frequency")
      missing <- setdiff(required, names(platform))
      if (length(missing) > 0L) {
        cli_abort(
          c(
            "{.field {field}} is missing fields:",
            "x" = "{.val {missing}}"
          ),
          call = call
        )
      }
      validate_exact_names(platform, required, field)
      private$validate_platform_json_time(
        platform$time,
        field = paste0(field, "$time"),
        call = call
      )
      private$validate_platform_json_frequency(
        platform$frequency,
        field = paste0(field, "$frequency"),
        call = call
      )
      invisible(platform)
    },

    validate_platform_json_time = function(
      time,
      field = "platform$time",
      call = caller_env()
    ) {
      if (is.null(time)) {
        return(invisible(time))
      }
      validate_named_list(time, field)
      required <- c("column_id", "replaces_id")
      validate_exact_names(time, required, field)
      private$validate_optional_scalar_string(
        time$column_id,
        paste0(field, "$column_id"),
        call = call
      )
      private$validate_optional_scalar_string(
        time$replaces_id,
        paste0(field, "$replaces_id"),
        call = call
      )
      invisible(time)
    },

    validate_platform_json_frequency = function(
      frequency,
      field = "platform$frequency",
      call = caller_env()
    ) {
      if (is.null(frequency)) {
        return(invisible(frequency))
      }
      validate_named_list(frequency, field)
      required <- c("codes", "column_id", "replaces_id")
      missing <- setdiff(required, names(frequency))
      if (length(missing) > 0L) {
        cli_abort(
          c(
            "{.field {field}} is missing fields:",
            "x" = "{.val {missing}}"
          ),
          call = call
        )
      }
      validate_exact_names(frequency, required, field)
      codes <- frequency$codes
      if (is.null(codes) || !is.list(codes) || length(codes) == 0L) {
        cli_abort(
          "{.field {field}$codes} must be a non-empty list.",
          call = call
        )
      }
      walk(codes, function(code) {
        if (is.null(code)) {
          return(invisible(code))
        }
        if (
          !is.character(code) ||
            length(code) != 1L ||
            is.na(code) ||
            !nzchar(code)
        ) {
          cli_abort(
            "{.field {field}$codes} must contain strings or nulls.",
            call = call
          )
        }
      })
      non_null_codes <- compact(codes)
      if (length(non_null_codes) > 0L) {
        frequency_code(map_chr(non_null_codes, base::identity))
      }
      private$validate_optional_scalar_string(
        frequency$column_id,
        paste0(field, "$column_id"),
        call = call
      )
      private$validate_optional_scalar_string(
        frequency$replaces_id,
        paste0(field, "$replaces_id"),
        call = call
      )
      invisible(frequency)
    },

    validate_optional_scalar_string = function(
      x,
      field,
      call = caller_env()
    ) {
      if (is.null(x)) {
        return(invisible(x))
      }
      if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
        cli_abort(
          "{.field {field}} must be a non-empty string or {.code NULL}.",
          call = call
        )
      }
      invisible(x)
    },

    validate_index_identity = function(x) {
      validate_named_list(x, "identity")
      required <- c("connector_id", "object_id", "object_type", "data_version")
      missing <- setdiff(required, names(x))
      if (length(missing) > 0L) {
        cli_abort(c(
          "{.field identity} is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(x, c(required, "source_object_id"), "identity")
      validate_connector_id(x$connector_id)
      validate_object_id(x$object_id)
      validate_metadata_object_type(x$object_type)
      if ("source_object_id" %in% names(x)) {
        validate_scalar_string(
          x$source_object_id,
          allow_empty = TRUE,
          allow_null = TRUE,
          arg = "identity.source_object_id"
        )
      }
      validate_required_data_version(x$data_version, "identity.data_version")
    },

    validate_index_metadata = function(x, languages) {
      validate_named_list(x, "metadata")
      missing <- setdiff(languages, names(x))
      if (length(missing) > 0L) {
        cli_abort(c(
          "{.field metadata} is missing language entries:",
          "x" = "{.val {missing}}"
        ))
      }
      extra <- setdiff(names(x), languages)
      if (length(extra) > 0L) {
        cli_abort(c(
          "{.field metadata} contains entries outside {.field languages}:",
          "x" = "{.val {extra}}"
        ))
      }
      walk(x, private$validate_index_metadata_entry)
    },

    validate_index_metadata_entry = function(entry) {
      validate_named_list(entry, "metadata entry")
      allowed <- c(
        "title",
        "source_label",
        "description",
        "keywords",
        "subject_area",
        "unit",
        "next_update"
      )
      missing <- setdiff(allowed, names(entry))
      if (length(missing) > 0L) {
        cli_abort(c(
          "A metadata entry is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(entry, allowed, "metadata entry")
      validate_scalar_string(
        entry$title,
        arg = "metadata.title"
      )
      validate_scalar_string(
        entry$source_label,
        arg = "metadata.source_label"
      )
      validate_scalar_string(
        entry$description,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "metadata.description"
      )
      if (!is.character(entry$keywords)) {
        cli_abort("{.field metadata.keywords} must be a character vector.")
      }
      validate_scalar_string(
        entry$subject_area,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "metadata.subject_area"
      )
      validate_scalar_string(
        entry$unit,
        allow_empty = TRUE,
        allow_null = TRUE,
        arg = "metadata.unit"
      )
      validate_optional_next_update(entry$next_update, "metadata.next_update")
    },

    validate_index_schema = function(x, languages) {
      validate_named_list(x, "schema")
      required <- c(
        "dimensions",
        "measures",
        "platform",
        "series_key_columns"
      )
      missing <- setdiff(required, names(x))
      if (length(missing) > 0L) {
        cli_abort(c(
          "{.field schema} is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(x, required, "schema")
      if (!is.list(x$dimensions) || !is.list(x$measures)) {
        cli_abort("{.field schema} dimensions and measures must be lists.")
      }
      private$validate_platform_serialized(
        x$platform,
        field = "schema.platform"
      )
      walk(
        x$dimensions,
        private$validate_index_schema_dimension,
        languages = languages
      )
      walk(
        x$measures,
        private$validate_index_schema_measure,
        languages = languages
      )
    },

    validate_index_schema_dimension = function(dimension, languages) {
      validate_named_list(dimension, "schema dimension")
      required <- c(
        "dimension_id",
        "labels",
        "role",
        "data_type",
        "value_count"
      )
      missing <- setdiff(required, names(dimension))
      if (length(missing) > 0L) {
        cli_abort(c(
          "A schema dimension is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(dimension, required, "schema dimension")
      validate_scalar_string(
        dimension$dimension_id,
        arg = "schema.dimensions.dimension_id"
      )
      private$validate_language_map(
        dimension$labels,
        languages,
        "schema.dimensions.labels"
      )
      validate_scalar_string(
        dimension$role,
        arg = "schema.dimensions.role"
      )
      valid_roles <- c("dimension", "time")
      if (!dimension$role %in% valid_roles) {
        cli_abort(c(
          "{.field schema.dimensions.role} contains invalid values:",
          "x" = "{.val {dimension$role}}",
          "i" = "Valid roles are {.val {valid_roles}}."
        ))
      }
      validate_scalar_string(
        dimension$data_type,
        arg = "schema.dimensions.data_type"
      )
      if (
        !(is.numeric(dimension$value_count) &&
          length(dimension$value_count) == 1L &&
          !is.na(dimension$value_count) &&
          dimension$value_count >= 0 &&
          dimension$value_count == as.integer(dimension$value_count))
      ) {
        cli_abort(
          "{.field schema.dimensions.value_count} must be a scalar integer."
        )
      }
    },

    validate_index_schema_measure = function(measure, languages) {
      validate_named_list(measure, "schema measure")
      required <- c("measure_id", "labels")
      missing <- setdiff(required, names(measure))
      if (length(missing) > 0L) {
        cli_abort(c(
          "A schema measure is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(measure, c(required, "unit"), "schema measure")
      validate_scalar_string(
        measure$measure_id,
        arg = "schema.measures.measure_id"
      )
      private$validate_language_map(
        measure$labels,
        languages,
        "schema.measures.labels"
      )
      if ("unit" %in% names(measure)) {
        validate_scalar_string(
          measure$unit,
          allow_empty = TRUE,
          allow_null = TRUE,
          arg = "schema.measures.unit"
        )
      }
    },

    validate_index_value_domains = function(x, languages) {
      validate_named_list(x, "value_domains")
      if (anyDuplicated(names(x))) {
        cli_abort("{.field value_domains} dimension ids must be unique.")
      }
      walk2(
        x,
        names(x),
        private$validate_index_value_domain,
        languages = languages
      )
    },

    validate_index_value_domain = function(domain, dimension_id, languages) {
      if (!is.list(domain)) {
        cli_abort(
          "Each {.field value_domains} entry must be a language-keyed list."
        )
      }
      validate_scalar_string(
        dimension_id,
        arg = "value_domains dimension id"
      )
      missing <- setdiff(languages, names(domain))
      extra <- setdiff(names(domain), languages)
      if (
        length(missing) > 0L ||
          length(extra) > 0L ||
          anyNA(names(domain)) ||
          !all(nzchar(names(domain))) ||
          !identical(names(domain), languages) ||
          "codes" %in% names(domain)
      ) {
        cli_abort(
          "Each {.field value_domains} entry must be keyed exactly by natural languages."
        )
      }
      vectors <- map(domain, private$validate_index_value_domain_vector)
      reference_codes <- names(vectors[[1L]])
      walk(vectors[-1L], function(values) {
        if (!identical(names(values), reference_codes)) {
          cli_abort(
            "All language vectors for a value domain must have identical code names in identical order."
          )
        }
      })
    },

    validate_index_value_domain_vector = function(values) {
      if (
        !is.character(values) ||
          is.null(names(values)) ||
          anyNA(names(values)) ||
          !all(nzchar(names(values))) ||
          anyNA(values) ||
          !all(nzchar(values))
      ) {
        cli_abort(
          "Every value-domain language entry must be a named character vector with non-empty codes and labels."
        )
      }
      values
    },

    validate_index_coverage = function(x) {
      validate_named_list(x, "coverage")
      required <- c(
        "time_range",
        "observation_count",
        "dimension_cardinalities",
        "series_count"
      )
      missing <- setdiff(required, names(x))
      if (length(missing) > 0L) {
        cli_abort(c(
          "{.field coverage} is missing fields:",
          "x" = "{.val {missing}}"
        ))
      }
      validate_exact_names(x, required, "coverage")
    },

    validate_language_map = function(x, languages, field) {
      if (is.character(x) && !is.null(names(x))) {
        x <- as.list(x)
      }
      validate_named_list(x, field)
      missing <- setdiff(languages, names(x))
      extra <- setdiff(names(x), languages)
      if (
        length(missing) > 0L ||
          length(extra) > 0L ||
          anyNA(names(x)) ||
          "codes" %in% names(x)
      ) {
        cli_abort(
          "{.field {field}} must be keyed exactly by natural languages."
        )
      }
      walk2(x, names(x), function(value, language) {
        if (!is.character(value) || length(value) != 1L || is.na(value)) {
          cli_abort(
            "Every {.field {field}} value must be a scalar non-missing string."
          )
        }
      })
    }
  ),
  active = list(
    document_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field document_type} is read-only.")
      }
      private$.document_type
    },
    schema_version = function(value) {
      if (!missing(value)) {
        cli_abort("{.field schema_version} is read-only.")
      }
      private$.schema_version
    },
    generated_at = function(value) {
      if (!missing(value)) {
        cli_abort("{.field generated_at} is read-only.")
      }
      private$.generated_at
    },
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
    object_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field object_type} is read-only.")
      }
      private$.object_type
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
    languages = function(value) {
      if (!missing(value)) {
        cli_abort("{.field languages} is read-only.")
      }
      private$.languages
    },
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
    value_domains = function(value) {
      if (!missing(value)) {
        cli_abort("{.field value_domains} is read-only.")
      }
      private$.value_domains
    },
    coverage = function(value) {
      if (!missing(value)) {
        cli_abort("{.field coverage} is read-only.")
      }
      private$.coverage
    },
    source_references = function(value) {
      if (!missing(value)) {
        cli_abort("{.field source_references} is read-only.")
      }
      private$.source_references
    },
    extensions = function(value) {
      if (!missing(value)) {
        cli_abort("{.field extensions} is read-only.")
      }
      private$.extensions
    }
  )
)
