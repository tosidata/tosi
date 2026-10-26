test_that("description sections expose read-only source text and extensible types", {
  section <- TosiDescriptionSection$new(
    "Survey estimates.",
    title = "Methodology",
    type = "source-methodology"
  )
  expect_r6_class(section, "TosiDescriptionSection")
  expect_identical(section$text, "Survey estimates.")
  expect_identical(section$title, "Methodology")
  expect_identical(section$type, "source-methodology")
  expect_identical(
    section$as_list(),
    list(
      text = "Survey estimates.",
      title = "Methodology",
      type = "source-methodology"
    )
  )
  expect_error(section$text <- "Changed", "read-only")
  expect_error(section$title <- "Changed", "read-only")
  expect_error(section$type <- "notes", "read-only")
  expect_error(section$text[[1]] <- "Changed", "read-only")
  expect_identical(section$text, "Survey estimates.")

  unclassified <- TosiDescriptionSection$new("Limitations: mixed source prose.")
  expect_null(unclassified$title)
  expect_null(unclassified$type)
  expect_identical(
    unclassified$as_list(),
    list(text = "Limitations: mixed source prose.")
  )
})
