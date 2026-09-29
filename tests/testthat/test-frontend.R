test_that("the remote frontend signatures and exports are exact", {
  expected <- list(
    tosi = alist(
      query = ,
      source_filter = NULL,
      aggregation = NULL,
      lang = NULL,
      col_mode = c("labels", "safe_labels", "ids"),
      format = "tbl"
    ),
    tosi_data = alist(
      path = ,
      source_filter = NULL,
      aggregation = NULL,
      lang = NULL,
      col_mode = c("labels", "safe_labels", "ids"),
      format = "tbl"
    ),
    tosi_schema = alist(
      path = ,
      source_filter = NULL,
      aggregation = NULL,
      lang = NULL
    ),
    tosi_metadata = alist(path = , lang = NULL),
    tosi_aggregation_options = alist(path = , lang = NULL),
    tosi_data_version = alist(path = ),
    tosi_catalog = alist(connector_id = , prefix = NULL, lang = NULL),
    tosi_search = alist(search_string = , lang = NULL),
    tosi_url = alist(
      url = ,
      lang = NULL,
      col_mode = c("labels", "safe_labels", "ids"),
      format = "tbl"
    ),
    tosi_source_reference = alist(reference = , lang = NULL),
    tosi_index_document = alist(path = , lang = NULL),
    tosi_help = alist(topic = )
  )

  for (name in names(expected)) {
    expect_identical(
      formals(get(name, envir = asNamespace("tosi"))),
      as.pairlist(expected[[name]]),
      info = name
    )
  }
  expect_true(all(names(expected) %in% getNamespaceExports("tosi")))
})

test_that("each frontend forwards its operation and supplied arguments", {
  calls <- list()
  local_mocked_bindings(perform_service_request = function(operation, args) {
    calls[[length(calls) + 1L]] <<- list(operation = operation, args = args)
    operation
  })
  selection <- list(
    empty = character(),
    singleton = "A",
    multiple = c("A", "B"),
    nested = list(code = "C", absent = NULL)
  )
  cases <- list(
    list(
      "tosi",
      quote(tosi("population", NULL, selection, "en", "ids", "tbl")),
      list(
        query = "population",
        source_filter = NULL,
        aggregation = selection,
        lang = "en",
        col_mode = "ids",
        format = "tbl"
      )
    ),
    list(
      "tosi_data",
      quote(tosi_data("statfin/table", selection, NULL, "fi", "labels", "tbl")),
      list(
        path = "statfin/table",
        source_filter = selection,
        aggregation = NULL,
        lang = "fi",
        col_mode = "labels",
        format = "tbl"
      )
    ),
    list(
      "tosi_schema",
      quote(tosi_schema("statfin/table", selection, list(time = "year"), "sv")),
      list(
        path = "statfin/table",
        source_filter = selection,
        aggregation = list(time = "year"),
        lang = "sv"
      )
    ),
    list(
      "tosi_metadata",
      quote(tosi_metadata("statfin/table", "en")),
      list(path = "statfin/table", lang = "en")
    ),
    list(
      "tosi_aggregation_options",
      quote(tosi_aggregation_options("tulli/table", "fi")),
      list(path = "tulli/table", lang = "fi")
    ),
    list(
      "tosi_data_version",
      quote(tosi_data_version("statfin/table")),
      list(path = "statfin/table")
    ),
    list(
      "tosi_catalog",
      quote(tosi_catalog("statfin", "population", "en")),
      list(connector_id = "statfin", prefix = "population", lang = "en")
    ),
    list(
      "tosi_search",
      quote(tosi_search("population", "fi")),
      list(search_string = "population", lang = "fi")
    ),
    list(
      "tosi_url",
      quote(tosi_url("https://example.invalid/table", "en", "ids", "tbl")),
      list(
        url = "https://example.invalid/table",
        lang = "en",
        col_mode = "ids",
        format = "tbl"
      )
    ),
    list(
      "tosi_source_reference",
      quote(tosi_source_reference("statfin/reference", "en")),
      list(reference = "statfin/reference", lang = "en")
    ),
    list(
      "tosi_index_document",
      quote(tosi_index_document("statfin/table", c("fi", "sv"))),
      list(path = "statfin/table", lang = c("fi", "sv"))
    ),
    list(
      "tosi_help",
      quote(tosi_help("statfin")),
      list(topic = "statfin")
    )
  )

  results <- map_chr(cases, ~ eval(.x[[2L]]))
  expected_calls <- map(cases, ~ list(operation = .x[[1L]], args = .x[[3L]]))
  expect_identical(results, map_chr(cases, 1L))
  expect_identical(calls, expected_calls)
})

test_that("named selectors and references use literal server argument names", {
  calls <- list()
  local_mocked_bindings(perform_service_request = function(operation, args) {
    calls[[length(calls) + 1L]] <<- list(operation = operation, args = args)
    NULL
  })

  tosi_schema(
    path = "fred/BWT",
    source_filter = "BWT",
    aggregation = list(time = "year"),
    lang = "en"
  )
  tosi_catalog(connector_id = "fred", prefix = "release")
  tosi_source_reference(reference = "source-reference/mock/ref", lang = "fi")

  expect_identical(
    calls,
    list(
      list(
        operation = "tosi_schema",
        args = list(
          path = "fred/BWT",
          source_filter = "BWT",
          aggregation = list(time = "year"),
          lang = "en"
        )
      ),
      list(
        operation = "tosi_catalog",
        args = list(connector_id = "fred", prefix = "release")
      ),
      list(
        operation = "tosi_source_reference",
        args = list(reference = "source-reference/mock/ref", lang = "fi")
      )
    )
  )
})

test_that("missing, null, empty, and defaulted arguments stay distinct", {
  calls <- list()
  local_mocked_bindings(perform_service_request = function(operation, args) {
    calls[[length(calls) + 1L]] <<- list(operation = operation, args = args)
    NULL
  })
  forward_tosi <- function(query) tosi(query)
  forward_help <- function(topic) tosi_help(topic)
  forward_schema <- function(path, lang) tosi_schema(path, lang = lang)

  tosi()
  tosi(NULL)
  tosi("")
  tosi_data("statfin/table")
  tosi_url("https://example.invalid/table")
  tosi_help()
  tosi_help(NULL)
  forward_tosi()
  forward_help()
  forward_schema("statfin/table")

  empty <- structure(list(), names = character())
  expect_identical(
    calls,
    list(
      list(operation = "tosi", args = empty),
      list(operation = "tosi", args = list(query = NULL)),
      list(operation = "tosi", args = list(query = "")),
      list(operation = "tosi_data", args = list(path = "statfin/table")),
      list(
        operation = "tosi_url",
        args = list(url = "https://example.invalid/table")
      ),
      list(operation = "tosi_help", args = empty),
      list(operation = "tosi_help", args = list(topic = NULL)),
      list(operation = "tosi", args = empty),
      list(operation = "tosi_help", args = empty),
      list(operation = "tosi_schema", args = list(path = "statfin/table"))
    )
  )
})
