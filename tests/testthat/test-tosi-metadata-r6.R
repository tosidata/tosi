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
    c("as_list", "description_text", "format", "print")
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

test_that("metadata normalizes descriptions once and extracts complete source text", {
  new_metadata <- function(description = NULL) {
    TosiMetadata$new(
      "mock",
      "pop",
      as.POSIXct("2025-01-01", tz = "UTC"),
      "en",
      "Population",
      "Source",
      description = description
    )
  }
  sections <- list(
    TosiDescriptionSection$new("Source context"),
    NULL,
    TosiDescriptionSection$new(
      "Survey estimates.",
      title = "Methodology",
      type = "methodology"
    ),
    TosiDescriptionSection$new("Sampling uncertainty.", title = "Limitations"),
    TosiDescriptionSection$new("Survey design.", type = "methodology")
  )
  metadata <- new_metadata(sections)
  expect_identical(class(metadata$description), "list")
  expect_identical(metadata$description, sections[c(1, 3, 4, 5)])
  expect_identical(metadata$description[[2]]$type, "methodology")
  expect_null(metadata$description[[3]]$type)
  expect_identical(
    metadata$description_text(),
    paste0(
      "Source context\n\nMethodology\nSurvey estimates.\n\n",
      "Limitations\nSampling uncertainty.\n\nSurvey design."
    )
  )
  expect_identical(
    metadata$as_list()$description,
    list(
      list(text = "Source context"),
      list(
        text = "Survey estimates.",
        title = "Methodology",
        type = "methodology"
      ),
      list(text = "Sampling uncertainty.", title = "Limitations"),
      list(text = "Survey design.", type = "methodology")
    )
  )
  expect_error(metadata$description <- list(), "read-only")
  expect_error(metadata$description[[1]] <- sections[[3]], "read-only")
  expect_error(metadata$description[[1]]$text <- "Changed", "read-only")
  local_copy <- metadata$description
  expect_identical(local_copy[[1]], sections[[1]])
  expect_error(local_copy[[1]]$text <- "Local edit", "read-only")
  expect_identical(metadata$description[[1]]$text, "Source context")

  single <- new_metadata(sections[[1]])
  expect_identical(single$description, list(sections[[1]]))
  plain <- new_metadata("Limitations: mixed source prose.")
  expect_r6_class(plain$description[[1]], "TosiDescriptionSection")
  expect_identical(
    plain$as_list()$description,
    list(list(text = "Limitations: mixed source prose."))
  )
  expect_identical(plain$description_text(), "Limitations: mixed source prose.")
  expect_identical(new_metadata()$description, list())
  expect_identical(new_metadata(list(NULL))$description, list())
  expect_identical(new_metadata()$description_text(), "")
})
