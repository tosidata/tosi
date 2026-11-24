#' Find and retrieve tables
#'
#' @description
#' List connectors, find tables, and retrieve data from TosiData. Set up a
#' trusted service connection first; see [tosi_options()].
#'
#' - `tosi()` with no query lists available connectors and their IDs.
#' - `tosi_catalog()` lists tables provided by one connector.
#' - `tosi_search()` searches for tables across connector catalogs.
#' - `tosi_data()` retrieves a table identified by a data path.
#' - `tosi_url()` retrieves a table or catalog from a supported source URL.
#' - `tosi_source_reference()` retrieves a supported source document.
#'
#' Catalogs and search results list objects, not observation rows. Use the
#' selected entry's canonical `object_path` for [inspection][tosi_metadata]
#' and retrieval.
#'
#' @section Smart queries with tosi():
#' `tosi(query)` routes the query based on what you supply:
#'
#' - **Connector ID:** `tosi("eurostat")` lists the connector's tables.
#' - **Data path:** `tosi("eurostat/sdg_07_40")` retrieves the table's data.
#' - **Source URL:** a supported HTTP(S) URL can identify a table or a catalog.
#' - **Search terms:** `tosi("renewable energy")` searches connector catalogs.
#' - **Source-reference path:** `source-reference/<connector>/<reference>`
#'   retrieves the referenced document, where supported.
#'
#' Where a connector supports browsing by partial path, a path that matches a
#' prefix but not an exact table returns a catalog, even if it lists only one
#' table. Use `tosi_data()` when you need a table: an unresolved path raises an
#' error rather than returning a catalog.
#'
#' @section Select observations:
#' `source_filter` selects source values, series, or rows. `aggregation`
#' selects source-provided classifications or levels, not a calculation over
#' the returned rows. See [tosi_help()] for available connector instructions
#' and [tosi_aggregation_options()] for supported choices. Pass the same
#' selections to [tosi_schema()] to inspect the proposed request.
#'
#' For a source URL, use `tosi()` with `source_filter` or `aggregation` if you
#' need explicit selections. `tosi_url()` does not take these arguments.
#'
#' @section Result language:
#' For data retrieval, request one language, for example `lang = "en"` for
#' English. An explicit language overrides a language indicated by a source URL
#' without changing your session preferences. If neither is given, TosiData
#' uses the first available language in your [tosi_options()] preferences, or
#' the source's default. The connector listing shows languages for each
#' connector, not necessarily for every table it provides.
#'
#' In [tosi_catalog()], `lang = c("fi", "en")` keeps existing Finnish and
#' English catalog labels, and `lang = "all_languages"` keeps all available
#' labels. This does not request multiple copies of the table data. In
#' [tosi_search()], `lang` controls which labels are displayed, not which
#' languages are searched.
#'
#' @param query A connector ID, data path, URL, source-reference path, or search
#'   string. Omit it or use `NULL` to list available connectors.
#' @param path A data path beginning with a connector ID and `/`, followed by a
#'   canonical object ID or a supported source identifier or path. Use the
#'   `object_path` returned by catalogs and searches directly for retrieval and
#'   inspection.
#' @param reference A platform source-reference URI from a card's `$uri` in
#'   `metadata$source_references`, or its `connector_id/reference_id` path.
#'   Open external HTTP(S) references as links; `tosi_source_reference()` does
#'   not fetch them.
#' @param source_filter Optional selection of source values, series, or rows to
#'   retrieve. The accepted format and defaults depend on the connector. See
#'   [tosi_help()] for connector-specific instructions.
#' @param aggregation Optional named list selecting source classifications or
#'   aggregation levels by dimension. On connectors that support it, use
#'   `tosi_aggregation_options(path)` to inspect available choices.
#'   See [tosi_help()] for connector-specific instructions and examples.
#' @param lang Optional explicit result language. A non-`NULL` value overrides
#'   the session preference for that call.
#' @param col_mode Column naming mode:
#'   - `"labels"` (default) uses column labels.
#'   - `"safe_labels"` simplifies labels to ASCII letters, digits, and underscores.
#'   - `"ids"` uses column IDs.
#'
#'   This changes column names, not the values in the columns.
#' @param domain_mode For data retrieval, `"labels"` (default) requests labels
#'   in dimension cells, and `"codes"` requests source codes where supported.
#'   Unlike `col_mode`, this changes cell values, not column names.
#' @param format Output format for data retrieval. Use `"tbl"` to get a
#'   [tosi_table][is_tosi_table] in R.
#' @param connector_id A connector identifier.
#' @param prefix Keep catalog entries whose canonical object IDs start with
#'   this prefix. Matching ignores case and does not search table titles.
#' @param search_string Search terms.
#' @param url A source URL recognized by a connector.
#' @returns
#' - `tosi()` returns one of the following, depending on `query`:
#'   - No query or `NULL`: a `tosi_connector_catalog` tibble listing connectors.
#'   - A connector ID, catalog prefix, or supported catalog URL: a
#'     `tosi_dataset_catalog` tibble listing tables.
#'   - A data path identifying a table or a supported table URL: a `tosi_table`
#'     containing the data.
#'   - Search terms: a `tosi_search_results` tibble of matching tables.
#'   - A source-reference path: a [TosiSourceDocument].
#' - `tosi_data()`: a [tosi_table][is_tosi_table], a tibble with an embedded
#'   schema. Check its `result_scope` before using the rows as complete data.
#' - `tosi_url()`: a `tosi_table` or catalog result.
#' - `tosi_catalog()`: a `tosi_dataset_catalog` tibble.
#' - `tosi_search()`: a `tosi_search_results` tibble.
#' - `tosi_source_reference()`: a resolved [TosiSourceDocument], distinct from
#'   the compact [TosiSourceReference] cards included in other results.
#' @seealso [tosi_options()] for connection setup, [tosi_metadata()] for
#'   inspection, and [tosi_help()] for available connector instructions.
#'
#' @examples
#' \dontrun{
#' # After setting up a trusted connection (see ?tosi_options):
#' tosi()
#' tosi_search("renewable energy", lang = "en")
#' tosi_catalog("eurostat", prefix = "sdg_07_40", lang = "en")
#'
#' # Use the object_path of the catalog entry you want.
#' path <- "eurostat/sdg_07_40"
#' data <- tosi_data(path, lang = "en")
#' attr(data, "result_scope")
#' }
#' @name remote_frontends
NULL

