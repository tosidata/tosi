# Source-independent table structure

`TosiStructure` describes a table or series through ordered components,
identifiers, labels, roles, and available value domains. It retains
language, frequency, and series-key information without requiring source
identity or version.
[TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md)
adds that source binding and inherits the structural methods. Fields are
read-only; direct and nested replacement fails.

## Component inspection

Use `$component(id)` for exact-ID lookup and `$domain_table(id)` for the
complete domain. Each component also provides `$domain_table()` with the
same return contract. `component$domain_size()` counts the stored
primary domain vector without constructing a table: `NA_integer_` when
unavailable, `0L` for a recorded empty domain.

Code domains may include `note` alongside `code` and `label`, with one
note per code in the same order; missing entries and repeated notes are
retained. A Dimension may also expose a read-only `classification_id`.
Interpret it within its source, Dimension and version context, not as a
globally stable identifier. `$as_list()` retains both facts, and
`$as_schema()` preserves them while sharing components.

`print(component)` or `component$print(n = 3)` bounds displayed domain
rows for Dimensions, Time, Frequency and unknown roles. Attributes show
metadata and domain size only; Value shows its unit when recorded.
Printing returns the same object invisibly without mutation.
`$domain_table()` returns the complete domain regardless of display
limits; truncation and omission markers are not literal source-filter
values.

Use `str(schema)` or `str(component)` to inspect R6 fields and method
signatures rather than the interactive overview. Component constructors
are technical exports, not an extension interface.

