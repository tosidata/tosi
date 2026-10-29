# tosi 0.1.4

* Remove `tosi_index_document()` and `TosiIndexDocument`; use `tosi_metadata()` and `tosi_schema()` separately.
* Store metadata descriptions as ordered `TosiDescriptionSection` objects.
* Add frequency-bearing `time_range()` values and `as_time_range()`, with schema methods for actual observation/series counts and domain sizes.
* Retain domain notes and classification identifiers in schema components.

# tosi 0.1.3

* Replace calls to the removed `physical_column_names()` function with `schema$column_names(col_mode)`.
* Older saved results and old-server responses may fail with `$column_names()` or `as_tibble(..., drop_replaced = TRUE)`. Re-fetch results from an updated server, or retain the older client for those results.

# tosi 0.1.2

* Configure session-local table cache budgets in bytes with `tosi_options(cache_memory_size = ..., cache_disk_size = ...)`, or clear both layers with `tosi_cache_clear()`.

# tosi 0.1.1

* Add `schema$component()` and `$domain_table()` methods for inspecting schema components and their complete value domains without nested-list wrangling.
* Improve schema printing with a compact component overview, object type and data version. Individual components provide focused summaries, while `str()` continues to show R6 fields and methods.

# tosi 0.1.0

* Publish in GitHub
