test_that("read-only bindings form a named list for the selected fields", {
  bindings <- read_only_bindings(c("object_type", "lang"))
  expect_type(bindings, "list")
  expect_named(bindings, c("object_type", "lang"))

  empty <- read_only_bindings(character())
  expect_type(empty, "list")
  expect_length(empty, 0L)
})

test_that("read-only bindings preserve field and instance identity in R6", {
  withr::local_options(cli.num_colors = 1L)
  example_class <- R6::R6Class(
    "ReadOnlyExample",
    portable = FALSE,
    public = list(
      initialize = function(object_type, lang) {
        private$.object_type <- object_type
        private$.lang <- lang
      }
    ),
    private = list(.object_type = NULL, .lang = NULL),
    active = read_only_bindings(c("object_type", "lang"))
  )
  first <- example_class$new("table", "en")
  second <- example_class$new("series", "fi")
  expect_identical(c(first$object_type, first$lang), c("table", "en"))
  expect_identical(c(second$object_type, second$lang), c("series", "fi"))

  for (value in list("changed", NULL)) {
    error <- expect_error(first$object_type <- value, class = "rlang_error")
    expect_identical(
      conditionMessage(error),
      as.character(cli::format_inline("{.field object_type} is read-only."))
    )
    expect_identical(c(first$object_type, first$lang), c("table", "en"))

    error <- expect_error(first$lang <- value, class = "rlang_error")
    expect_identical(
      conditionMessage(error),
      as.character(cli::format_inline("{.field lang} is read-only."))
    )
    expect_identical(c(first$object_type, first$lang), c("table", "en"))
    expect_identical(c(second$object_type, second$lang), c("series", "fi"))
  }
})
