local_result_service <- function(
  value,
  descriptor = list(
    path = "/v1/results/result-native-7e28bc6a",
    representation = "r-serialization",
    compression = "gzip"
  ),
  write_result = function(value, path) {
    saveRDS(value, path, compress = "gzip", version = 3)
  },
  on_post = function() {},
  env = parent.frame()
) {
  withr::local_options(tosi.url = NULL, tosi.token = NULL, .local_envir = env)
  result <- list(
    kind = "r_object",
    delivery = "artifact",
    value = descriptor
  )
  state <- new.env(parent = emptyenv())
  state$post_requests <- list()
  state$get_requests <- list()
  state$download_paths <- character()
  source <- tempfile()
  write_result(value, source)
  state$bytes <- readBin(source, "raw", n = file.info(source)$size)
  unlink(source)
  state$sse_body <- paste0(
    "event: progress\ndata: {\"message\":\"Accepted\"}\n\n",
    "event: result\ndata: ",
    jsonlite::toJSON(result, auto_unbox = TRUE),
    "\n\n"
  )

  testthat::local_mocked_bindings(
    req_perform_connection = function(req, blocking = TRUE, ...) {
      state$post_requests[[length(state$post_requests) + 1L]] <- req
      on_post()
      connection <- rawConnection(charToRaw(state$sse_body), open = "rb")
      body <- httr2::StreamingBody$new(connection)
      unlockBinding("is_complete", body)
      body$is_complete <- function() {
        seek(connection) >= nchar(state$sse_body, type = "bytes")
      }
      httr2::new_response(
        method = httr2::req_get_method(req),
        url = httr2::req_get_url(req),
        status_code = 200L,
        headers = list("Content-Type" = "text/event-stream"),
        body = body,
        request = req
      )
    },
    req_perform = function(req, path = NULL, ...) {
      state$get_requests[[length(state$get_requests) + 1L]] <- req
      state$download_paths <- c(state$download_paths, path)
      writeBin(state$bytes, path)
      httr2::new_response(
        method = httr2::req_get_method(req),
        url = httr2::req_get_url(req),
        status_code = 200L,
        headers = list("Content-Type" = "application/octet-stream"),
        body = raw(),
        request = req
      )
    },
    .package = "tosi",
    .env = env
  )
  state
}

test_that("connection and server errors have safe distinct messages", {
  withr::local_options(tosi.url = "https://service.invalid", tosi.token = "")
  error <- rlang::error_cnd(
    "httr2_http",
    status = 500L,
    message = "internal diagnostic"
  )
  local_mocked_bindings(req_perform_connection = function(...) {
    rlang::cnd_signal(error)
  })
  expect_identical(
    conditionMessage(rlang::catch_cnd(suppressMessages(tosi_metadata(
      "eurostat/tps00001"
    )))),
    "TosiData: the service returned a server error. Please try again later."
  )
  error <- rlang::error_cnd("httr2_failure", message = "internal diagnostic")
  expect_identical(
    conditionMessage(rlang::catch_cnd(suppressMessages(tosi_metadata(
      "eurostat/tps00001"
    )))),
    "TosiData: could not establish the service connection. Check that the service is running and reachable."
  )
})

test_that("a missing service URL gives an actionable error", {
  withr::local_options(tosi.url = NULL, tosi.token = NULL)
  withr::local_envvar(TOSI_URL = NA_character_)
  expect_error(
    tosi_help(),
    "Set a service URL with tosi_options(url = ...) or TOSI_URL.",
    fixed = TRUE
  )

  Sys.setenv(TOSI_URL = "")
  expect_error(
    tosi_help(),
    "Set a service URL with tosi_options(url = ...) or TOSI_URL.",
    fixed = TRUE
  )
})

test_that("options override the environment for the whole retrieval", {
  withr::local_envvar(c(
    TOSI_URL = "https://environment.invalid",
    TOSI_TOKEN = "environment-token"
  ))
  peer <- local_result_service("result", on_post = function() {
    options(tosi.url = "https://later.invalid", tosi.token = "later-token")
    Sys.setenv(
      TOSI_URL = "https://later-env.invalid",
      TOSI_TOKEN = "later-env-token"
    )
  })
  tosi_options(
    url = "https://chosen.invalid/service/",
    token = "  chosen-token  "
  )

  expect_identical(suppressMessages(tosi_help("statfin")), "result")
  expect_identical(
    httr2::req_get_url(peer$post_requests[[1L]]),
    "https://chosen.invalid/service/v1/requests"
  )
  expect_identical(
    httr2::req_get_url(peer$get_requests[[1L]]),
    "https://chosen.invalid/v1/results/result-native-7e28bc6a"
  )
  expect_identical(
    map_chr(
      c(peer$post_requests, peer$get_requests),
      ~ httr2::req_get_headers(.x, redacted = "reveal")$Authorization
    ),
    c("Bearer chosen-token", "Bearer chosen-token")
  )
  expect_false(
    "token" %in%
      names(
        httr2::req_get_body(
          peer$post_requests[[1L]],
          obfuscated = "reveal"
        )$args
      )
  )
})

