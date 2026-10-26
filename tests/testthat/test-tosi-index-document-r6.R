index_test_models <- function(
  lang = "en",
  object = "population",
  version = as.POSIXct("2025-01-01", tz = "UTC")
) {
  list(
    metadata = TosiMetadata$new(
      "mock",
      object,
      version,
      lang,
      "Population",
      "Mock source",
      description = "Population by region",
      source_references = TosiSourceReference$new(
        uri = "https://example.org/source",
        title = "Source notes",
        relationship = "notes",
        lang = lang
      )
    ),
    schema = TosiSchema$new(
      "mock",
      object,
      version,
      components = list(
        TosiSchemaDimension$new(
          "geo",
          label = "Geography",
          domain_codes = "FI",
          domain_labels = "Finland"
        ),
        TosiSchemaValue$new(unit = "persons"),
        TosiSchemaAttribute$new("status", label = "Observation status")
      ),
      lang = lang,
      object_type = "series"
    )
  )
}

test_that("indexes retain one native model pair and derive language and identity", {
  en <- index_test_models()
  index <- TosiIndexDocument$new(metadata = en$metadata, schema = en$schema)
  expect_identical(index$metadata, en$metadata)
  expect_identical(index$schema, en$schema)
  expect_identical(index$lang, "en")
  expect_false("schemas" %in% names(index))
  expect_identical(index$connector_id, en$schema$connector_id)
  expect_identical(index$object_id, en$schema$object_id)
  expect_identical(index$data_version, en$schema$data_version)
  expect_identical(index$schema$component("value")$unit, "persons")
  expect_identical(
    index$schema$component("status")$label,
    "Observation status"
  )
  expect_identical(
    index$schema$domain_table("geo"),
    en$schema$domain_table("geo")
  )
  projected <- index$as_list()
  expect_named(
    projected,
    c("connector_id", "object_id", "data_version", "lang", "metadata", "schema")
  )
  expect_identical(projected$lang, "en")
  expect_identical(projected$metadata, en$metadata$as_list())
  expect_identical(projected$schema, en$schema$as_list())
  expect_type(projected$metadata$source_references[[1]], "list")
  expect_identical(
    projected$metadata$description,
    list(list(text = "Population by region"))
  )
  contains_r6 <- function(x) {
    R6::is.R6(x) || (is.list(x) && any(map_lgl(x, contains_r6)))
  }
  expect_false(contains_r6(projected))
  expect_output(index$print(), "mock/population")
  expect_true("Language: en" %in% index$format())
  expect_error(index$connector_id <- connector_id("changed"), "read-only")
  expect_error(index$object_id <- object_id("changed"), "read-only")
  expect_error(index$data_version <- index$data_version + 1, "read-only")
  expect_error(index$lang <- "fi", "read-only")
  expect_error(index$metadata <- en$metadata, "read-only")
  expect_error(index$schema <- en$schema, "read-only")
  expect_error(index$metadata$title <- "Changed", "read-only")
  expect_error(index$schema$components$value$unit <- "Changed", "read-only")
  restored <- unserialize(serialize(index, NULL))
  expect_identical(restored$as_list(), projected)
  expect_identical(restored$schema$column_names(), en$schema$column_names())
})

test_that("index construction enforces shared source binding and model languages", {
  en <- index_test_models()
  newer <- index_test_models(version = en$schema$data_version + 1)
  other <- index_test_models(object = "other")
  fi <- index_test_models("fi")
  expect_error(TosiIndexDocument$new(en$metadata, newer$schema), "version")
  expect_error(TosiIndexDocument$new(en$metadata, other$schema), "identity")
  expect_error(TosiIndexDocument$new(en$metadata, fi$schema), "language")
  expect_error(
    TosiIndexDocument$new(en$metadata, en$schema$as_list()),
    "genuine"
  )
  expect_error(
    TosiIndexDocument$new(en$metadata$as_list(), en$schema),
    "genuine"
  )
  expect_identical(newer$schema$data_version, en$schema$data_version + 1)
  index <- TosiIndexDocument$new(fi$metadata, fi$schema)
  expect_identical(index$lang, "fi")
  expect_identical(index$metadata, fi$metadata)
  expect_identical(index$schema, fi$schema)
})
