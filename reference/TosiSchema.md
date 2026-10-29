# Source-bound table structure

`TosiSchema` inherits
[TosiStructure](https://tosidata.github.io/tosi/reference/TosiStructure.md)
and directly stores canonical source identity and version. Inherited
structure and source-binding fields are read-only; direct and nested
replacement fails. Construct a schema directly or bind an existing
structure with `$as_schema()`.

A `tosi_table` embeds this schema as the sole authority for its source
binding, with no independent identity or version copy. Obtaining the
table's `schema` attribute retains that binding. Metadata describes the
delivered result, with no guarantee after wrangling. These shared model
constructors are technical exports, not an external subclassing
interface.

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
- [`TosiStructure$frequencies()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-frequencies)
- [`TosiStructure$n_observations()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-n_observations)
- [`TosiStructure$n_series()`](https://tosidata.github.io/tosi/reference/TosiStructure.html#method-n_series)

------------------------------------------------------------------------

### `TosiSchema$new()`

Construct the structural graph and its canonical source binding. The
version's shape is checked here; the producer establishes which source
input it describes.

#### Usage

    TosiSchema$new(
      connector_id,
      object_id,
      data_version,
      components,
      object_type = NULL,
      lang = NULL,
      frequency = NULL,
      series_key = NULL,
      observation_count = NULL,
      series_count = NULL
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

- `observation_count`:

  Optional actual observation count for this object's scope; `NULL` or
  `NA_real_` means unknown.

- `series_count`:

  Optional actual series count for this object's scope; `NULL` or
  `NA_real_` means unknown.

#### Returns

A new `TosiSchema` object.

------------------------------------------------------------------------

### `TosiSchema$print()`

Print source identity and version, followed by the role-grouped overview
described in
[TosiStructure](https://tosidata.github.io/tosi/reference/TosiStructure.md)'s
`$print()` method.

#### Usage

    TosiSchema$print()

#### Returns

This schema object, invisibly and without mutation.

------------------------------------------------------------------------

### `TosiSchema$as_list()`

Return an ordinary list with top-level source-binding fields followed by
the
[TosiStructure](https://tosidata.github.io/tosi/reference/TosiStructure.md)
projection, including components as named lists. This projection is not
independently authoritative state.

#### Usage

    TosiSchema$as_list()

#### Returns

A named list with `connector_id`, `object_id` and `data_version`
followed by structural fields and count groups.

------------------------------------------------------------------------

### `TosiSchema$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiSchema$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