test_that("clearing options restores live environment fallback", {
  withr::local_envvar(c(
    TOSI_URL = "https://fallback.invalid",
    TOSI_TOKEN = "  fallback-token  "
  ))
  peer <- local_result_service("result")
  tosi_options(url = "https://unused.invalid", token = "unused-token")
  tosi_options(url = NULL, token = NULL)

  expect_identical(suppressMessages(tosi_help("statfin")), "result")
  expect_identical(
    httr2::req_get_url(peer$post_requests[[1L]]),
    "https://fallback.invalid/v1/requests"
  )
  expect_identical(
    httr2::req_get_url(peer$get_requests[[1L]]),
    "https://fallback.invalid/v1/results/result-native-7e28bc6a"
  )
  expect_identical(
    map_chr(
      c(peer$post_requests, peer$get_requests),
      ~ httr2::req_get_headers(.x, redacted = "reveal")$Authorization
    ),
    c("Bearer fallback-token", "Bearer fallback-token")
  )
})

test_that("requests compact the session language preference snapshot", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid",
    TOSI_TOKEN = "probe-token"
  ))
  withr::local_options(tosi.language_preference = NULL)
  peer <- local_result_service("result")
  preferences <- list(character(), "fi", c("fi", "en"), NULL)

  for (preference in preferences) {
    options(tosi.language_preference = preference)
    expect_identical(
      suppressMessages(perform_service_request(
        "tosi_help",
        list(topic = "statfin")
      )),
      "result"
    )
  }

  observed <- map(
    peer$post_requests,
    ~ httr2::req_get_body(.x, obfuscated = "reveal")$args$options
  )
  empty_options <- structure(list(), names = character())
  expect_identical(
    observed,
    list(
      empty_options,
      list(language_preference = "fi"),
      list(language_preference = c("fi", "en")),
      empty_options
    )
  )

  encoded <- map_chr(
    peer$post_requests,
    function(request) {
      httr2::req_get_body(request, obfuscated = "reveal") |>
        jsonlite::toJSON(auto_unbox = FALSE, null = "null")
    }
  )
  expect_true(str_detect(encoded[[1L]], fixed('"options":{}')))
  expect_false(str_detect(encoded[[1L]], fixed("language_preference")))
  expect_true(str_detect(
    encoded[[2L]],
    fixed(
      '"options":{"language_preference":["fi"]}'
    )
  ))
  expect_true(str_detect(
    encoded[[3L]],
    fixed(
      '"options":{"language_preference":["fi","en"]}'
    )
  ))
  expect_true(str_detect(encoded[[4L]], fixed('"options":{}')))
  expect_false(str_detect(encoded[[4L]], fixed("language_preference")))
})

test_that("an explicit language does not change later request defaults", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid",
    TOSI_TOKEN = "probe-token"
  ))
  withr::local_options(tosi.language_preference = c("fi", "en"))
  peer <- local_result_service("result")

  suppressMessages(tosi_data("statfin/table", lang = "sv"))
  suppressMessages(tosi_data("statfin/table"))

  bodies <- map(
    peer$post_requests,
    ~ httr2::req_get_body(.x, obfuscated = "reveal")
  )
  expect_identical(bodies[[1L]]$args$lang, "sv")
  expect_false("lang" %in% names(bodies[[2L]]$args))
  expect_identical(
    map(bodies, ~ .x$args$options),
    rep(list(list(language_preference = c("fi", "en"))), 2L)
  )
  expect_identical(getOption("tosi.language_preference"), c("fi", "en"))
})

