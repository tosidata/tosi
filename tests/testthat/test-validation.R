test_that("is_scalar_string() reports primitive scalar-string validity", {
  expect_true(is_scalar_string("x"))
  expect_false(is_scalar_string(""))
  expect_true(is_scalar_string("", allow_empty = TRUE))
  expect_false(is_scalar_string(NA_character_))
  expect_false(is_scalar_string(c("a", "b")))
  expect_false(is_scalar_string(NULL))
  expect_false(is_scalar_string())
})

test_that("validate_scalar_string() keeps empty and NULL policies separate", {
  expect_error(validate_scalar_string(""), "non-empty")
  expect_no_error(validate_scalar_string("", allow_empty = TRUE))
  expect_error(
    validate_scalar_string("", allow_empty = FALSE),
    "non-empty"
  )
  expect_no_error(
    validate_scalar_string(
      NULL,
      allow_empty = FALSE,
      allow_null = TRUE
    )
  )
  expect_error(
    validate_scalar_string(NULL, allow_empty = TRUE),
    "must be a string"
  )
})

test_that("validate_scalar_string() errors when required input is missing", {
  expect_error(
    validate_scalar_string(allow_empty = TRUE),
    "is missing"
  )
})
