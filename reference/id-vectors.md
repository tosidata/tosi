# Connector and object IDs

A connector ID names a data source's connector; an object ID names an
object within that connector. `connector_id()` and `object_id()` create
vectors of these IDs or extract the corresponding component from an
[`object_path()`](https://tosidata.github.io/tosi/reference/object_path.md).
They validate IDs exactly, without changing query strings. Each ID must
start with an ASCII letter, followed by zero or more ASCII letters,
digits, or underscores: `^[A-Za-z][A-Za-z0-9_]*$`. Missing IDs are not
accepted when constructing or validating IDs.

## Usage

``` r
validate_connector_id(x, arg = caller_arg(x), call = caller_env())

validate_object_id(x, arg = caller_arg(x), call = caller_env())

connector_id(x)

object_id(x)

is_connector_id(x)

is_object_id(x)
```

## Arguments

- x:

  IDs to construct or validate, an object path to extract from, or any
  object for the predicates. Constructors coerce to character and
  validate each ID.

- arg:

  Argument name used for validator error reporting.

- call:

  Calling environment used for validator error reporting.

## Value

`connector_id()` and `object_id()` return character-backed ID vectors.
`is_connector_id()` and `is_object_id()` return `TRUE` or `FALSE`.
`validate_connector_id()` and `validate_object_id()` return the input
invisibly.
