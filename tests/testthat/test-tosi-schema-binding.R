test_that("source-bound schemas inherit the structural graph and methods", {
  version <- structure(
    as.POSIXct("2025-01-02 03:04:05.125", tz = "Pacific/Chatham"),
    names = "statfin/trade",
    generation = "fixture-generation"
  )
  components <- list(
    TosiSchemaDimension$new(
      "geo",
      label = "Trade value",
      domain_codes = c("FI", "SE")
    ),
    TosiSchemaDimension$new("period", label = "Year"),
    TosiSchemaTime$new(replaces_id = "period"),
    TosiSchemaValue$new(unit = "EUR"),
    TosiSchemaAttribute$new("undelivered", label = "Trade-value")
  )
  structural <- TosiStructure$new(
    components = components,
    object_type = "series",
    lang = "codes",
    frequency = frequency_code("A")
  )
  schema <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "trade",
    data_version = version,
    components = components,
    object_type = "series",
    lang = "codes",
    frequency = frequency_code("A")
  )

  expect_r6_class(schema, "TosiSchema")
  expect_r6_class(schema, "TosiStructure")
  expect_identical(schema$components, components)
  expect_identical(schema$object_type, "series")
  expect_identical(schema$lang, "codes")
  expect_identical(schema$frequency, frequency_code("A"))
  expect_identical(schema$series_key, "geo")
  expect_identical(schema$component("geo"), components[[1L]])
  expect_identical(schema$domain_table("geo"), structural$domain_table("geo"))
  for (mode in c("ids", "labels", "safe_labels")) {
    expect_identical(schema$column_names(mode), structural$column_names(mode))
  }
  expect_identical(schema$connector_id, connector_id("statfin"))
  expect_identical(schema$object_id, object_id("trade"))
  expect_identical(schema$data_version, version)
  expect_false("schema" %in% names(schema))
  expect_false("reference" %in% names(schema))

  projected <- schema$as_list()
  expect_identical(
    names(projected),
    c(
      "connector_id",
      "object_id",
      "data_version",
      "object_type",
      "lang",
      "frequency",
      "series_key",
      "components"
    )
  )
  expect_identical(
    projected,
    c(
      list(
        connector_id = connector_id("statfin"),
        object_id = object_id("trade"),
        data_version = version
      ),
      structural$as_list()
    )
  )
})

test_that("converted inherited and source-binding state stays read-only", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  structure <- TosiStructure$new(
    components = list(TosiSchemaDimension$new("geo"), TosiSchemaValue$new()),
    object_type = "table",
    lang = "en",
    frequency = frequency_code("A")
  )
  schema <- structure$as_schema("statfin", "trade", version)
  before <- schema$as_list()

  expect_error(schema$object_type <- "series", "read-only")
  expect_error(schema$lang <- "codes", "read-only")
  expect_error(schema$frequency <- frequency_code("M"), "read-only")
  expect_error(schema$series_key <- "geo", "read-only")
  expect_error(schema$components <- list(TosiSchemaValue$new()), "read-only")
  expect_error(
    schema$components[[1L]] <- TosiSchemaDimension$new("other"),
    "read-only"
  )
  expect_error(schema$connector_id <- connector_id("other"), "read-only")
  expect_error(schema$object_id <- object_id("other"), "read-only")
  expect_error(schema$data_version <- version + 1, "read-only")
  expect_error(schema$connector_id[1L] <- connector_id("other"), "read-only")
  expect_error(schema$object_id[1L] <- object_id("other"), "read-only")
  expect_error(schema$data_version[1L] <- version + 1, "read-only")
  expect_identical(schema$connector_id, connector_id("statfin"))
  expect_identical(schema$object_id, object_id("trade"))
  expect_identical(schema$data_version, version)
  expect_identical(schema$as_list(), before)
})

test_that("source-bound construction retains structural checks", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  dimension <- TosiSchemaDimension$new("geo")

  expect_error(
    TosiSchema$new(
      "statfin",
      "trade",
      version,
      components = list(dimension, TosiSchemaTime$new(replaces_id = "missing")),
      lang = "en"
    ),
    "replaces_id",
    class = "rlang_error"
  )
  schema <- TosiSchema$new(
    "statfin",
    "trade",
    version,
    components = list(dimension),
    lang = "en"
  )
  expect_null(schema$object_type)
  expect_identical(schema$components, list(dimension))
})

