# Object paths

`object_path()` constructs a canonical object path. Supply a complete
path such as `"example_connector/example_table"` (syntax only), or
combine connector IDs and object IDs supplied separately. Each complete
path has exactly one `/` between a canonical
[`connector_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
and a canonical
[`object_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md).
This does not check whether the object exists; use
[`tosi_catalog()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
or
[`tosi_search()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
to find objects.

## Usage

``` r
object_path(x, object_id = NULL)
```

## Arguments

- x:

  Complete object paths, or connector IDs when `object_id` is supplied.

- object_id:

  `NULL`, or object IDs to combine with `x`.

## Value

A character-backed `tosi_object_path` vector.

## Details

When combining vectors, a single connector ID is repeated for each
object ID, or a single object ID for each connector ID. Otherwise the
vectors must have the same length. Missing values are rejected at
construction, but can arise through ordinary vector indexing.
