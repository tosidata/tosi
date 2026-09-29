# Find and retrieve tables

List connectors, find tables, and retrieve data from TosiData.

- `tosi()` is a smart, multipurpose tool for common tasks. See [Smart
  queries with tosi()](#smart-queries-with-tosi-).

- `tosi_data()` retrieves a table identified by a data path.

- `tosi_catalog()` lists tables provided by a connector.

- `tosi_search()` searches for tables matching search terms.

- `tosi_url()` retrieves a table or catalog from a URL recognized by a
  connector.

- `tosi_source_reference()` retrieves a referenced source document.

For table descriptions, schemas, aggregation choices, and versions, see
[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md).
For indexing, see
[`tosi_index_document()`](https://tosidata.github.io/tosi/reference/tosi_index_document.md).
For connector instructions, see
[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md).

## Usage

``` r
tosi(
  query,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
)

tosi_data(
  path,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
)

tosi_catalog(connector_id, prefix = NULL, lang = NULL)

tosi_search(search_string, lang = NULL)

tosi_url(
  url,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
)

tosi_source_reference(reference, lang = NULL)
```

## Arguments

- query:

  A connector ID, data path, URL, source-reference path, or search
  string. Omit it or use `""` to list available connectors.

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

- col_mode:

  Column naming mode:

  - `"labels"` (default) uses column labels.

  - `"safe_labels"` simplifies labels to ASCII letters, digits, and
    underscores.

  - `"ids"` uses column IDs.

  This changes column names, not the values in the columns.

- format:

  Output format for data retrieval. Currently only `"tbl"` is supported,
  returning a `tosi_table`.

- path:

  A data path beginning with a connector ID and `/`, followed by a
  canonical object ID or a supported source identifier or path. Object
  paths returned by catalogs and searches can be used directly.

  For StatFin (PX), `"statfin/vaenn/14x2.px"` identifies a source table
  whose canonical object path is `"statfin/vaenn_14x2_px"`. For ECB,
  `"ecb/FM.B.U2.EUR.4F.KR.MLFR.LEV"` selects a series from `"ecb/FM"`;
  the part after `"FM."` is interpreted as `source_filter`.

- connector_id:

  A connector identifier.

- prefix:

  Restrict catalog entries to tables whose canonical object IDs start
  with this prefix.

- search_string:

  Search terms.

- url:

  A source URL recognized by a connector.

- reference:

  A connector/reference path or platform source-reference URI. Obtain a
  source-document reference from the `uri` field of a source-reference
  card in table metadata. External HTTP(S) references are website links,
  not documents this endpoint retrieves.

## Value

- `tosi()` returns one of the following, depending on `query`:

  - No query or `""`: a `tosi_connector_catalog` tibble listing
    connectors.

  - A connector ID, catalog prefix, or supported catalog URL: a
    `tosi_dataset_catalog` tibble listing tables.

  - A data path identifying a table or a supported table URL: a
    `tosi_table` containing the data.

  - Search terms: a `tosi_search_results` tibble of matching tables.

  - A source-reference path: a
    [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md).

- `tosi_data()`: a `tosi_table`.

- `tosi_url()`: a `tosi_table` or catalog result.

- `tosi_catalog()`: a `tosi_dataset_catalog` tibble.

- `tosi_search()`: a `tosi_search_results` tibble.

- `tosi_source_reference()`: a resolved
  [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md),
  distinct from the compact
  [TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  cards included in other results.

## Smart queries with tosi()

`tosi()` combines browsing, search, and retrieval. What it does depends
on what you supply as `query`:

- **No query:** `tosi()` or `tosi("")` lists available connectors and
  their IDs.

- **Connector ID:** `tosi("eurostat")` lists the tables provided by the
  Eurostat connector.

- **Data path:** `tosi("eurostat/tps00001")` retrieves the table's data.

- **Source URL:** `tosi(url)` identifies the connector and retrieves the
  table identified by a supported HTTP(S) URL. A URL identifying a
  connector or catalog prefix returns a table listing instead.

- **Search terms:** `tosi("internet use")` searches for tables across
  connector catalogs.

- **Source-reference path:** a path of the form
  `source-reference/<connector>/<reference>` retrieves the referenced
  document, where supported.

Catalogs and search results contain a canonical `object_path` for each
entry. Pass it as a data path to `tosi()` to retrieve the table's data.

Some connectors also support browsing by partial path. If the connector
cannot identify an exact table, `tosi()` lists tables whose paths start
with the supplied prefix. Even a single match is returned as a catalog,
not data. Use `tosi_data()` when you require data: an unresolved path
then raises an error instead of returning a catalog.

## Result language

Use `lang` to select the result language, for example `lang = "en"` for
English. This overrides any language specified in a source URL without
changing your session preferences.

When no explicit or URL language is supplied, TosiData uses the first
available language in your
[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
preferences. If no preference is available, it uses the source's first
language. The connector listing returned by `tosi()` shows the available
languages.

## See also

[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
for connection setup and session preferences.

## Examples

``` r
if (FALSE) { # \dontrun{
# After configuring your connection with tosi_options():
tosi()                               # List connectors
tosi("statfin")                      # Browse tables
tosi_data("statfin/vaenn/14x2.px")   # Retrieve a table by source path
tosi_data("statfin/vaenn_14x2_px")   # Or by canonical object path

# Request English for this call only.
tosi_data("statfin/vaenn_14x2_px", lang = "en")
} # }
```