test_that("supported profiles restore complete representative R values", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid/service/",
    TOSI_TOKEN = "  probe-token  "
  ))
  table <- structure(
    data.frame(label = c("one", NA_character_), value = c(1, NA_real_)),
    class = c("tosi_table", "data.frame"),
    schema = list(full = TRUE),
    provenance = list(source = "fixture"),
    result_scope = "preview"
  )
  model <- TosiHelp$new(
    "statfin",
    "Statistics Finland",
    "# Help",
    "0.0.0.9000"
  )
  version <- structure(
    as.POSIXct("2026-09-07 12:34:56.125", tz = "Pacific/Chatham"),
    names = "statfin/canonical-example"
  )
  discovery <- list(
    connectors = new_tosi_connector_catalog(tibble::tibble(
      id = c("statfin", "eurostat"),
      name = c("Statistics Finland", "Eurostat"),
      source_rank = c(1L, 2L)
    )),
    datasets = new_tosi_dataset_catalog(tibble::tibble(
      object_path = c("statfin/table_b", "statfin/table_a"),
      title = c("Long population title", "Employment"),
      object_type = c("table", "table"),
      match_context = c("Finnish title", NA_character_)
    )),
    search = new_tosi_search_results(tibble::tibble(
      object_path = c("eurostat/result_b", "statfin/result_a"),
      title = c("Population result", "Employment result"),
      score = c(0.75, 0.5),
      match_context = c("Swedish title", NA_character_)
    )),
    empty_connectors = new_tosi_connector_catalog(tibble::tibble(
      id = character(),
      name = character(),
      description = character(),
      source = character(),
      languages = list(),
      aggregation_options = logical()
    )),
    empty_datasets = new_tosi_dataset_catalog(tibble::tibble(
      object_path = character(),
      title = character(),
      object_type = character(),
      language = character(),
      description = character(),
      keywords = character()
    )),
    empty_search = new_tosi_search_results(tibble::tibble())
  )
  expected <- list(
    table = table,
    model = model,
    version = version,
    discovery = discovery
  )
  peer <- local_result_service(expected)

  expect_message(
    result <- perform_service_request("tosi_schema", list(path = "statfin/x")),
    "Accepted"
  )

  expect_identical(result$table, table)
  expect_s3_class(result$model, "TosiHelp")
  expect_identical(result$model$as_list(), model$as_list())
  expect_identical(result$version, version)
  expect_identical(result$discovery, discovery)
  expect_identical(
    map_chr(result$discovery, ~ class(.x)[[1L]]),
    c(
      connectors = "tosi_connector_catalog",
      datasets = "tosi_dataset_catalog",
      search = "tosi_search_results",
      empty_connectors = "tosi_connector_catalog",
      empty_datasets = "tosi_dataset_catalog",
      empty_search = "tosi_search_results"
    )
  )
  expect_identical(dim(result$discovery$empty_search), c(0L, 0L))
  expect_identical(
    result$discovery$datasets$object_path,
    c("statfin/table_b", "statfin/table_a")
  )
  expect_identical(
    result$discovery$search$match_context,
    c("Swedish title", NA_character_)
  )

  qs_peer <- local_result_service(
    expected,
    descriptor = list(
      path = "/v1/results/result-native-7e28bc6a",
      representation = "qs2",
      compression = "zstd"
    ),
    write_result = qs2::qs_save
  )
  qs_result <- suppressMessages(
    perform_service_request("tosi_schema", list(path = "statfin/x"))
  )
  expect_identical(qs_result$table, table)
  expect_s3_class(qs_result$model, "TosiHelp")
  expect_identical(qs_result$model$as_list(), model$as_list())
  expect_identical(qs_result$version, version)
  expect_identical(qs_result$discovery, discovery)
  expect_length(qs_peer$post_requests, 1L)
  expect_length(qs_peer$get_requests, 1L)
  expect_length(qs_peer$download_paths, 1L)
  expect_false(file.exists(qs_peer$download_paths[[1L]]))

  expect_length(peer$post_requests, 1L)
  post <- peer$post_requests[[1L]]
  post_body <- httr2::req_get_body(post, obfuscated = "reveal")
  expect_null(post$options$timeout_ms)
  expect_identical(post_body$operation, jsonlite::unbox("tosi_schema"))
  expect_named(
    post_body$client,
    c("program", "package_version", "r_version", "os")
  )
  expect_identical(post_body$client$program, jsonlite::unbox("tosi"))
  expect_identical(
    post_body$client$package_version,
    jsonlite::unbox(as.character(getNamespaceVersion("tosi")))
  )
  expect_identical(
    post_body$client$r_version,
    jsonlite::unbox(paste(R.version$major, R.version$minor, sep = "."))
  )
  expect_identical(
    post_body$client$os,
    jsonlite::unbox(.Platform$OS.type)
  )
  expect_false(any(
    c("hostname", "username", "path", "environment") %in%
      names(post_body$client)
  ))
  expect_length(peer$get_requests, 1L)
  expect_length(peer$download_paths, 1L)
  expect_false(file.exists(peer$download_paths[[1L]]))

  get <- peer$get_requests[[1L]]
  headers <- httr2::req_get_headers(get, redacted = "reveal")
  expect_identical(httr2::req_get_method(get), "GET")
  expect_identical(
    httr2::req_get_url(get),
    "https://example.invalid/v1/results/result-native-7e28bc6a"
  )
  expect_identical(headers$Authorization, "Bearer probe-token")
  expect_identical(get$options$timeout_ms, 60000)
  expect_identical(get$options$followlocation, FALSE)
  expect_null(get$policies$retry_max_tries)
})

