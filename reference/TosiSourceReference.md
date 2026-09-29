# Source-reference card

`TosiSourceReference` is a compact card for a source document, included
in
[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
and
[`tosi_index_document()`](https://tosidata.github.io/tosi/reference/tosi_index_document.md)
results. It holds a labelled URI and optional description, not the
document body. To retrieve a supported reference's text, use
[`tosi_source_reference()`](https://tosidata.github.io/tosi/reference/remote_frontends.md),
which returns a
[TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md).
Fields are read-only; direct and nested replacement fails.

## Active bindings

- `uri`:

  Single HTTP(S) or platform source-reference URI.

- `title`:

  Single human-readable label.

- `relationship`:

  Relationship between the source object and reference.

- `lang`:

  Optional natural-language code for the label card.

- `description`:

  Optional short description.

## Methods

### Public methods

- [`TosiSourceReference$new()`](#method-TosiSourceReference-initialize)

- [`TosiSourceReference$as_list()`](#method-TosiSourceReference-as_list)

- [`TosiSourceReference$format()`](#method-TosiSourceReference-format)

- [`TosiSourceReference$print()`](#method-TosiSourceReference-print)

- [`TosiSourceReference$clone()`](#method-TosiSourceReference-clone)

------------------------------------------------------------------------

### `TosiSourceReference$new()`

Construct a compact source-reference card.

#### Usage

    TosiSourceReference$new(
      uri,
      title,
      relationship,
      lang = NULL,
      description = NULL
    )

#### Arguments

- `uri`:

  Single HTTP(S) or platform source-reference URI.

- `title`:

  Single human-readable label.

- `relationship`:

  Relationship between the source object and reference.

- `lang`:

  Optional natural-language code for the label card.

- `description`:

  Optional short description.

#### Returns

A new `TosiSourceReference` object.

------------------------------------------------------------------------

### `TosiSourceReference$as_list()`

Return the card fields as a named list.

#### Usage

    TosiSourceReference$as_list()

#### Returns

A named list containing the card fields.

------------------------------------------------------------------------

### `TosiSourceReference$format()`

Format a concise card summary.

#### Usage

    TosiSourceReference$format(...)

#### Arguments

- `...`:

  Reserved for future formatting options; currently ignored.

#### Returns

A character vector containing the card summary.

------------------------------------------------------------------------

### `TosiSourceReference$print()`

Print the concise card summary.

#### Usage

    TosiSourceReference$print(...)

#### Arguments

- `...`:

  Arguments passed to `$format()`.

#### Returns

The `TosiSourceReference` object, invisibly.

------------------------------------------------------------------------

### `TosiSourceReference$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiSourceReference$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
