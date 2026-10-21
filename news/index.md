# Changelog

## tosi 0.1.3

- Replace calls to the removed `physical_column_names()` function with
  `schema$column_names(col_mode)`.
- Older saved results and old-server responses may fail with
  `$column_names()` or `as_tibble(..., drop_replaced = TRUE)`. Re-fetch
  results from an updated server, or retain the older client for those
  results.

## tosi 0.1.2

- Configure session-local table cache budgets in bytes with
  `tosi_options(cache_memory_size = ..., cache_disk_size = ...)`, or
  clear both layers with
  [`tosi_cache_clear()`](https://tosidata.github.io/tosi/reference/tosi_cache_clear.md).

## tosi 0.1.1

- Add `schema$component()` and `$domain_table()` methods for inspecting
  schema components and their complete value domains without nested-list
  wrangling.
- Improve schema printing with a compact component overview, object type
  and data version. Individual components provide focused summaries,
  while [`str()`](https://rdrr.io/r/utils/str.html) continues to show R6
  fields and methods.

## tosi 0.1.0

- Publish in GitHub
