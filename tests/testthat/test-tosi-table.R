test_that("tosi_table is an ordinary tibble carrier", {
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "test_table",
    data_version = as.POSIXct("2024-01-01", tz = "UTC"),
    components = list(
      TosiSchemaDimension$new(
        "geo",
        label = "Geography",
        data_type = "character",
        domain_codes = c("FI", "SE"),
        domain_labels = c("Finland", "Sweden")
      ),
      TosiSchemaValue$new()
    ),
    object_type = "table",
    lang = "en"
  )
  data <- tibble::tibble(
    geo = c("FI", "SE"),
    value = c(1.1, 2.2)
  )
  table <- new_tosi_table(
    x = data,
    schema = schema,
    col_mode = "ids",
    title = "Test table",
    source_label = "Statistics Finland"
  )

  expect_true(is_tosi_table(table))
  expect_s3_class(table, "tbl_df")
  embedded <- attr(table, "schema", exact = TRUE)
  expect_identical(embedded, schema)
  expect_r6_class(embedded, "TosiSchema")
  expect_identical(embedded$component("geo"), schema$components[[1L]])
  expect_identical(embedded$connector_id, connector_id("statfin"))
  expect_identical(embedded$object_id, object_id("test_table"))
  expect_identical(
    embedded$data_version,
    as.POSIXct("2024-01-01", tz = "UTC")
  )
  expect_length(
    intersect(
      names(attributes(table)),
      c("reference", "connector_id", "object_id", "data_version")
    ),
    0L
  )
  expect_identical(names(table), c("geo", "value"))
  expect_identical(table$value, data$value)
  expect_identical(attr(table, "result_scope", exact = TRUE), "complete")
  expect_false("result_scope" %in% names(table))
  output <- paste(capture.output(print(table)), collapse = "\n")
  expect_match(output, "statfin/test_table", fixed = TRUE)
  expect_match(output, "2024-01-01", fixed = TRUE)

  ordinary <- tibble::as_tibble(table)
  expect_false(is_tosi_table(ordinary))
  expect_equal(ordinary, data, ignore_attr = TRUE)
  expect_identical(tibble::as_tibble(table, drop_replaced = TRUE), ordinary)
  expected <- table
  class(expected) <- class(data)
  expect_identical(ordinary, tibble::as_tibble(expected))
  expect_identical(
    tibble::as_tibble(table, .name_repair = toupper, rownames = "row"),
    tibble::as_tibble(expected, .name_repair = toupper, rownames = "row")
  )
})

test_that("platform tables require a source-bound schema", {
  structural <- TosiStructure$new(
    components = list(TosiSchemaValue$new()),
    lang = "en"
  )
  expect_error(
    new_tosi_table(tibble::tibble(value = 1), structural, "ids"),
    "TosiSchema",
    class = "rlang_error"
  )
})

