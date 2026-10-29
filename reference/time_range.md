# Frequency-bearing reference-period bounds

`time_range()` constructs one range from scalar Date or POSIXct
endpoints with the same carrier and `first_period <= last_period`. It
preserves the supplied reference-period anchors and datetime timezones
without coercion.

## Usage

``` r
time_range(first_period, last_period, frequency)

as_time_range(x, frequency, ...)

# S3 method for class 'Date'
as_time_range(x, frequency, ...)

# S3 method for class 'POSIXct'
as_time_range(x, frequency, ...)
```

## Arguments

- first_period, last_period:

  Scalar Date or POSIXct reference periods.

- frequency:

  One nonmissing canonical code accepted by
  [`frequency_code()`](https://tosidata.github.io/tosi/reference/frequency_code.md).

- x:

  A Date or POSIXct vector of reference periods.

- ...:

  Reserved for methods; no additional reduction options are used.

## Value

A list-backed `tosi_time_range` with fields `frequency` (a scalar
`tosi_frequency_code`), `first_period` and `last_period`.

## Details

`as_time_range()` reduces a Date or POSIXct vector using
[`min()`](https://rdrr.io/r/base/Extremes.html) and
[`max()`](https://rdrr.io/r/base/Extremes.html) and calls
`time_range()`. Frequency is explicit; missing times are not filtered
and there is no empty-time recovery. Bounds do not imply continuous
occupancy, an enumerated domain, calendar alignment or per-series
coverage.

## Examples

``` r
time_range(as.Date("2020-01-01"), as.Date("2022-01-01"), "A")
#> $frequency
#> [1] A
#> 35 Levels: A S Q M W2 W D A2 A3 A4 A5 A10 A20 A30 A_3 M2 M_2 M_3 W3 W4 ... N15
#> 
#> $first_period
#> [1] "2020-01-01"
#> 
#> $last_period
#> [1] "2022-01-01"
#> 
#> attr(,"class")
#> [1] "tosi_time_range"
as_time_range(as.Date(c("2022-01-01", "2020-01-01")), "A")
#> $frequency
#> [1] A
#> 35 Levels: A S Q M W2 W D A2 A3 A4 A5 A10 A20 A30 A_3 M2 M_2 M_3 W3 W4 ... N15
#> 
#> $first_period
#> [1] "2020-01-01"
#> 
#> $last_period
#> [1] "2022-01-01"
#> 
#> attr(,"class")
#> [1] "tosi_time_range"
```
