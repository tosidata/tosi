# Find and retrieve tables

List connectors, find tables, and retrieve data from TosiData. Set up a
trusted service connection first; see
[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md).

- `tosi()` with no query lists available connectors and their IDs.

- `tosi_catalog()` lists tables provided by one connector.

- `tosi_search()` searches for tables across connector catalogs.

- `tosi_data()` retrieves a table identified by a data path.

- `tosi_url()` retrieves a table or catalog from a supported source URL.

- `tosi_source_reference()` retrieves a supported source document.

Catalogs and search results list objects, not observation rows. Use the
selected entry's canonical `object_path` for
[inspection](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
and retrieval.

## Usage

``` r
tosi(
  query = NULL,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
)

tosi_data(
  path,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
)

tosi_catalog(connector_id, prefix = NULL, lang = NULL)

tosi_search(search_string, lang = NULL)

tosi_url(
  url,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
)

tosi_source_reference(reference, lang = NULL)
```

## Arguments

- query:

  A connector ID, data path, URL, source-reference path, or search
  string. Omit it or use `NULL` to list available connectors.

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

- col_mode:

  Column naming mode:

  - `"labels"` (default) uses column labels.

  - `"safe_labels"` simplifies labels to ASCII letters, digits, and
    underscores.

  - `"ids"` uses column IDs.

  This changes column names, not the values in the columns.

- domain_mode:

  For data retrieval, `"labels"` (default) requests labels in dimension
  cells, and `"codes"` requests source codes where supported. Unlike
  `col_mode`, this changes cell values, not column names.

- format:

  Output format for data retrieval. Use `"tbl"` to get a
  [tosi_table](https://tosidata.github.io/tosi/reference/tosi_table.md)
  in R.

- path:

  A data path beginning with a connector ID and `/`, followed by a
  canonical object ID or a supported source identifier or path. Use the
  `object_path` returned by catalogs and searches directly for retrieval
  and inspection.

- connector_id:

  A connector identifier.

- prefix:

  Keep catalog entries whose canonical object IDs start with this
  prefix. Matching ignores case and does not search table titles.

- search_string:

  Search terms.

- url:

  A source URL recognized by a connector.

- reference:

  A platform source-reference URI from a card's `$uri` in
  `metadata$source_references`, or its `connector_id/reference_id` path.
  Open external HTTP(S) references as links; `tosi_source_reference()`
  does not fetch them.

## Value

- `tosi()` returns one of the following, depending on `query`:

  - No query or `NULL`: a `tosi_connector_catalog` tibble listing
    connectors.

  - A connector ID, catalog prefix, or supported catalog URL: a
    `tosi_dataset_catalog` tibble listing tables.

  - A data path identifying a table or a supported table URL: a
    `tosi_table` containing the data.

  - Search terms: a `tosi_search_results` tibble of matching tables.

  - A source-reference path: a
    [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md).

- `tosi_data()`: a
  [tosi_table](https://tosidata.github.io/tosi/reference/tosi_table.md),
  a tibble with an embedded schema. Check its `result_scope` before
  using the rows as complete data.

- `tosi_url()`: a `tosi_table` or catalog result.

- `tosi_catalog()`: a `tosi_dataset_catalog` tibble.

- `tosi_search()`: a `tosi_search_results` tibble.

- `tosi_source_reference()`: a resolved
  [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md),
  distinct from the compact
  [TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  cards included in other results.

## Smart queries with tosi()

`tosi(query)` routes the query based on what you supply:

- **Connector ID:** `tosi("eurostat")` lists the connector's tables.

- **Data path:** `tosi("eurostat/sdg_07_40")` retrieves the table's
  data.

- **Source URL:** a supported HTTP(S) URL can identify a table or a
  catalog.

- **Search terms:** `tosi("renewable energy")` searches connector
  catalogs.

- **Source-reference path:** `source-reference/<connector>/<reference>`
  retrieves the referenced document, where supported.

Where a connector supports browsing by partial path, a path that matches
a prefix but not an exact table returns a catalog, even if it lists only
one table. Use `tosi_data()` when you need a table: an unresolved path
raises an error rather than returning a catalog.

## Select observations

`source_filter` selects source values, series, or rows. `aggregation`
selects source-provided classifications or levels, not a calculation
over the returned rows. See
[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
for available connector instructions and
[`tosi_aggregation_options()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
for supported choices. Pass the same selections to
[`tosi_schema()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
to inspect the proposed request.

For a source URL, use `tosi()` with `source_filter` or `aggregation` if
you need explicit selections. `tosi_url()` does not take these
arguments.

## Result language

For data retrieval, request one language, for example `lang = "en"` for
English. An explicit language overrides a language indicated by a source
URL without changing your session preferences. If neither is given,
TosiData uses the first available language in your
[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
preferences, or the source's default. The connector listing shows
languages for each connector, not necessarily for every table it
provides.

In `tosi_catalog()`, `lang = c("fi", "en")` keeps existing Finnish and
English catalog labels, and `lang = "all_languages"` keeps all available
labels. This does not request multiple copies of the table data. In
`tosi_search()`, `lang` controls which labels are displayed, not which
languages are searched.

## See also

[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
for connection setup,
[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
for inspection, and
[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
for available connector instructions.

## Examples

``` r
if (FALSE) { # \dontrun{
# After setting up a trusted connection (see ?tosi_options):
tosi()
tosi_search("renewable energy", lang = "en")
tosi_catalog("eurostat", prefix = "sdg_07_40", lang = "en")

# Use the object_path of the catalog entry you want.
path <- "eurostat/sdg_07_40"
data <- tosi_data(path, lang = "en")
attr(data, "result_scope")
} # }
```
