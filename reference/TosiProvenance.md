# Provenance history

`TosiProvenance` records the ordered steps used to produce and deliver a
data artifact. Read an artifact's history with
[`provenance()`](https://tosidata.github.io/tosi/reference/provenance.md).
Create a history with `TosiProvenance$new()`, optionally passing
`parent` to copy its steps and add one new step without changing the
parent.

`$steps` is read-only: direct and nested replacement fails.
`$add_step()` appends to this object in place, so other references to it
see the new step. Reading an artifact's provenance returns its live
object, not a copy.

## Active bindings

- `steps`:

  Read-only ordered list of plain named-list provenance steps. Direct
  and nested replacement fails; append through `$add_step()`.

## Methods

### Public methods

- [`TosiProvenance$new()`](#method-TosiProvenance-initialize)

- [`TosiProvenance$add_step()`](#method-TosiProvenance-add_step)

- [`TosiProvenance$as_list()`](#method-TosiProvenance-as_list)

- [`TosiProvenance$to_json()`](#method-TosiProvenance-to_json)

- [`TosiProvenance$print()`](#method-TosiProvenance-print)

- [`TosiProvenance$clone()`](#method-TosiProvenance-clone)

------------------------------------------------------------------------

### `TosiProvenance$new()`

Construct a provenance lineage.

`parent` may be `NULL`, another `TosiProvenance`, or any carrier
supported by
[`provenance()`](https://tosidata.github.io/tosi/reference/provenance.md).
Parent steps are copied before the new step is appended.

#### Usage

    TosiProvenance$new(
      stage,
      parent = NULL,
      timestamp = lubridate::now("UTC"),
      tosi_version = NULL,
      source_url = NULL,
      http_status = NULL,
      http_headers = NULL,
      fetched_from = NULL,
      checksum = NULL,
      file_size = NULL,
      connector_version = NULL,
      r_version = NULL,
      trace_id = NULL,
      extra = list(),
      ...
    )

#### Arguments

- `stage`:

  A non-empty character scalar naming the pipeline stage.

- `parent`:

  The provenance parent, or `NULL` for a root lineage.

- `timestamp`:

  A finite, non-missing `POSIXct` scalar.

- `tosi_version`:

  Optional package-version string. The public `tosi` package version is
  used by default.

- `source_url`:

  Optional source URL character scalar.

- `http_status`:

  Optional numeric HTTP status.

- `http_headers`:

  Optional HTTP headers.

- `fetched_from`:

  Optional source location: `"origin"`, `"local_cache"`,
  `"cloud_cache"`, or `"stale_fallback"`.

- `checksum`:

  Optional checksum character scalar.

- `file_size`:

  Optional file size.

- `connector_version`:

  Optional connector version.

- `r_version`:

  Optional R-version string. The current R version is used by default.

- `trace_id`:

  Optional trace identifier.

- `extra`:

  A named list of additional step fields.

- `...`:

  Additional named values collected into `extra`.

------------------------------------------------------------------------

### `TosiProvenance$add_step()`

Append one step to this provenance object in place. Ordinary aliases of
this object observe the appended step.

#### Usage

    TosiProvenance$add_step(
      stage,
      timestamp = lubridate::now("UTC"),
      tosi_version = NULL,
      source_url = NULL,
      http_status = NULL,
      http_headers = NULL,
      fetched_from = NULL,
      checksum = NULL,
      file_size = NULL,
      connector_version = NULL,
      r_version = NULL,
      trace_id = NULL,
      extra = list(),
      ...
    )

#### Arguments

- `stage`:

  A non-empty character scalar naming the pipeline stage.

- `timestamp`:

  A finite, non-missing `POSIXct` scalar.

- `tosi_version`:

  Optional package-version string. The public `tosi` package version is
  used by default.

- `source_url`:

  Optional source URL character scalar.

- `http_status`:

  Optional numeric HTTP status.

- `http_headers`:

  Optional HTTP headers.

- `fetched_from`:

  Optional source location: `"origin"`, `"local_cache"`,
  `"cloud_cache"`, or `"stale_fallback"`.

- `checksum`:

  Optional checksum character scalar.

- `file_size`:

  Optional file size.

- `connector_version`:

  Optional connector version.

- `r_version`:

  Optional R-version string. The current R version is used by default.

- `trace_id`:

  Optional trace identifier.

- `extra`:

  A named list of additional step fields.

- `...`:

  Additional named values collected into `extra`.

#### Returns

This `TosiProvenance` object, invisibly.

------------------------------------------------------------------------

### `TosiProvenance$as_list()`

Return a copy of the steps as named lists, with ISO-8601 timestamps.

#### Usage

    TosiProvenance$as_list()

#### Returns

A list of named step lists.

------------------------------------------------------------------------

### `TosiProvenance$to_json()`

Return the steps as JSON with ISO-8601 timestamps.

#### Usage

    TosiProvenance$to_json(pretty = TRUE)

#### Arguments

- `pretty`:

  Whether to format the JSON with indentation.

#### Returns

A JSON string containing an ordered array of step objects.

------------------------------------------------------------------------

### `TosiProvenance$print()`

Print a compact stage summary.

#### Usage

    TosiProvenance$print(...)

#### Arguments

- `...`:

  Ignored.

#### Returns

This `TosiProvenance` object, invisibly.

------------------------------------------------------------------------

### `TosiProvenance$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiProvenance$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
