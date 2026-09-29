#' Generate physical column names
#'
#' Converts ordered schema components to physical column names. `"labels"`
#' uses component labels, `"safe_labels"` converts those labels to safe IDs,
#' and `"ids"` uses canonical component IDs. Label modes repair collisions
#' against canonical Time and Value names and fixed output names supplied in
#' `reserved_names`.
#'
#' This materialization boundary trusts constructor-created components and does
#' not revalidate their schema facts. Language selection is not part of this
#' interface. Callers producing code-valued data supply components with the
#' source-selected natural-language presentation in their labels.
#'
#' @param components Ordered list of schema components with `id`, `label`, and
#'   `role` fields.
#' @param col_mode One of `"labels"`, `"safe_labels"`, or `"ids"`.
#' @param reserved_names Physical output names owned by fixed columns. These
#'   names are protected from collisions in label modes.
#' @return Ordered character vector of physical column names.
#' @keywords internal
#' @export
physical_column_names <- function(
  components,
  col_mode,
  reserved_names = character()
) {
  component_ids <- unname(map_chr(components, "id"))
  if (identical(col_mode, "ids")) {
    return(component_ids)
  }

  labels <- unname(map_chr(components, "label"))
  physical_names <- switch(
    col_mode,
    labels = labels,
    safe_labels = stringi::stri_trans_general(labels, "Latin-ASCII") |>
      str_replace_all("[^a-zA-Z0-9_]", "_") |>
      str_replace("^(?=[[:digit:]])", "_")
  )
  fallback <- !nzchar(str_trim(labels)) | !nzchar(physical_names)
  physical_names[fallback] <- component_ids[fallback]
  if (any(fallback)) {
    cli_warn(c(
      "Localized column labels were unavailable for some components.",
      "i" = "Using canonical IDs for: {.val {component_ids[fallback]}}."
    ))
  }

  canonical <- component_ids %in%
    c("time", "value") &
    unname(map_chr(components, "role")) %in% c("time", "value")
  physical_names[canonical] <- component_ids[canonical]
  protected_names <- c(reserved_names, physical_names[canonical])
  repaired_names <- make.unique(
    c(protected_names, physical_names[!canonical]),
    sep = "_"
  )
  physical_names[!canonical] <- repaired_names[
    length(protected_names) + seq_len(sum(!canonical))
  ]
  physical_names
}
