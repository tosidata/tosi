test_that("shared schema generators are public construction surfaces", {
  expect_true(all(
    c(
      "TosiStructure",
      "TosiSchema",
      "TosiDataReference"
    ) %in%
      getNamespaceExports("tosi")
  ))
  expect_false("TosiDataSchema" %in% getNamespaceExports("tosi"))
  expect_false(exists(
    "TosiDataSchema",
    envir = asNamespace("tosi"),
    inherits = FALSE
  ))
})

test_that("TosiDataReference owns canonical identity and source version", {
  version <- as.POSIXct("2025-01-02 03:04:05", tz = "UTC")
  reference <- TosiDataReference$new("statfin", "population", version)

  expect_r6_class(reference, "TosiDataReference")
  expect_identical(reference$connector_id, connector_id("statfin"))
  expect_identical(reference$object_id, object_id("population"))
  expect_identical(reference$data_version, version)
  expect_identical(
    reference$as_list(),
    list(
      connector_id = connector_id("statfin"),
      object_id = object_id("population"),
      data_version = version
    )
  )
  expect_identical(
    TosiDataReference$new(
      connector_id("statfin"),
      object_id("population"),
      version
    )$as_list(),
    reference$as_list()
  )
})

test_that("reference construction reuses complete canonical ID constraints", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  for (field in c("connector_id", "object_id")) {
    for (invalid in list(
      NULL,
      NA_character_,
      "",
      c("one", "two"),
      "not/canonical"
    )) {
      arguments <- list(
        connector_id = "statfin",
        object_id = "population",
        data_version = version
      )
      arguments[field] <- list(invalid)
      expect_error(
        do.call(TosiDataReference$new, arguments),
        class = "rlang_error"
      )
    }
  }
  expect_error(TosiDataReference$new(
    object_id = "population",
    data_version = version
  ))
  expect_error(TosiDataReference$new(
    connector_id = "statfin",
    data_version = version
  ))
})

test_that("references require a finite non-missing POSIXct scalar", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  invalid_versions <- list(
    NULL,
    "2025-01-02",
    as.Date("2025-01-02"),
    c(version, version),
    as.POSIXct(NA_real_, origin = "1970-01-01", tz = "UTC"),
    as.POSIXct(Inf, origin = "1970-01-01", tz = "UTC")
  )
  for (invalid in invalid_versions) {
    expect_error(
      TosiDataReference$new("statfin", "population", invalid),
      "data_version",
      class = "rlang_error"
    )
  }
  expect_error(TosiDataReference$new("statfin", "population"))
})

test_that("reference fields reject direct and nested replacement", {
  version <- as.POSIXct("2025-01-02", tz = "UTC")
  reference <- TosiDataReference$new("statfin", "population", version)
  before <- reference$as_list()

  expect_error(reference$connector_id <- connector_id("other"), "read-only")
  expect_error(reference$object_id <- object_id("other"), "read-only")
  expect_error(reference$data_version <- version + 1, "read-only")
  expect_error(reference$connector_id[[1L]] <- "other", "read-only")
  expect_identical(reference$as_list(), before)
})
