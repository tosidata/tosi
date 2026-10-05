# Construct discovery result tables

These technical constructors attach a result-kind marker class to an
ordinary tibble. The resulting connector catalogs, dataset catalogs, and
search results retain ordinary tibble dimensions, truncation, and
subsetting while printing a concise identifying header. Empty dataset
catalogs and search results print guidance instead of an empty table.

## Usage

``` r
new_tosi_connector_catalog(x)

new_tosi_dataset_catalog(x)

new_tosi_search_results(x)
```

## Arguments

- x:

  A tibble-like discovery result.

## Value

`x` as an ordinary tibble with its discovery result marker class.
