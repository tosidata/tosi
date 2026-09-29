# Search-index document

[`tosi_index_document()`](https://tosidata.github.io/tosi/reference/tosi_index_document.md)
returns a `TosiIndexDocument` for indexing an object in search. It
includes identity, language-specific metadata, a schema summary, value
domains, coverage, and source-reference cards. Metadata and schema
sections are named lists, not
[TosiMetadata](https://tosidata.github.io/tosi/reference/TosiMetadata.md)
or [TosiSchema](https://tosidata.github.io/tosi/reference/TosiSchema.md)
objects. Fields are read-only; direct and nested replacement fails.

## Active bindings

- `document_type`:

  Fixed index-document type.

- `schema_version`:

  Index-document contract version.

- `generated_at`:

  Finite non-missing scalar `POSIXct` generation time.

- `connector_id`:

  Canonical connector identity.

- `object_id`:

  Canonical object identity.

- `object_type`:

  Object type: `"table"`, `"series"`, or `"list"`.

- `source_object_id`:

  Optional source-native object identifier.

- `data_version`:

  Finite non-missing scalar `POSIXct` source version.

- `languages`:

  Natural languages represented in the document.

- `metadata`:

  Language-keyed metadata entries.

- `schema`:

  Schema summary as a named list.

- `value_domains`:

  Language-keyed source-dimension value domains.

- `coverage`:

  Coverage summary.

- `source_references`:

  List of compact
  [TosiSourceReference](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  cards, not retrieved
  [TosiSourceDocument](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md)
  objects.

- `extensions`:

  Named connector-specific index extensions.

## Methods

### Public methods

- [`TosiIndexDocument$new()`](#method-TosiIndexDocument-initialize)

- [`TosiIndexDocument$identity()`](#method-TosiIndexDocument-identity)

- [`TosiIndexDocument$as_list()`](#method-TosiIndexDocument-as_list)

- [`TosiIndexDocument$format()`](#method-TosiIndexDocument-format)

- [`TosiIndexDocument$print()`](#method-TosiIndexDocument-print)

- [`TosiIndexDocument$clone()`](#method-TosiIndexDocument-clone)

------------------------------------------------------------------------

### `TosiIndexDocument$new()`

Construct a normalized search-index document.

#### Usage

    TosiIndexDocument$new(
      identity,
      languages,
      metadata,
      schema,
      value_domains,
      coverage,
      source_references = list(),
      extensions = list()
    )

#### Arguments

- `identity`:

  Named list containing `connector_id`, `object_id`, `object_type`, and
  `data_version`, with optional `source_object_id`.

- `languages`:

  Natural-language codes represented in normalized sections.

- `metadata`:

  Language-keyed normalized metadata entries.

- `schema`:

  Portable normalized schema summary.

- `value_domains`:

  Language-keyed source-dimension value domains.

- `coverage`:

  Connector-supplied coverage summary.

- `source_references`:

  List of genuine live compact `TosiSourceReference` cards.

- `extensions`:

  Named list of connector-specific index extensions.

#### Returns

A new `TosiIndexDocument` object.

------------------------------------------------------------------------

### `TosiIndexDocument$identity()`

Return the document's object identity as a named list.

#### Usage

    TosiIndexDocument$identity()

#### Returns

A named list containing `connector_id`, `object_id`, `object_type`, and
`data_version`, plus `source_object_id` when present.

------------------------------------------------------------------------

### `TosiIndexDocument$as_list()`

Return the index document as a named list. Source-reference cards are
included as named lists rather than R6 objects.

#### Usage

    TosiIndexDocument$as_list()

#### Returns

A named list containing the index sections.

------------------------------------------------------------------------

### `TosiIndexDocument$format()`

Format a concise index-document summary.

#### Usage

    TosiIndexDocument$format(...)

#### Arguments

- `...`:

  Reserved for future formatting options; currently ignored.

#### Returns

A character vector containing the index-document summary.

------------------------------------------------------------------------

### `TosiIndexDocument$print()`

Print the concise index-document summary.

#### Usage

    TosiIndexDocument$print(...)

#### Arguments

- `...`:

  Arguments passed to `$format()`.

#### Returns

The `TosiIndexDocument` object, invisibly.

------------------------------------------------------------------------

### `TosiIndexDocument$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiIndexDocument$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
