# Retrieved source document

Supported
[`tosi_source_reference()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
calls return a `TosiSourceDocument` containing a document's text,
language, title, and source details. Unlike the compact
[TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
cards, this object contains the document body in `$content`. Fields are
read-only; direct and nested replacement fails. `$format()` and
`$print()` show a summary without the body.

## Active bindings

- `uri`:

  Single HTTP(S) or platform source-reference URI.

- `title`:

  Single human-readable document title.

- `relationship`:

  Relationship between the source object and document.

- `lang`:

  Natural-language code for the resolved document.

- `available_languages`:

  Available natural-language document codes.

- `content`:

  Resolved textual document body.

- `content_type`:

  Media type of the resolved document body.

- `source`:

  Optional human-readable source label.

## Methods

### Public methods

- [`TosiSourceDocument$new()`](#method-TosiSourceDocument-initialize)

- [`TosiSourceDocument$as_list()`](#method-TosiSourceDocument-as_list)

- [`TosiSourceDocument$format()`](#method-TosiSourceDocument-format)

- [`TosiSourceDocument$print()`](#method-TosiSourceDocument-print)

- [`TosiSourceDocument$clone()`](#method-TosiSourceDocument-clone)

------------------------------------------------------------------------

### `TosiSourceDocument$new()`

Construct a resolved source-document result.

#### Usage

    TosiSourceDocument$new(
      uri,
      title,
      relationship,
      lang,
      available_languages,
      content,
      content_type,
      source
    )

#### Arguments

- `uri`:

  Single HTTP(S) or platform source-reference URI.

- `title`:

  Single human-readable document title.

- `relationship`:

  Relationship between the source object and document.

- `lang`:

  Natural-language code for the resolved document.

- `available_languages`:

  Available natural-language document codes.

- `content`:

  Resolved textual document body.

- `content_type`:

  Media type of the resolved document body.

- `source`:

  Optional human-readable source label.

#### Returns

A new `TosiSourceDocument` object.

------------------------------------------------------------------------

### `TosiSourceDocument$as_list()`

Return the document fields, including the body, as a named list.

#### Usage

    TosiSourceDocument$as_list()

#### Returns

A named list containing the document fields.

------------------------------------------------------------------------

### `TosiSourceDocument$format()`

Format a concise document summary without the document body.

#### Usage

    TosiSourceDocument$format(...)

#### Arguments

- `...`:

  Reserved for future formatting options; currently ignored.

#### Returns

A character vector containing the document summary.

------------------------------------------------------------------------

### `TosiSourceDocument$print()`

Print the concise document summary without the document body.

#### Usage

    TosiSourceDocument$print(...)

#### Arguments

- `...`:

  Arguments passed to `$format()`.

#### Returns

The `TosiSourceDocument` object, invisibly.

------------------------------------------------------------------------

### `TosiSourceDocument$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiSourceDocument$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
