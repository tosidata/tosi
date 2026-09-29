perform_service_request <- function(operation, args, call = caller_env()) {
  url <- getOption("tosi.url") %||% Sys.getenv("TOSI_URL")
  token <- str_trim(getOption("tosi.token") %||% Sys.getenv("TOSI_TOKEN"))
  if (!nzchar(url)) {
    cli_abort(
      "Set a service URL with tosi_options(url = ...) or TOSI_URL.",
      call = call
    )
  }

  args$options <- compact(list(
    language_preference = getOption("tosi.language_preference")
  ))

  req <- request(url) |>
    req_url_path_append("v1", "requests") |>
    req_auth_bearer_token(token) |>
    req_headers(Accept = "text/event-stream") |>
    req_body_json(
      list(
        operation = unbox(operation),
        args = args,
        client = list(
          program = unbox("tosi"),
          package_version = unbox(as.character(getNamespaceVersion("tosi"))),
          r_version = unbox(paste(R.version$major, R.version$minor, sep = ".")),
          os = unbox(.Platform$OS.type)
        )
      ),
      auto_unbox = FALSE
    ) |>
    req_options(followlocation = FALSE)

  cli_inform("TosiData: waiting for the service response.")
  response <- tryCatch(
    req_perform_connection(req, blocking = TRUE),
    httr2_http = function(e) {
      if (e$status < 500L || e$status > 599L) {
        rlang::cnd_signal(e)
      }
      cli_abort(
        "TosiData: the service returned a server error. Please try again later.",
        call = call
      )
    },
    httr2_failure = function(e) {
      cli_abort(
        "TosiData: could not establish the service connection. Check that the service is running and reachable.",
        call = call
      )
    }
  )
  on.exit(close(response), add = TRUE)
  resp_check_content_type(response, valid_types = "text/event-stream")

  result <- NULL
  while (!resp_stream_is_complete(response)) {
    event <- resp_stream_sse(response)
    if (is.null(event)) {
      break
    }

    value <- parse_json(event[["data"]], simplifyVector = FALSE)
    if (event[["type"]] == "progress") {
      cli_inform(value[["message"]])
    } else if (event[["type"]] == "error") {
      cli_abort(value[["message"]], call = call)
    } else if (event[["type"]] == "result") {
      result <- value
      break
    } else {
      cli_abort("The service sent an unexpected event.", call = call)
    }
  }

  if (is.null(result)) {
    cli_abort("The service response ended without a result.", call = call)
  }
  descriptor <- result[["value"]]
  if (
    !identical(result[["kind"]], "r_object") ||
      !identical(result[["delivery"]], "artifact")
  ) {
    cli_abort(
      "The service returned an unsupported result profile.",
      call = call
    )
  }
  decoder <- switch(
    descriptor$representation,
    "r-serialization" = readRDS,
    "qs2" = qs2::qs_read,
    cli_abort(
      "The service returned an unsupported result profile.",
      call = call
    )
  )

  filename <- download_service_result(
    descriptor[["path"]],
    url,
    token,
    call = call
  )
  on.exit(unlink(filename), add = TRUE)
  decoder(filename)
}

download_service_result <- function(path, url, token, call = caller_env()) {
  valid_path <- is_scalar_string(path, allow_empty = TRUE) &&
    str_detect(path, "\\A/v1/results/[A-Za-z0-9-]+\\z")
  if (!valid_path) {
    cli_abort("The service returned an invalid result path.", call = call)
  }

  req <- request(url) |>
    req_url_relative(path) |>
    req_auth_bearer_token(token) |>
    req_timeout(60) |>
    req_options(followlocation = FALSE) |>
    req_error(is_error = \(response) resp_status(response) != 200L)

  filename <- tempfile("tosi-result-")
  completed <- FALSE
  on.exit(if (!completed) unlink(filename), add = TRUE)
  response <- req_perform(req, path = filename)
  resp_check_content_type(
    response,
    valid_types = "application/octet-stream"
  )
  completed <- TRUE
  filename
}
