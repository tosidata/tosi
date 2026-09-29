# tosi

TosiData makes open data easy to find and use in research, analysis, and
reporting. The `tosi` R package lets you retrieve data from multiple
sources in a consistent format and refresh your analysis as new figures
become available.

- **Data from many sources.** Access Eurostat, OECD, the ECB, FRED, and
  national statistical offices through the same simple commands.
- **Ready for analysis.** Get consistently formatted tables you can use
  directly with dplyr, ggplot2, and other R tools.
- **Designed to save time.** Retrieve data quickly using source IDs or
  URLs, through the same simple interface.
- **Keep your analysis up to date.** Automatically refresh your results,
  charts, and reports with new data when you rerun your code.
- **High-fidelity data.** Data stays faithful to its source, retaining
  the labels, metadata, and version information you need to interpret
  and verify it.

## How it works

[`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
is a multipurpose helper for browsing sources, finding tables, and
retrieving data.

### List connectors:

``` r

library(tosi)
tosi()
#> # Connector catalog: 27 × 6
#>   id        name           description source languages aggregation_options
#>   <tosicid> <chr>          <chr>       <chr>  <list>    <lgl>              
#> 1 eurostat  Eurostat       Statistica… Euros… <chr [3]> FALSE              
#> 2 oecd      OECD Data Exp… Statistica… OECD   <chr [1]> FALSE              
#> 3 ec        European Comm… Statistica… Europ… <chr [1]> FALSE              
#> 4 ecb       ECB Statistic… Statistica… Europ… <chr [1]> FALSE              
#> 5 fred      Federal Reser… Complete c… Feder… <chr [1]> FALSE              
#> # ℹ 22 more rows
```

### List tables provided by a connector:

``` r

tosi("eurostat")  # alternatively: tosi_catalog("eurostat")
#> # Dataset catalog: 7,603 × 4
#>   object_path           title                          object_type language
#>   <tosipath>            <chr>                          <chr>       <chr>   
#> 1 eurostat/lfsq_epgais  Persons in full-time/part-tim… series      en      
#> 2 eurostat/lfsq_epgan2  Persons in full-time/part-tim… series      en      
#> 3 eurostat/lfsq_epgan21 Persons in full-time/part-tim… series      en      
#> 4 eurostat/lfsq_epgana  Persons in full-time/part-tim… series      en      
#> 5 eurostat/lfsq_eppga   Persons in part-time employme… series      en      
#> # ℹ 7,598 more rows
```

### Retrieve data:

``` r

tosi("eurostat/tps00001") # Alternatively: tosi_data("eurostat/tps00001")
#> # tosi_table:   eurostat/tps00001
#> # title:        Population on 1 January
#> # source:       Eurostat
#> # data_version: 2026-07-21 21:00:00 UTC
#> # A tibble:     624 × 9
#>   `Time frequency` `Demographic indicator`     Geopolitical entity …¹ Time 
#>   <chr>            <chr>                       <chr>                  <chr>
#> 1 Annual           Population on 1 January - … Andorra                2015 
#> 2 Annual           Population on 1 January - … Andorra                2016 
#> 3 Annual           Population on 1 January - … Andorra                2017 
#> 4 Annual           Population on 1 January - … Andorra                2018 
#> 5 Annual           Population on 1 January - … Andorra                2019 
#> # ℹ 619 more rows
#> # ℹ abbreviated name: ¹​`Geopolitical entity (reporting)`
#> # ℹ 5 more variables: freq <freq>, time <date>, value <dbl>,
#> #   `Observation status (Flag) V2 structure` <chr>,
#> #   `Confidentiality status (flag)` <chr>
```

### Search for tables:

``` r

tosi("internet use") # Alternatively: tosi_search("internet use")
#> # Search results: 42 × 4
#>   object_path       title                              object_type language
#>   <tosipath>        <chr>                              <chr>       <chr>   
#> 1 eurostat/tgs00047 Households that have internet acc… series      en      
#> 2 eurostat/tgs00052 Individuals who ordered goods or … series      en      
#> 3 eurostat/tin00028 Internet use by individuals        series      en      
#> 4 eurostat/tin00093 Individuals who have never used t… series      en      
#> 5 eurostat/tin00134 Level of internet access - househ… series      en      
#> # ℹ 37 more rows
```

### Inspect a table’s version and structure:

``` r

path <- "eurostat/tps00001"
tosi_data_version(path)
tosi_schema(path)
```

## Install

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("tosidata/tosi")
```

## Configure

TosiData is currently available by invitation. To discuss access for
your organization, contact <contact@tosidata.com>.

Connect using your service URL and access token:

``` r

tosi_options(
  url = "https://service.example.invalid",
  token = "<your-access-token>"
)
```

For additional settings, see
[`?tosi_options`](https://tosidata.github.io/tosi/reference/tosi_options.md).

## Learn more

For arguments and result details, see the
[`tosi()`](https://tosidata.github.io/tosi/reference/remote_frontends.md)
function reference. For questions or problems, use the [issue
tracker](https://github.com/tosidata/tosi/issues).
