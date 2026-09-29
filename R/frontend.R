#' Find and retrieve tables
#'
#' @description
#' List connectors, find tables, and retrieve data from TosiData.
#'
#' - `tosi()` is a smart, multipurpose tool for common tasks. See
#'   [Smart queries with tosi()](#smart-queries-with-tosi-).
#' - `tosi_data()` retrieves a table identified by a data path.
#' - `tosi_catalog()` lists tables provided by a connector.
#' - `tosi_search()` searches for tables matching search terms.
#' - `tosi_url()` retrieves a table or catalog from a URL recognized by a
#'   connector.
#' - `tosi_source_reference()` retrieves a referenced source document.
#'
#' For table descriptions, schemas, aggregation choices, and versions, see
#' [tosi_metadata()]. For indexing, see [tosi_index_document()]. For connector
#' instructions, see [tosi_help()].
#'
#' @section Smart queries with tosi():
#' `tosi()` combines browsing, search, and retrieval. What it does depends on
#' what you supply as `query`:
#'
#' - **No query:** `tosi()` or `tosi("")` lists available connectors and their
#'   IDs.
#' - **Connector ID:** `tosi("eurostat")` lists the tables provided by the
#'   Eurostat connector.
#' - **Data path:** `tosi("eurostat/tps00001")` retrieves the table's data.
#' - **Source URL:** `tosi(url)` identifies the connector and retrieves the
#'   table identified by a supported HTTP(S) URL. A URL identifying a connector
#'   or catalog prefix returns a table listing instead.
#' - **Search terms:** `tosi("internet use")` searches for tables across
#'   connector catalogs.
#' - **Source-reference path:** a path of the form
#'   `source-reference/<connector>/<reference>` retrieves the referenced
#'   document, where supported.
#'
#' Catalogs and search results contain a canonical `object_path` for each
#' entry. Pass it as a data path to `tosi()` to retrieve the table's data.
#'
#' Some connectors also support browsing by partial path. If the connector
#' cannot identify an exact table, `tosi()` lists tables whose paths start with
#' the supplied prefix. Even a single match is returned as a catalog, not data.
#' Use [tosi_data()] when you require data: an unresolved path then raises an
#' error instead of returning a catalog.
#'
#' @section Result language:
#' Use `lang` to select the result language, for example `lang = "en"` for
#' English. This overrides any language specified in a source URL without
#' changing your session preferences.
#'
#' When no explicit or URL language is supplied, TosiData uses the first
#' available language in your [tosi_options()] preferences. If no preference is
#' available, it uses the source's first language. The connector listing returned
#' by `tosi()` shows the available languages.
#'
#' @param query A connector ID, data path, URL, source-reference path, or search
#'   string. Omit it or use `""` to list available connectors.
#' @param path A data path beginning with a connector ID and `/`, followed by a
#'   canonical object ID or a supported source identifier or path. Object paths
#'   returned by catalogs and searches can be used directly.
#'
#'   For StatFin (PX), `"statfin/vaenn/14x2.px"` identifies a source table whose
#'   canonical object path is `"statfin/vaenn_14x2_px"`. For ECB,
#'   `"ecb/FM.B.U2.EUR.4F.KR.MLFR.LEV"` selects a series from `"ecb/FM"`; the
#'   part after `"FM."` is interpreted as `source_filter`.
#' @param reference A connector/reference path or platform source-reference URI.
#'   Obtain a source-document reference from the `uri` field of a source-reference
#'   card in table metadata. External HTTP(S) references are website links, not
#'   documents this endpoint retrieves.
#' @param source_filter Optional selection of source values, series, or rows to
#'   retrieve. The accepted format and defaults depend on the connector. See
#'   [tosi_help()] for connector-specific instructions.
#' @param aggregation Optional named list selecting source classifications or
#'   aggregation levels by dimension. Use `tosi_aggregation_options(path)` to
#'   inspect available choices. See [tosi_help()] for connector-specific
#'   instructions and examples.
#' @param lang Optional explicit result language. A non-`NULL` value overrides
#'   the session preference for that call.
#' @param col_mode Column naming mode:
#'   - `"labels"` (default) uses column labels.
#'   - `"safe_labels"` simplifies labels to ASCII letters, digits, and underscores.
#'   - `"ids"` uses column IDs.
#'
#'   This changes column names, not the values in the columns.
#' @param format Output format for data retrieval. Currently only `"tbl"` is
#'   supported, returning a `tosi_table`.
#' @param connector_id A connector identifier.
#' @param prefix Restrict catalog entries to tables whose canonical object IDs
#'   start with this prefix.
#' @param search_string Search terms.
#' @param url A source URL recognized by a connector.
#' @returns
#' - `tosi()` returns one of the following, depending on `query`:
#'   - No query or `""`: a `tosi_connector_catalog` tibble listing connectors.
#'   - A connector ID, catalog prefix, or supported catalog URL: a
#'     `tosi_dataset_catalog` tibble listing tables.
#'   - A data path identifying a table or a supported table URL: a `tosi_table`
#'     containing the data.
#'   - Search terms: a `tosi_search_results` tibble of matching tables.
#'   - A source-reference path: a [TosiSourceDocument].
#' - `tosi_data()`: a `tosi_table`.
#' - `tosi_url()`: a `tosi_table` or catalog result.
#' - `tosi_catalog()`: a `tosi_dataset_catalog` tibble.
#' - `tosi_search()`: a `tosi_search_results` tibble.
#' - `tosi_source_reference()`: a resolved [TosiSourceDocument], distinct from
#'   the compact [TosiSourceReference] cards included in other results.
#' @seealso [tosi_options()] for connection setup and session preferences.
#'
#' @examples
#' \dontrun{
#' # After configuring your connection with tosi_options():
#' tosi()                               # List connectors
#' tosi("statfin")                      # Browse tables
#' tosi_data("statfin/vaenn/14x2.px")   # Retrieve a table by source path
#' tosi_data("statfin/vaenn_14x2_px")   # Or by canonical object path
#'
#' # Request English for this call only.
#' tosi_data("statfin/vaenn_14x2_px", lang = "en")
#' }
#' @name remote_frontends
NULL

