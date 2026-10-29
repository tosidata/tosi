# Source-backed description section

A read-only section contains plain source text, an optional source
heading and an optional language-independent semantic type.
[TosiMetadata](https://tosidata.github.io/tosi/reference/TosiMetadata.md)
contains an ordinary ordered list of sections and owns their language
and complete text extraction through `$description_text()`. No
classification, translation or source retrieval is performed.

Types form an extensible vocabulary, not a closed enumeration.
Conventions are `description` for an explicit general description,
`interpretation` for source guidance, `limitations` for source cautions,
and `notes` for other explanatory notices. Use a type only when a source
field or heading supports it. Unfamiliar types are retained; `NULL`
means unclassified text and does not imply that interpretation or
limitations are absent. An unfamiliar heading may retain its title
without a type.

Fields reject direct and nested replacement. Section instances use
ordinary R6 reference semantics; metadata retains them without cloning.

## Active bindings

- `text`:

  Plain section text.

- `title`:

  Optional source heading.

- `type`:

  Optional language-independent semantic type.

## Methods

### Public methods

- [`TosiDescriptionSection$new()`](#method-TosiDescriptionSection-initialize)

- [`TosiDescriptionSection$as_list()`](#method-TosiDescriptionSection-as_list)

- [`TosiDescriptionSection$clone()`](#method-TosiDescriptionSection-clone)

------------------------------------------------------------------------

### `TosiDescriptionSection$new()`

Construct a source-backed description section.

#### Usage

    TosiDescriptionSection$new(text, title = NULL, type = NULL)

#### Arguments

- `text`:

  Plain section text.

- `title`:

  Optional source heading.

- `type`:

  Optional language-independent semantic type. No type is inferred.

#### Returns

A new `TosiDescriptionSection` object.

------------------------------------------------------------------------

### `TosiDescriptionSection$as_list()`

Project the section to ordinary R data.

#### Usage

    TosiDescriptionSection$as_list()

#### Returns

A named list containing text and any supplied title and type.

------------------------------------------------------------------------

### `TosiDescriptionSection$clone()`

The objects of this class are cloneable with this method.

#### Usage

    TosiDescriptionSection$clone(deep = FALSE)

#### Arguments

- `deep`:

  Whether to make a deep clone.

## Examples

``` r
section <- TosiDescriptionSection$new(
  "Survey estimates.", title = "Methods", type = "interpretation"
)
section$text
#> [1] "Survey estimates."
section$as_list()
#> $text
#> [1] "Survey estimates."
#> 
#> $title
#> [1] "Methods"
#> 
#> $type
#> [1] "interpretation"
#> 
```
