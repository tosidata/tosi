#' Frequency-bearing reference-period bounds
#'
#' `time_range()` constructs one range from scalar Date or POSIXct endpoints
#' with the same carrier and `first_period <= last_period`. It preserves the
#' supplied reference-period anchors and datetime timezones without coercion.
#'
#' `as_time_range()` reduces a Date or POSIXct vector using `min()` and `max()`
#' and calls `time_range()`. Frequency is explicit; missing times are not
#' filtered and there is no empty-time recovery. Bounds do not imply continuous
#' occupancy, an enumerated domain, calendar alignment or per-series coverage.
#'
#' @param first_period,last_period Scalar Date or POSIXct reference periods.
#' @param frequency One nonmissing canonical code accepted by
#'   [frequency_code()].
#' @param x A Date or POSIXct vector of reference periods.
#' @param ... Reserved for methods; no additional reduction options are used.
#' @return A list-backed `tosi_time_range` with fields `frequency` (a scalar
#'   `tosi_frequency_code`), `first_period` and `last_period`.
#' @export
#' @examples
#' time_range(as.Date("2020-01-01"), as.Date("2022-01-01"), "A")
#' as_time_range(as.Date(c("2022-01-01", "2020-01-01")), "A")
time_range <- function(first_period, last_period, frequency) {
  frequency <- frequency_code(frequency)
  validate_frequency_code(frequency)
  if (length(frequency) != 1L || anyNA(frequency)) {
    cli_abort(
      "{.arg frequency} must be one nonmissing canonical frequency code."
    )
  }
  carrier <- if (inherits(first_period, "Date")) "Date" else "POSIXct"
  if (
    length(first_period) != 1L ||
      length(last_period) != 1L ||
      !inherits(first_period, carrier) ||
      !inherits(last_period, carrier) ||
      !isTRUE(first_period <= last_period)
  ) {
    cli_abort(c(
      "Range endpoints must be scalar Date or POSIXct values.",
      "i" = "Use the same carrier and first_period <= last_period."
    ))
  }
  structure(
    list(
      frequency = frequency,
      first_period = first_period,
      last_period = last_period
    ),
    class = "tosi_time_range"
  )
}

#' @rdname time_range
#' @export
as_time_range <- function(x, frequency, ...) {
  UseMethod("as_time_range")
}

#' @rdname time_range
#' @export
as_time_range.Date <- function(x, frequency, ...) {
  time_range(min(x), max(x), frequency)
}

#' @rdname time_range
#' @export
as_time_range.POSIXct <- as_time_range.Date
