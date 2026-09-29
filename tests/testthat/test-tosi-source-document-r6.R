new_test_source_document <- function(
  uri = "tosi://source-reference/mock/pop/source-metadata?lang=en",
  title = "Source metadata",
  relationship = "notes",
  lang = "en",
  available_languages = c("en", "fi"),
  content = "## Source\n\nMock source notes.",
  content_type = "text/markdown",
  source = "Mock source"
) {
  TosiSourceDocument$new(
    uri = uri,
    title = title,
    relationship = relationship,
    lang = lang,
    available_languages = available_languages,
    content = content,
    content_type = content_type,
    source = source
  )
}

test_that("TosiSourceDocument stores the resolved document envelope", {
  document <- new_test_source_document()

  expect_true(R6::is.R6(document))
  expect_true(inherits(document, "TosiSourceDocument"))
  expect_false(TosiSourceDocument$portable)
  expect_setequal(
    setdiff(names(TosiSourceDocument$public_methods), "clone"),
    c("initialize", "as_list", "format", "print")
  )
  expect_identical(
    document$as_list(),
    list(
      uri = "tosi://source-reference/mock/pop/source-metadata?lang=en",
      title = "Source metadata",
      relationship = "notes",
      lang = "en",
      available_languages = c("en", "fi"),
      content = "## Source\n\nMock source notes.",
      content_type = "text/markdown",
      source = "Mock source"
    )
  )
})

test_that("TosiSourceDocument validates every document field category", {
  expect_error(
    new_test_source_document(uri = "ftp://example.com/source"),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(
      uri = "tosi://source-reference/mock/pop/source-metadata?rank=1"
    ),
    class = "rlang_error"
  )
  expect_error(new_test_source_document(title = ""), class = "rlang_error")
  expect_error(
    new_test_source_document(relationship = "invalid"),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(lang = "codes"),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(available_languages = c("en", "en")),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(available_languages = "fi"),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(content = character()),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(content_type = c("text/plain", "text/html")),
    class = "rlang_error"
  )
  expect_error(
    new_test_source_document(source = c("first", "second")),
    class = "rlang_error"
  )

  without_source <- new_test_source_document(source = NULL)
  expect_null(without_source$source)
})

test_that("TosiSourceDocument projects read-only constructor values", {
  document <- new_test_source_document()

  candidate <- document$clone()
  expect_error(candidate$title <- "Changed title", "read-only")
  candidate <- document$clone()
  expect_error(candidate$content <- "Changed body", "read-only")
  candidate <- document$clone()
  expect_error(candidate$available_languages[[1L]] <- "sv", "read-only")
  candidate <- document$clone()
  expect_error(candidate$source <- NULL, "read-only")

  projected <- document$as_list()
  expect_identical(
    names(projected),
    c(
      "uri",
      "title",
      "relationship",
      "lang",
      "available_languages",
      "content",
      "content_type",
      "source"
    )
  )
  expect_identical(projected$title, "Source metadata")
  expect_identical(projected$content, "## Source\n\nMock source notes.")
  expect_identical(projected$available_languages, c("en", "fi"))
  expect_identical(projected$source, "Mock source")
  expect_identical(document$content, projected$content)
})

test_that("TosiSourceDocument formats and prints without its complete body", {
  body <- "complete-private-document-body-9f3b"
  document <- new_test_source_document(content = body)

  formatted <- document$format()
  output <- capture_output(printed <- withVisible(document$print()))

  expect_type(formatted, "character")
  expect_match(formatted[[1L]], "<TosiSourceDocument>", fixed = TRUE)
  expect_true(any(str_detect(formatted, fixed(document$title))))
  expect_true(any(str_detect(formatted, fixed(document$uri))))
  expect_false(any(str_detect(formatted, fixed(body))))
  expect_false(any(str_detect(output, fixed(body))))
  expect_false(printed$visible)
  expect_identical(printed$value, document)
})

test_that("TosiSourceDocument clones without a legacy list contract", {
  document <- new_test_source_document()
  shallow <- document$clone()
  deep <- document$clone(deep = TRUE)

  expect_false(is.list(document))
  expect_false(inherits(document, "tosi_source_reference"))
  expect_false(identical(shallow, document))
  expect_false(identical(deep, document))
  expect_identical(shallow$as_list(), document$as_list())
  expect_identical(deep$as_list(), document$as_list())

  expect_error(shallow$relationship <- "methodology", "read-only")
  expect_error(deep$relationship <- "methodology", "read-only")
  expect_identical(document$relationship, "notes")
})