Time construction accepts `ranges = NULL`, one
[`time_range()`](https://tosidata.github.io/tosi/reference/time_range.md)
value or a list of values with unique frequencies. `$ranges` is a
read-only unnamed list in supplied order; `$as_list()$ranges` contains
plain records with frequency strings and Date/POSIXct endpoints. Ranges
do not populate `$frequencies()` or establish an enumerated Time domain.

## Active bindings

- `object_type`:

  Optional connector-supplied object type.

- `lang`:

  Scalar natural-language code or `"codes"`.

- `components`:

  Non-empty ordered list of schema components.

- `frequency`:

  Optional scalar known frequency code.

- `series_key`:

  Resolved series-key component IDs.

## Methods

### Public methods

- [`TosiStructure$new()`](#method-TosiStructure-initialize)

- [`TosiStructure$frequencies()`](#method-TosiStructure-frequencies)

- [`TosiStructure$n_observations()`](#method-TosiStructure-n_observations)

- [`TosiStructure$n_series()`](#method-TosiStructure-n_series)

- [`TosiStructure$as_schema()`](#method-TosiStructure-as_schema)

- [`TosiStructure$print()`](#method-TosiStructure-print)

- [`TosiStructure$component()`](#method-TosiStructure-component)

- [`TosiStructure$domain_table()`](#method-TosiStructure-domain_table)

- [`TosiStructure$column_names()`](#method-TosiStructure-column_names)

- [`TosiStructure$as_list()`](#method-TosiStructure-as_list)

- [`TosiStructure$clone()`](#method-TosiStructure-clone)

------------------------------------------------------------------------

### `TosiStructure$new()`

Construct a structural schema from package-owned schema components.

#### Usage

    TosiStructure$new(
      components,
      object_type = NULL,
      lang = NULL,
      frequency = NULL,
      series_key = NULL,
      observation_count = NULL,
      series_count = NULL
    )

#### Arguments

- `components`:

  Non-empty ordered list of package-owned schema component objects.

- `object_type`:

  Optional connector-supplied object type: `"table"`, `"series"`, or
  `NULL`.

- `lang`:

  Scalar natural-language code or `"codes"`.

- `frequency`:

  Optional scalar known frequency code.

- `series_key`:

  Optional ordered character vector of eligible series-key component
  IDs.

- `observation_count`:

  Optional actual observation count for this object's scope; `NULL` or
  `NA_real_` means unknown.

- `series_count`:

  Optional actual series count for this object's scope; `NULL` or
  `NA_real_` means unknown.

#### Returns

A new `TosiStructure` object.

------------------------------------------------------------------------

### `TosiStructure$frequencies()`

Return the fixed frequency when present, otherwise the Frequency
component's domain, without inference or retrieval.

#### Usage

    TosiStructure$frequencies()

#### Returns

The existing frequency vector, preserving class, order, missing values
and typed-empty values, or `NULL` when absent or unavailable.

------------------------------------------------------------------------

### `TosiStructure$n_observations()`

Report source-established actual observations for this object's scope or
potential grid positions, not occupancy. Potential counts span logical
axes including Time, counting canonical replacements once; Value,
Attributes and scalar frequency are not axes. Neither kind falls back to
the other or performs retrieval.

#### Usage

    TosiStructure$n_observations(kind = c("actual", "potential"))

#### Arguments

- `kind`:

  One of `"actual"` (default) or `"potential"`.

#### Returns

One numeric count, or `NA_real_` when unknown; a known empty grid is
zero.

------------------------------------------------------------------------

### `TosiStructure$n_series()`

Report source-established actual series for this object's scope or
potential grid positions across the resolved `series_key`, not
occupancy. An unavailable key is unknown; an empty key has one slot.
Neither kind falls back to the other or performs retrieval.

#### Usage

    TosiStructure$n_series(kind = c("actual", "potential"))

#### Arguments

- `kind`:

  One of `"actual"` (default) or `"potential"`.

#### Returns

One numeric count, or `NA_real_` when unknown; a known empty grid is
zero.

------------------------------------------------------------------------

### `TosiStructure$as_schema()`

Create a new source-bound schema with the supplied binding, retaining
actual counts and sharing existing component instances without cloning.
The receiver and its source binding, if any, remain unchanged.

#### Usage

    TosiStructure$as_schema(connector_id, object_id, data_version)

#### Arguments

- `connector_id`:

  Scalar canonical connector ID.

- `object_id`:

  Scalar canonical object ID.

- `data_version`:

  Finite non-missing scalar `POSIXct` source version.

#### Returns

A new `TosiSchema` object.

------------------------------------------------------------------------

### `TosiStructure$print()`

Print a compact overview without domain values. Dimensions, Time,
Frequency and unknown roles appear together; Attributes and Value are
summarized separately. Relative order within each group is preserved,
without changing stored component order. Domain sizes distinguish
unrecorded from recorded empty domains.

#### Usage

    TosiStructure$print()

#### Returns

This schema object, invisibly and without mutation.

------------------------------------------------------------------------

### `TosiStructure$component()`

Look up a component by its exact ID, not a list name, label, role or
position. An unknown ID raises a lookup error.

#### Usage

    TosiStructure$component(id)

#### Arguments

- `id`:

  Exact component ID.

#### Returns

The existing schema component object, without cloning.

------------------------------------------------------------------------

### `TosiStructure$domain_table()`

Return a component's complete domain by delegating to its
`$domain_table()` method. An unknown ID raises a lookup error. Domain
values are not translated into source filters; filter conventions are
source-specific.

#### Usage

    TosiStructure$domain_table(id)

#### Arguments

- `id`:

  Exact component ID.

#### Returns

A tibble in source order with `code` and optional `label`/`note`,
`time`, or `frequency` columns, preserving vector types including native
Date/POSIXct and frequency values. Returns `NULL` for an unrecorded
domain (including Value), or a typed zero-row tibble for a recorded
empty domain.

------------------------------------------------------------------------

### `TosiStructure$column_names()`

Return physical column names in component order without changing the
structure. `"labels"` uses component labels, `"safe_labels"` converts
them to safe IDs, and `"ids"` uses canonical component IDs. Label modes
fall back to IDs with a warning when labels are blank, protect canonical
Time and Value names, and repair collisions across the complete
structure, including undelivered Attributes.

#### Usage

    TosiStructure$column_names(col_mode = c("labels", "safe_labels", "ids"))

#### Arguments

- `col_mode`:

  One of `"labels"`, `"safe_labels"`, or `"ids"`.

#### Returns

A character vector of physical names named by component ID.

------------------------------------------------------------------------

### `TosiStructure$as_list()`

Return the schema as a named list, with components as named lists. Count
groups always contain both `actual` and `potential`; unknown counts are
retained as `NULL` entries.

#### Usage

    TosiStructure$as_list()

#### Returns

A named list containing the schema fields, components and
`observation_count` and `series_count` groups.

------------------------------------------------------------------------

### `TosiStructure$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiStructure$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
