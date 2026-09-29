# Get a document for search indexing

Retrieve a table's metadata and structure as a search-index document.
Unlike other result endpoints, this endpoint supports multiple result
languages in one request.

## Usage

``` r
tosi_index_document(path, lang = NULL)
```

## Arguments

- path:

  A data path beginning with a connector ID and `/`, followed by a
  canonical object ID or a supported source identifier or path. Object
  paths returned by catalogs and searches can be used directly.

  For StatFin (PX), `"statfin/vaenn/14x2.px"` identifies a source table
  whose canonical object path is `"statfin/vaenn_14x2_px"`. For ECB,
  `"ecb/FM.B.U2.EUR.4F.KR.MLFR.LEV"` selects a series from `"ecb/FM"`;
  the part after `"FM."` is interpreted as `source_filter`.

- lang:

  Optional character vector of result languages for the index document.
  A non-`NULL` value overrides the session preference.

## Value

A
[TosiIndexDocument](https://tosidata.github.io/tosi/reference/TosiIndexDocument.md)
object.

## See also

[`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
for table descriptions and schemas, and
[remote_frontends](https://tosidata.github.io/tosi/reference/remote_frontends.md)
for retrieval.

## Examples

``` r
if (FALSE) { # \dontrun{
tosi_index_document("statfin/vaenn_14x2_px", lang = c("fi", "en"))
} # }
```