test_that("binding matches construction and shares unchanged components", {
  version <- as.POSIXct("2025-01-02 03:04:05", tz = "UTC")
  components <- list(
    TosiSchemaDimension$new("geo", domain_codes = c("FI", "SE")),
    TosiSchemaDimension$new("kind", label = "Trade value"),
    TosiSchemaValue$new(unit = "EUR"),
    TosiSchemaAttribute$new("note", label = "Trade-value")
  )
  structure <- TosiStructure$new(
    components = components,
    object_type = "series",
    lang = "codes",
    frequency = frequency_code("W2"),
    series_key = "kind"
  )
  before <- structure$as_list()
  before_class <- class(structure)
  before_names <- names(structure)
  direct <- TosiSchema$new(
    connector_id = "statfin",
    object_id = "trade",
    data_version = version,
    components = components,
    object_type = "series",
    lang = "codes",
    frequency = frequency_code("W2"),
    series_key = "kind"
  )

  schema <- structure$as_schema(
    connector_id("statfin"),
    object_id("trade"),
    version
  )
  another <- structure$as_schema("statfin", "trade", version)

  expect_r6_class(schema, "TosiSchema")
  expect_r6_class(schema, "TosiStructure")
  expect_false(identical(schema, structure))
  expect_false(identical(schema, direct))
  expect_false(identical(schema, another))
  expect_identical(schema$as_list(), direct$as_list())
  expect_identical(another$as_list(), direct$as_list())
  expect_identical(schema$components, components)
  expect_identical(schema$components, structure$components)
  for (component in components) {
    expect_identical(schema$component(component$id), component)
    expect_identical(
      schema$domain_table(component$id),
      component$domain_table()
    )
  }
  for (mode in c("ids", "labels", "safe_labels")) {
    expect_identical(schema$column_names(mode), structure$column_names(mode))
  }
  expect_identical(structure$as_list(), before)
  expect_identical(class(structure), before_class)
  expect_identical(names(structure), before_names)
  expect_false(inherits(structure, "TosiSchema"))
  expect_false("reference" %in% names(structure))
})

test_that("bound schemas bind again without changing their source binding", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  schema <- TosiSchema$new(
    "statfin",
    "trade",
    version,
    components = list(TosiSchemaDimension$new("geo"), TosiSchemaValue$new()),
    lang = "en"
  )
  before <- schema$as_list()
  before_class <- class(schema)

  rebound <- schema$as_schema("demo", "other", version + 1)
  same_binding <- schema$as_schema("statfin", "trade", version)

  expect_false(identical(same_binding, schema))
  expect_identical(same_binding$as_list(), before)
  expect_identical(same_binding$components, schema$components)
  expect_r6_class(rebound, "TosiSchema")
  expect_r6_class(rebound, "TosiStructure")
  expect_false(identical(rebound, schema))
  expect_identical(rebound$connector_id, connector_id("demo"))
  expect_identical(rebound$object_id, object_id("other"))
  expect_identical(rebound$data_version, version + 1)
  expect_identical(schema$connector_id, connector_id("statfin"))
  expect_identical(schema$object_id, object_id("trade"))
  expect_identical(schema$data_version, version)
  expect_identical(rebound$components, schema$components)
  structural_fields <- setdiff(
    names(before),
    c("connector_id", "object_id", "data_version")
  )
  expect_identical(
    rebound$as_list()[structural_fields],
    before[structural_fields]
  )
  expect_identical(schema$as_list(), before)
  expect_identical(class(schema), before_class)
})

test_that("schema construction reuses complete canonical ID constraints", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  components <- list(TosiSchemaValue$new())
  for (field in c("connector_id", "object_id")) {
    for (invalid in list(
      NULL,
      NA_character_,
      "",
      c("one", "two"),
      "not/canonical"
    )) {
      arguments <- list(
        connector_id = "statfin",
        object_id = "population",
        data_version = version,
        components = components,
        lang = "en"
      )
      arguments[field] <- list(invalid)
      expect_error(
        do.call(TosiSchema$new, arguments),
        class = "rlang_error"
      )
    }
  }
  expect_error(TosiSchema$new(
    object_id = "population",
    data_version = version,
    components = components,
    lang = "en"
  ))
  expect_error(TosiSchema$new(
    connector_id = "statfin",
    data_version = version,
    components = components,
    lang = "en"
  ))
})

test_that("schemas require a finite non-missing POSIXct scalar", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  components <- list(TosiSchemaValue$new())
  invalid_versions <- list(
    NULL,
    "2025-01-02",
    as.Date("2025-01-02"),
    c(version, version),
    as.POSIXct(NA_real_, origin = "1970-01-01", tz = "UTC"),
    as.POSIXct(Inf, origin = "1970-01-01", tz = "UTC")
  )
  for (invalid in invalid_versions) {
    expect_error(
      TosiSchema$new(
        "statfin",
        "population",
        invalid,
        components = components,
        lang = "en"
      ),
      "data_version",
      class = "rlang_error"
    )
  }
  expect_error(TosiSchema$new(
    "statfin",
    "population",
    components = components,
    lang = "en"
  ))
})

test_that("failed conversion leaves the structure unchanged", {
  structure <- TosiStructure$new(
    components = list(TosiSchemaValue$new()),
    lang = "en"
  )
  before <- structure$as_list()
  expect_error(
    structure$as_schema("statfin", "trade", NULL),
    "data_version",
    class = "rlang_error"
  )
  expect_identical(structure$as_list(), before)
})
