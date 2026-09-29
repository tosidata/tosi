test_that("TosiHelp projects producer-supplied read-only state without lookup", {
  package_version_calls <- 0L
  markdown <- "# Example help\n\nSynthetic connector guidance."
  help <- local({
    local_mocked_bindings(
      packageVersion = function(...) {
        package_version_calls <<- package_version_calls + 1L
        "0.0.0"
      },
      .package = "utils"
    )
    TosiHelp$new(
      connector_id = "example",
      title = "Example help",
      content = markdown,
      core_version = "9.8.7"
    )
  })
  expect_identical(package_version_calls, 0L)
  expected <- list(
    connector_id = "example",
    title = "Example help",
    lang = "en",
    content_type = "text/markdown",
    content = markdown,
    core_version = "9.8.7"
  )

  expect_true("TosiHelp" %in% getNamespaceExports("tosi"))
  expect_true(R6::is.R6(help))
  expect_true(inherits(help, "TosiHelp"))
  expect_false(inherits(help, "TosiSourceDocument"))
  expect_identical(help$as_list(), expected)
  walk(names(expected), function(field) {
    expect_identical(help[[field]], expected[[field]])
    expect_error(help[[field]] <- "changed", "read-only")
  })
  expect_error(help$content[[1L]] <- "changed", "read-only")

  projected <- help$as_list()
  projected$content <- "An independently edited projection."
  expect_identical(help$content, markdown)
  expect_identical(help$as_list(), expected)
})

test_that("TosiHelp formats and prints Markdown with links and examples", {
  local_mocked_bindings(
    is_installed = function(...) {
      cli::cli_abort("Markdown use must not consult an optional renderer.")
    }
  )
  withr::local_options(
    browser = function(...) cli::cli_abort("Must not open a browser."),
    viewer = function(...) cli::cli_abort("Must not open a Viewer."),
    tosi_help_example_ran = FALSE
  )
  markdown <- paste(
    "# Example help",
    "",
    "- Browse [Example database](https://example.org/tables?x=1&y=2).",
    "",
    "```r",
    "options(tosi_help_example_ran = TRUE)",
    "1 < 2",
    "```",
    sep = "\n"
  )
  help <- TosiHelp$new("example", "Example help", markdown, "9.8.7")

  expect_identical(help$format(), markdown)
  expect_identical(help$format("markdown"), markdown)
  expect_identical(help$as_list()$content, markdown)
  output <- capture_output(printed <- withVisible(help$print()))
  expect_identical(output, markdown)
  expect_identical(capture_output(print(help)), markdown)
  expect_false(printed$visible)
  expect_identical(printed$value, help)
  expect_false(getOption("tosi_help_example_ran"))
})

test_that("TosiHelp converts Markdown to optional HTML without evaluation", {
  skip_if_not_installed("commonmark")
  withr::local_options(
    browser = function(...) cli::cli_abort("Must not open a browser."),
    viewer = function(...) cli::cli_abort("Must not open a Viewer."),
    tosi_help_example_ran = FALSE
  )
  markdown <- paste(
    "# Example help",
    "",
    "- Browse [Example database](https://example.org/tables?x=1&y=2).",
    "",
    "```r",
    "options(tosi_help_example_ran = TRUE)",
    "1 < 2",
    "```",
    sep = "\n"
  )
  help <- TosiHelp$new("example", "Example help", markdown, "9.8.7")

  expect_output(html <- help$format("html"), NA)
  expect_type(html, "character")
  expect_length(html, 1L)
  expect_match(html, "<h1>Example help</h1>", fixed = TRUE)
  expect_match(
    html,
    '<a href="https://example.org/tables?x=1&amp;y=2">Example database</a>',
    fixed = TRUE
  )
  expect_match(html, 'class="language-r"', fixed = TRUE)
  expect_match(html, "1 &lt; 2", fixed = TRUE)
  expect_false(getOption("tosi_help_example_ran"))
  expect_identical(help$format(), markdown)
  expect_identical(help$content_type, "text/markdown")
})

test_that("TosiHelp needs the optional renderer only for requested HTML", {
  local_mocked_bindings(
    is_installed = function(pkg, ...) {
      expect_identical(pkg, "commonmark")
      FALSE
    }
  )
  markdown <- "# Example help\n\n[Browse](https://example.org/tables)."
  help <- TosiHelp$new("example", "Example help", markdown, "9.8.7")

  expect_identical(help$format(), markdown)
  expect_identical(help$as_list()$content, markdown)
  expect_identical(capture_output(help$print()), markdown)
  expect_error(
    help$format("html"),
    "commonmark.*HTML",
    class = "rlang_error"
  )
  expect_error(help$format("html"), "install.packages", fixed = TRUE)
})

test_that("TosiHelp rejects unsupported output formats", {
  help <- TosiHelp$new(
    "example",
    "Example help",
    "# Example help",
    "9.8.7"
  )

  expect_error(help$format("pdf"), "markdown.*html", class = "rlang_error")
})
