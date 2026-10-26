test_that("metadata display keeps source sections and cards behind details", {
  reference <- TosiSourceReference$new(
    uri = "https://source.example.invalid/methodology",
    title = "Methodology",
    relationship = "methodology",
    lang = "en"
  )
  metadata <- TosiMetadata$new(
    connector_id = "mock",
    object_id = "population",
    data_version = as.POSIXct("2025-01-01", tz = "UTC"),
    lang = "en",
    title = "Population by region",
    source_label = "Statistical office",
    source_object_id = "POP/REGION",
    subject_area = "Population",
    next_update = as.Date("2025-02-01"),
    description = list(
      TosiDescriptionSection$new("Survey estimates.", title = "Methods"),
      TosiDescriptionSection$new("Sampling uncertainty.", title = "Limitations")
    ),
    source_references = reference
  )
  before <- metadata$as_list()

  summary <- metadata$format()
  expect_true(all(
    c(
      "<TosiMetadata> mock/population",
      "Title: Population by region",
      "Source: Statistical office",
      "Language: en",
      "Source version: 2025-01-01 00:00:00.000000 UTC",
      "Subject area: Population",
      "Next update: 2025-02-01",
      "Description sections: 2",
      "Source references: 1"
    ) %in%
      summary
  ))
  expect_false(any(str_detect(
    summary,
    "Survey estimates|Sampling uncertainty|https://"
  )))

  details <- metadata$format(details = TRUE)
  expect_true("Source object: POP/REGION" %in% details)
  expect_true(
    "Methods\nSurvey estimates.\n\nLimitations\nSampling uncertainty." %in%
      details
  )
  expect_true(all(reference$format() %in% details))
  expect_identical(metadata$as_list(), before)

  printed <- capture.output(
    result <- withVisible(metadata$print(details = TRUE))
  )
  expect_identical(printed, str_split_1(paste(details, collapse = "\n"), "\n"))
  expect_identical(result$value, metadata)
  expect_false(result$visible)
})

test_that("metadata display supports absent prose and source-owned update text", {
  metadata <- TosiMetadata$new(
    connector_id = "mock",
    object_id = "population",
    data_version = as.POSIXct("2025-01-01", tz = "UTC"),
    lang = "en",
    title = "Population",
    source_label = "Statistical office",
    next_update = "After the next census"
  )

  expect_true(all(
    c(
      "Next update: After the next census",
      "Description sections: 0",
      "Source references: 0"
    ) %in%
      metadata$format(details = TRUE)
  ))
  expect_identical(metadata$format(details = TRUE), metadata$format())
})
