test_that("TosiMetadata projects read-only values and compact cards", {
  data_version <- as.POSIXct("2025-01-01", tz = "UTC")
  reference <- TosiSourceReference$new(
    uri = "tosi://source-reference/mock/pop/source-metadata",
    title = "Source metadata",
    relationship = "notes",
    lang = "en"
  )
  metadata <- TosiMetadata$new(
    connector_id = "mock",
    object_id = "pop",
    source_object_id = "source/pop",
    data_version = data_version,
    lang = "en",
    title = "Population",
    source_label = "Mock source",
    description = "Population by region",
    subject_area = "Population",
    next_update = as.Date("2025-02-01"),
    source_references = reference
  )

  projected <- metadata$as_list()

  expect_r6_class(metadata, "TosiMetadata")
  expect_length(projected, 11L)
  expect_setequal(
    names(projected),
    c(
      "connector_id",
      "object_id",
      "source_object_id",
      "data_version",
      "lang",
      "title",
      "source_label",
      "description",
      "subject_area",
      "next_update",
      "source_references"
    )
  )
  expect_identical(projected$connector_id, connector_id("mock"))
  expect_identical(projected$object_id, object_id("pop"))
  expect_identical(projected$data_version, data_version)
  expect_identical(projected$title, "Population")
  expect_identical(metadata$source_references, list(reference))
  expect_identical(projected$source_references, list(reference$as_list()))
  expect_true(all(map_lgl(projected$source_references, is.list)))
  expect_false(any(map_lgl(projected$source_references, R6::is.R6)))
  expect_false(any(
    c("content", "content_type", "source") %in%
      names(projected$source_references[[1L]])
  ))
  expect_setequal(
    setdiff(
      names(TosiMetadata$public_methods),
      c("initialize", "clone")
    ),
    "as_list"
  )

  candidate <- metadata$clone()
  expect_error(candidate$title <- "Changed", "read-only")
  candidate <- metadata$clone()
  expect_error(candidate$source_references[[1L]] <- NULL, "read-only")
  candidate_reference <- reference$clone()
  expect_error(candidate_reference$title <- "Changed", "read-only")

  expect_identical(metadata$title, "Population")
  expect_identical(metadata$source_references, list(reference))
  expect_identical(reference$title, "Source metadata")

  shallow <- metadata$clone()
  deep <- metadata$clone(deep = TRUE)

  expect_false(identical(shallow, metadata))
  expect_false(identical(deep, metadata))
  expect_identical(shallow$as_list(), metadata$as_list())
  expect_identical(deep$as_list(), metadata$as_list())
  expect_identical(shallow$source_references[[1L]], reference)
  expect_identical(deep$source_references[[1L]], reference)
})

test_that("TosiMetadata rejects resolved documents as compact cards", {
  document <- TosiSourceDocument$new(
    uri = "tosi://source-reference/mock/pop/source-metadata",
    title = "Source metadata",
    relationship = "notes",
    lang = "en",
    available_languages = "en",
    content = "Resolved body",
    content_type = "text/plain",
    source = "Mock source"
  )

  expect_error(
    TosiMetadata$new(
      connector_id = "mock",
      object_id = "pop",
      data_version = as.POSIXct("2025-01-01", tz = "UTC"),
      lang = "en",
      title = "Population",
      source_label = "Mock source",
      source_references = list(document)
    ),
    class = "rlang_error"
  )
})
