#' Object paths
#'
#' `object_path()` identifies an object within a connector. Supply complete
#' paths such as `"eurostat/tps00001"`, or supply connector IDs and object IDs
#' separately to combine them. Each complete path has exactly one `/` between
#' a canonical [connector_id()] and a canonical [object_id()].
#'
#' When combining vectors, a single connector ID is repeated for each object
#' ID, or a single object ID for each connector ID. Otherwise the vectors must
#' have the same length. Missing values are rejected at construction, but can
#' arise through ordinary vector indexing.
#'
#' @param x Complete object paths, or connector IDs when `object_id` is
#'   supplied.
#' @param object_id `NULL`, or object IDs to combine with `x`.
#'
#' @return A character-backed `tosi_object_path` vector.
#' @export
object_path <- function(x, object_id = NULL) {
  if (is.null(object_id)) {
    x <- vctrs::vec_cast(x, character())
    slash_count <- str_count(x, fixed("/"))

    if (anyNA(x) || any(slash_count != 1L)) {
      cli_abort(
        c(
          "{.arg x} must contain canonical object paths.",
          "i" = "Each path must contain exactly one slash."
        )
      )
    }

    components <- str_split_fixed(x, fixed("/"), n = 2L)
    validate_connector_id(components[, 1], arg = "connector component of x")
    validate_object_id(components[, 2], arg = "object component of x")

    return(new_object_path(x))
  }

  connectors <- connector_id(x)
  objects <- object_id(object_id)
  components <- vctrs::vec_recycle_common(
    connector_id = connectors,
    object_id = objects
  )

  new_object_path(str_c(
    as.character(components$connector_id),
    "/",
    as.character(components$object_id)
  ))
}

new_object_path <- function(x = character()) {
  vctrs::new_vctr(x, class = "tosi_object_path")
}

#' @export
connector_id.tosi_object_path <- function(x) {
  values <- vctrs::vec_data(x)
  components <- str_split_fixed(values, fixed("/"), n = 2L)[, 1]
  components[is.na(values)] <- NA_character_
  new_connector_id(components)
}

#' @export
object_id.tosi_object_path <- function(x) {
  values <- vctrs::vec_data(x)
  components <- str_split_fixed(values, fixed("/"), n = 2L)[, 2]
  components[is.na(values)] <- NA_character_
  new_object_id(components)
}

#' @export
format.tosi_object_path <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
as.character.tosi_object_path <- function(x, ...) {
  vctrs::vec_data(x)
}

#' @export
vec_ptype_abbr.tosi_object_path <- function(x, ...) "tosipath"

#' @export
vec_ptype_full.tosi_object_path <- function(x, ...) "tosi_object_path"

#' @export
vec_ptype2.tosi_object_path.tosi_object_path <- function(x, y, ...) {
  new_object_path()
}

#' @export
vec_ptype2.tosi_object_path.character <- function(x, y, ...) character()

#' @export
vec_ptype2.character.tosi_object_path <- function(x, y, ...) character()

#' @export
vec_cast.tosi_object_path.tosi_object_path <- function(x, to, ...) x

#' @export
vec_cast.tosi_object_path.character <- function(x, to, ...) object_path(x)

#' @export
vec_cast.character.tosi_object_path <- function(x, to, ...) {
  vctrs::vec_data(x)
}

#' @importFrom pillar pillar_shaft
#' @export
pillar_shaft.tosi_object_path <- function(x, ...) {
  values <- vctrs::vec_data(x)
  components <- str_split_fixed(values, fixed("/"), n = 2L)
  formatted <- str_c(
    col_cyan(components[, 1]),
    style_dim("/"),
    style_bold(components[, 2])
  )
  formatted[is.na(values)] <- NA_character_

  pillar::new_pillar_shaft_simple(formatted, ...)
}