test_that("opt-in conversion drops only delivered replacement columns", {
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "test_table",
    data_version = as.POSIXct("2024-01-01", tz = "UTC"),
    components = list(
      TosiSchemaAttribute$new("undelivered", label = "Shared name"),
      TosiSchemaDimension$new("FREQ", label = "Shared name"),
      TosiSchemaDimension$new("TIME_PERIOD", label = "Time"),
      TosiSchemaDimension$new("geo", label = "Shared name"),
      TosiSchemaFrequency$new(label = "Shared name", replaces_id = "FREQ"),
      TosiSchemaTime$new(replaces_id = "TIME_PERIOD"),
      TosiSchemaValue$new(),
      TosiSchemaAttribute$new("flag", label = "Shared name")
    ),
    object_type = "table",
    lang = "en"
  )
  data <- tibble::tibble(
    FREQ = c("Quarterly", "Quarterly"),
    TIME_PERIOD = c("2024-Q1", "2024-Q2"),
    geo = factor(c("FI", "SE")),
    freq = factor(c("Q", "Q")),
    time = as.Date(c("2024-01-01", "2024-04-01")),
    value = c(1L, NA_integer_),
    flag = c(NA_character_, "provisional")
  )
  schema_before <- schema$as_list()
  for (mode in c("ids", "labels", "safe_labels")) {
    physical <- schema$column_names(mode)
    named <- data
    names(named) <- unname(physical[names(data)])
    table <- new_tosi_table(named, schema, mode, result_scope = "preview")
    columns_before <- map(table, identity)
    attributes_before <- attributes(table)
    ordinary <- tibble::as_tibble(table)
    expect_identical(names(ordinary), names(named))
    expect_equal(ordinary, named, ignore_attr = TRUE)
    keep <- !names(ordinary) %in% physical[c("FREQ", "TIME_PERIOD")]

    expect_no_condition(
      converted <- tibble::as_tibble(table, drop_replaced = TRUE)
    )
    expect_identical(converted, ordinary[keep])
    expect_false(is_tosi_table(converted))
    expect_identical(attr(converted, "schema"), schema)
    expect_identical(map(table, identity), columns_before)
    expect_identical(attributes(table), attributes_before)
    expect_identical(schema$as_list(), schema_before)

    # A replaced source column need not be physically delivered.
    narrower <- table[!names(table) %in% physical[["FREQ"]]]
    expect_identical(
      tibble::as_tibble(narrower, drop_replaced = TRUE),
      converted
    )
  }
})

test_that("tosi_table enforces result scope at construction", {
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "test_table",
    data_version = as.POSIXct("2024-01-01", tz = "UTC"),
    components = list(TosiSchemaValue$new()),
    object_type = "table",
    lang = "en"
  )
  data <- tibble::tibble(value = 1)
  positional <- new_tosi_table(
    data,
    schema,
    "ids",
    "Test table",
    "Statistics Finland",
    NULL
  )

  expect_identical(
    attr(positional, "result_scope", exact = TRUE),
    "complete"
  )
  expect_error(
    new_tosi_table(data, schema, "ids", result_scope = "partial"),
    "complete.*preview"
  )
  expect_error(
    new_tosi_table(
      data,
      schema,
      "ids",
      result_scope = c("complete", "preview")
    ),
    "complete.*preview"
  )
})

test_that("preview table printing guides without emitting a condition", {
  schema <- TosiSchema$new(
    connector_id = "tulli",
    object_id = "test_table",
    data_version = as.POSIXct("2024-01-01", tz = "UTC"),
    components = list(TosiSchemaValue$new()),
    object_type = "table",
    lang = "en"
  )
  data <- tibble::tibble(value = 1)
  preview <- new_tosi_table(
    data,
    schema,
    "ids",
    result_scope = structure(
      "preview",
      names = "scope",
      class = "test_result_scope"
    )
  )
  complete <- new_tosi_table(data, schema, "ids")

  expect_identical(
    attr(preview, "result_scope", exact = TRUE),
    "preview"
  )
  expect_no_condition(
    preview_output <- capture.output(print(preview))
  )
  expect_match(
    paste(preview_output, collapse = "\n"),
    "preview.*source filter.*complete",
    ignore.case = TRUE
  )
  expect_false(str_detect(
    paste(capture.output(print(complete)), collapse = "\n"),
    regex("source filter.*complete", ignore_case = TRUE)
  ))
  expect_false("result_scope" %in% names(preview))
})


test_that("table construction retains rows when there are no physical columns", {
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "test_table",
    data_version = as.POSIXct("2024-01-01", tz = "UTC"),
    components = list(TosiSchemaValue$new()),
    object_type = "table",
    lang = "en"
  )
  for (rows in c(0L, 3L)) {
    data <- tibble::tibble(.rows = rows)
    table <- new_tosi_table(data, schema, "ids")
    expect_identical(dim(table), c(rows, 0L))
    expect_identical(dim(tibble::as_tibble(table)), c(rows, 0L))
  }
})
