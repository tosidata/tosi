test_that("TosiIndexDocument preserves identity with read-only state", {
  data_version <- as.POSIXct("2025-01-01", tz = "UTC")
  reference <- TosiSourceReference$new(
    uri = "tosi://source-reference/mock/population/source?lang=en",
    title = "Source notes",
    relationship = "notes",
    lang = "en"
  )
  coverage <- list(
    time_range = list(
      start = "2020",
      end = "2021",
      value_type = "year",
      derivation = "derived_from_schema"
    ),
    observation_count = list(
      value = 2L,
      derivation = "derived_from_schema",
      approximate = FALSE
    ),
    dimension_cardinalities = list(geo = 1L),
    series_count = list(
      value = 1L,
      derivation = "derived",
      approximate = FALSE
    )
  )
  index <- TosiIndexDocument$new(
    identity = list(
      connector_id = connector_id("mock"),
      object_id = object_id("population"),
      source_object_id = "source/population",
      object_type = "series",
      data_version = data_version
    ),
    languages = "en",
    metadata = list(
      en = list(
        title = "Population",
        source_label = "Mock source",
        description = NULL,
        keywords = character(),
        subject_area = "Population",
        unit = "persons",
        next_update = NULL
      )
    ),
    schema = list(
      dimensions = list(
        list(
          dimension_id = "geo",
          labels = list(en = "Geography"),
          role = "dimension",
          data_type = "category",
          value_count = 1L
        )
      ),
      measures = list(
        list(
          measure_id = "value",
          labels = list(en = "value"),
          unit = "persons"
        )
      ),
      platform = list(
        time = NULL,
        frequency = list(
          codes = list("A"),
          column_id = NULL,
          replaces_id = NULL
        )
      ),
      series_key_columns = "geo"
    ),
    value_domains = list(
      geo = list(en = c(FI = "Finland"))
    ),
    coverage = coverage,
    source_references = list(reference)
  )

  invalid_schema <- index$schema
  invalid_schema$platform$frequency$codes <- list()
  expect_error(
    TosiIndexDocument$new(
      identity = index$identity(),
      languages = index$languages,
      metadata = index$metadata,
      schema = invalid_schema,
      value_domains = index$value_domains,
      coverage = index$coverage,
      source_references = index$source_references,
      extensions = index$extensions
    ),
    class = "rlang_error"
  )

  projected <- index$as_list()

  expect_identical(projected$identity, index$identity())
  expect_identical(projected$identity$source_object_id, "source/population")
  expect_identical(projected$metadata$en$title, "Population")
  expect_identical(projected$value_domains$geo$en, c(FI = "Finland"))
  expect_type(projected$source_references[[1L]], "list")
  expect_false(R6::is.R6(projected$source_references[[1L]]))
  expect_identical(projected$source_references[[1L]]$title, "Source notes")

  candidate <- index$clone()
  expect_error(
    candidate$source_object_id <- "source/changed-population",
    "read-only"
  )
  candidate <- index$clone()
  expect_error(candidate$metadata$en$title <- "Changed", "read-only")
  candidate <- index$clone()
  expect_error(candidate$source_references[[1L]] <- NULL, "read-only")
  candidate_reference <- reference$clone()
  expect_error(candidate_reference$title <- "Changed", "read-only")

  expect_identical(index$source_object_id, "source/population")
  expect_identical(index$metadata$en$title, "Population")
  expect_identical(index$source_references, list(reference))
  expect_identical(reference$title, "Source notes")

  shallow <- index$clone()
  deep <- index$clone(deep = TRUE)

  expect_false(identical(shallow, index))
  expect_false(identical(deep, index))
  expect_identical(shallow$as_list(), index$as_list())
  expect_identical(deep$as_list(), index$as_list())
  expect_identical(shallow$source_references[[1L]], reference)
  expect_identical(deep$source_references[[1L]], reference)
})
