test_that("discovery result tables keep ordinary tibble behavior", {
  withr::local_options(cli.num_colors = 1)

  cases <- list(
    list(
      constructor = new_tosi_connector_catalog,
      class = "tosi_connector_catalog",
      header = "Connector catalog",
      inputs = list(
        tibble::tibble(
          id = c("statfin", "eurostat"),
          name = c("Statistics Finland", "Eurostat")
        ),
        tibble::tibble(id = character(), name = character())
      )
    ),
    list(
      constructor = new_tosi_dataset_catalog,
      class = "tosi_dataset_catalog",
      header = "Dataset catalog",
      inputs = list(
        tibble::tibble(
          object_path = c("statfin/table_a", "statfin/table_b"),
          title = c("Table A", "Table B"),
          source = "Statistics Finland"
        ),
        tibble::tibble(
          object_path = character(),
          title = character(),
          source = character()
        )
      )
    ),
    list(
      constructor = new_tosi_search_results,
      class = "tosi_search_results",
      header = "Search results",
      inputs = list(
        tibble::tibble(
          object_path = c("statfin/table_a", "eurostat/table_b"),
          title = c("Table A", "Table B"),
          matched_language = c("en", "fi")
        ),
        tibble::tibble()
      )
    )
  )

  for (case in cases) {
    for (input in case$inputs) {
      input_before <- input
      result <- case$constructor(input)

      expect_identical(input, input_before)
      expect_s3_class(result, case$class)
      expect_s3_class(result, "tbl_df")
      expect_s3_class(result, "tbl")
      expect_s3_class(result, "data.frame")
      expect_identical(as.list(result), as.list(input))
      expect_identical(dim(result), dim(input))

      summary <- pillar::tbl_sum(result)
      ordinary_summary <- pillar::tbl_sum(input)
      expect_identical(names(summary)[[1]], case$header)
      expect_identical(summary[[1]], ordinary_summary[[1]])

      result_before <- result
      printed <- NULL
      output <- capture.output(
        printed <- withVisible(print(result, n = 1, width = 80))
      )
      expect_false(printed$visible)
      expect_identical(printed$value, result_before)
      expect_identical(result, result_before)
      expect_true(any(str_detect(output, fixed(case$header))))
    }
  }
})

test_that("discovery result labels use bold cyan with plain fallback", {
  cases <- list(
    list(
      result = new_tosi_connector_catalog(tibble::tibble(
        id = character(),
        name = character()
      )),
      label = "Connector catalog"
    ),
    list(
      result = new_tosi_dataset_catalog(tibble::tibble(
        object_path = character(),
        title = character()
      )),
      label = "Dataset catalog"
    ),
    list(
      result = new_tosi_search_results(tibble::tibble()),
      label = "Search results"
    )
  )

  for (case in cases) {
    withr::local_options(cli.num_colors = 1)
    plain_summary <- pillar::tbl_sum(case$result)
    plain_output <- capture.output(print(case$result, n = 1, width = 80))

    expect_identical(names(plain_summary)[[1]], case$label)
    expect_false(cli::ansi_has_any(names(plain_summary)[[1]]))

    withr::local_options(cli.num_colors = 256)
    styled_summary <- pillar::tbl_sum(case$result)
    styled_output <- capture.output(print(case$result, n = 1, width = 80))
    styled_label <- names(styled_summary)[[1]]

    expect_identical(
      styled_label,
      as.character(cli::col_cyan(cli::style_bold(case$label)))
    )
    expect_identical(cli::ansi_strip(styled_label), case$label)
    expect_identical(styled_summary[[1]], plain_summary[[1]])
    expect_false(cli::ansi_has_any(styled_summary[[1]]))
    expect_identical(cli::ansi_strip(styled_output), plain_output)
  }
})

test_that("discovery result identifiers and base subsets remain available", {
  connectors <- new_tosi_connector_catalog(tibble::tibble(
    id = c("statfin", "eurostat"),
    name = c("Statistics Finland", "Eurostat")
  ))
  datasets <- new_tosi_dataset_catalog(tibble::tibble(
    object_path = c("statfin/table_a", "statfin/table_b"),
    title = c("Table A", "Table B")
  ))
  search <- new_tosi_search_results(tibble::tibble(
    object_path = c("statfin/table_b", "eurostat/table_c"),
    title = c("Table B", "Table C")
  ))

  expect_identical(connectors[["id"]], c("statfin", "eurostat"))
  expect_identical(
    datasets[["object_path"]],
    c("statfin/table_a", "statfin/table_b")
  )
  expect_identical(
    search[["object_path"]],
    c("statfin/table_b", "eurostat/table_c")
  )

  expect_s3_class(connectors[1, ], "tbl_df")
  expect_equal(
    connectors[1, ],
    tibble::tibble(id = "statfin", name = "Statistics Finland"),
    ignore_attr = TRUE
  )
  expect_equal(
    datasets[2, ],
    tibble::tibble(object_path = "statfin/table_b", title = "Table B"),
    ignore_attr = TRUE
  )
  expect_equal(
    search[1, ],
    tibble::tibble(object_path = "statfin/table_b", title = "Table B"),
    ignore_attr = TRUE
  )
})

test_that("search result printing delegates width and row limits to pillar", {
  withr::local_options(cli.num_colors = 256)

  long_id <- paste0("statfin/", str_dup("long-identifier-", 3))
  long_title <- str_dup("A long discovery title ", 3)
  search <- new_tosi_search_results(tibble::tibble(
    object_path = c(long_id, "statfin/second", "statfin/third"),
    title = c(long_title, "Second result", "Third result"),
    matched_language = c("en", "fi", "sv"),
    match_score = c(1, 0.8, 0.7)
  ))
  search_before <- search

  narrow_print <- NULL
  narrow_lines <- capture.output(
    narrow_print <- withVisible(print(search, n = 1, width = 36))
  )
  wide_print <- NULL
  wide_lines <- capture.output(
    wide_print <- withVisible(print(search, n = 3, width = 240))
  )
  narrow_lines <- cli::ansi_strip(narrow_lines)
  wide_lines <- cli::ansi_strip(wide_lines)
  narrow <- paste(narrow_lines, collapse = "\n")
  wide <- paste(wide_lines, collapse = "\n")

  expect_false(narrow_print$visible)
  expect_false(wide_print$visible)
  expect_identical(narrow_print$value, search_before)
  expect_identical(wide_print$value, search_before)
  expect_identical(search, search_before)
  expect_match(narrow, fixed("Search results"))
  expect_match(narrow, "2 more rows")
  expect_true(any(str_detect(narrow_lines, "^#.*match_score")))
  expect_false(str_detect(narrow, fixed(long_id)))
  expect_false(str_detect(narrow, fixed(long_title)))
  expect_match(wide, fixed(long_id))
  expect_match(wide, fixed(long_title))
  expect_identical(search$matched_language, c("en", "fi", "sv"))
})
