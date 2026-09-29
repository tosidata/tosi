is_scalar_string <- function(x, allow_empty = FALSE) {
  if (missing(x)) {
    return(FALSE)
  }

  is.character(x) &&
    length(x) == 1L &&
    !is.na(x) &&
    (allow_empty || nzchar(x))
}

validate_scalar_string <- function(
  x,
  allow_empty = FALSE,
  allow_null = FALSE,
  arg = caller_arg(x),
  call = caller_env()
) {
  expected <- if (allow_empty) "a string" else "a non-empty string"
  if (allow_null) {
    expected <- paste(expected, "or NULL")
  }

  if (missing(x)) {
    cli_abort("{.arg {arg}} must be {expected}.", call = call)
  }

  if (is.null(x)) {
    if (allow_null) {
      return(invisible(x))
    }

    cli_abort("{.arg {arg}} must be {expected}.", call = call)
  }

  if (is_scalar_string(x, allow_empty = allow_empty)) {
    return(invisible(x))
  }

  cli_abort("{.arg {arg}} must be {expected}.", call = call)
}

validate_optional_next_update <- function(x, field) {
  valid <- is.null(x) ||
    (inherits(x, "Date") && length(x) == 1L && !is.na(x)) ||
    (inherits(x, "POSIXct") && length(x) == 1L && !is.na(x)) ||
    (is.character(x) && length(x) == 1L && !is.na(x))

  if (!valid) {
    cli_abort("{.field {field}} must be Date, POSIXct, string, or NULL.")
  }
}

validate_metadata_object_type <- function(x) {
  valid <- c("table", "series", "list")
  if (!is.character(x) || length(x) != 1L || !x %in% valid) {
    cli_abort("{.field object_type} must be one of {.val {valid}}.")
  }
}

validate_required_data_version <- function(x, field) {
  finite_posixct <- inherits(x, "POSIXct") &&
    length(x) == 1L &&
    !is.na(x) &&
    is.numeric(unclass(x)) &&
    is.finite(unclass(x))

  if (!finite_posixct) {
    cli_abort(
      "{.field {field}} must be a finite, non-missing {.cls POSIXct} scalar."
    )
  }
}

validate_natural_language <- function(x, field) {
  if (
    !is.character(x) ||
      length(x) != 1L ||
      is.na(x) ||
      !nzchar(x) ||
      identical(x, "codes")
  ) {
    cli_abort(
      "{.field {field}} must be a natural language code, not {.val codes}."
    )
  }
}

validate_natural_languages <- function(x, field) {
  if (
    !is.character(x) ||
      length(x) == 0L ||
      anyNA(x) ||
      !all(nzchar(x)) ||
      anyDuplicated(x) ||
      "codes" %in% x
  ) {
    cli_abort(c(
      "{.field {field}} must contain unique natural language codes.",
      "x" = "{.val codes} is not a natural language."
    ))
  }
}

validate_named_list <- function(x, field) {
  if (
    !is.list(x) ||
      (length(x) > 0L &&
        (is.null(names(x)) || anyNA(names(x)) || !all(nzchar(names(x)))))
  ) {
    cli_abort("{.field {field}} must be a named list.")
  }
}

validate_exact_names <- function(x, allowed, field) {
  extra <- setdiff(names(x), allowed)
  if (length(extra) > 0L) {
    cli_abort(c(
      "{.field {field}} contains unexpected fields:",
      "x" = "{.val {extra}}"
    ))
  }
}

validate_extension_names <- function(x) {
  if (length(x) == 0L) {
    return(invisible(x))
  }
  valid <- str_detect(names(x), "^[a-z][a-z0-9]*[.][a-z][a-z0-9_.-]*$")
  if (!all(valid)) {
    cli_abort(
      paste(
        "{.field extensions} names must use a namespaced form such as",
        "{.val statfin.topic}."
      )
    )
  }
  invisible(x)
}
