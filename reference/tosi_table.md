# Retrieved tables

A `tosi_table` is a tibble with a schema, title, source label,
provenance, and `result_scope` stored as attributes.
`result_scope = "complete"` means the table contains all rows for the
normalized request, not necessarily every row in the source.
`result_scope = "preview"` means the result is intentionally limited and
may need a source filter for complete data. Result scope is not a table
column or schema component.

## Usage

``` r
is_tosi_table(x)
```

## Arguments

- x:

  Any R object.

## Value

`TRUE` if `x` inherits from `"tosi_table"`, `FALSE` otherwise.
