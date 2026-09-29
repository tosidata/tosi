#' Schema component
#'
#' `TosiSchemaComponent` describes one physical user-data column whose semantic
#' role is not yet classified. Constructor-established state is stored privately
#' and exposed through read-only fields under the existing names. Field reads
#' are unchanged; direct and nested field replacement fails. Invariants are
#' validated during construction.
#'
#' @field id Canonical component identifier.
#' @field label Presentation label, defaulting to `id`.
#' @field role Fixed component role.
#' @field data_type Optional open logical data-type string.
#' @field domain Optional ordered value domain.
#' @param domain_codes Optional ordered character domain codes.
#' @param domain_labels Optional character labels parallel to `domain_codes`.
#' @keywords internal
#' @noRd
TosiSchemaComponent <- R6Class(
  "TosiSchemaComponent",
  portable = FALSE,
  public = list(
    initialize = function(
      id,
      label = NULL,
      data_type = NULL,
      domain_codes = NULL,
      domain_labels = NULL
    ) {
      validate_scalar_string(id)
      validate_canonical_id(id)

      label <- label %||% id
      validate_scalar_string(label)
      validate_scalar_string(data_type, allow_null = TRUE)

      if (!is.null(domain_labels) && is.null(domain_codes)) {
        cli_abort(
          "{.field domain_labels} requires non-NULL {.field domain_codes}."
        )
      }

      domain <- NULL
      if (!is.null(domain_codes)) {
        if (!is.character(domain_codes)) {
          cli_abort("Domain codes must be character values.")
        }
        codes <- as.character(domain_codes)
        valid_codes <- !anyNA(codes) &&
          all(nzchar(codes)) &&
          !anyDuplicated(codes)
        if (!valid_codes) {
          cli_abort(
            "Domain codes must be unique, present, and non-empty."
          )
        }

        domain <- list(code = codes)
        if (!is.null(domain_labels)) {
          if (!is.character(domain_labels)) {
            cli_abort("Domain labels must be character values.")
          }
          labels <- as.character(domain_labels)
          if (length(labels) != length(codes)) {
            cli_abort("Domain labels must be parallel to codes.")
          }
          use_code <- is.na(labels) | !nzchar(labels)
          labels[use_code] <- codes[use_code]
          domain$label <- labels
        }
      }

      private$.id <- id
      private$.label <- label
      private$.role <- "unknown"
      private$.data_type <- data_type
      private$.domain <- domain
    },

    as_list = function() {
      out <- list(
        id = self$id,
        label = self$label,
        role = self$role
      )
      if (!is.null(self$data_type)) {
        out$data_type <- self$data_type
      }
      if (!is.null(self$domain)) {
        out$domain <- self$domain
      }
      out
    }
  ),
  private = list(
    .id = NULL,
    .label = NULL,
    .role = NULL,
    .data_type = NULL,
    .domain = NULL
  ),
  active = list(
    id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field id} is read-only.")
      }
      private$.id
    },
    label = function(value) {
      if (!missing(value)) {
        cli_abort("{.field label} is read-only.")
      }
      private$.label
    },
    role = function(value) {
      if (!missing(value)) {
        cli_abort("{.field role} is read-only.")
      }
      private$.role
    },
    data_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field data_type} is read-only.")
      }
      private$.data_type
    },
    domain = function(value) {
      if (!missing(value)) {
        cli_abort("{.field domain} is read-only.")
      }
      private$.domain
    }
  )
)

#' Dimension schema component
#'
#' @inherit TosiSchemaComponent
#' @keywords internal
#' @noRd
TosiSchemaDimension <- R6Class(
  "TosiSchemaDimension",
  inherit = TosiSchemaComponent,
  portable = FALSE,
  public = list(
    initialize = function(
      id,
      label = NULL,
      data_type = NULL,
      domain_codes = NULL,
      domain_labels = NULL
    ) {
      super$initialize(id, label, data_type, domain_codes, domain_labels)
      private$.role <- "dimension"
    }
  )
)

