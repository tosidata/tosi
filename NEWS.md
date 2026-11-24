# tosi 0.2.0

* **Choose the language, column names, and dimension values separately.**
  When retrieving data:
  * `lang` chooses the language for labels, such as `"en"` for English or
    `"fi"` for Finnish.
  * `col_mode` controls column names: `"labels"` (default), `"safe_labels"`
    for simplified names, or `"ids"` for component IDs.
  * `domain_mode` controls the values in dimension columns: `"labels"`
    (default) or `"codes"` for source codes where supported.

  For example, `lang = "fi", domain_mode = "codes"` returns source codes in
  the data while keeping Finnish labels in the schema, where supported.
  `lang = "codes"` still requests coded values but does not choose a language.
* **List connectors with `tosi()` or `tosi(NULL)`.** `tosi("")` is treated as
  a search and errors because there is no search term.

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
