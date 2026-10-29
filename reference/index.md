# Package index

## Find and retrieve tables

- [`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  [`tosi_data()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  [`tosi_catalog()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  [`tosi_search()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  [`tosi_url()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  [`tosi_source_reference()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
  : Find and retrieve tables

- [`tosi_help()`](https://tosidata.github.io/tosi/reference/tosi_help.md)
  : Read connector help

- [`tosi_options()`](https://tosidata.github.io/tosi/reference/tosi_options.md)
  :

  Configure your `tosi` options

- [`tosi_cache_clear()`](https://tosidata.github.io/tosi/reference/tosi_cache_clear.md)
  : Clear cached table results

## Inspect table metadata and structure

- [`tosi_schema()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
  [`tosi_metadata()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
  [`tosi_aggregation_options()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
  [`tosi_data_version()`](https://tosidata.github.io/tosi/reference/tosi_metadata.md)
  : Inspect table metadata and options

## Work with tables and provenance

- [`is_tosi_table()`](https://tosidata.github.io/tosi/reference/tosi_table.md)
  [`as_tibble(`*`<tosi_table>`*`)`](https://tosidata.github.io/tosi/reference/tosi_table.md)
  : Retrieved tables
- [`provenance()`](https://tosidata.github.io/tosi/reference/provenance.md)
  [`` `provenance<-`() ``](https://tosidata.github.io/tosi/reference/provenance.md)
  : Read or set provenance

## Response objects

- [`TosiHelp`](https://tosidata.github.io/tosi/reference/TosiHelp.md) :
  Connector help article
- [`TosiMetadata`](https://tosidata.github.io/tosi/reference/TosiMetadata.md)
  : Descriptive metadata
- [`TosiDescriptionSection`](https://tosidata.github.io/tosi/reference/TosiDescriptionSection.md)
  : Source-backed description section
- [`TosiSchema`](https://tosidata.github.io/tosi/reference/TosiSchema.md)
  : Source-bound table structure
- [`TosiStructure`](https://tosidata.github.io/tosi/reference/TosiStructure.md)
  : Source-independent table structure
- [`TosiProvenance`](https://tosidata.github.io/tosi/reference/TosiProvenance.md)
  : Provenance history
- [`TosiSourceReference`](https://tosidata.github.io/tosi/reference/TosiSourceReference.md)
  : Source-reference card
- [`TosiSourceDocument`](https://tosidata.github.io/tosi/reference/TosiSourceDocument.md)
  : Retrieved source document

## Identifiers, frequencies and time ranges

- [`validate_connector_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  [`validate_object_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  [`connector_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  [`object_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  [`is_connector_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  [`is_object_id()`](https://tosidata.github.io/tosi/reference/id-vectors.md)
  : Connector and object IDs
- [`object_path()`](https://tosidata.github.io/tosi/reference/object_path.md)
  : Object paths
- [`new_frequency_code()`](https://tosidata.github.io/tosi/reference/frequency_code.md)
  [`frequency_code()`](https://tosidata.github.io/tosi/reference/frequency_code.md)
  [`is_frequency_code()`](https://tosidata.github.io/tosi/reference/frequency_code.md)
  : Canonical frequency-code vectors
- [`time_range()`](https://tosidata.github.io/tosi/reference/time_range.md)
  [`as_time_range()`](https://tosidata.github.io/tosi/reference/time_range.md)
  : Frequency-bearing reference-period bounds
