
<!-- README.md is generated from README.Rmd. Please edit that file -->

# arcgisplaces

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
<!-- badges: end -->

arcgisplaces is an R package to interface with [ArcGIS Places
Service](https://developers.arcgis.com/rest/places/).

> The places service is a ready-to-use location service that can search
> for businesses and geographic locations around the world. It allows
> you to find, locate, and discover detailed information about each
> place.

In order to use `{arcgisplaces}` you will need an ArcGIS Developers
account. [Get started
here.](https://developers.arcgis.com/documentation/mapping-apis-and-services/get-started/)

## Installation

You can install a binary of the development version of arcgisplaces from
[r-universe](https://r-arcgis.r-universe.dev/arcgisplaces) with:

``` r
install.packages("arcgisplaces", repos = "https://r-arcgis.r-universe.dev")
```

You will also need the development version of
[`{arcgisutils}`](https://github.com/R-ArcGIS/arcgisutils)

``` r
if (!requireNamespace("pak")) install.packages("pak")
pak::pak("r-arcgis/arcgisutils")
```

### Building from source

Or, you can install the development version from
[GitHub](https://github.com/r-arcgis/arcgisplaces). Note the development
version requires an installation of Rust. See
[rustup](https://rustup.rs/) for instructions to install Rust.

``` r
if (!requireNamespace("pak")) install.packages("pak")
pak::pak("r-arcgis/arcgisplaces")
```

## Usage

Finding places:

- `near_point()`: search for places near a location.
- `within_extent()`: search for places within an extent.
- `place_details()`: get detailed information about the places returned
  from `near_point()` or `within_extent()`.
  - Note: see `fields` for the possible attributes to return for place
    details.

Understanding categories:

- `categories()`: find categories by name or ID.

- `category_details()`: get detailed information about the categories
  returned from `categories()`.

- Find place attributes such as name, address, description, opening
  hours, price ratings, user ratings, and social links.

## Examples

`{arcgisutils}` is needed for authentication. The Places API supports
either using an API key via `auth_key()` or one generated via OAuth2
using either `auth_client()` or `auth_code()`. See the [Places API
documentation](https://developers.arcgis.com/rest/places/#authentication)
for more.

``` r
library(arcgisutils)
library(arcgisplaces)

# Authenticate with a Developer Account API Key
token <- auth_key()
set_arc_token(token)
```

## Place search

You can **search for places near a location** with `near_point()`.

``` r
coffee <- near_point(x = -122.334, y = 47.655, search_text = "Coffee")
coffee
#> Simple feature collection with 8 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -122.3426 ymin: 47.65539 xmax: -122.3255 ymax: 47.66175
#> Geodetic CRS:  WGS 84
#> # A data frame: 8 × 6
#>   place_id             name  distance categories icon              geometry
#> * <chr>                <chr>    <dbl> <I<list>>  <chr>          <POINT [°]>
#> 1 f6059fc575735b5e3f5… Irwi…      97  <df>       <NA>  (-122.3328 47.65539)
#> 2 88a10ccf031f02ef269… Fuel…     724. <df>       <NA>  (-122.3369 47.66122)
#> 3 5cc2d40bf37bff28738… Youn…     728. <df>       <NA>  (-122.3331 47.66152)
#> 4 a8c6da1aa0d08fe96e5… Frid…     741. <df>       <NA>   (-122.342 47.65895)
#> 5 906da2fe5164619199a… Star…     767. <df>       <NA>  (-122.3361 47.66175)
#> 6 957c39de6e0a0eb8afe… Mosa…     774  <df>       <NA>  (-122.3276 47.66048)
#> 7 4bdfa82268e67a698d0… A Mu…     964. <df>       <NA>  (-122.3255 47.66149)
#> 8 090286b411e3337850e… The …     976. <df>       <NA>  (-122.3426 47.66162)
```

Locations are returned as an sf object with the place ID, the place
name, distance from the search point, a character vector of categories.

<div class="callout-tip">

`arcgisplaces` will return an sf object, but the sf package is not
required to work with the package. The `sf` print method will not be
used unless the package is loaded. If package size is a
consideration—i.e. deploying an app in a Docker container—consider using
`wk` or `rsgeo`.

</div>

Details for the places can be fetched using `place_details()`. The
possible fields are [documented
online](https://developers.arcgis.com/rest/places/place-id-get/#requestedfields)
as well as contained in the exported vector `fields`. Because pricing is
dependent upon which fields are requested, it is a required argument.

To get the add `requested_fields = "hours"`. Note, that the other
possible fields will still be present in the result, but completely
empty.

``` r
details <- place_details(
  coffee$place_id,
  requested_fields = "rating",
  .progress = FALSE # remove progress bar
)

details[c("price", "user")]
#> Simple feature collection with 8 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: Inf ymin: Inf xmax: -Inf ymax: -Inf
#> Geodetic CRS:  WGS 84
#> # A data frame: 8 × 3
#>   price     user    location
#> * <chr>    <dbl> <POINT [°]>
#> 1 Cheap      4.1       EMPTY
#> 2 Cheap      3.9       EMPTY
#> 3 <NA>      NA         EMPTY
#> 4 Moderate  NA         EMPTY
#> 5 Cheap      3.4       EMPTY
#> 6 Cheap      3         EMPTY
#> 7 Cheap      4         EMPTY
#> 8 <NA>      NA         EMPTY
```

Or, you can search for places within a bounding box using
`within_extent()`. This could be quite handy for searching within
current map bounds, for example.

``` r
bakeries <- within_extent(
  -70.356, 43.588, -70.176, 43.7182,
  category_id = "13002"
)

bakeries[c("name")]
#> Simple feature collection with 24 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -70.356 ymin: 43.588 xmax: -70.176 ymax: 43.7182
#> Geodetic CRS:  WGS 84
#> # A data frame: 24 × 2
#>    name                                geometry
#>  * <chr>                            <POINT [°]>
#>  1 Panera Bread            (-70.32966 43.67791)
#>  2 Crumbl Cookies          (-70.33067 43.67675)
#>  3 Electric Bike Cafe       (-70.2864 43.63655)
#>  4 BenReuben’s Knishery    (-70.25299 43.63748)
#>  5 Two Fat Cats Bakery      (-70.26101 43.6327)
#>  6 Auntie Anne's           (-70.33517 43.63372)
#>  7 Lolli and Pops          (-70.33512 43.63377)
#>  8 Panera Bread              (-70.3303 43.6367)
#>  9 Cookie Jar Pastry Shop  (-70.22644 43.63367)
#> 10 Bake Maine Pottery Cafe (-70.25334 43.66708)
#> # ℹ 14 more rows
```
