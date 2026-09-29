test_that("TosiSchema preserves identity and an ordered semantic graph", {
  data_version <- as.POSIXct("2025-01-02 03:04:05", tz = "UTC")
  time_domain <- as.Date(c("2020-01-01", "2021-01-01"))
  frequency_domain <- frequency_code("A")

  geo <- TosiSchemaDimension$new(
    id = "geo",
    label = "Geography",
    data_type = "category",
    domain_codes = c("FI", "SE"),
    domain_labels = c("Finland", "Sweden")
  )
  source_period <- TosiSchemaDimension$new(
    id = "source_period",
    label = "Year",
    data_type = "category",
    domain_codes = c("2020", "2021"),
    domain_labels = c("2020", "2021")
  )
  time <- TosiSchemaTime$new(
    label = "Time",
    data_type = "date",
    replaces_id = "source_period",
    time_domain = time_domain
  )
  source_frequency <- TosiSchemaDimension$new(
    id = "source_frequency",
    label = "Source frequency",
    data_type = "category",
    domain_codes = "A",
    domain_labels = "Annual"
  )
  frequency <- TosiSchemaFrequency$new(
    label = "Frequency",
    data_type = "category",
    frequency_domain = frequency_domain,
    replaces_id = "source_frequency"
  )
  value <- TosiSchemaValue$new(unit = "persons")
  status <- TosiSchemaAttribute$new(
    id = "status",
    label = "Status",
    data_type = "category",
    domain_codes = c("F", "P"),
    domain_labels = c("Final", "Provisional"),
    level = "observation"
  )

  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "population",
    data_version = data_version,
    components = list(
      geo,
      source_period,
      time,
      source_frequency,
      frequency,
      value,
      status
    ),
    object_type = "series",
    lang = "en"
  )

  expect_identical(schema$connector_id, connector_id("statfin"))
  expect_identical(schema$object_id, object_id("population"))
  expect_identical(schema$data_version, data_version)
  expect_identical(schema$lang, "en")
  expect_identical(
    map_chr(schema$components, \(component) component$id),
    c(
      "geo",
      "source_period",
      "time",
      "source_frequency",
      "freq",
      "value",
      "status"
    )
  )
  expect_identical(
    map_chr(schema$components, \(component) component$role),
    c(
      "dimension",
      "dimension",
      "time",
      "dimension",
      "frequency",
      "value",
      "attribute"
    )
  )
  expect_identical(schema$series_key, c("geo", "freq"))
  expect_identical(time$replaces_id, "source_period")
  expect_identical(frequency$replaces_id, "source_frequency")
  expect_identical(time$domain, list(time = time_domain))
  expect_identical(
    frequency$domain,
    list(frequency = frequency_domain)
  )
  expect_null(value$domain)
  expect_identical(
    status$domain,
    list(code = c("F", "P"), label = c("Final", "Provisional"))
  )

  projected <- schema$as_list()
  expect_true(all(map_lgl(projected$components, is.list)))
  expect_identical(projected$components[[1L]]$domain, geo$domain)
  expect_identical(projected$components[[3L]]$domain, time$domain)
  expect_identical(projected$components[[5L]]$domain, frequency$domain)
  expect_identical(projected$components[[6L]]$domain, value$domain)
  expect_identical(projected$components[[7L]]$domain, status$domain)

  expect_identical(geo$label, "Geography")
  expect_identical(schema$components[[1L]]$label, "Geography")
  expect_identical(schema$as_list()$components[[1L]]$label, "Geography")
})

test_that("schema naming allocates from all components without changing schema", {
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "population",
    data_version = as.POSIXct("2025-01-02", tz = "UTC"),
    lang = "en",
    components = list(
      TosiSchemaDimension$new(id = "first", label = "Trade value"),
      TosiSchemaAttribute$new(id = "absent", label = "Trade-value"),
      TosiSchemaDimension$new(id = "last", label = "Trade value"),
      TosiSchemaDimension$new(id = "conflict", label = "time"),
      TosiSchemaTime$new(label = "Localized time", data_type = "date"),
      TosiSchemaValue$new()
    )
  )
  original <- schema$as_list()
  names <- schema$column_names("safe_labels")
  expect_identical(
    names[c("first", "last", "conflict", "time", "value")],
    c(
      first = "Trade_value",
      last = "Trade_value_2",
      conflict = "time_1",
      time = "time",
      value = "value"
    )
  )
  expect_identical(names[["absent"]], "Trade_value_1")
  expect_identical(schema$column_names("labels")[["time"]], "time")
  expect_identical(schema$column_names("ids")[["last"]], "last")
  expect_identical(schema$as_list(), original)
})

test_that("TosiSchema accepts biweekly frequency and retains source dates", {
  dates <- as.Date(c("2026-08-05", "2026-08-19"))
  time <- TosiSchemaTime$new(time_domain = dates)
  schema <- TosiSchema$new(
    connector_id = "mock",
    object_id = "biweekly",
    data_version = as.POSIXct("2026-08-20", tz = "UTC"),
    components = list(time, TosiSchemaValue$new()),
    object_type = "table",
    lang = "en",
    frequency = frequency_code("W2")
  )

  expect_identical(schema$frequency, frequency_code("W2"))
  expect_identical(schema$components[[1L]]$domain$time, dates)
  expect_identical(schema$as_list()$frequency, frequency_code("W2"))
  expect_null(schema$series_key)
})

