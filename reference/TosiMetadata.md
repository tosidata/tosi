# Descriptive metadata

[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
returns a `TosiMetadata` containing the title, source, language,
version, and optional description and source-reference cards. Fields are
read-only; direct and nested replacement fails. `$as_list()` returns the
metadata as a named list.

## Active bindings

- `connector_id`:

  Scalar canonical connector ID vector.

- `object_id`:

  Scalar canonical object ID vector.

- `source_object_id`:

  Optional source-native object identifier.

- `data_version`:

  Finite non-missing scalar `POSIXct` source version.

- `lang`:

  Natural-language code used by scalar labels.

- `title`:

  Human-facing object title.

- `source_label`:

  Human-facing source label.

- `description`:

  Optional object description.

- `subject_area`:

  Optional subject-area label.

- `next_update`:

  Optional next-update date, timestamp, or string.

- `source_references`:

  A
  [TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  card or list of cards, not retrieved
  [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md)
  objects. A single card becomes a one-element list.

## Methods

### Public methods

- [`TosiMetadata$new()`](#method-TosiMetadata-initialize)

- [`TosiMetadata$as_list()`](#method-TosiMetadata-as_list)

- [`TosiMetadata$clone()`](#method-TosiMetadata-clone)

------------------------------------------------------------------------

### `TosiMetadata$new()`

Construct a single-language object metadata result.

#### Usage

    TosiMetadata$new(
      connector_id,
      object_id,
      data_version,
      lang,
      title,
      source_label,
      source_object_id = NULL,
      description = NULL,
      subject_area = NULL,
      next_update = NULL,
      source_references = list()
    )

#### Arguments

- `connector_id`:

  Scalar canonical connector ID.

- `object_id`:

  Scalar canonical object ID.

- `data_version`:

  Finite non-missing scalar `POSIXct` source version.

- `lang`:

  Natural-language code used by scalar labels.

- `title`:

  Human-facing object title.

- `source_label`:

  Human-facing source label.

- `source_object_id`:

  Optional source-native object identifier.

- `description`:

  Optional object description.

- `subject_area`:

  Optional subject-area label.

- `next_update`:

  Optional next-update date, timestamp, or string.

- `source_references`:

  Genuine compact `TosiSourceReference` card or list of cards.

#### Returns

A new `TosiMetadata` object.

------------------------------------------------------------------------

### `TosiMetadata$as_list()`

Return the metadata as a named list, with source-reference cards as
named lists.

#### Usage

    TosiMetadata$as_list()

#### Returns

A named list containing the metadata fields and source references.

------------------------------------------------------------------------

### `TosiMetadata$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiMetadata$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
