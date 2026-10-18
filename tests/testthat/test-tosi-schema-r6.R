test_that("exact-ID lookup and domain inspection preserve schema state", {
  dates <- as.Date(c("2021-01-01", "2020-01-01"))
  frequencies <- frequency_code(c("W2", "A", NA))
  components <- list(
    TosiSchemaComponent$new("unclassified", domain_codes = c("z", "a")),
    TosiSchemaDimension$new(
      "region",
      label = "Region",
      domain_codes = c("SE", "FI"),
      domain_labels = c("Sweden", "Finland")
    ),
    TosiSchemaTime$new(time_domain = dates),
    TosiSchemaFrequency$new(frequency_domain = frequencies),
    TosiSchemaValue$new(unit = "persons"),
    TosiSchemaAttribute$new("status", domain_codes = c("P", "F"))
  )
  schema <- TosiStructure$new(
    components = components,
    lang = "en"
  )
  original <- schema$as_list()
  original_names <- schema$column_names()
  expected <- list(
    tibble::tibble(code = c("z", "a")),
    tibble::tibble(code = c("SE", "FI"), label = c("Sweden", "Finland")),
    tibble::tibble(time = dates),
    tibble::tibble(frequency = frequencies),
    NULL,
    tibble::tibble(code = c("P", "F"))
  )

  walk2(components, expected, function(component, domain) {
    expect_identical(schema$component(component$id), component)
    expect_identical(component$domain_table(), domain)
    expect_identical(schema$domain_table(component$id), domain)
  })
  expect_error(schema$component("Region"), "Unknown.*Region")
  expect_error(schema$component("reg"), "Unknown.*reg")
  expect_error(schema$component("dimension"), "Unknown.*dimension")
  expect_error(schema$domain_table("missing"), "Unknown.*missing")

  named_schema <- TosiStructure$new(
    lang = "en",
    components = list(alias = components[[2L]])
  )
  expect_identical(named_schema$component("region"), components[[2L]])
  expect_error(named_schema$component("alias"), "Unknown.*alias")

  extracted <- schema$domain_table("region")
  extracted$code[[1L]] <- "changed"
  expect_identical(schema$as_list(), original)
  expect_identical(schema$column_names(), original_names)
  expect_identical(schema$components, components)
  region <- schema$component("region")
  expect_error(region$label <- "Changed", "read-only")
  expect_identical(schema$clone()$component("region"), components[[2L]])
  expect_identical(
    schema$clone(deep = TRUE)$component("region"),
    components[[2L]]
  )
})

test_that("domain inspection distinguishes absent and typed empty domains", {
  absent <- list(
    TosiSchemaComponent$new("unclassified"),
    TosiSchemaDimension$new("region"),
    TosiSchemaTime$new(),
    TosiSchemaFrequency$new(),
    TosiSchemaValue$new(),
    TosiSchemaAttribute$new("status")
  )
  walk(absent, function(component) expect_null(component$domain_table()))

  empty <- list(
    TosiSchemaComponent$new("unclassified", domain_codes = character()),
    TosiSchemaDimension$new(
      "region",
      domain_codes = character(),
      domain_labels = character()
    ),
    TosiSchemaTime$new(time_domain = as.Date(character())),
    TosiSchemaFrequency$new(frequency_domain = frequency_code(character())),
    TosiSchemaAttribute$new("status", domain_codes = character())
  )
  expected <- list(
    tibble::tibble(code = character()),
    tibble::tibble(code = character(), label = character()),
    tibble::tibble(time = as.Date(character())),
    tibble::tibble(frequency = frequency_code(character())),
    tibble::tibble(code = character())
  )
  walk2(empty, expected, function(component, domain) {
    expect_identical(component$domain_table(), domain)
  })
})