test_that("unsupported descriptors and hostile paths are not downloaded", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid",
    TOSI_TOKEN = "probe-token"
  ))
  peer <- local_result_service("unused")
  profiles <- list(
    list(
      kind = "table",
      delivery = "artifact",
      value = list(
        path = "/v1/results/result-native-7e28bc6a",
        representation = "r-serialization",
        compression = "gzip"
      )
    ),
    list(
      kind = "r_object",
      delivery = "inline",
      value = list(
        path = "/v1/results/result-native-7e28bc6a",
        representation = "r-serialization",
        compression = "gzip"
      )
    ),
    list(
      kind = "r_object",
      delivery = "artifact",
      value = list(
        path = "/v1/results/result-native-7e28bc6a",
        representation = "arrow-ipc-stream",
        compression = "zstd"
      )
    )
  )
  for (profile in profiles) {
    peer$sse_body <- paste0(
      "event: result\ndata: ",
      jsonlite::toJSON(profile, auto_unbox = TRUE),
      "\n\n"
    )
    expect_error(
      suppressMessages(perform_service_request("tosi_data", list())),
      "unsupported result profile"
    )
  }

  hostile <- profiles[[1L]]
  hostile$kind <- "r_object"
  hostile$value$path <- "https://evil.invalid/v1/results/stolen"
  peer$sse_body <- paste0(
    "event: result\ndata: ",
    jsonlite::toJSON(hostile, auto_unbox = TRUE),
    "\n\n"
  )
  expect_error(
    suppressMessages(perform_service_request("tosi_data", list())),
    "invalid result path"
  )
  expect_length(peer$get_requests, 0L)
})

test_that("failed restoration removes the downloaded temporary file", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid",
    TOSI_TOKEN = "probe-token"
  ))
  descriptors <- list(
    list(
      path = "/v1/results/result-native-7e28bc6a",
      representation = "r-serialization",
      compression = "gzip"
    ),
    list(
      path = "/v1/results/result-native-7e28bc6a",
      representation = "qs2",
      compression = "zstd"
    )
  )
  for (descriptor in descriptors) {
    peer <- local_result_service("unused", descriptor = descriptor)
    peer$bytes <- charToRaw("not a serialized R object")

    expect_error(
      suppressMessages(perform_service_request("tosi_help", list())),
      info = descriptor$representation
    )
    expect_length(peer$download_paths, 1L)
    expect_false(file.exists(peer$download_paths[[1L]]))
  }
})

test_that("results end stream processing and missing results fail", {
  withr::local_envvar(c(
    TOSI_URL = "https://example.invalid",
    TOSI_TOKEN = "probe-token"
  ))
  peer <- local_result_service("unused")
  terminal <- sub(
    "event: progress.*?\\n\\n",
    "",
    peer$sse_body
  )
  peer$sse_body <- "event: progress\ndata: {\"message\":\"Accepted\"}\n\n"
  expect_error(
    suppressMessages(perform_service_request("tosi_data", list())),
    "The service response ended without a result.",
    fixed = TRUE
  )
  expect_length(peer$get_requests, 0L)
  cases <- list(
    duplicate = paste0(terminal, terminal),
    after_terminal = paste0(
      terminal,
      "event: progress\ndata: {\"message\":\"late\"}\n\n"
    )
  )

  for (name in names(cases)) {
    peer$sse_body <- cases[[name]]
    expect_identical(
      suppressMessages(perform_service_request("tosi_data", list())),
      "unused",
      info = name
    )
  }

  original <- "CORE-SENTINEL https://source.invalid /private/path"
  peer$sse_body <- paste0(
    "event: error\ndata: ",
    jsonlite::toJSON(
      list(code = "request_failed", message = original),
      auto_unbox = TRUE
    ),
    "\n\n"
  )
  error <- tryCatch(
    suppressMessages(perform_service_request("tosi_data_version", list())),
    error = identity
  )
  expect_identical(conditionMessage(error), original)
  expect_length(peer$get_requests, length(cases))
})
