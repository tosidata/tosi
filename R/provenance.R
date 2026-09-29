#' Read or set provenance
#'
#' `provenance(x)` reads the [TosiProvenance] history attached to `x`, or
#' `NULL` if there is none. The returned object is live: modifying it changes
#' the carrier's history. A non-`NULL` stored value must be a genuine
#' [TosiProvenance] object.
#'
#' `provenance(x) <- value` attaches a deep copy of `value`, so subsequent
#' changes to the original do not change the attached history. Assign `NULL`
#' to clear provenance when the carrier permits it.
#'
#' @details
#' By default, non-R6 objects that support attributes store provenance in
#' `attr(x, "provenance")`, including `tosi_table` objects. R6 objects read and
#' write `x$provenance` through a field or active binding and are changed by
#' reference. An absent, locked, or read-only R6 member follows the carrier's
#' own rules; some carriers do not permit clearing. `NULL` cannot be used as
#' a carrier.
#'
#' @param x A non-`NULL` object carrying provenance; ordinary objects must
#'   support attributes, and R6 objects use their `provenance` member.
#' @param value A genuine [TosiProvenance] object, or `NULL` if the carrier
#'   permits clearing provenance.
#' @param ... Ignored; passed to methods.
#' @return `provenance(x)` returns the live carrier-owned [TosiProvenance]
#'   object or `NULL`. The replacement form returns the updated carrier;
#'   R6 carriers are also mutated by reference.
#' @export
#' @rdname provenance
provenance <- function(x, ...) UseMethod("provenance")

#' @export
#' @rdname provenance
provenance.tosi_table <- function(x, ...) {
  value <- attr(x, "provenance", exact = TRUE)
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(paste(
      "The {.code provenance} attribute must contain a genuine",
      "{.cls TosiProvenance} object or {.code NULL}."
    ))
  }
  value
}

#' @export
#' @rdname provenance
provenance.R6 <- function(x, ...) {
  value <- x$provenance
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(paste(
      "The {.code provenance} field must contain a genuine",
      "{.cls TosiProvenance} object or {.code NULL}."
    ))
  }
  value
}

#' @export
#' @rdname provenance
provenance.default <- function(x, ...) {
  if (is.null(x)) {
    cli_abort("{.arg x} must not be {.code NULL}.")
  }
  value <- attr(x, "provenance", exact = TRUE)
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(paste(
      "The {.code provenance} attribute must contain a genuine",
      "{.cls TosiProvenance} object or {.code NULL}."
    ))
  }
  value
}

#' @export
#' @rdname provenance
`provenance<-` <- function(x, value) UseMethod("provenance<-")

#' @export
#' @rdname provenance
`provenance<-.tosi_table` <- function(x, value) {
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(
      "{.arg value} must be a {.cls TosiProvenance} object or {.code NULL}."
    )
  }
  if (!is.null(value)) {
    value <- value$clone(deep = TRUE)
  }
  attr(x, "provenance") <- value
  x
}

#' @export
#' @rdname provenance
`provenance<-.R6` <- function(x, value) {
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(paste(
      "{.arg value} must be a genuine {.cls TosiProvenance} object",
      "or {.code NULL}."
    ))
  }
  x$provenance <- if (is.null(value)) {
    NULL
  } else {
    value$clone(deep = TRUE)
  }
  x
}

#' @export
#' @rdname provenance
`provenance<-.default` <- function(x, value) {
  if (is.null(x)) {
    cli_abort("{.arg x} must not be {.code NULL}.")
  }
  if (!is.null(value) && !has_tosi_provenance_identity(value)) {
    cli_abort(paste(
      "{.arg value} must be a genuine {.cls TosiProvenance} object",
      "or {.code NULL}."
    ))
  }
  attr(x, "provenance") <- if (is.null(value)) {
    NULL
  } else {
    value$clone(deep = TRUE)
  }
  x
}
