test_that("tosi_options updates only supplied settings", {
  withr::local_options(
    tosi.url = "https://original.invalid",
    tosi.token = "original-token",
    tosi.language_preference = "en"
  )

  expect_identical(
    withVisible(tosi_options(language_preference = c("fi", "en"))),
    list(value = NULL, visible = FALSE)
  )
  expect_identical(getOption("tosi.url"), "https://original.invalid")
  expect_identical(getOption("tosi.token"), "original-token")
  expect_identical(getOption("tosi.language_preference"), c("fi", "en"))

  expect_output(tosi_options(), NA)
  expect_identical(
    withVisible(tosi_options()),
    list(value = NULL, visible = FALSE)
  )
  expect_identical(getOption("tosi.language_preference"), c("fi", "en"))
  expect_identical(getOption("tosi.url"), "https://original.invalid")
  expect_identical(getOption("tosi.token"), "original-token")

  tosi_options(token = NULL, language_preference = NULL)
  expect_null(getOption("tosi.token"))
  expect_null(getOption("tosi.language_preference"))
  expect_identical(getOption("tosi.url"), "https://original.invalid")
})

test_that("tosi_options defaults scheme-less URLs to HTTPS", {
  withr::local_options(tosi.url = NULL)

  tosi_options(url = "tosidata.cloud.run")
  expect_identical(getOption("tosi.url"), "https://tosidata.cloud.run")

  tosi_options(url = "service.example.invalid:8443/api")
  expect_identical(
    getOption("tosi.url"),
    "https://service.example.invalid:8443/api"
  )
})

test_that("tosi_options preserves explicit URLs and clearing", {
  withr::local_options(tosi.url = NULL)

  for (url in list(
    "https://service.example.invalid",
    "http://localhost:8080",
    "",
    NULL
  )) {
    tosi_options(url = url)
    expect_identical(getOption("tosi.url"), url)
  }
})
