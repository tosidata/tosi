test_that("component inspection is bounded and attributes do not dump domains", {
  withr::local_options(width = 80, cli.num_colors = 1)
  components <- list(
    TosiSchemaComponent$new("other", domain_codes = paste0("u", 1:5)),
    TosiSchemaDimension$new("area", domain_codes = paste0("a", 1:5)),
    TosiSchemaTime$new(time_domain = as.Date("2020-01-01") + 0:4),
    TosiSchemaFrequency$new(
      frequency_domain = frequency_code(c("A", "M", "Q", "W", "D"))
    ),
    TosiSchemaValue$new(unit = "EUR"),
    TosiSchemaAttribute$new(
      "note",
      label = "Note",
      data_type = "string",
      level = "series",
      domain_codes = paste0("secret", 1:5)
    )
  )
  for (component in components) {
    before <- component$as_list()
    output <- capture.output(result <- withVisible(print(component)))
    expect_match(output[[1]], component$id, fixed = TRUE)
    expect_identical(result$value, component)
    expect_false(result$visible)
    expect_identical(component$as_list(), before)
    structure <- paste(capture.output(str(component)), collapse = "\n")
    expect_match(structure, "domain: active binding", fixed = TRUE)
    expect_match(structure, "print: function (n = 3)", fixed = TRUE)
    expect_null(component$format)
  }
  for (component in components[1:4]) {
    text <- paste(capture.output(component$print(n = 3)), collapse = "\n")
    expect_match(text, "2 more rows", fixed = TRUE)
    text <- paste(capture.output(component$print(n = 1)), collapse = "\n")
    expect_match(text, "4 more rows", fixed = TRUE)
    expect_identical(
      class(component$domain_table()),
      c("tbl_df", "tbl", "data.frame")
    )
  }
  expect_s3_class(components[[3]]$domain_table()$time, "Date")
  expect_s3_class(
    components[[4]]$domain_table()$frequency,
    "tosi_frequency_code"
  )
  text <- paste(capture.output(components[[5]]$print()), collapse = "\n")
  expect_match(text, "unit: EUR", fixed = TRUE)
  text <- paste(capture.output(components[[6]]$print()), collapse = "\n")
  for (fact in c("Note", "string", "series", "Domain: 5")) {
    expect_match(text, fact, fixed = TRUE)
  }
  expect_false(grepl("secret", text, fixed = TRUE))
  expect_identical(components[[6]]$domain_table()$code, paste0("secret", 1:5))
})

test_that("generic overview represents all roles without domain values or mutation", {
  withr::local_options(width = 100, cli.num_colors = 1)
  components <- list(
    TosiSchemaDimension$new("second", domain_codes = c("hidden1", "hidden2")),
    TosiSchemaAttribute$new(
      "note",
      domain_codes = "hidden_note",
      level = "series"
    ),
    TosiSchemaComponent$new("unknown"),
    TosiSchemaDimension$new("first", domain_codes = character()),
    TosiSchemaValue$new(unit = "EUR"),
    TosiSchemaTime$new(time_domain = as.Date("2020-01-01")),
    TosiSchemaFrequency$new(frequency_domain = frequency_code("A"))
  )
  schema <- TosiSchema$new(
    "demo",
    "sample",
    as.POSIXct("2020-01-01", tz = "UTC"),
    components,
    lang = "en"
  )
  before <- schema$as_list()
  names_before <- schema$column_names()
  output <- capture.output(result <- withVisible(schema$print()))
  text <- paste(output, collapse = "\n")
  for (fact in c(
    "demo/sample",
    "ID",
    "label",
    "role",
    "domain",
    "second",
    "first",
    "unknown",
    "time",
    "freq",
    "note",
    "value",
    "EUR",
    "not recorded",
    "data_version: 2020-01-01"
  )) {
    expect_match(text, fact, fixed = TRUE)
  }
  expect_true(
    which(grepl("second", output))[1] < which(grepl("first", output))[1]
  )
  expect_true(
    which(grepl("unknown", output))[1] < which(grepl("first", output))[1]
  )
  expect_match(text, "first.*dimension.*0")
  for (hidden in c("hidden", "object_type", "<TosiSchemaDimension>")) {
    expect_false(grepl(hidden, text, fixed = TRUE))
  }
  expect_identical(result$value, schema)
  expect_false(result$visible)
  expect_identical(schema$as_list(), before)
  expect_identical(schema$column_names(), names_before)
  for (i in seq_along(components)) {
    expect_identical(schema$components[[i]], components[[i]])
  }
  expect_identical(schema$domain_table("second")$code, c("hidden1", "hidden2"))
  expect_length(formals(schema$print), 0)
  structure <- paste(capture.output(str(schema)), collapse = "\n")
  expect_match(structure, "components: active binding", fixed = TRUE)
  expect_null(schema$format)
})

