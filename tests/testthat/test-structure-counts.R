test_that("actual and potential counts stay independent", {
  structure <- TosiStructure$new(
    list(
      TosiSchemaDimension$new("geo", domain_codes = as.character(1:10)),
      TosiSchemaTime$new(time_domain = as.Date("2020-01-01") + 0:9),
      TosiSchemaValue$new(),
      TosiSchemaAttribute$new("status", domain_codes = c("F", "P"))
    ),
    object_type = "series",
    lang = "en",
    frequency = frequency_code("A"),
    observation_count = 60L,
    series_count = 8L
  )
  expect_identical(structure$n_observations(), 60)
  expect_identical(structure$n_series(), 8)
  expect_identical(structure$n_observations("potential"), 100)
  expect_identical(structure$n_series("potential"), 10)

  unknown <- TosiStructure$new(
    structure$components,
    object_type = "series",
    lang = "en"
  )
  expect_identical(unknown$n_observations(), NA_real_)
  expect_identical(unknown$n_series(), NA_real_)
  expect_identical(
    unknown$as_list()$observation_count,
    list(actual = NULL, potential = 100)
  )
  expect_identical(
    unknown$as_list()$series_count,
    list(actual = NULL, potential = 10)
  )

  missing <- TosiStructure$new(
    list(TosiSchemaDimension$new("geo")),
    lang = "en",
    observation_count = 0,
    series_count = 0
  )
  expect_identical(missing$n_observations(), 0)
  expect_identical(missing$n_series(), 0)
  expect_identical(missing$n_observations("potential"), NA_real_)
  expect_identical(
    missing$as_list()$observation_count,
    list(actual = 0, potential = NULL)
  )
  empty <- TosiStructure$new(
    list(TosiSchemaDimension$new("geo", domain_codes = character())),
    lang = "en"
  )
  expect_identical(empty$n_observations("potential"), 0)
})

test_that("potential grids count replacements once and use the resolved key", {
  structure <- TosiStructure$new(
    list(
      TosiSchemaDimension$new("x", domain_codes = as.character(seq_len(50000))),
      TosiSchemaDimension$new("y", domain_codes = as.character(seq_len(50000))),
      TosiSchemaDimension$new("period"),
      TosiSchemaDimension$new("source_freq"),
      TosiSchemaTime$new(
        replaces_id = "period",
        time_domain = as.Date("2020-01-01") + 0:1
      ),
      TosiSchemaFrequency$new(
        replaces_id = "source_freq",
        frequency_domain = frequency_code(c("A", "Q"))
      )
    ),
    object_type = "series",
    lang = "en"
  )
  expect_identical(structure$series_key, c("x", "y", "freq"))
  expect_identical(structure$n_series("potential"), 5000000000)
  expect_identical(structure$n_observations("potential"), 10000000000)
})

test_that("conversion and index projection preserve counts and components", {
  version <- as.POSIXct("2025-01-01", tz = "UTC")
  structure <- TosiStructure$new(
    list(
      TosiSchemaDimension$new("geo", domain_codes = as.character(1:10)),
      TosiSchemaTime$new(time_domain = as.Date("2020-01-01") + 0:9),
      TosiSchemaValue$new()
    ),
    object_type = "series",
    lang = "en",
    observation_count = 60,
    series_count = 8
  )
  before <- structure$as_list()
  schema <- structure$as_schema("mock", "population", version)
  expect_identical(schema$components, structure$components)
  expect_identical(schema$n_observations(), 60)
  expect_identical(schema$n_series(), 8)
  expect_identical(structure$as_list(), before)
  metadata <- TosiMetadata$new(
    "mock",
    "population",
    version,
    "en",
    "Population",
    "Mock"
  )
  projected <- TosiIndexDocument$new(metadata, schema)$as_list()
  expect_identical(projected$schema, schema$as_list())
  expect_identical(
    projected$schema$observation_count,
    list(actual = 60, potential = 100)
  )
  expect_identical(
    projected$schema$series_count,
    list(actual = 8, potential = 10)
  )
  expect_false(any(
    c("observation_count", "series_count") %in% names(projected)
  ))
})
