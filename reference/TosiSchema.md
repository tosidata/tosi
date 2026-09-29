# Table structure

[`tosi_schema()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
returns a `TosiSchema` describing a table or series through its ordered
columns, identifiers, labels, roles, and available value domains. It
also includes the source version, language, and any frequency and
series-key information. Fields are read-only; direct and nested
replacement fails. Use `$column_names()` to see the physical names for
each column mode.

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
