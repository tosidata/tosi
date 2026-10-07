new_service_cache <- function(memory_size = 256 * 1024^2, disk_size = 1024^3) {
  cachem::cache_layered(
    cachem::cache_mem(max_size = memory_size, max_age = 300),
    cachem::cache_disk(
      max_size = disk_size,
      max_age = 300,
      evict = "fifo",
      destroy_on_finalize = TRUE,
      # Keep the downloaded bytes, not a new serialization of the decoded value.
      write_fn = function(entry, path) {
        if (!file.rename(entry$file, path)) {
          cli_abort("Could not move the downloaded result into the cache.")
        }
      },
      read_fn = function(path) {
        value <- tryCatch(qs2::qs_read(path), error = function(e) readRDS(path))
        list(value = value, file = path)
      }
    )
  )
}

# Initialize on first use, keeping the disk directory session-local.
get_service_cache <- local({
  cache <- NULL
  sizes <- NULL
  function() {
    current_sizes <- list(
      memory_size = getOption("tosi.cache_memory_size", 256 * 1024^2),
      disk_size = getOption("tosi.cache_disk_size", 1024^3)
    )
    if (is.null(cache) || !identical(sizes, current_sizes)) {
      if (!is.null(cache)) {
        cache$reset()
      }
      cache <<- do.call(new_service_cache, current_sizes)
      sizes <<- current_sizes
    }
    cache
  }
})

#' Clear cached table results
#'
#' Reset both the memory and disk caches in the current R session. The next
#' matching [tosi()] or [tosi_data()] call makes a new service request.
#' See [tosi_options()] for cache size settings and lifetime limitations.
#'
#' @return Invisible `NULL`.
#' @examples
#' tosi_cache_clear()
#' @export
tosi_cache_clear <- function() {
  get_service_cache()$reset()
  invisible(NULL)
}
