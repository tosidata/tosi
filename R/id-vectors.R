TOSI_CANONICAL_ID_PATTERN <- "\\A[A-Za-z][A-Za-z0-9_]*\\z"

#' Connector and object IDs
#'
#' A connector ID names a data source's connector; an object ID names an
#' object within that connector. `connector_id()` and `object_id()` create
#' vectors of these IDs or extract the corresponding component from an
#' [object_path()]. They validate IDs exactly, without changing query strings.
#' Each ID must start with an ASCII letter, followed by zero or more ASCII
#' letters, digits, or underscores: `^[A-Za-z][A-Za-z0-9_]*$`. Missing IDs
#' are not accepted when constructing or validating IDs.
#'
#' @param x IDs to construct or validate, an object path to extract from,
#'   or any object for the predicates. Constructors coerce to character and
#'   validate each ID.
#' @param arg Argument name used for validator error reporting.
#' @param call Calling environment used for validator error reporting.
#' @return `connector_id()` and `object_id()` return character-backed ID
#'   vectors. `is_connector_id()` and `is_object_id()` return `TRUE` or `FALSE`.
#'   `validate_connector_id()` and `validate_object_id()` return the input
#'   invisibly.
#' @name id-vectors
NULL

is_canonical_id <- function(x) {
  if (!is.character(x)) {
    return(FALSE)
  }

  !is.na(x) & str_detect(x, TOSI_CANONICAL_ID_PATTERN)
}

new_connector_id <- function(x = character()) {
  vctrs::new_vctr(x, class = "tosi_connector_id")
}

new_object_id <- function(x = character()) {
  vctrs::new_vctr(x, class = "tosi_object_id")
}

validate_canonical_id <- function(
  x,
  arg = caller_arg(x),
  call = caller_env()
) {
  if (!all(is_canonical_id(x))) {
    cli_abort(
      c(
        "{.arg {arg}} must be a canonical platform ID.",
        "i" = "Each value must match {.code ^[A-Za-z][A-Za-z0-9_]*$}.",
        "x" = "Invalid values include slashes, dots, hyphens, spaces, Unicode letters, control characters, leading digits, empty strings, and missing values."
      ),
      call = call
    )
  }
  invisible(x)
}

#' @rdname id-vectors
#' @export
validate_connector_id <- function(
  x,
  arg = caller_arg(x),
  call = caller_env()
) {
  validate_canonical_id(x, arg = arg, call = call)
}

#' @rdname id-vectors
#' @export
validate_object_id <- function(
  x,
  arg = caller_arg(x),
  call = caller_env()
) {
  validate_canonical_id(x, arg = arg, call = call)
}

#' @rdname id-vectors
#' @export
connector_id <- function(x) {
  UseMethod("connector_id")
}

#' @export
connector_id.default <- function(x) {
  x <- vctrs::vec_cast(x, character())
  validate_connector_id(x)
  new_connector_id(x)
}

#' @rdname id-vectors
#' @export
object_id <- function(x) {
  UseMethod("object_id")
}

#' @export
object_id.default <- function(x) {
  x <- vctrs::vec_cast(x, character())
  validate_object_id(x)
  new_object_id(x)
}

#' @rdname id-vectors
#' @export
is_connector_id <- function(x) {
  inherits(x, "tosi_connector_id")
}

#' @rdname id-vectors
#' @export
is_object_id <- function(x) {
  inherits(x, "tosi_object_id")
}

#' @export
format.tosi_connector_id <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
format.tosi_object_id <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
as.character.tosi_connector_id <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
as.character.tosi_object_id <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
vec_ptype_abbr.tosi_connector_id <- function(x, ...) "tosicid"
#' @export
vec_ptype_abbr.tosi_object_id <- function(x, ...) "tosioid"
#' @export
vec_ptype_full.tosi_connector_id <- function(x, ...) "tosi_connector_id"
#' @export
vec_ptype_full.tosi_object_id <- function(x, ...) "tosi_object_id"
#' @export
vec_ptype2.tosi_connector_id.tosi_connector_id <- function(x, y, ...) {
  new_connector_id()
}
#' @export
vec_ptype2.tosi_object_id.tosi_object_id <- function(x, y, ...) new_object_id()
#' @export
vec_ptype2.tosi_connector_id.character <- function(x, y, ...) character()
#' @export
vec_ptype2.character.tosi_connector_id <- function(x, y, ...) character()
#' @export
vec_ptype2.tosi_object_id.character <- function(x, y, ...) character()
#' @export
vec_ptype2.character.tosi_object_id <- function(x, y, ...) character()
#' @export
vec_cast.tosi_connector_id.tosi_connector_id <- function(x, to, ...) x
#' @export
vec_cast.tosi_object_id.tosi_object_id <- function(x, to, ...) x
#' @export
vec_cast.tosi_connector_id.character <- function(x, to, ...) connector_id(x)
#' @export
vec_cast.tosi_object_id.character <- function(x, to, ...) object_id(x)
#' @export
vec_cast.character.tosi_connector_id <- function(x, to, ...) vctrs::vec_data(x)
#' @export
vec_cast.character.tosi_object_id <- function(x, to, ...) vctrs::vec_data(x)
