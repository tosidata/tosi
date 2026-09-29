---
name: tosi
description: Find, inspect, and retrieve statistical data through the tosi R client for TosiData. Use when searching for tables, retrieving data by data path or source URL, interpreting schemas, or consulting connector help and source documents.
---

# Use TosiData from R

Use the `tosi` client, not platform internals. Load it with `library(tosi)`.
Requests require a trusted service URL and access token, configured through
`TOSI_URL` / `TOSI_TOKEN` or `tosi_options()`. Never print or commit tokens;
ask for connection setup if it is missing.

## Find a table

```r
tosi()                      # List available connectors
tosi_search("internet use") # Find candidate tables
```

Browse a chosen connector with `tosi_catalog("eurostat")`. Read the returned
entries and use their canonical `object_path` values as data paths; do not guess
identifiers or assume the first search result answers the question. If the user supplies a source URL,
`tosi(url)` can resolve supported URLs to data or a catalog.

## Inspect, then retrieve

Set `path` to the selected `object_path` and inspect it before downloading:

```r
tosi_metadata(path) # Descriptive metadata
tosi_schema(path)   # Schema components and value domains
```

Check that the subject, geography, time coverage, units, and classifications
match the question. Read connector help before choosing `source_filter`:
syntax and defaults vary by source. Use `tosi_aggregation_options(path)` when
you need source-supported classifications or aggregation levels; do not assume
this argument performs arbitrary statistical aggregation.

```r
data <- tosi_data(path)
```

Use `tosi_data()` when you require data: an unresolved path errors rather than
returning a catalog. Narrow large requests with the documented `source_filter`
and, where appropriate, `aggregation`. The same selections can be supplied to
`tosi_schema()` before retrieval.

## Understand the result

Expect these response types:

| Call | Response |
| --- | --- |
| `tosi()` without a query | `tosi_connector_catalog` tibble |
| `tosi_catalog()` | `tosi_dataset_catalog` tibble |
| `tosi_search()` | `tosi_search_results` tibble |
| `tosi_data()` | `tosi_table` tibble |
| `tosi_schema()` | `TosiSchema` R6 object |
| `tosi_metadata()` | `TosiMetadata` R6 object |
| `tosi_help()` | `TosiHelp` R6 object |
| `tosi_source_reference()` | `TosiSourceDocument` R6 object |
| `tosi_index_document()` | `TosiIndexDocument` R6 object |
| `tosi_aggregation_options()` | Named list of choices by dimension |
| `tosi_data_version()` | Named `POSIXct` timestamp |

With a query, `tosi()` returns the corresponding discovery, data, or source-document
result. `tosi_url()` returns data or a catalog. Source-reference cards embedded
in results are `TosiSourceReference` objects, not resolved documents; provenance
is represented by `TosiProvenance`.

Treat a `tosi_table` as a tibble carrying schema and provenance. Read its
`TosiSchema` components by role: `dimension`, `time`, `frequency`, `value`, and
`attribute`. Dimensions identify categories such as region; time and frequency
have distinct roles, not the dimension role. Inspect component IDs, labels,
data types, and value domains alongside the returned columns; do not assume
every schema contains every role.

Use `lang = "en"` when requesting English. Column names default to labels;
`col_mode = "ids"` uses column IDs and `"safe_labels"` simplifies labels.
`col_mode` changes column names, not column values.

Check `attr(data, "result_scope")`: `"preview"` means intentionally bounded rows;
`"complete"` means complete for the normalized request, not necessarily the
entire source table. Refine a preview's selection before treating it as complete. Preserve `provenance(data)`
and `attr(data, "schema")` before wrangling; metadata preservation after
transformations is not guaranteed. Report the source, selection, units, and
data version with your findings.

## Get help and supporting information

```r
tosi_help()        # List help topics
tosi_help("tulli") # Read one connector's instructions
```

These calls display the help document directly in interactive R. In a sourced
script, use `print(tosi_help("tulli"))`. For function arguments, use
`help("tosi_data", package = "tosi")`.

Retrieve a source document with `tosi_source_reference()` using the platform
source-reference URI in a card's `uri` field; external HTTP(S) references are
website links instead. Use `tosi_data_version(path)` to check the current data
version, not to pin a later retrieval. For search-indexing work, consult `help("tosi_index_document",
package = "tosi")`.