#' Time schema component
#'
#' @inherit TosiSchemaComponent
#' @field replaces_id Optional canonical ID of a source Dimension replaced by
#'   this canonical Time component.
#' @keywords internal
#' @noRd
TosiSchemaTime <- R6Class(
  "TosiSchemaTime",
  inherit = TosiSchemaComponent,
  portable = FALSE,
  public = list(
    initialize = function(
      label = NULL,
      data_type = NULL,
      replaces_id = NULL,
      time_domain = NULL
    ) {
      validate_scalar_string(replaces_id, allow_null = TRUE)
      if (!is.null(replaces_id)) {
        validate_canonical_id(replaces_id)
      }
      ## TODO: validate time_domain
      super$initialize(
        "time",
        label,
        data_type
      )
      private$.role <- "time"
      private$.replaces_id <- replaces_id
      private$.domain <- list(time = time_domain)
    },

    as_list = function() {
      out <- super$as_list()
      if (!is.null(self$replaces_id)) {
        out$replaces_id <- self$replaces_id
      }
      out
    }
  ),
  private = list(
    .replaces_id = NULL
  ),
  active = list(
    replaces_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field replaces_id} is read-only.")
      }
      private$.replaces_id
    }
  )
)

#' Frequency schema component
#'
#' @inherit TosiSchemaComponent
#' @field replaces_id Optional canonical ID of a source Dimension replaced by
#'   this canonical Frequency component.
#' @keywords internal
#' @noRd
TosiSchemaFrequency <- R6Class(
  "TosiSchemaFrequency",
  inherit = TosiSchemaComponent,
  portable = FALSE,
  public = list(
    initialize = function(
      label = NULL,
      data_type = NULL,
      frequency_domain = NULL,
      replaces_id = NULL
    ) {
      validate_scalar_string(replaces_id, allow_null = TRUE)
      if (!is.null(replaces_id)) {
        validate_canonical_id(replaces_id)
      }
      super$initialize(
        "freq",
        label,
        data_type
      )
      private$.role <- "frequency"
      private$.replaces_id <- replaces_id
      private$.domain <- list(frequency = frequency_domain)
    },

    as_list = function() {
      out <- super$as_list()
      if (!is.null(self$replaces_id)) {
        out$replaces_id <- self$replaces_id
      }
      out
    }
  ),
  private = list(
    .replaces_id = NULL
  ),
  active = list(
    replaces_id = function(value) {
      if (!missing(value)) {
        cli_abort("{.field replaces_id} is read-only.")
      }
      private$.replaces_id
    }
  )
)

#' Value schema component
#'
#' @inherit TosiSchemaComponent
#' @field unit Optional scalar unit metadata.
#' @keywords internal
#' @noRd
TosiSchemaValue <- R6Class(
  "TosiSchemaValue",
  inherit = TosiSchemaComponent,
  portable = FALSE,
  public = list(
    initialize = function(unit = NULL) {
      validate_scalar_string(unit, allow_null = TRUE)
      super$initialize(
        id = "value",
        label = "value",
        data_type = "number"
      )
      private$.role <- "value"
      private$.unit <- unit
    },

    as_list = function() {
      out <- super$as_list()
      if (!is.null(self$unit)) {
        out$unit <- self$unit
      }
      out
    }
  ),
  private = list(
    .unit = NULL
  ),
  active = list(
    unit = function(value) {
      if (!missing(value)) {
        cli_abort("{.field unit} is read-only.")
      }
      private$.unit
    }
  )
)

#' Attribute schema component
#'
#' @inherit TosiSchemaComponent
#' @field level Optional attribute level: `"table"`, `"series"`, or
#'   `"observation"`.
#' @keywords internal
#' @noRd
TosiSchemaAttribute <- R6Class(
  "TosiSchemaAttribute",
  inherit = TosiSchemaComponent,
  portable = FALSE,
  public = list(
    initialize = function(
      id,
      label = NULL,
      data_type = NULL,
      domain_codes = NULL,
      domain_labels = NULL,
      level = NULL
    ) {
      validate_scalar_string(level, allow_null = TRUE)
      if (!is.null(level) && !level %in% c("table", "series", "observation")) {
        cli_abort(
          "{.field level} must be table, series, observation, or NULL."
        )
      }
      super$initialize(id, label, data_type, domain_codes, domain_labels)
      private$.role <- "attribute"
      private$.level <- level
    },

    as_list = function() {
      out <- super$as_list()
      if (!is.null(self$level)) {
        out$level <- self$level
      }
      out
    }
  ),
  private = list(
    .level = NULL
  ),
  active = list(
    level = function(value) {
      if (!missing(value)) {
        cli_abort("{.field level} is read-only.")
      }
      private$.level
    }
  )
)

