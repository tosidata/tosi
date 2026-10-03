## -- Discovery result S3 classes ---------------------------------------------

#' Construct discovery result tables
#'
#' These technical constructors attach a result-kind marker class to an
#' ordinary tibble. The resulting connector catalogs, dataset catalogs, and
#' search results retain ordinary tibble dimensions, truncation, and
#' subsetting while printing a concise identifying header. Empty dataset
#' catalogs and search results print guidance instead of an empty table.
#'
#' @param x A tibble-like discovery result.
#'
#' @return `x` as an ordinary tibble with its discovery result marker class.
#' @name discovery-results
#' @keywords internal
NULL

#' @rdname discovery-results
#' @export
new_tosi_connector_catalog <- function(x) {
  tibble::new_tibble(x, class = "tosi_connector_catalog")
}

#' @rdname discovery-results
#' @export
new_tosi_dataset_catalog <- function(x) {
  tibble::new_tibble(x, class = "tosi_dataset_catalog")
}

#' @rdname discovery-results
#' @export
new_tosi_search_results <- function(x) {
  tibble::new_tibble(x, class = "tosi_search_results")
}

#' @export
print.tosi_dataset_catalog <- function(x, ...) {
  if (nrow(x) > 0L) {
    return(NextMethod())
  }
  cat("No datasets found in this catalog.\n")
  cat("Try a shorter path or browse the connector.\n")
  invisible(x)
}

#' @export
print.tosi_search_results <- function(x, ...) {
  if (nrow(x) > 0L) {
    return(NextMethod())
  }
  cat("No matching datasets found.\n")
  cat("Try broader search terms.\n")
  invisible(x)
}

## -- Pillar summaries ---------------------------------------------------------

#' @importFrom pillar tbl_sum
#' @export
tbl_sum.tosi_connector_catalog <- function(x, ...) {
  summary <- NextMethod()
  names(summary)[[1]] <- col_cyan(style_bold("Connector catalog"))
  summary
}

#' @export
tbl_sum.tosi_dataset_catalog <- function(x, ...) {
  summary <- NextMethod()
  names(summary)[[1]] <- col_cyan(style_bold("Dataset catalog"))
  summary
}

#' @export
tbl_sum.tosi_search_results <- function(x, ...) {
  summary <- NextMethod()
  names(summary)[[1]] <- col_cyan(style_bold("Search results"))
  summary
}