#' @rdname remote_frontends
#' @export
tosi <- function(
  query = NULL,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
) {
  args <- list(
    query = query,
    source_filter = source_filter,
    aggregation = aggregation,
    lang = lang,
    col_mode = match.arg(col_mode),
    domain_mode = match.arg(domain_mode),
    format = format
  )
  perform_service_request("tosi", args)
}

#' @rdname remote_frontends
#' @export
tosi_data <- function(
  path,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
) {
  args <- list(
    path = path,
    source_filter = source_filter,
    aggregation = aggregation,
    lang = lang,
    col_mode = match.arg(col_mode),
    domain_mode = match.arg(domain_mode),
    format = format
  )
  perform_service_request("tosi_data", args)
}

#' @rdname tosi_metadata
#' @export
tosi_schema <- function(
  path,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL
) {
  perform_service_request(
    "tosi_schema",
    list(
      path = path,
      source_filter = source_filter,
      aggregation = aggregation,
      lang = lang
    )
  )
}

#' Inspect table metadata and options
#'
#' @description
#' These functions return information about a table, not observation rows.
#' `tosi_metadata()` describes the subject and source. `tosi_schema()`
#' describes the structure, including the components and their available
#' domains. Use the same `source_filter` and `aggregation` with `tosi_schema()`
#' as for the planned data request.
#'
#' `tosi_aggregation_options()` lists source-provided choices where supported.
#' Look for `TRUE` in the `aggregation_options` column of the connector listing
#' from `tosi()`. `tosi_data_version()` checks the version reported by the
#' connector independently of retrieval.
#'
#' @inheritParams remote_frontends
#' @returns
#' - `tosi_metadata()`: a [TosiMetadata] object, which may include
#'   [TosiSourceReference] cards.
#' - `tosi_schema()`: a [TosiSchema] object.
#' - `tosi_aggregation_options()`: a named list of available aggregation choices
#'   grouped by source dimension.
#' - `tosi_data_version()`: a `POSIXct` timestamp named by the canonical
#'   object path. It is not necessarily an uncached check and does not pin a
#'   later retrieval. For the version actually delivered, use the schema
#'   attached to the [returned table][is_tosi_table].
#' @seealso [tosi_data()] for retrieval and [tosi_help()] for available
#'   connector-specific selection instructions.
#' @examples
#' \dontrun{
#' # After setting up a trusted connection (see ?tosi_options):
#' path <- "eurostat/sdg_07_40"
#' metadata <- tosi_metadata(path, lang = "en")
#' metadata$print(details = TRUE)
#' schema <- tosi_schema(path, lang = "en")
#' schema$components
#' tosi_data_version(path)
#' }
#' @export
tosi_metadata <- function(path, lang = NULL) {
  perform_service_request("tosi_metadata", list(path = path, lang = lang))
}

#' @rdname tosi_metadata
#' @export
tosi_aggregation_options <- function(path, lang = NULL) {
  perform_service_request("tosi_aggregation_options", list(path = path, lang = lang))
}

#' @rdname tosi_metadata
#' @export
tosi_data_version <- function(path) {
  perform_service_request("tosi_data_version", list(path = path))
}

#' @rdname remote_frontends
#' @export
tosi_catalog <- function(connector_id, prefix = NULL, lang = NULL) {
  perform_service_request(
    "tosi_catalog",
    list(connector_id = connector_id, prefix = prefix, lang = lang)
  )
}

#' @rdname remote_frontends
#' @export
tosi_search <- function(search_string, lang = NULL) {
  perform_service_request(
    "tosi_search",
    list(search_string = search_string, lang = lang)
  )
}

#' @rdname remote_frontends
#' @export
tosi_url <- function(
  url,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  domain_mode = c("labels", "codes"),
  format = "tbl"
) {
  args <- list(
    url = url,
    lang = lang,
    col_mode = match.arg(col_mode),
    domain_mode = match.arg(domain_mode),
    format = format
  )
  perform_service_request("tosi_url", args)
}

#' @rdname remote_frontends
#' @export
tosi_source_reference <- function(reference, lang = NULL) {
  perform_service_request("tosi_source_reference", list(reference = reference, lang = lang))
}

#' Read connector help
#'
#' @description
#' Start with `tosi_help()` for the service's help index. Not every connector
#' has a help topic. For example, the `"tulli"` topic explains Uljas
#' classifications, source filters, and selection defaults.
#'
#' @param topic A help topic from the index, such as `"tulli"`. Omit it or
#'   use `"index"` to read the index.
#' @returns A [TosiHelp] object containing English Markdown. Use `print()` to
#'   display it in a script or `$content` to access the text.
#' @seealso [tosi_options()] for connection setup, [tosi_data()] for retrieval,
#'   and [tosi_metadata()] for table inspection.
#' @examples
#' \dontrun{
#' # After setting up a trusted connection (see ?tosi_options):
#' print(tosi_help())
#' print(tosi_help("tulli"))
#' }
#' @export
tosi_help <- function(topic = NULL) {
  perform_service_request("tosi_help", list(topic = topic %||% "index"))
}
