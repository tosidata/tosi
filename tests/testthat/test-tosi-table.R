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
  expect_identical(attr(table, "schema", exact = TRUE), schema)
  expect_identical(names(table), c("geo", "value"))
  expect_identical(table$value, data$value)
  expect_identical(attr(table, "result_scope", exact = TRUE), "complete")
  expect_false("result_scope" %in% names(table))

  ordinary <- tibble::as_tibble(table)
  expect_false(is_tosi_table(ordinary))
  expect_equal(ordinary, data, ignore_attr = TRUE)
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
