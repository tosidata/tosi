test_that("frequency_code() uses the canonical ordered vocabulary", {
  expected_codes <- c(
    "A",
    "S",
    "Q",
    "M",
    "W2",
    "W",
    "D",
    "A2",
    "A3",
    "A4",
    "A5",
    "A10",
    "A20",
    "A30",
    "A_3",
    "M2",
    "M_2",
    "M_3",
    "W3",
    "W4",
    "W_2",
    "W_3",
    "D_2",
    "H",
    "H2",
    "H3",
    "B",
    "N",
    "I",
    "OA",
    "OM",
    "_O",
    "_U",
    "_Z",
    "N15"
  )

  expect_identical(names(.frequency_code_levels), expected_codes)
  expect_identical(
    unname(.frequency_code_levels[c("A", "W2", "N15")]),
    c("Annual", "Biweekly", "Every 15 minutes")
  )

  inputs <- list(
    expected_codes,
    factor(expected_codes),
    factor(expected_codes, levels = expected_codes),
    factor(expected_codes, levels = rev(expected_codes))
  )
  walk(inputs, function(input) {
    out <- frequency_code(input)
    expect_identical(as.character(out), expected_codes)
    expect_identical(levels(out), expected_codes)
  })

  x <- frequency_code(c(annual = "A", unknown = NA, monthly = "M"))
  expect_true(is_frequency_code(x))
  expect_s3_class(x, "factor")
  expect_identical(as.character(x), c("A", NA_character_, "M"))
})

test_that("frequency_code() maps subset factors by code without warnings", {
  input <- factor(
    c("W", "W2", "N15", NA, "M"),
    levels = c("N15", "W", "M", "W2")
  )

  expect_no_warning(out <- frequency_code(input))
  expect_identical(
    as.character(out),
    c("W", "W2", "N15", NA_character_, "M")
  )
})

test_that("frequency_code() preserves missing and empty semantics", {
  expect_null(frequency_code(NULL))
  expect_identical(
    frequency_code(c(NA, NA)),
    frequency_code(rep(NA_character_, 2))
  )
  expect_identical(
    frequency_code(factor(c("W2", NA), levels = "W2")),
    frequency_code(c("W2", NA))
  )
  expect_identical(frequency_code(factor(NA_character_)), frequency_code(NA))
  expect_identical(frequency_code(character()), new_frequency_code())
  expect_identical(frequency_code(factor(character())), new_frequency_code())
  expect_identical(
    frequency_code(factor(character(), levels = "W")),
    new_frequency_code()
  )
})

test_that("frequency_code() rejects unsupported inputs and codes", {
  expect_error(frequency_code(logical()), class = "rlang_error")
  expect_error(frequency_code(""), class = "rlang_error")
  expect_error(frequency_code(c("A", "X")), class = "rlang_error")
  expect_error(frequency_code("BW"), class = "rlang_error")
  expect_error(
    frequency_code(factor("A", levels = c("A", "X"))),
    class = "rlang_error"
  )
})

test_that("same-version frequency operations preserve code meaning", {
  x <- frequency_code(c("A", "W2", "H", "N15", NA))
  y <- frequency_code(c("M", "H2"))

  expect_identical(frequency_code(x), x)
  expect_identical(x[c(3L, 2L, 5L)], frequency_code(c("H", "W2", NA)))
  expect_identical(x[0L], new_frequency_code())
  expect_identical(
    vctrs::vec_slice(x, c(4L, 2L)),
    frequency_code(c("N15", "W2"))
  )
  expect_identical(
    vctrs::vec_c(x, y),
    frequency_code(c("A", "W2", "H", "N15", NA, "M", "H2"))
  )
  expect_identical(vctrs::vec_cast(x, new_frequency_code()), x)
  expect_identical(vctrs::vec_cast(x, character()), as.character(x))
  expect_error(vctrs::vec_c(x, "M"), class = "vctrs_error_ptype2")
})

test_that("frequency-code vectors retain pillar presentation", {
  x <- frequency_code("M")

  expect_identical(format(x), "M")
  expect_identical(pillar::type_sum(x), "freq")
  expect_true(any(stringr::str_detect(
    capture.output(tibble::tibble(a = x)),
    "<freq>"
  )))
})

test_that("validate_frequency_code() enforces class invariants", {
  malformed <- new_frequency_code(100L)
  attr(malformed, "levels") <- "annual"

  expect_true(is_frequency_code(malformed))
  expect_error(validate_frequency_code(malformed), class = "rlang_error")
})
