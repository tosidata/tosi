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

# S3 method for class 'tosi_table'
as_tibble(x, ..., drop_replaced = FALSE)
```

## Arguments

- x:

  Any R object.

- ...:

  Arguments passed to
  [`tibble::as_tibble()`](https://tibble.tidyverse.org/reference/as_tibble.html).

- drop_replaced:

  If `TRUE`, omit delivered source columns identified by schema
  components' `replaces_id`. Names are derived from the complete
  embedded schema using the table's stored column mode.

## Value

`TRUE` if `x` inherits from `"tosi_table"`, `FALSE` otherwise.

`as_tibble()` returns an ordinary tibble. Conversion retains ordinary
tibble metadata behavior; the schema is not reduced or rebuilt, and no
metadata guarantee is made after conversion.

## Details

`attr(x, "schema")` is a
[TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md),
directly usable through its inherited schema methods. It holds the sole
canonical source identity and version through `$connector_id`,
`$object_id`, and `$data_version`; these are not independently stored on
the table. Metadata describes the result at delivery. Wrangling may
alter or discard it.