test_that("long labels preserve essential facts on narrow consoles", {
  withr::local_options(width = 60, pillar.width = NULL, cli.num_colors = 1)
  long_label <- paste(
    rep("A supported long component label", 10),
    collapse = " "
  )
  components <- list(
    TosiSchemaDimension$new("area", label = long_label, domain_codes = letters),
    TosiSchemaDimension$new(
      "kind",
      label = long_label,
      domain_codes = letters[1:3]
    ),
    TosiSchemaAttribute$new(
      "note",
      label = long_label,
      domain_codes = letters[1:7]
    ),
    TosiSchemaAttribute$new(
      "flag",
      label = long_label,
      domain_codes = letters[1:2]
    )
  )
  schema <- TosiSchema$new(
    "demo",
    "sample",
    as.POSIXct("2020-01-01", tz = "UTC"),
    components,
    lang = "en",
    object_type = "table"
  )
  before <- schema$as_list()
  names_before <- schema$column_names()
  output <- capture.output(print(schema))
  expect_lte(max(nchar(output, type = "width")), 60)
  expect_match(output[[1]], "demo/sample", fixed = TRUE)
  expect_true(any(grepl("object_type: table", output, fixed = TRUE)))
  expect_true(any(grepl("Attributes:", output, fixed = TRUE)))
  for (fact in c(
    "area.*dimension.*26",
    "kind.*dimension.*3",
    "note.*7",
    "flag.*2"
  )) {
    expect_true(any(grepl(fact, output)))
  }
  expect_true(which(grepl("area", output))[1] < which(grepl("kind", output))[1])
  expect_true(which(grepl("note", output))[1] < which(grepl("flag", output))[1])
  expect_false(any(grepl("more rows", output, fixed = TRUE)))
  expect_identical(schema$as_list(), before)
  expect_identical(schema$column_names(), names_before)
  expect_identical(schema$component("area")$label, long_label)
  expect_identical(schema$component("note")$label, long_label)
  expect_identical(schema$domain_table("area")$code, letters)
  expect_identical(schema$domain_table("note")$code, letters[1:7])
})

test_that("schemas without dimensions and missing versus empty domains stay useful", {
  for (component in list(
    TosiSchemaComponent$new("other"),
    TosiSchemaTime$new(),
    TosiSchemaFrequency$new(),
    TosiSchemaAttribute$new("status"),
    TosiSchemaAttribute$new("empty", domain_codes = character()),
    TosiSchemaValue$new()
  )) {
    schema <- TosiSchema$new(
      "demo",
      "sample",
      as.POSIXct("2020-01-01", tz = "UTC"),
      list(component),
      lang = "en"
    )
    text <- paste(capture.output(print(schema)), collapse = "\n")
    expect_match(text, component$id, fixed = TRUE)
    detail <- paste(capture.output(print(component)), collapse = "\n")
    if (component$id == "empty") {
      expect_match(text, "empty.*0")
      expect_match(detail, "Domain: 0", fixed = TRUE)
    } else if (component$role != "value") {
      expect_match(text, "not recorded", fixed = TRUE)
      expect_match(detail, "Domain: not recorded", fixed = TRUE)
    }
  }
})
