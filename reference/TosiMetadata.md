# Descriptive metadata

[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
returns a `TosiMetadata` containing the title, source, language,
version, and optional description and source-reference cards. Fields are
read-only; direct and nested replacement fails. `$description_text()`
derives complete source text, including headings, in section order.
`$as_list()` recursively projects sections and compact reference cards
to ordinary lists. `$format()` and `$print()` show a compact summary.
Set `details = TRUE` to include the complete source description and
compact reference cards, without retrieving the referenced documents.

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

  Ordinary ordered list of
  [TosiDescriptionSection](https://tosidata.github.io/tosi/reference/TosiDescriptionSection.md)
  objects; empty when absent. Existing instances are retained without
  cloning.

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

- [`TosiMetadata$description_text()`](#method-TosiMetadata-description_text)

- [`TosiMetadata$format()`](#method-TosiMetadata-format)

- [`TosiMetadata$print()`](#method-TosiMetadata-print)

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

  `NULL`, plain scalar text, one
  [TosiDescriptionSection](https://tosidata.github.io/tosi/reference/TosiDescriptionSection.md),
  or an ordinary ordered list of section instances. `NULL` becomes an
  empty list; text becomes one unclassified section; a single section
  becomes a one-element list. Collections omit `NULL` entries and retain
  section instances and order. No headings or types are inferred from
  prose.

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

Return the metadata as a named list, recursively projecting description
sections and source-reference cards to named lists.

#### Usage

    TosiMetadata$as_list()

#### Returns

A named list containing ordinary metadata, sections and cards.

------------------------------------------------------------------------

### `TosiMetadata$description_text()`

Extract all source text and supplied headings in section order, without
retrieval, translation or classification.

#### Usage

    TosiMetadata$description_text()

#### Returns

A scalar character string; `""` when no sections are present.

------------------------------------------------------------------------

### `TosiMetadata$format()`

Format a compact summary or include the complete source description and
compact reference cards. Description headings and section order are
preserved.

#### Usage

    TosiMetadata$format(details = FALSE)

#### Arguments

- `details`:

  Include description sections and reference cards.

#### Returns

A character vector of display lines.

------------------------------------------------------------------------

### `TosiMetadata$print()`

Print the formatted metadata without retrieving referenced documents.

#### Usage

    TosiMetadata$print(...)

#### Arguments

- `...`:

  Arguments passed to `$format()`.

#### Returns

The metadata object, invisibly.

------------------------------------------------------------------------

### `TosiMetadata$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiMetadata$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
