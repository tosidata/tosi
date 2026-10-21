# Source-independent table structure

`TosiStructure` describes a table or series through its ordered
components, identifiers, labels, roles, and available value domains,
without requiring source identity or a source version. It retains
language, frequency, and series-key information.
[TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md)
inherits this structure and adds a canonical source identity and
version. Both classes support the same structural methods. Fields are
read-only; direct and nested replacement fails. Use `$column_names()` to
see the physical names for each column mode.

Use `structure$as_schema(connector_id, object_id, data_version)` to
create a new source-bound schema. The receiver is unchanged and existing
component instances are shared, not cloned. The inherited method on a
bound schema also creates a new result with the supplied binding,
without replacing the receiver's source binding.

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
      series_key = NULL
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

#### Returns

A new `TosiStructure` object.

------------------------------------------------------------------------

### `TosiStructure$as_schema()`

Create a source-bound schema sharing the existing component instances.
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

Print a compact role-grouped overview of every component, without domain
values or changing stored component order.

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
`$domain_table()` method. An unknown ID raises a lookup error.

#### Usage

    TosiStructure$domain_table(id)

#### Arguments

- `id`:

  Exact component ID.

#### Returns

A tibble in source order with `code` and optional `label`, `time`, or
`frequency` columns, preserving vector types. Returns `NULL` for an
unrecorded domain, or a typed zero-row tibble for a recorded empty
domain.

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

Return the schema as a named list, with components as named lists.

#### Usage

    TosiStructure$as_list()

#### Returns

A named list containing the schema fields and components.

------------------------------------------------------------------------

### `TosiStructure$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiStructure$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
