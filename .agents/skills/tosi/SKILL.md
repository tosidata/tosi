---
name: tosi
description: Find, inspect, and retrieve statistical data through the public tosi R client for TosiData. Use when discovering connectors and tables, retrieving data by object path or source URL, interpreting returned observations, or consulting connector help and source documents.
---

# Use TosiData from R

TosiData is a hosted service for finding and retrieving statistical data from
sources such as Eurostat. `tosi` is its R client. Load it with `library(tosi)`.

Use only a service you trust. Requests need a service URL and access token
(`TOSI_URL` and `TOSI_TOKEN`; see `help("tosi_options", package = "tosi")`).
If access is not configured, ask for setup and use installed help in the meantime.
Never print or commit the token.

## Find the right object

A **connector** gives access to a source. Its **catalog** lists **data objects**
such as tables and series.

- To see which connectors are available, call `tosi()`.
- If you know the connector, browse its objects with `tosi_catalog()`, passing
  the connector ID.
- If you know the subject, search across catalogs with `tosi_search()`, for
  example `tosi_search("internet use")`.
- If you have a source URL, `tosi(url)` can resolve supported URLs to data or a
  catalog. Check which it returned.

Catalog and search entries identify objects; they are not observations. Choose
a candidate and use its returned `object_path` (`connector_id/object_id`) as
`path` in the next calls. Don't guess the path or assume the first match is the
right one.

## Inspect, select, and retrieve

Use `tosi_metadata(path)` to check what the object measures and find source
references. Use `tosi_schema(path)` to see how it is organized and check which
units, places, and periods are available.

**Installed R help** explains function arguments and results without a service
connection. `help(package = "tosi")` lists topics; start with
`help("tosi_data", package = "tosi")` for retrieval or
`help("TosiStructure", package = "tosi")` for schema and component values.

**Service help** explains source-specific filters, defaults, and interpretation.
List the available topics with `tosi_help()`, then pass a listed topic to
`tosi_help(topic)`. If no guide covers your source, don't infer filter syntax
from schema values alone. Use the same selections in `tosi_schema()` and
`tosi_data()` when inspecting and retrieving a subset. In scripts, use `print()`
to display help results.

Retrieve observations with `data <- tosi_data(path)`. Check
`attr(data, "result_scope")` before analyzing: `"preview"` is limited;
`"complete"` means complete for the request, not necessarily for the whole
source table. Inspect the returned columns. Before transforming the table,
record the delivered version (`attr(data, "schema")$data_version`) and
`provenance(data)`. See `help("is_tosi_table", package = "tosi")` for details.
