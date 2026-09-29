# Canonical frequency-code vectors

Frequency codes use the 34 [SDMX CL_FREQ
2.1](https://registry.sdmx.org/ws/public/sdmxapi/rest/codelist/SDMX/CL_FREQ/2.1)
codes and the platform-defined `"N15"` quarter-hour extension. The first
seven levels are `"A"`, `"S"`, `"Q"`, `"M"`, `"W2"`, `"W"`, and `"D"`.
The remaining SDMX codes follow codelist order, with `"N15"` last.

## Usage

``` r
new_frequency_code(x = integer())

frequency_code(x)

is_frequency_code(x)
```

## Arguments

- x:

  For `frequency_code()`, a character, factor, or `tosi_frequency_code`
  vector, an all-missing logical vector, or `NULL`. For
  `new_frequency_code()`, an integer vector of level positions. For
  `is_frequency_code()`, any R object.

## Value

`frequency_code()` returns a factor-backed `tosi_frequency_code` vector
with canonical levels, or `NULL` for `NULL` input.
`new_frequency_code()` returns a factor-backed `tosi_frequency_code`
vector from integer positions. `is_frequency_code()` returns `TRUE` if
`x` inherits from `"tosi_frequency_code"`, `FALSE` otherwise.

## Details

`"W2"` means every two weeks and `"M2"` every two months. `"B"` excludes
Saturdays and Sundays but does not define a holiday calendar. `"N"` is
minutely and may be sparse; `"I"`, `"OA"`, and `"OM"` retain irregular
and occasional meanings. `"_O"`, `"_U"`, and `"_Z"` mean other,
unspecified, and not applicable. A frequency does not define timezone,
period alignment, equal spacing, or duration arithmetic.

`frequency_code()` converts character or factor codes to a
frequency-code vector. Factor inputs use their string codes, not their
integer positions. Missing values are preserved, including an
all-missing logical vector; unrecognized codes are rejected. `NULL`
stays `NULL`; empty character and factor inputs produce an empty vector
with all canonical levels.

`new_frequency_code()` constructs a vector from integer positions in the
canonical level order (1 for `"A"`, 5 for `"W2"`), with `NA_integer_`
for missing values. It expects an integer vector; the default is empty.
