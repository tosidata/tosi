# Generate physical column names

Converts ordered schema components to physical column names. `"labels"`
uses component labels, `"safe_labels"` converts those labels to safe
IDs, and `"ids"` uses canonical component IDs. Label modes repair
collisions against canonical Time and Value names and fixed output names
supplied in `reserved_names`.

## Usage

``` r
physical_column_names(components, col_mode, reserved_names = character())
```

## Arguments

- components:

  Ordered list of schema components with `id`, `label`, and `role`
  fields.

- col_mode:

  One of `"labels"`, `"safe_labels"`, or `"ids"`.

- reserved_names:

  Physical output names owned by fixed columns. These names are
  protected from collisions in label modes.

## Value

Ordered character vector of physical column names.

## Details

This materialization boundary trusts constructor-created components and
does not revalidate their schema facts. Language selection is not part
of this interface. Callers producing code-valued data supply components
with the source-selected natural-language presentation in their labels.
