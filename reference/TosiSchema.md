# Table structure

[`tosi_schema()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
returns a `TosiSchema` describing a table or series through its ordered
columns, identifiers, labels, roles, and available value domains. It
also includes the source version, language, and any frequency and
series-key information. Fields are read-only; direct and nested
replacement fails. Use `$column_names()` to see the physical names for
each column mode.

Use `schema$component(id)` to obtain the existing component by its exact
ID, and `schema$domain_table(id)` to inspect its complete domain. Every
component also provides `component$domain_table()` with the same return
contract. These methods preserve source order and vector types. Code
domains contain `code` and, only when supplied, `label`; Time and
Frequency domains contain `time` and `frequency`, respectively,
retaining native Date and frequency values. An unrecorded domain returns
`NULL` (including Value); a recorded empty domain returns a typed
zero-row tibble. Domain inspection does not translate values into source
filters; filter conventions are source-specific. Use `print(schema)` or
`schema$print()` for a compact overview without domain values.
Dimensions, Time, Frequency and unknown roles are shown together;
Attributes and Value are summarized separately. Relative order within
each group is preserved; the stored component order is unchanged. Domain
sizes distinguish unrecorded from recorded empty domains. Each component
supports `print(component)` and `component$print(n = 3)` for focused
inspection. The per-call `n` bounds domain rows for Dimensions, Time,
Frequency and unknown roles. Attributes show metadata and domain size
only; Value shows its unit when recorded. Printing returns the same
object invisibly without mutation. `$domain_table()` extracts the
complete domain regardless of display limits. Display truncation and
omission markers are not literal source-filter values. Use `str(schema)`
or `str(component)` for structural R6 inspection, including fields and
method signatures, rather than the interactive overview. Component
constructors are technical exports, not an extension interface.

## Active bindings

- `connector_id`:

  Scalar canonical connector ID vector.

- `object_id`:

  Scalar canonical object ID vector.

- `data_version`:

  Finite non-missing scalar `POSIXct` version.

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

- [`TosiSchema$new()`](#method-TosiSchema-initialize)

- [`TosiSchema$print()`](#method-TosiSchema-print)

- [`TosiSchema$component()`](#method-TosiSchema-component)

- [`TosiSchema$domain_table()`](#method-TosiSchema-domain_table)

- [`TosiSchema$column_names()`](#method-TosiSchema-column_names)

- [`TosiSchema$as_list()`](#method-TosiSchema-as_list)

- [`TosiSchema$clone()`](#method-TosiSchema-clone)

------------------------------------------------------------------------

### `TosiSchema$new()`

Construct an object schema from package-owned schema components.

#### Usage

    TosiSchema$new(
      connector_id,
      object_id,
      data_version,
      components,
      object_type = NULL,
      lang = NULL,
      frequency = NULL,
      series_key = NULL
    )

#### Arguments

- `connector_id`:

  Scalar canonical connector ID.

- `object_id`:

  Scalar canonical object ID.

- `data_version`:

  Finite non-missing scalar `POSIXct` source version.

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

#### Returns

A new `TosiSchema` object.

------------------------------------------------------------------------

### `TosiSchema$print()`

Print a compact role-grouped overview of every component, without domain
values or changing stored component order.

#### Usage

    TosiSchema$print()

#### Returns

This schema object, invisibly and without mutation.

------------------------------------------------------------------------

### `TosiSchema$component()`

Look up a component by its exact ID, not a list name, label, role or
position. An unknown ID raises a lookup error.

#### Usage

    TosiSchema$component(id)

#### Arguments

- `id`:

  Exact component ID.

#### Returns

The existing schema component object, without cloning.

------------------------------------------------------------------------

### `TosiSchema$domain_table()`

Return a component's complete domain by delegating to its
`$domain_table()` method. An unknown ID raises a lookup error.

#### Usage

    TosiSchema$domain_table(id)

#### Arguments

- `id`:

  Exact component ID.

#### Returns

A tibble in source order with `code` and optional `label`, `time`, or
`frequency` columns, preserving vector types. Returns `NULL` for an
unrecorded domain, or a typed zero-row tibble for a recorded empty
domain.

------------------------------------------------------------------------

### `TosiSchema$column_names()`

Return physical column names in schema order without changing the
schema.

#### Usage

    TosiSchema$column_names(col_mode = c("labels", "safe_labels", "ids"))

#### Arguments

- `col_mode`:

  One of `"labels"`, `"safe_labels"`, or `"ids"`.

#### Returns

A character vector of physical names named by component ID.

------------------------------------------------------------------------

### `TosiSchema$as_list()`

Return the schema as a named list, with components as named lists.

#### Usage

    TosiSchema$as_list()

#### Returns

A named list containing the schema fields and components.

------------------------------------------------------------------------

### `TosiSchema$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiSchema$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
