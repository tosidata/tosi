# Inspect table metadata and options

Inspect a table without retrieving its data. `tosi_metadata()` returns
its descriptive metadata; `tosi_schema()` describes its structure and
can apply `source_filter` and `aggregation` selections.
`tosi_aggregation_options()` lists available aggregation choices by
source dimension. `tosi_data_version()` checks the current version
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
  canonical object ID or a supported source identifier or path. Object
  paths returned by catalogs and searches can be used directly.

  For StatFin (PX), `"statfin/vaenn/14x2.px"` identifies a source table
  whose canonical object path is `"statfin/vaenn_14x2_px"`. For ECB,
  `"ecb/FM.B.U2.EUR.4F.KR.MLFR.LEV"` selects a series from `"ecb/FM"`;
  the part after `"FM."` is interpreted as `source_filter`.

- source_filter:

  Optional selection of source values, series, or rows to retrieve. The
  accepted format and defaults depend on the connector. See
  [`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
  for connector-specific instructions.

- aggregation:

  Optional named list selecting source classifications or aggregation
  levels by dimension. Use `tosi_aggregation_options(path)` to inspect
  available choices. See
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

- `tosi_data_version()`: a named `POSIXct` timestamp identifying the
  current data version. Checking it does not fix a later retrieval's
  version.

## See also

[remote_frontends](https://tosidata.github.io/tosi/reference/remote_frontends.md)
for retrieval and result-language preferences,
[`tosi_index_document()`](https://tosidata.github.io/tosi/reference/tosi_index_document.md)
for search indexing, and
[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
for connector-specific selection instructions.

## Examples

``` r
if (FALSE) { # \dontrun{
tosi_metadata("statfin/vaenn_14x2_px")
tosi_schema("statfin/vaenn_14x2_px", lang = "en")
tosi_aggregation_options("statfin/vaenn_14x2_px")
tosi_data_version("statfin/vaenn_14x2_px")
} # }
```
