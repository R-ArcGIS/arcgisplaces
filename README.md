
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
install.packages("arcgisgeocode", repos = "https://r-arcgis.r-universe.dev")
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
if (requireNamespace("pak")) install.packages("pak")
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

`arcgisutils` is needed for authentication. The Places API supports
either using an API key via `auth_key()` or one generated via OAuth2
using either `auth_client()` or `auth_code()`. See [API
documentation](https://developers.arcgis.com/rest/places/#authentication)
for more.

``` r
library(arcgisutils)
#> 
#> Attaching package: 'arcgisutils'
#> The following object is masked from 'package:base':
#> 
#>     %||%
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
#> Simple feature collection with 6 features and 5 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -1122.334 ymin: -952.345 xmax: 877.666 ymax: 1047.655
#> Geodetic CRS:  WGS 84
#>                           place_id                                 name
#> 1 f6059fc575735b5e3f558c96ab69e6f6 Irwin's Neighborhood Bakery and Cafe
#> 2 88a10ccf031f02ef2697591f72e1e169                          Fuel Coffee
#> 3 a8c6da1aa0d08fe96e5d80d0f3b3de03                     Friday Afternoon
#> 4 906da2fe5164619199a2f2ba9c99a650                            Starbucks
#> 5 d49bac9ae79ebfc88dc2c070ad0ee91c                    HHD Heuk Hwa Dang
#> 6 4bdfa82268e67a698d0b8ea3d2df3853                          A Muddy Cup
#>   distance   categories icon                   geometry
#> 1     97.0 c("13002.... <NA> POINT (-122.3328 47.65539)
#> 2    723.8 c("13035.... <NA> POINT (-122.3369 47.66122)
#> 3    740.8 c("13036.... <NA>  POINT (-122.342 47.65895)
#> 4    767.3 13035, C.... <NA> POINT (-122.3361 47.66175)
#> 5    964.1 13033, B.... <NA> POINT (-122.3425 47.66153)
#> 6    964.2 c("13035.... <NA> POINT (-122.3255 47.66149)
```

Locations are returned as an sf object with the place ID, the place
name, distance from the search point, a character vector of categories.

> [!TIP]
>
> `arcgisplaces` will return an sf object, but the sf package is not
> required to work with the package. The `sf` print method will not be
> used unless the package is loaded. If package size is a
> consideration—i.e. deploying an app in a Docker container—consider
> using `wk` or `rsgeo`.

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
#> Simple feature collection with 6 features and 2 fields
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: Inf ymin: Inf xmax: -Inf ymax: -Inf
#> Geodetic CRS:  WGS 84
#>      price user    location
#> 1    Cheap  4.0 POINT EMPTY
#> 2    Cheap  3.9 POINT EMPTY
#> 3 Moderate   NA POINT EMPTY
#> 4    Cheap  3.4 POINT EMPTY
#> 5     <NA>   NA POINT EMPTY
#> 6    Cheap  3.9 POINT EMPTY
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
#> Simple feature collection with 29 features and 1 field
#> Geometry type: POINT
#> Dimension:     XY
#> Bounding box:  xmin: -70.356 ymin: 43.588 xmax: -70.176 ymax: 43.7182
#> Geodetic CRS:  WGS 84
#> First 10 features:
#>                       name                   geometry
#> 1           Crumbl Cookies POINT (-70.33067 43.67675)
#> 2       Electric Bike Cafe  POINT (-70.2864 43.63655)
#> 3  Gross Confection Bakery POINT (-70.25428 43.65763)
#> 4           Dina’s Cuisine POINT (-70.28725 43.67695)
#> 5           Lolli and Pops POINT (-70.33512 43.63377)
#> 6    C Salt Gourmet Market  POINT (-70.2271 43.59174)
#> 7          Bread & Friends POINT (-70.25693 43.65514)
#> 8     BenReuben’s Knishery POINT (-70.25299 43.63748)
#> 9        Katie Made Bakery POINT (-70.24992 43.66449)
#> 10           Cinnamon Girl POINT (-70.27412 43.68086)
```
