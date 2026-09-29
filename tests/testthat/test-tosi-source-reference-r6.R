test_that("TosiSourceReference stores a compact label card", {
  reference <- TosiSourceReference$new(
    uri = "tosi://source-reference/mock/table/source-metadata?lang=en",
    title = "Source metadata",
    relationship = "notes",
    lang = "en",
    description = "PX header metadata"
  )

  expect_true(inherits(reference, "TosiSourceReference"))
  expect_false(TosiSourceReference$portable)
  expect_setequal(
    setdiff(names(TosiSourceReference$public_methods), "clone"),
    c("initialize", "as_list", "format", "print")
  )
  expect_identical(
    reference$as_list(),
    list(
      uri = "tosi://source-reference/mock/table/source-metadata?lang=en",
      title = "Source metadata",
      relationship = "notes",
      lang = "en",
      description = "PX header metadata"
    )
  )
})

test_that("TosiSourceReference preserves defaults and compact printing", {
  reference <- TosiSourceReference$new(
    uri = "https://example.com/methodology",
    title = "Methodology",
    relationship = "methodology"
  )

  expect_null(reference$lang)
  expect_null(reference$description)
  expect_named(
    reference$as_list(),
    c("uri", "title", "relationship", "lang", "description")
  )

  formatted <- reference$format()
  output <- capture_output(printed <- withVisible(reference$print()))

  expect_match(formatted[[1L]], "<TosiSourceReference>", fixed = TRUE)
  expect_match(output[[1L]], "<TosiSourceReference>", fixed = TRUE)
  expect_false(printed$visible)
  expect_identical(printed$value, reference)
})

test_that("TosiSourceReference validates its construction boundary", {
  new_reference <- function(
    uri = "tosi://source-reference/mock/table/source-metadata",
    title = "Source metadata",
    relationship = "notes",
    lang = NULL,
    description = NULL
  ) {
    TosiSourceReference$new(
      uri = uri,
      title = title,
      relationship = relationship,
      lang = lang,
      description = description
    )
  }

  expect_error(
    new_reference(uri = "ftp://example.com/doc"),
    class = "rlang_error"
  )
  expect_error(
    new_reference(uri = "tosi://mock/table/source-metadata"),
    class = "rlang_error"
  )
  expect_error(
    new_reference(uri = "tosi://source-reference/mock"),
    class = "rlang_error"
  )
  expect_error(
    new_reference(
      uri = "tosi://source-reference/mock/table/source-metadata?lang=codes"
    ),
    class = "rlang_error"
  )
  expect_error(new_reference(title = ""), class = "rlang_error")
  expect_error(
    new_reference(description = c("first", "second")),
    class = "rlang_error"
  )
  expect_error(new_reference(relationship = "bad"), class = "rlang_error")
  expect_error(
    new_reference(relationship = "method"),
    class = "rlang_error"
  )
  expect_error(new_reference(lang = "codes"), class = "rlang_error")
  expect_error(
    new_reference(
      uri = "tosi://source-reference/not-valid/table/source-metadata"
    ),
    class = "rlang_error"
  )
  expect_error(
    new_reference(
      uri = "tosi://source-reference/mock/table/source-metadata?rank=1"
    ),
    class = "rlang_error"
  )

  empty_description <- new_reference(description = "")
  expect_identical(empty_description$description, "")
})
