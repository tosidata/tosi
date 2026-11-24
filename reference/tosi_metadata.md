# Inspect table metadata and options

These functions return information about a table, not observation rows.
`tosi_metadata()` describes the subject and source. `tosi_schema()`
describes the structure, including the components and their available
domains. Use the same `source_filter` and `aggregation` with
`tosi_schema()` as for the planned data request.

`tosi_aggregation_options()` lists source-provided choices where
supported. Look for `TRUE` in the `aggregation_options` column of the
connector listing from
[`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md).
`tosi_data_version()` checks the version reported by the connector
independently of retrieval.

## Usage

``` r
tosi_schema(path, source_filter = NULL, aggregation = NULL, lang = NULL)

tosi_metadata(path, lang = NULL)

tosi_aggregation_options(path, lang = NULL)

tosi_data_version(path)
```

## Arguments

- path:

  A data path beginning with a connector ID and `/`, followed by a
  canonical object ID or a supported source identifier or path. Use the
  `object_path` returned by catalogs and searches directly for retrieval
  and inspection.

- source_filter:

  Optional selection of source values, series, or rows to retrieve. The
  accepted format and defaults depend on the connector. See
  [`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
  for connector-specific instructions.

- aggregation:

  Optional named list selecting source classifications or aggregation
  levels by dimension. On connectors that support it, use
  `tosi_aggregation_options(path)` to inspect available choices. See
  [`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
  for connector-specific instructions and examples.

- lang:

  Optional explicit result language. A non-`NULL` value overrides the
  session preference for that call.

## Value

- `tosi_metadata()`: a
  [TosiMetadata](https://tosidata.github.io/tosi/reference/TosiMetadata.md)
  object, which may include
  [TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  cards.

- `tosi_schema()`: a
  [TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md)
  object.

- `tosi_aggregation_options()`: a named list of available aggregation
  choices grouped by source dimension.

- `tosi_data_version()`: a `POSIXct` timestamp named by the canonical
  object path. It is not necessarily an uncached check and does not pin
  a later retrieval. For the version actually delivered, use the schema
  attached to the [returned
  table](https://tosidata.github.io/tosi/reference/tosi_table.md).

## See also

[`tosi_data()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
for retrieval and
[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
for available connector-specific selection instructions.

## Examples

``` r
if (FALSE) { # \dontrun{
# After setting up a trusted connection (see ?tosi_options):
path <- "eurostat/sdg_07_40"
metadata <- tosi_metadata(path, lang = "en")
metadata$print(details = TRUE)
schema <- tosi_schema(path, lang = "en")
schema$components
tosi_data_version(path)
} # }
```
