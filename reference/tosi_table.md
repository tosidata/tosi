# Retrieved tables

A `tosi_table` is a tibble with a schema, title, source label,
provenance, and `result_scope` stored as attributes. Check
`attr(x, "result_scope")` before using the rows:

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

- `"complete"`: all rows for the request as interpreted by the
  connector, including filters and defaults. This does not necessarily
  mean all rows in the source.

- `"preview"`: intentionally limited rows. Refine the selection using
  the available [connector
  instructions](https://tosidata.github.io/tosi/reference/tosi_help.md)
  and check the new result.

Result scope is not a table column or schema component.

`attr(x, "schema")` is a
[TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md)
with the delivered object's `$connector_id`, `$object_id`, and
`$data_version`. See `names(x)` for the actual column names and
[TosiStructure](https://tosidata.github.io/tosi/reference/TosiStructure.md)
for mapping component IDs to names. Use
[`provenance()`](https://tosidata.github.io/tosi/reference/provenance.md)
for the result's history. These attributes describe the table as
delivered; wrangling may alter or discard them.
