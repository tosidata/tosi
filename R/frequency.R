.frequency_code_levels <- c(
  "A" = "Annual",
  "S" = "Half-yearly, semester",
  "Q" = "Quarterly",
  "M" = "Monthly",
  "W2" = "Biweekly",
  "W" = "Weekly",
  "D" = "Daily",
  "A2" = "Biennial",
  "A3" = "Triennial",
  "A4" = "Quadrennial",
  "A5" = "Quinquennial",
  "A10" = "Decennial",
  "A20" = "Bidecennial",
  "A30" = "Tridecennial",
  "A_3" = "Three times a year",
  "M2" = "Bimonthly",
  "M_2" = "Semimonthly",
  "M_3" = "Three times a month",
  "W3" = "Triweekly",
  "W4" = "Four-weekly",
  "W_2" = "Semiweekly",
  "W_3" = "Three times a week",
  "D_2" = "Twice a day",
  "H" = "Hourly",
  "H2" = "Bihourly",
  "H3" = "Trihourly",
  "B" = "Daily - business week",
  "N" = "Minutely",
  "I" = "Irregular",
  "OA" = "Occasional annual",
  "OM" = "Occasional monthly",
  "_O" = "Other",
  "_U" = "Unspecified",
  "_Z" = "Not applicable",
  "N15" = "Every 15 minutes"
)

#' @rdname frequency_code
#' @export
new_frequency_code <- function(x = integer()) {
  vec_assert(x, integer())

  new_factor(
    x,
    levels = names(.frequency_code_levels),
    class = "tosi_frequency_code"
  )
}


#' Canonical frequency-code vectors
#'
#' Frequency codes use the 34
#' [SDMX CL_FREQ 2.1](https://registry.sdmx.org/ws/public/sdmxapi/rest/codelist/SDMX/CL_FREQ/2.1)
#' codes and the platform-defined `"N15"` quarter-hour extension. The first
#' seven levels are `"A"`, `"S"`, `"Q"`, `"M"`, `"W2"`, `"W"`, and `"D"`.
#' The remaining SDMX codes follow codelist order, with `"N15"` last.
#'
#' `"W2"` means every two weeks and `"M2"` every two months. `"B"` excludes
#' Saturdays and Sundays but does not define a holiday calendar. `"N"` is
#' minutely and may be sparse; `"I"`, `"OA"`, and `"OM"` retain irregular and
#' occasional meanings. `"_O"`, `"_U"`, and `"_Z"` mean other, unspecified,
#' and not applicable. A frequency does not define timezone, period alignment,
#' equal spacing, or duration arithmetic.
#'
#' @details
#' `frequency_code()` converts character or factor codes to a frequency-code
#' vector. Factor inputs use their string codes, not their integer positions.
#' Missing values are preserved, including an all-missing logical vector;
#' unrecognized codes are rejected. `NULL` stays `NULL`; empty character and
#' factor inputs produce an empty vector with all canonical levels.
#'
#' `new_frequency_code()` constructs a vector from integer positions in the
#' canonical level order (1 for `"A"`, 5 for `"W2"`), with `NA_integer_` for
#' missing values. It expects an integer vector; the default is empty.
#'
#' @param x For `frequency_code()`, a character, factor, or
#'   `tosi_frequency_code` vector, an all-missing logical vector, or `NULL`.
#'   For `new_frequency_code()`, an integer vector of level positions. For
#'   `is_frequency_code()`, any R object.
#' @return `frequency_code()` returns a factor-backed `tosi_frequency_code`
#'   vector with canonical levels, or `NULL` for `NULL` input.
#'   `new_frequency_code()` returns a factor-backed `tosi_frequency_code`
#'   vector from integer positions. `is_frequency_code()` returns `TRUE` if
#'   `x` inherits from `"tosi_frequency_code"`, `FALSE` otherwise.
#' @export
frequency_code <- function(x) {
  if (is.null(x) || is_frequency_code(x)) {
    return(x)
  }

  if (is.logical(x) && length(x) > 0L && all(is.na(x))) {
    return(new_frequency_code(rep(NA_integer_, length(x))))
  }

  if (is.character(x)) {
    x <- tryCatch(
      forcats::fct(x, levels = names(.frequency_code_levels)),
      error = function(e) {
        cli_abort(
          c(
            "{.arg x} must use canonical frequency-code levels.",
            "i" = "Expected levels are {.val {names(.frequency_code_levels)}}."
          )
        )
      }
    )
    return(new_frequency_code(as.integer(x)))
  }

  if (is.factor(x)) {
    if (!all(levels(x) %in% names(.frequency_code_levels))) {
      cli_abort(
        c(
          "{.arg x} must use canonical frequency-code levels.",
          "i" = "Expected levels are {.val {names(.frequency_code_levels)}}."
        )
      )
    }
    return(
      new_frequency_code(match(as.character(x), names(.frequency_code_levels)))
    )
  }

  cli_abort(
    "{.arg x} must be a character or factor vector."
  )
}

#' @rdname frequency_code
#' @keywords internal
#' @noRd
validate_frequency_code <- function(
  x,
  call = caller_env()
) {
  if (!is_frequency_code(x)) {
    cli_abort(
      "{.arg x} must be a <tosi_frequency_code> vector.",
      call = call
    )
  }

  if (!identical(levels(x), names(.frequency_code_levels))) {
    cli_abort(
      c(
        "{.arg x} must use canonical frequency-code levels.",
        "i" = "Expected levels are {.val {names(.frequency_code_levels)}}."
      ),
      call = call
    )
  }

  invisible(x)
}

#' @rdname frequency_code
#' @export
is_frequency_code <- function(x) {
  inherits(x, "tosi_frequency_code")
}

#' @export
vec_ptype_abbr.tosi_frequency_code <- function(x, ...) "freq"

#' @method type_sum tosi_frequency_code
#' @export
type_sum.tosi_frequency_code <- function(x) "freq"

#' @export
vec_ptype_full.tosi_frequency_code <- function(x, ...) "tosi_frequency_code"

#' @export
format.tosi_frequency_code <- function(x, ...) {
  as.character(x)
}

#' @export
vec_ptype2.tosi_frequency_code.tosi_frequency_code <- function(x, y, ...) {
  new_frequency_code()
}

#' @export
vec_cast.tosi_frequency_code.tosi_frequency_code <- function(x, to, ...) {
  x
}

#' @export
vec_cast.tosi_frequency_code.character <- function(x, to, ...) {
  frequency_code(x)
}

#' @export
vec_cast.character.tosi_frequency_code <- function(x, to, ...) {
  as.character.factor(x)
}
