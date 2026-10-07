# Clear cached table results

Reset both the memory and disk caches in the current R session. The next
matching
[`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
or
[`tosi_data()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
call makes a new service request. See
[`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
for cache size settings and lifetime limitations.

## Usage

``` r
tosi_cache_clear()
```

## Value

Invisible `NULL`.

## Examples

``` r
tosi_cache_clear()
```
