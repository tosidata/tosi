# Read or set provenance

`provenance(x)` reads the
[TosiProvenance](https://tosidata.github.io/tosi/reference/TosiProvenance.md)
history attached to `x`, or `NULL` if there is none. The returned object
is live: modifying it changes the carrier's history. A non-`NULL` stored
value must be a genuine
[TosiProvenance](https://tosidata.github.io/tosi/reference/TosiProvenance.md)
object.

## Usage

``` r
provenance(x, ...)

# S3 method for class 'tosi_table'
provenance(x, ...)

# S3 method for class 'R6'
provenance(x, ...)

# Default S3 method
provenance(x, ...)

provenance(x) <- value

# S3 method for class 'tosi_table'
provenance(x) <- value

# S3 method for class 'R6'
provenance(x) <- value

# Default S3 method
provenance(x) <- value
```

## Arguments

- x:

  A non-`NULL` object carrying provenance; ordinary objects must support
  attributes, and R6 objects use their `provenance` member.

- ...:

  Ignored; passed to methods.

- value:

  A genuine
  [TosiProvenance](https://tosidata.github.io/tosi/reference/TosiProvenance.md)
  object, or `NULL` if the carrier permits clearing provenance.

## Value

`provenance(x)` returns the live carrier-owned
[TosiProvenance](https://tosidata.github.io/tosi/reference/TosiProvenance.md)
object or `NULL`. The replacement form returns the updated carrier; R6
carriers are also mutated by reference.

## Details

`provenance(x) <- value` attaches a deep copy of `value`, so subsequent
changes to the original do not change the attached history. Assign
`NULL` to clear provenance when the carrier permits it.

By default, non-R6 objects that support attributes store provenance in
`attr(x, "provenance")`, including `tosi_table` objects. R6 objects read
and write `x$provenance` through a field or active binding and are
changed by reference. An absent, locked, or read-only R6 member follows
the carrier's own rules; some carriers do not permit clearing. `NULL`
cannot be used as a carrier.
