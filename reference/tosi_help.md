# Read connector help

List available help topics or retrieve a connector-help article. For
example, `tosi_help("tulli")` explains Uljas classifications, source
filters, and selection defaults.

## Usage

``` r
tosi_help(topic)
```

## Arguments

- topic:

  A help topic such as `"tulli"`; omit to list available topics.

## Value

A [TosiHelp](https://tosidata.github.io/tosi/reference/TosiHelp.md)
object containing English Markdown.

## See also

[remote_frontends](https://tosidata.github.io/tosi/reference/remote_frontends.md)
for retrieval and
[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
for table inspection.

## Examples

``` r
if (FALSE) { # \dontrun{
tosi_help()         # List available topics
tosi_help("tulli")  # Read connector instructions
} # }
```
