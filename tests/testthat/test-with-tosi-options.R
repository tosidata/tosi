test_that("temporary settings restore present and absent options", {
  withr::local_options(tosi.url = "https://original.invalid", tosi.token = NULL)
  value <- with_tosi_options(
    {
      expect_identical(getOption("tosi.url"), "https://temporary.invalid")
      expect_identical(getOption("tosi.token"), "temporary-token")
      42L
    },
    url = "temporary.invalid",
    token = "temporary-token"
  )
  expect_identical(value, 42L)
  expect_identical(getOption("tosi.url"), "https://original.invalid")
  expect_null(getOption("tosi.token"))
})

test_that("temporary settings nest and restore after errors", {
  withr::local_options(tosi.language_preference = "en")
  with_tosi_options(
    {
      expect_error(
        with_tosi_options(
          {
            expect_identical(getOption("tosi.language_preference"), "sv")
            rlang::abort("example failure")
          },
          language_preference = "sv"
        ),
        "example failure"
      )
      expect_identical(getOption("tosi.language_preference"), "fi")
    },
    language_preference = "fi"
  )
  expect_identical(getOption("tosi.language_preference"), "en")
})

test_that("temporary settings preserve caller evaluation and visibility", {
  local_value <- 3L
  expect_identical(with_tosi_options(local_value + 1L), 4L)
  expect_identical(
    withVisible(with_tosi_options(invisible(7L))),
    list(value = 7L, visible = FALSE)
  )
})
