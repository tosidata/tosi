test_that("public provenance defaults to the public package version", {
  observed_package <- NULL
  local_mocked_bindings(
    packageVersion = function(pkg, ...) {
      observed_package <<- pkg
      package_version("1.2.3")
    },
    .package = "utils"
  )

  lineage <- TosiProvenance$new(stage = "fetch")

  expect_identical(observed_package, "tosi")
  expect_identical(lineage$steps[[1L]]$tosi_version, "1.2.3")
})

test_that("provenance adds semantic steps with ordinary R6 sharing", {
  timestamp <- as.POSIXct("2024-01-15 12:00:00", tz = "UTC")
  lineage <- TosiProvenance$new(
    "fetch",
    timestamp = timestamp,
    fetched_from = "origin"
  )
  alias <- lineage
  alias$add_step("transform", timestamp = timestamp, operation = "normalize")

  expect_identical(alias, lineage)
  expect_identical(map_chr(lineage$steps, "stage"), c("fetch", "transform"))
  expect_identical(
    lineage$steps[[2L]]$extra,
    list(operation = "normalize")
  )

  delivered <- TosiProvenance$new(
    "deliver",
    parent = lineage,
    timestamp = timestamp,
    connector_version = "1"
  )
  expect_false(identical(delivered, lineage))
  expect_identical(
    map_chr(delivered$steps, "stage"),
    c("fetch", "transform", "deliver")
  )
  expect_identical(delivered$steps[[3L]]$connector_version, "1")
  expect_identical(
    map_chr(lineage$steps, "stage"),
    c("fetch", "transform")
  )

  projection <- delivered$as_list()
  expect_type(projection, "list")
  expect_identical(
    map_chr(projection, "timestamp"),
    rep("2024-01-15T12:00:00+0000", 3L)
  )

  candidate <- lineage$clone(deep = TRUE)
  expect_error(candidate$steps <- list(), "read-only")
  candidate <- lineage$clone(deep = TRUE)
  expect_error(
    candidate$steps[[1L]]$stage <- "changed",
    "read-only"
  )
})

test_that("non-Parquet provenance carriers retain generic behavior", {
  timestamp <- as.POSIXct("2024-01-15 12:00:00", tz = "UTC")
  supplied <- TosiProvenance$new("fetch", timestamp = timestamp)
  schema <- TosiSchema$new(
    connector_id = "provenance_carrier",
    object_id = "table",
    data_version = timestamp,
    components = list(TosiSchemaValue$new()),
    object_type = "table",
    lang = "en"
  )
  table <- new_tosi_table(
    tibble::tibble(value = 1),
    schema = schema,
    col_mode = "ids"
  )

  expect_null(provenance(table))
  provenance(table) <- supplied
  expect_r6_class(provenance(table), "TosiProvenance")
  expect_false(identical(provenance(table), supplied))
  expect_identical(provenance(table)$as_list(), supplied$as_list())
  provenance(table) <- NULL
  expect_null(provenance(table))

  default_carrier <- 1L
  expect_null(provenance(default_carrier))
  provenance(default_carrier) <- supplied
  expect_false(identical(provenance(default_carrier), supplied))
  expect_identical(provenance(default_carrier)$as_list(), supplied$as_list())
  provenance(default_carrier) <- NULL
  expect_null(provenance(default_carrier))

  OrdinaryCarrier <- R6::R6Class(
    "OrdinaryProvenanceCarrier",
    public = list(provenance = NULL)
  )
  carrier <- OrdinaryCarrier$new()
  carrier_alias <- carrier

  expect_null(provenance(carrier))
  provenance(carrier) <- supplied
  expect_identical(provenance(carrier_alias), provenance(carrier))
  expect_false(identical(provenance(carrier), supplied))
  expect_identical(provenance(carrier)$as_list(), supplied$as_list())
  expect_error(provenance(carrier) <- "invalid", class = "rlang_error")
  provenance(carrier) <- NULL
  expect_null(provenance(carrier_alias))
})

test_that("active R6 provenance carriers use their getter and setter", {
  timestamp <- as.POSIXct("2024-01-15 12:00:00", tz = "UTC")
  supplied <- TosiProvenance$new("fetch", timestamp = timestamp)
  ActiveCarrier <- R6::R6Class(
    "ActiveProvenanceCarrier",
    private = list(.provenance = NULL),
    active = list(
      provenance = function(value) {
        if (missing(value)) {
          private$.provenance
        } else {
          private$.provenance <- value
        }
      }
    )
  )
  carrier <- ActiveCarrier$new()
  carrier_alias <- carrier

  expect_null(provenance(carrier))
  provenance(carrier) <- supplied
  expect_identical(provenance(carrier_alias), provenance(carrier))
  expect_false(identical(provenance(carrier), supplied))
  expect_identical(provenance(carrier)$as_list(), supplied$as_list())
  provenance(carrier) <- NULL
  expect_null(provenance(carrier_alias))
})

test_that("R6 carrier structure determines missing and read-only behavior", {
  timestamp <- as.POSIXct("2024-01-15 12:00:00", tz = "UTC")
  supplied <- TosiProvenance$new("fetch", timestamp = timestamp)

  MissingCarrier <- R6::R6Class("MissingProvenanceCarrier")
  missing_carrier <- MissingCarrier$new()
  expect_null(provenance(missing_carrier))
  expect_error(provenance(missing_carrier) <- supplied)

  UnlockedCarrier <- R6::R6Class(
    "UnlockedProvenanceCarrier",
    lock_objects = FALSE
  )
  unlocked_carrier <- UnlockedCarrier$new()
  provenance(unlocked_carrier) <- supplied
  expect_false(identical(provenance(unlocked_carrier), supplied))
  expect_identical(provenance(unlocked_carrier)$as_list(), supplied$as_list())

  ReadOnlyCarrier <- R6::R6Class(
    "ReadOnlyProvenanceCarrier",
    public = list(
      initialize = function(provenance) {
        private$.provenance <- provenance
      }
    ),
    private = list(.provenance = NULL),
    active = list(
      provenance = function(value) {
        if (!missing(value)) {
          cli_abort("{.field provenance} is read-only.")
        }
        private$.provenance
      }
    )
  )
  read_only_carrier <- ReadOnlyCarrier$new(supplied)

  expect_identical(provenance(read_only_carrier), supplied)
  expect_error(
    provenance(read_only_carrier) <- supplied,
    "read-only"
  )
})
