test_that("object paths validate complete canonical paths", {
  values <- c("statfin/table_a", "eurostat/HICP")
  paths <- object_path(values)

  expect_s3_class(paths, "tosi_object_path")
  expect_identical(as.character(paths), values)
  expect_length(object_path(character()), 0L)

  invalid <- c(
    "statfin",
    "statfin/table/extra",
    "/table",
    "statfin/",
    "stat.fin/table",
    "statfin/table-name",
    NA_character_
  )

  for (value in invalid) {
    expect_error(object_path(value), "object path|canonical")
  }
})

test_that("object paths combine canonical components with vctrs recycling", {
  expect_identical(
    object_path(c("statfin", "eurostat"), object_id = "HICP"),
    object_path(c("statfin/HICP", "eurostat/HICP"))
  )
  expect_identical(
    object_path(
      connector_id(c("statfin", "eurostat")),
      object_id = object_id(c("table_a", "HICP"))
    ),
    object_path(c("statfin/table_a", "eurostat/HICP"))
  )
  expect_length(object_path(character(), object_id = "HICP"), 0L)
  expect_error(
    object_path(c("statfin", "eurostat"), object_id = c("a", "b", "c")),
    "recycle"
  )
  expect_error(object_path("stat.fin", object_id = "table"), "canonical")
  expect_error(object_path("statfin", object_id = "table-name"), "canonical")
})

test_that("ID generics extract typed object-path components", {
  paths <- object_path(c("statfin/table_a", "eurostat/HICP"))

  expect_identical(
    connector_id(paths),
    connector_id(c("statfin", "eurostat"))
  )
  expect_identical(object_id(paths), object_id(c("table_a", "HICP")))

  missing_path <- paths[NA_integer_]
  connector <- connector_id(missing_path)
  object <- object_id(missing_path)

  expect_s3_class(connector, "tosi_connector_id")
  expect_s3_class(object, "tosi_object_id")
  expect_true(is.na(as.character(connector)))
  expect_true(is.na(as.character(object)))
})

test_that("object paths retain ordinary vector behavior", {
  paths <- object_path(c("statfin/table_a", "eurostat/HICP"))

  expect_identical(format(paths), as.character(paths))
  expect_identical(paths[1], object_path("statfin/table_a"))
  expect_identical(
    vctrs::vec_c(paths[1], paths[2]),
    paths
  )
  expect_identical(
    vctrs::vec_c(paths, "ecb/EXR"),
    c("statfin/table_a", "eurostat/HICP", "ecb/EXR")
  )
  expect_identical(
    vctrs::vec_c("ecb/EXR", paths),
    c("ecb/EXR", "statfin/table_a", "eurostat/HICP")
  )

  prototype <- vctrs::vec_ptype(paths)
  expect_identical(vctrs::vec_cast(as.character(paths), prototype), paths)
  expect_error(vctrs::vec_cast("not-a-path", prototype), "object path")
})

test_that("object-path pillar shafts style components and truncate by width", {
  paths <- object_path(c("statfin/table_a", "eurostat/HICP"))

  withr::local_options(cli.num_colors = 1)
  plain <- format(pillar::pillar_shaft(paths), width = 40)
  expect_identical(as.character(plain), as.character(paths))
  expect_false(any(cli::ansi_has_any(plain)))

  withr::local_options(cli.num_colors = 256)
  styled <- format(pillar::pillar_shaft(paths), width = 40)
  expected <- paste0(
    cli::col_cyan(c("statfin", "eurostat")),
    cli::style_dim("/"),
    cli::style_bold(c("table_a", "HICP"))
  )

  expect_identical(as.character(styled), as.character(expected))
  expect_identical(cli::ansi_strip(styled), as.character(paths))

  narrow <- format(pillar::pillar_shaft(paths), width = 8)
  expect_true(all(cli::ansi_nchar(narrow) <= 8L))
  expect_true(
    all(cli::ansi_nchar(narrow) < cli::ansi_nchar(as.character(paths)))
  )

  missing <- format(pillar::pillar_shaft(paths[NA_integer_]), width = 8)
  expect_identical(cli::ansi_strip(as.character(missing)), "NA")

  empty <- format(pillar::pillar_shaft(paths[integer()]), width = 8)
  expect_length(empty, 0L)
})