test_that("TosiStructure constructs an identity-free ordered semantic graph", {
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

  schema <- TosiStructure$new(
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

  expect_r6_class(schema, "TosiStructure")
  expect_false(inherits(schema, "TosiSchema"))
  expect_false(any(
    c(
      "connector_id",
      "object_id",
      "data_version",
      "reference"
    ) %in%
      names(schema)
  ))
  expect_named(
    schema$as_list(),
    c("object_type", "lang", "frequency", "series_key", "components"),
    ignore.order = TRUE
  )
  expect_identical(schema$object_type, "series")
  expect_identical(schema$lang, "en")
  expect_null(schema$frequency)
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
  components <- list(
    first_alias = TosiSchemaDimension$new(id = "first", label = "Trade value"),
    absent_alias = TosiSchemaAttribute$new(
      id = "absent",
      label = "Trade-value"
    ),
    last_alias = TosiSchemaDimension$new(id = "last", label = "Trade value"),
    time_alias = TosiSchemaDimension$new(id = "conflict", label = "time"),
    value_alias = TosiSchemaDimension$new(
      id = "value_conflict",
      label = "value"
    ),
    fixed_alias = TosiSchemaDimension$new(id = "fixed", label = "status"),
    leading_alias = TosiSchemaDimension$new(id = "leading", label = "1écho"),
    canonical_time = TosiSchemaTime$new(
      label = "Localized time",
      data_type = "date"
    ),
    canonical_value = TosiSchemaValue$new(),
    status_alias = TosiSchemaAttribute$new(id = "status", label = "status")
  )
  structural <- TosiStructure$new(lang = "en", components = components)
  bound <- structural$as_schema(
    "statfin",
    "trade",
    as.POSIXct("2025-01-02", tz = "UTC")
  )
  ids <- unname(map_chr(components, "id"))
  expected <- list(
    ids = ids,
    labels = c(
      "Trade value",
      "Trade-value",
      "Trade value_1",
      "time_1",
      "value_1",
      "status",
      "1écho",
      "time",
      "value",
      "status_1"
    ),
    safe_labels = c(
      "Trade_value",
      "Trade_value_1",
      "Trade_value_2",
      "time_1",
      "value_1",
      "status",
      "_1echo",
      "time",
      "value",
      "status_1"
    )
  )

  for (schema in list(structural, bound)) {
    original <- schema$as_list()
    fields <- names(schema)
    for (mode in names(expected)) {
      physical_names <- schema$column_names(mode)
      expect_identical(physical_names, stats::setNames(expected[[mode]], ids))
    }
    expect_identical(schema$column_names(), schema$column_names("labels"))
    expect_identical(schema$as_list(), original)
    expect_identical(schema$components, components)
    expect_identical(names(schema), fields)
  }
})

test_that("structural naming preserves blank-label fallback warnings", {
  structural <- TosiStructure$new(
    lang = "en",
    components = list(
      TosiSchemaDimension$new(id = "blank", label = "  "),
      TosiSchemaDimension$new(id = "missing"),
      TosiSchemaValue$new()
    )
  )
  bound <- structural$as_schema(
    "statfin",
    "trade",
    as.POSIXct("2025-01-02", tz = "UTC")
  )
  for (schema in list(structural, bound)) {
    original <- schema$as_list()
    expected <- c(blank = "blank", missing = "missing", value = "value")
    expect_no_warning(physical_names <- schema$column_names("ids"))
    expect_identical(physical_names, expected)
    for (mode in c("labels", "safe_labels")) {
      expect_warning(
        physical_names <- schema$column_names(mode),
        "Using canonical IDs for"
      )
      expect_identical(physical_names, expected)
    }
    expect_identical(schema$as_list(), original)
  }
})

test_that("structural naming is the only public naming interface", {
  expect_false("physical_column_names" %in% getNamespaceExports("tosi"))
  expect_false(exists(
    "physical_column_names",
    envir = asNamespace("tosi"),
    inherits = TRUE
  ))
  expect_named(formals(TosiStructure$public_methods$column_names), "col_mode")
})

test_that("TosiStructure accepts biweekly frequency and retains source dates", {
  dates <- as.Date(c("2026-08-05", "2026-08-19"))
  time <- TosiSchemaTime$new(time_domain = dates)
  schema <- TosiStructure$new(
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

test_that("TosiStructure accepts biweekly and unknown frequency domains", {
  frequencies <- frequency_code(c("W2", "W", NA))
  frequency <- TosiSchemaFrequency$new(
    frequency_domain = frequencies
  )
  schema <- TosiStructure$new(
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

test_that("TosiStructure and all component classes reject field replacement", {
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
  schema <- TosiStructure$new(
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
  expect_error(candidate$object_type <- "series", "read-only")
  expect_error(candidate$lang <- "codes", "read-only")
  expect_error(candidate$frequency <- frequency_code("A"), "read-only")
  expect_error(candidate$series_key <- "geo", "read-only")
  expect_error(candidate$components <- list(dimension), "read-only")
  expect_error(candidate$components[[1L]] <- dimension, "read-only")
  expect_identical(candidate$as_list(), schema$as_list())
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

  expect_identical(schema$object_type, "table")
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

test_that("TosiStructure permits zero or one Value component", {
  dimension <- TosiSchemaDimension$new("geo")
  no_value <- TosiStructure$new(
    components = list(dimension),
    object_type = "table",
    lang = "en"
  )
  one_value <- TosiStructure$new(
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
    TosiStructure$new(
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

test_that("TosiStructure rejects a graph with an unresolved replacement", {
  expect_error(
    TosiStructure$new(
      components = list(
        TosiSchemaDimension$new("geo"),
        TosiSchemaTime$new(replaces_id = "source_period"),
        TosiSchemaValue$new()
      ),
      object_type = "series",
      lang = "en"
    ),
    "replaces_id",
    class = "rlang_error"
  )
})

test_that("identity-free schemas retain aggregate structural constraints", {
  dimension <- TosiSchemaDimension$new("geo")
  invalid_graphs <- list(
    list(),
    list("geo"),
    list(dimension, dimension),
    list(TosiSchemaDimension$new("time")),
    list(
      TosiSchemaAttribute$new("period"),
      TosiSchemaTime$new(replaces_id = "period")
    )
  )
  patterns <- c(
    "non-empty list",
    "TosiSchemaComponent",
    "unique",
    "Reserved",
    "replaces_id"
  )
  walk2(invalid_graphs, patterns, function(components, pattern) {
    expect_error(
      TosiStructure$new(components = components, lang = "en"),
      pattern,
      class = "rlang_error"
    )
  })
  expect_error(
    TosiStructure$new(
      components = list(dimension, TosiSchemaFrequency$new()),
      lang = "en",
      frequency = frequency_code("A")
    ),
    "frequency",
    class = "rlang_error"
  )
  expect_error(
    TosiStructure$new(components = list(dimension), lang = NULL),
    "lang",
    class = "rlang_error"
  )
  expect_error(
    TosiStructure$new(
      components = list(dimension),
      lang = "en",
      object_type = "list"
    ),
    "object_type",
    class = "rlang_error"
  )
})

test_that("structural series keys retain derivation and ordered eligibility", {
  components <- list(
    TosiSchemaDimension$new("geo"),
    TosiSchemaDimension$new("kind")
  )
  schema <- TosiStructure$new(
    components = components,
    object_type = "series",
    lang = "codes",
    series_key = "kind"
  )
  expect_identical(schema$series_key, "kind")
  expect_error(
    TosiStructure$new(components = components, lang = "en", series_key = "geo"),
    "series_key",
    class = "rlang_error"
  )
  expect_error(
    TosiStructure$new(
      components = components,
      object_type = "series",
      lang = "en",
      series_key = c("kind", "geo")
    ),
    "ordered eligible subset",
    class = "rlang_error"
  )
  expect_error(
    TosiStructure$new(
      components = c(components, list(TosiSchemaTime$new())),
      object_type = "series",
      lang = "en",
      series_key = "geo"
    ),
    "fully derived key",
    class = "rlang_error"
  )
})
