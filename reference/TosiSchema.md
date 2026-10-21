# Source-bound table structure

`TosiSchema` inherits
[TosiStructure](https://tosidata.github.io/tosi/reference/TosiStructure.md)
and directly stores canonical source identity and version. Construct it
directly or use
`structure$as_schema(connector_id, object_id, data_version)` to bind an
existing structure without changing it or cloning its components. Use
`$component()`, `$domain_table()`, and `$column_names()` directly,
without unwrapping another schema object. Canonical identity and source
version are available through read-only `$connector_id`, `$object_id`,
and `$data_version` bindings.

A `tosi_table` embeds this source-bound schema. Obtaining its `schema`
attribute retains the source binding. The schema is the sole authority
for that binding; the table stores no independent identity or version
copy. Metadata describes the delivered result, with no guarantee after
wrangling. `$as_list()` returns an ordinary list with top-level
source-binding fields followed by structural fields; components are
projected as named lists. This projection is not independently
authoritative state.

Inherited fields and source-binding fields are read-only; direct and
nested replacement fails. The version's shape is checked at
construction; the producer establishes which source input it describes.
These shared model constructors are technical exports, not an external
subclassing interface.

## Super class

[`TosiStructure`](https://tosidata.github.io/tosi/reference/TosiStructure.md)
-\> `TosiSchema`

## Active bindings

- `connector_id`:

  Read-only scalar canonical connector ID vector.

- `object_id`:

  Read-only scalar canonical object ID vector.

- `data_version`:

  Read-only finite non-missing scalar `POSIXct` source version.

## Methods

### Public methods

- [`TosiSchema$new()`](#method-TosiSchema-initialize)

- [`TosiSchema$print()`](#method-TosiSchema-print)

- [`TosiSchema$as_list()`](#method-TosiSchema-as_list)

- [`TosiSchema$clone()`](#method-TosiSchema-clone)

Inherited methods

- [`TosiStructure$as_schema()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-as_schema)
- [`TosiStructure$column_names()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-column_names)
- [`TosiStructure$component()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-component)
- [`TosiStructure$domain_table()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-domain_table)

------------------------------------------------------------------------

### `TosiSchema$new()`

Construct the structural graph and its canonical source binding.

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

Print source identity and version, followed by the structural overview.

#### Usage

    TosiSchema$print()

#### Returns

This schema object, invisibly and without mutation.

------------------------------------------------------------------------

### `TosiSchema$as_list()`

Return source-binding fields followed by structural fields.

#### Usage

    TosiSchema$as_list()

#### Returns

A named list with `connector_id`, `object_id`, `data_version`,
`object_type`, `lang`, `frequency`, `series_key`, and `components`, in
that order. Components are projected as named lists; other fields retain
their values, types, and attributes.

------------------------------------------------------------------------

### `TosiSchema$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiSchema$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
