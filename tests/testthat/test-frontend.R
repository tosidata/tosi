test_that("index documents are absent from the public package", {
  namespace <- asNamespace("tosi")
  retired <- c("TosiIndexDocument", "tosi_index_document")

  expect_equal(intersect(retired, getNamespaceExports("tosi")), character())
  expect_false(exists("TosiIndexDocument", envir = namespace, inherits = FALSE))
  expect_false(exists(
    "tosi_index_document",
    envir = namespace,
    inherits = FALSE
  ))
})

test_that("the remote frontend signatures and exports are exact", {
  expected <- list(
    tosi = alist(
      query = NULL,
      source_filter = NULL,
      aggregation = NULL,
      lang = NULL,
      col_mode = c("labels", "safe_labels", "ids"),
      domain_mode = c("labels", "codes"),
      format = "tbl"
    ),
    tosi_data = alist(
      path = ,
      source_filter = NULL,
      aggregation = NULL,
      lang = NULL,
      col_mode = c("labels", "safe_labels", "ids"),
      domain_mode = c("labels", "codes"),
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
      domain_mode = c("labels", "codes"),
      format = "tbl"
    ),
    tosi_source_reference = alist(reference = , lang = NULL),
    tosi_help = alist(topic = NULL)
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
      quote(tosi("population", NULL, selection, "en", "ids", format = "tbl")),
      list(
        query = "population",
        source_filter = NULL,
        aggregation = selection,
        lang = "en",
        col_mode = "ids",
        domain_mode = "labels",
        format = "tbl"
      )
    ),
    list(
      "tosi_data",
      quote(tosi_data("statfin/table", selection, NULL, "fi", "safe", "cod")),
      list(
        path = "statfin/table",
        source_filter = selection,
        aggregation = NULL,
        lang = "fi",
        col_mode = "safe_labels",
        domain_mode = "codes",
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
      quote(tosi_url("https://example.invalid/table", "en", "ids", format = "tbl")),
      list(
        url = "https://example.invalid/table",
        lang = "en",
        col_mode = "ids",
        domain_mode = "labels",
        format = "tbl"
      )
    ),
    list(
      "tosi_source_reference",
      quote(tosi_source_reference("statfin/reference", "en")),
      list(reference = "statfin/reference", lang = "en")
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
        args = list(connector_id = "fred", prefix = "release", lang = NULL)
      ),
      list(
        operation = "tosi_source_reference",
        args = list(reference = "source-reference/mock/ref", lang = "fi")
      )
    )
  )
})

test_that("NULL uses the default query, help topic, and selectors", {
  local_mocked_bindings(perform_service_request = function(operation, args) args)

  expect_identical(tosi()["query"], list(query = NULL))
  expect_identical(tosi(NULL), tosi())
  expect_identical(tosi_help()$topic, "index")
  expect_identical(tosi_help(NULL), tosi_help())

  args <- tosi_data("statfin/table")
  expect_identical(tosi_data("statfin/table", lang = NULL), args)
  expect_identical(tosi_data("statfin/table", col_mode = NULL), args)
  expect_identical(tosi_data("statfin/table", domain_mode = NULL), args)
  expect_identical(args$col_mode, "labels")
  expect_identical(args$domain_mode, "labels")
  expect_error(tosi_data())
})