supplied_service_args <- function(call, env) {
  arg_names <- names(as.list(call)[-1L])
  # Evaluate missing() in the frontend frame without forcing its promises.
  is_missing <- map_lgl(
    arg_names,
    function(arg_name) {
      eval(base::call("missing", as.name(arg_name)), envir = env)
    }
  )
  arg_names <- arg_names[!is_missing]
  if (!length(arg_names)) {
    return(structure(list(), names = character()))
  }
  mget(arg_names, envir = env, inherits = FALSE)
}

#' @rdname remote_frontends
#' @export
tosi <- function(
  query,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
) {
  perform_service_request(
    "tosi",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname remote_frontends
#' @export
tosi_data <- function(
  path,
  source_filter = NULL,
  aggregation = NULL,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
) {
  perform_service_request(
    "tosi_data",
    supplied_service_args(match.call(), environment())
  )
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
    supplied_service_args(match.call(), environment())
  )
}

#' Inspect table metadata and options
#'
#' @description
#' Inspect a table without retrieving its data. `tosi_metadata()` returns its
#' descriptive metadata; `tosi_schema()` describes its structure and can apply
#' `source_filter` and `aggregation` selections. `tosi_aggregation_options()`
#' lists available aggregation choices by source dimension.
#' `tosi_data_version()` checks the current version independently of retrieval.
#'
#' @inheritParams remote_frontends
#' @returns
#' - `tosi_metadata()`: a [TosiMetadata] object, which may include
#'   [TosiSourceReference] cards.
#' - `tosi_schema()`: a [TosiSchema] object.
#' - `tosi_aggregation_options()`: a named list of available aggregation choices
#'   grouped by source dimension.
#' - `tosi_data_version()`: a named `POSIXct` timestamp identifying the current
#'   data version. Checking it does not fix a later retrieval's version.
#' @seealso [remote_frontends] for retrieval and result-language preferences,
#'   [tosi_index_document()] for search indexing, and [tosi_help()] for
#'   connector-specific selection instructions.
#' @examples
#' \dontrun{
#' tosi_metadata("statfin/vaenn_14x2_px")
#' tosi_schema("statfin/vaenn_14x2_px", lang = "en")
#' tosi_aggregation_options("statfin/vaenn_14x2_px")
#' tosi_data_version("statfin/vaenn_14x2_px")
#' }
#' @export
tosi_metadata <- function(path, lang = NULL) {
  perform_service_request(
    "tosi_metadata",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname tosi_metadata
#' @export
tosi_aggregation_options <- function(path, lang = NULL) {
  perform_service_request(
    "tosi_aggregation_options",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname tosi_metadata
#' @export
tosi_data_version <- function(path) {
  perform_service_request(
    "tosi_data_version",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname remote_frontends
#' @export
tosi_catalog <- function(connector_id, prefix = NULL, lang = NULL) {
  perform_service_request(
    "tosi_catalog",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname remote_frontends
#' @export
tosi_search <- function(search_string, lang = NULL) {
  perform_service_request(
    "tosi_search",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname remote_frontends
#' @export
tosi_url <- function(
  url,
  lang = NULL,
  col_mode = c("labels", "safe_labels", "ids"),
  format = "tbl"
) {
  perform_service_request(
    "tosi_url",
    supplied_service_args(match.call(), environment())
  )
}

#' @rdname remote_frontends
#' @export
tosi_source_reference <- function(reference, lang = NULL) {
  perform_service_request(
    "tosi_source_reference",
    supplied_service_args(match.call(), environment())
  )
}

#' Get a document for search indexing
#'
#' @description
#' Retrieve a table's metadata and structure as a search-index document.
#' Unlike other result endpoints, this endpoint supports multiple result
#' languages in one request.
#'
#' @inheritParams remote_frontends
#' @param lang Optional character vector of result languages for the index
#'   document. A non-`NULL` value overrides the session preference.
#' @returns A [TosiIndexDocument] object.
#' @seealso [tosi_metadata()] for table descriptions and schemas, and
#'   [remote_frontends] for retrieval.
#' @examples
#' \dontrun{
#' tosi_index_document("statfin/vaenn_14x2_px", lang = c("fi", "en"))
#' }
#' @export
tosi_index_document <- function(path, lang = NULL) {
  perform_service_request(
    "tosi_index_document",
    supplied_service_args(match.call(), environment())
  )
}

#' Read connector help
#'
#' @description
#' List available help topics or retrieve a connector-help article. For example,
#' `tosi_help("tulli")` explains Uljas classifications, source filters, and
#' selection defaults.
#'
#' @param topic A help topic such as `"tulli"`; omit to list available topics.
#' @returns A [TosiHelp] object containing English Markdown.
#' @seealso [remote_frontends] for retrieval and [tosi_metadata()] for table
#'   inspection.
#' @examples
#' \dontrun{
#' tosi_help()         # List available topics
#' tosi_help("tulli")  # Read connector instructions
#' }
#' @export
tosi_help <- function(topic) {
  perform_service_request(
    "tosi_help",
    supplied_service_args(match.call(), environment())
  )
}
