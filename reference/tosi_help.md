# Read connector help

Start with `tosi_help()` for the service's help index. Not every
connector has a help topic. For example, the `"tulli"` topic explains
Uljas classifications, source filters, and selection defaults.

## Usage

``` r
tosi_help(topic = NULL)
```

## Arguments

- topic:

  A help topic from the index, such as `"tulli"`. Omit it or use
  `"index"` to read the index.

## Value

A [TosiHelp](https://tosidata.github.io/tosi/reference/TosiHelp.md)
object containing English Markdown. Use
[`print()`](https://rdrr.io/r/base/print.html) to display it in a script
or `$content` to access the text.

## See also

[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
for connection setup,
[`tosi_data()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
for retrieval, and
[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
for table inspection.

## Examples

``` r
if (FALSE) { # \dontrun{
# After setting up a trusted connection (see ?tosi_options):
print(tosi_help())
print(tosi_help("tulli"))
} # }
```