test_that("TosiSchema accepts mixed biweekly and unknown frequency domains", {
  frequencies <- frequency_code(c("W2", "W", NA))
  frequency <- TosiSchemaFrequency$new(
    frequency_domain = frequencies
  )
  schema <- TosiSchema$new(
    connector_id = "mock",
    object_id = "mixed_frequency",
    data_version = as.POSIXct("2026-08-20", tz = "UTC"),
    components = list(
      TosiSchemaTime$new(),
      frequency,
      TosiSchemaValue$new()
    ),
    object_type = "table",
    lang = "en"
  )

  expect_identical(schema$components[[2L]]$domain$frequency, frequencies)
  expect_identical(
    schema$as_list()$components[[2L]]$domain$frequency,
    frequencies
  )
  expect_null(schema$frequency)
  expect_null(schema$series_key)
})

test_that("TosiSchema and all component classes reject field replacement", {
  component <- TosiSchemaComponent$new(
    id = "unknown",
    label = "Unknown",
    domain_codes = "A",
    domain_labels = "Alpha"
  )
  dimension <- TosiSchemaDimension$new("geo", label = "Geography")
  time <- TosiSchemaTime$new(
    time_domain = as.Date("2025-01-01")
  )
  frequency <- TosiSchemaFrequency$new(
    frequency_domain = frequency_code("A")
  )
  value <- TosiSchemaValue$new(unit = "persons")
  attribute <- TosiSchemaAttribute$new(
    "status",
    level = "observation"
  )
  schema <- TosiSchema$new(
    connector_id = "mock",
    object_id = "population",
    data_version = as.POSIXct("2025-01-01", tz = "UTC"),
    components = list(
      component,
      dimension,
      time,
      frequency,
      value,
      attribute
    ),
    object_type = "table",
    lang = "en"
  )

  candidate <- schema$clone()
  expect_error(candidate$object_id <- object_id("changed"), "read-only")
  candidate <- schema$clone()
  expect_error(candidate$components[[1L]] <- dimension, "read-only")
  candidate <- component$clone()
  expect_error(candidate$label <- "Changed", "read-only")
  candidate <- component$clone()
  expect_error(candidate$domain$label[[1L]] <- "Changed", "read-only")
  candidate <- dimension$clone()
  expect_error(candidate$role <- "unknown", "read-only")
  candidate <- time$clone()
  expect_error(candidate$replaces_id <- "source_period", "read-only")
  candidate <- frequency$clone()
  expect_error(candidate$replaces_id <- "source_frequency", "read-only")
  candidate <- value$clone()
  expect_error(candidate$unit <- "people", "read-only")
  candidate <- attribute$clone()
  expect_error(candidate$level <- "series", "read-only")

  expect_identical(schema$object_id, object_id("population"))
  expect_identical(component$domain$label, "Alpha")
  expect_identical(dimension$role, "dimension")
  expect_null(time$replaces_id)
  expect_null(frequency$replaces_id)
  expect_identical(value$unit, "persons")
  expect_identical(attribute$level, "observation")

  shallow <- schema$clone()
  deep <- schema$clone(deep = TRUE)

  expect_false(identical(shallow, schema))
  expect_false(identical(deep, schema))
  expect_identical(shallow$as_list(), schema$as_list())
  expect_identical(deep$as_list(), schema$as_list())
  expect_identical(shallow$components[[1L]], component)
  expect_identical(deep$components[[1L]], component)
  expect_error(shallow$lang <- "fi", "read-only")
  expect_error(deep$lang <- "fi", "read-only")
})

test_that("TosiSchemaValue supplies canonical numeric facts and a unit", {
  value <- TosiSchemaValue$new(unit = "persons")

  expect_identical(
    value$as_list(),
    list(
      id = "value",
      label = "value",
      role = "value",
      data_type = "number",
      unit = "persons"
    )
  )
  expect_null(value$domain)
  expect_null(TosiSchemaValue$new()$unit)

  obsolete_arguments <- list(
    list(label = "Population"),
    list(data_type = "double"),
    list(domain_codes = "OBS"),
    list(domain_labels = "Observed")
  )
  walk(obsolete_arguments, function(arguments) {
    expect_error(
      do.call(TosiSchemaValue$new, arguments),
      "unused argument"
    )
  })
})

test_that("TosiSchema permits zero or one Value component", {
  data_version <- as.POSIXct("2025-01-02", tz = "UTC")
  dimension <- TosiSchemaDimension$new("geo")
  no_value <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "population",
    data_version = data_version,
    components = list(dimension),
    object_type = "table",
    lang = "en"
  )
  one_value <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "population",
    data_version = data_version,
    components = list(dimension, TosiSchemaValue$new()),
    object_type = "table",
    lang = "en"
  )

  expect_false(any(map_lgl(
    no_value$components,
    inherits,
    "TosiSchemaValue"
  )))
  expect_identical(
    sum(map_lgl(one_value$components, inherits, "TosiSchemaValue")),
    1L
  )
  expect_error(
    TosiSchema$new(
      connector_id = "statfin",
      object_id = "population",
      data_version = data_version,
      components = list(
        dimension,
        TosiSchemaValue$new(),
        TosiSchemaValue$new()
      ),
      object_type = "table",
      lang = "en"
    ),
    class = "rlang_error"
  )
})

test_that("TosiSchema rejects a graph with an unresolved replacement", {
  data_version <- as.POSIXct("2025-01-02", tz = "UTC")

  expect_error(
    TosiSchema$new(
      connector_id = "statfin",
      object_id = "population",
      data_version = data_version,
      components = list(
        TosiSchemaDimension$new("geo"),
        TosiSchemaTime$new(replaces_id = "source_period"),
        TosiSchemaValue$new()
      ),
      object_type = "series",
      lang = "en"
    ),
    class = "rlang_error"
  )
})
