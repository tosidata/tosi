test_that("canonical connector and object ids validate allowed values", {
  expect_s3_class(connector_id(c("statfin", "ECB_1")), "tosi_connector_id")
  expect_s3_class(object_id(c("HICP", "tbl_001")), "tosi_object_id")
  expect_identical(as.character(object_id("HICP")), "HICP")
})

test_that("canonical connector and object ids reject non-canonical values", {
  invalid <- c(
    "statfin/vaenn",
    "stat.fin",
    "stat-fin",
    "stat fin",
    "åland",
    "1statfin",
    "stat\nfin",
    "",
    NA_character_
  )

  for (value in invalid) {
    expect_error(connector_id(value), "canonical")
    expect_error(object_id(value), "canonical")
  }
})

test_that("id vectors behave as character-backed vectors at boundaries", {
  ids <- object_id(c("HICP", "GDP"))

  expect_true(is.character(ids))
  expect_identical(ids[1], object_id("HICP"))
  expect_identical(
    vctrs::vec_c(ids, object_id("POP")),
    object_id(c("HICP", "GDP", "POP"))
  )
  expect_identical(
    jsonlite::toJSON(ids, auto_unbox = TRUE),
    jsonlite::toJSON(c("HICP", "GDP"), auto_unbox = TRUE)
  )
  expect_s3_class(tibble::tibble(object_id = ids)$object_id, "tosi_object_id")
})