#' Table structure
#'
#' [tosi_schema()] returns a `TosiSchema` describing a table or series through
#' its ordered columns, identifiers, labels, roles, and available value domains.
#' It also includes the source version, language, and any frequency and
#' series-key information. Fields are read-only; direct and nested replacement
#' fails. Use `$column_names()` to see the physical names for each column mode.
#'
#' @field connector_id Scalar canonical connector ID vector.
#' @field object_id Scalar canonical object ID vector.
#' @field data_version Finite non-missing scalar `POSIXct` version.
#' @field object_type Optional connector-supplied object type.
#' @field lang Scalar natural-language code or `"codes"`.
#' @field components Non-empty ordered list of schema components.
#' @field frequency Optional scalar known frequency code.
#' @field series_key Resolved series-key component IDs.
#'
#' @export
TosiSchema <- R6Class(
  "TosiSchema",
  portable = FALSE,
  public = list(
    #' @description
    #' Construct an object schema from package-owned schema components.
    #'
    #' @param connector_id Scalar canonical connector ID.
    #' @param object_id Scalar canonical object ID.
    #' @param data_version Finite non-missing scalar `POSIXct` source version.
    #' @param components Non-empty ordered list of package-owned schema
    #'   component objects.
    #' @param object_type Optional connector-supplied object type: `"table"`,
    #'   `"series"`, or `NULL`.
    #' @param lang Scalar natural-language code or `"codes"`.
    #' @param frequency Optional scalar known frequency code.
    #' @param series_key Optional ordered character vector of eligible
    #'   series-key component IDs.
    #'
    #' @return A new `TosiSchema` object.
    initialize = function(
      connector_id,
      object_id,
      data_version,
      components,
      object_type = NULL,
      lang = NULL,
      frequency = NULL,
      series_key = NULL
    ) {
      # Validate before function-position lookup because the accepted formal
      # names shadow the canonical constructor bindings.
      validate_scalar_string(connector_id)
      validate_scalar_string(object_id)
      canonical_connector_id <- connector_id(connector_id)
      canonical_object_id <- object_id(object_id)
      validate_required_data_version(data_version, "data_version")

      validate_scalar_string(object_type, allow_null = TRUE)
      if (!is.null(object_type) && !object_type %in% c("table", "series")) {
        cli_abort(
          "{.field object_type} must be {.val table}, {.val series}, or NULL."
        )
      }

      if (!identical(lang, "codes")) {
        validate_natural_language(lang, "lang")
      }

      if (!is.list(components) || length(components) == 0L) {
        cli_abort("{.field components} must be a non-empty list.")
      }

      valid_components <- map_lgl(components, inherits, "TosiSchemaComponent")
      if (!all(valid_components)) {
        cli_abort(
          "{.field components} must contain TosiSchemaComponent objects."
        )
      }

      component_ids <- map_chr(components, "id")
      if (anyDuplicated(component_ids)) {
        cli_abort("Component {.field id} values must be unique.")
      }
      if (sum(map_lgl(components, inherits, "TosiSchemaValue")) > 1L) {
        cli_abort("A schema may contain at most one {.cls TosiSchemaValue}.")
      }

      valid_reserved_ids <- map_lgl(components, \(component) {
        (component$id != "time" || inherits(component, "TosiSchemaTime")) &&
          (component$id != "freq" ||
            inherits(component, "TosiSchemaFrequency")) &&
          (component$id != "value" || inherits(component, "TosiSchemaValue")) &&
          (!inherits(component, "TosiSchemaTime") || component$id == "time") &&
          (!inherits(component, "TosiSchemaFrequency") ||
            component$id == "freq") &&
          (!inherits(component, "TosiSchemaValue") || component$id == "value")
      })
      if (!all(valid_reserved_ids)) {
        cli_abort(
          "Reserved component IDs must use their matching component classes."
        )
      }

      ## Validate replacements exist
      replacement_components <- components |>
        keep(
          \(component) {
            !is.null(component$replaces_id)
          }
        )
      walk(replacement_components, \(component) {
        target_index <- match(component$replaces_id, component_ids)
        valid_target <- !is.na(target_index) &&
          inherits(components[[target_index]], "TosiSchemaDimension")
        if (!valid_target) {
          cli_abort(
            "{.field replaces_id} must name an existing Dimension."
          )
        }
      })

      if (!is.null(frequency)) {
        validate_frequency_code(frequency)
      }
      has_frequency_component <- any(
        map_lgl(components, inherits, "TosiSchemaFrequency")
      )
      if (!is.null(frequency) && has_frequency_component) {
        cli_abort(
          "{.field frequency} cannot coexist with a Frequency component."
        )
      }

      explicit_key <- !is.null(series_key)
      if (explicit_key && !identical(object_type, "series")) {
        cli_abort("{.field series_key} is only valid for series schemas.")
      }
      if (
        explicit_key &&
          (!is.character(series_key) ||
            anyNA(series_key) ||
            !all(nzchar(series_key)) ||
            anyDuplicated(series_key))
      ) {
        cli_abort(
          "{.field series_key} must contain unique non-missing component IDs."
        )
      }

      ## Validate series_key is a subset of eligible components
      replaced_ids <- map_chr(replacement_components, "replaces_id")
      eligible_components <- keep(components, \(component) {
        (inherits(component, "TosiSchemaDimension") &&
          !component$id %in% replaced_ids) ||
          inherits(component, "TosiSchemaFrequency")
      })
      eligible_ids <- map_chr(eligible_components, \(component) component$id)
      has_time <- any(map_lgl(components, inherits, "TosiSchemaTime"))
      has_unknown <- any(map_lgl(
        components,
        \(component) identical(component$role, "unknown")
      ))
      derivable <- identical(object_type, "series") && has_time && !has_unknown

      if (derivable) {
        if (explicit_key && !identical(series_key, eligible_ids)) {
          cli_abort(
            "Explicit {.field series_key} must equal the fully derived key."
          )
        }
        resolved_series_key <- eligible_ids
      } else if (explicit_key) {
        ordered_subset <- eligible_ids[eligible_ids %in% series_key]
        if (!identical(series_key, ordered_subset)) {
          cli_abort(
            "{.field series_key} must be an ordered eligible subset."
          )
        }
        resolved_series_key <- series_key
      } else {
        resolved_series_key <- NULL
      }

      private$.connector_id <- canonical_connector_id
      private$.object_id <- canonical_object_id
      private$.data_version <- data_version
      private$.object_type <- object_type
      private$.lang <- lang
      private$.components <- components
      private$.frequency <- frequency
      private$.series_key <- resolved_series_key
    },

    #' @description
    #' Return physical column names in schema order without changing the schema.
    #'
    #' @param col_mode One of `"labels"`, `"safe_labels"`, or `"ids"`.
    #' @return A character vector of physical names named by component ID.
    column_names = function(col_mode = c("labels", "safe_labels", "ids")) {
      col_mode <- match.arg(col_mode)
      stats::setNames(
        physical_column_names(self$components, col_mode),
        map_chr(self$components, "id")
      )
    },

    #' @description
    #' Return the schema as a named list, with components as named lists.
    #'
    #' @return A named list containing the schema fields and components.
    as_list = function() {
      list(
        connector_id = self$connector_id,
        object_id = self$object_id,
        data_version = self$data_version,
        object_type = self$object_type,
        lang = self$lang,
        frequency = self$frequency,
        series_key = self$series_key,
        components = map(self$components, \(component) component$as_list())
      )
    }
  ),
  private = list(
    .connector_id = NULL,
    .object_id = NULL,
    .data_version = NULL,
    .object_type = NULL,
    .lang = NULL,
    .components = NULL,
    .frequency = NULL,
    .series_key = NULL
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
    },
    object_type = function(value) {
      if (!missing(value)) {
        cli_abort("{.field object_type} is read-only.")
      }
      private$.object_type
    },
    lang = function(value) {
      if (!missing(value)) {
        cli_abort("{.field lang} is read-only.")
      }
      private$.lang
    },
    components = function(value) {
      if (!missing(value)) {
        cli_abort("{.field components} is read-only.")
      }
      private$.components
    },
    frequency = function(value) {
      if (!missing(value)) {
        cli_abort("{.field frequency} is read-only.")
      }
      private$.frequency
    },
    series_key = function(value) {
      if (!missing(value)) {
        cli_abort("{.field series_key} is read-only.")
      }
      private$.series_key
    }
  )
)
