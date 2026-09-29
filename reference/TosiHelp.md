# Connector help article

[`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
returns a `TosiHelp` article with English Markdown instructions for a
connector, or the default help index. The six fields are read-only. Use
`$content` for the full text or `$as_list()` for a named list of fields.

`$format()` returns the unchanged Markdown. `$print()` writes the
complete Markdown to the terminal, retaining link destinations and
fenced examples. `$format("html")` returns HTML text using the optional
`commonmark` package. These methods never open a browser or Viewer and
never evaluate examples. Content uses ordinary Markdown headings, lists,
links and fenced code; raw HTML, scripts and executable document chunks
are outside this subset.

## Active bindings

- `connector_id`:

  Requested help topic (`"index"` for the default), or the connector
  identifier for connector help.

- `title`:

  Human-readable help title.

- `lang`:

  Help language, always `"en"`.

- `content_type`:

  Content media type, always `"text/markdown"`.

- `content`:

  Complete Markdown document.

- `core_version`:

  Producing core package version as a string.

## Methods

### Public methods

- [`TosiHelp$new()`](#method-TosiHelp-initialize)

- [`TosiHelp$as_list()`](#method-TosiHelp-as_list)

- [`TosiHelp$format()`](#method-TosiHelp-format)

- [`TosiHelp$print()`](#method-TosiHelp-print)

- [`TosiHelp$clone()`](#method-TosiHelp-clone)

------------------------------------------------------------------------

### `TosiHelp$new()`

Construct a help result without loading help resources.

#### Usage

    TosiHelp$new(connector_id, title, content, core_version)

#### Arguments

- `connector_id`:

  Requested topic (`"index"` for the default).

- `title`:

  Human-readable help title.

- `content`:

  Complete English Markdown document.

- `core_version`:

  Producing core package version as a string.

#### Returns

A new `TosiHelp` object.

------------------------------------------------------------------------

### `TosiHelp$as_list()`

Return the help fields as a named list.

#### Usage

    TosiHelp$as_list()

#### Returns

A named list containing the six help fields.

------------------------------------------------------------------------

### `TosiHelp$format()`

Return Markdown or convert it to HTML without evaluation.

#### Usage

    TosiHelp$format(format = c("markdown", "html"))

#### Arguments

- `format`:

  Output format: `"markdown"` (default) or `"html"`. HTML requires the
  optional `commonmark` package.

#### Returns

A single string containing Markdown or HTML text.

------------------------------------------------------------------------

### `TosiHelp$print()`

Print the complete Markdown without rendering or evaluation.

#### Usage

    TosiHelp$print(...)

#### Arguments

- `...`:

  Unused; printing always writes Markdown to the terminal.

#### Returns

The `TosiHelp` object, invisibly.

------------------------------------------------------------------------

### `TosiHelp$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiHelp$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.
