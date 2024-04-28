#' Search for places within an extent (bounding box).
#'
#' The `/places/within-extent` request searches for places within an extent (bounding box).
#'
#' You must supply the `xmin`, `ymin`, `xmax` and `ymax` coordinates to define the extent. The maximum width and height of an extent that can be used in a search is 20,000 meters.
#'
#' You can also provide multiple categories or search text to find specific types of places within the extent.
#'
#' Note: You cannot permanently store places. Please see the [Terms of use](https://developers.arcgis.com/documentation/mapping-apis-and-services/deployment/terms-of-use/).
#'
#' Note: Query parameters are case-sensitive.
#' @inheritParams near_point
#' @inheritParams category_details
#' @param xmin The minimum x coordinate, or longitude, of the search extent in `EPSG:4326.`
#' @param ymin The minimum y coordinate, or latitude, of the search extent in `EPSG:4326`
#' @param xmax The maximum x coordinate, or longitude, of the search extent in `EPSG:4326`.
#' @param ymax The maximum y coordinate, or latitude, of the search extent in `EPSG:4326`
#' @export
#' @returns
#' An `sf` object with columns
#' - `place_id`: The unique Id of this place. The ID can be passed to `place_details()` to retrieve additional details.
#' - `name`: The name of the place, or point of interest. You can search for places by name using the searchText property
#' - `categories`: A `data.frame` with two columns `category_id` and `label`. Categories are uniquely identified by a categoryId. For example, `17119` identifies a "Bicycle Store" and `10051` identifies a "Stadium". Note that a single place can belong to multiple categories (for example, a petrol station could also have a super-market).
#' - `icon`: A character vector of the URL for an icon for this place or category in either svg, cim or png format.
#' - `geometry`: an `sfc_POINT` object in `EPSG:4326`
#'
#' @references [API Documentation](https://developers.arcgis.com/rest/places/within-extent-get/)
#' @examples
#' \dontrun{
#' within_extent(
#'   139.74,
#'   35.65,
#'   139.75,
#'   35.66,
#'   category_ids = "10001"
#' )
#' }

within_extent <- function(
    xmin,
    ymin,
    xmax,
    ymax,
    search_text = NULL,
    category_id = NULL,
    icon = NULL,
    token = arc_token()
) {

  # input validation
  check_string(search_text, allow_null = TRUE)
  check_string(icon, allow_null = TRUE)
  check_character(category_id, allow_null = TRUE)

  if (!is.null(icon)) {
    rlang::arg_match0(icon, c("svg", "cim", "png"))
  }

  # check for valid token
  obj_check_token(token)

  # get the results directly from  Rust
  res_raw <- places_within_extent(
    search_text,
    category_id,
    icon,
    xmin,
    ymin,
    xmax,
    ymax,
    token$access_token,
    places_url()
  )

  # TODO make a check to see if the result was NULL
  # if so, return an error
  if (rlang::is_null(res_raw)) {
    # TODO better error message here eesh
    cli::cli_abort("Query returned an error")
  }

  results <- rbind_results(res_raw)

  # repair geometry into sfc
  results[["geometry"]] <- structure(
    results[["geometry"]],
    precision = 0L,
    bbox = construct_bbox(xmin, ymin, xmax, ymax),
    crs = EPSG4326,
    class = c("sfc_POINT", "sfc")
  )

  # results
  # create the sf Object
  res <- structure(
    results[, c("place_id", "name", "categories", "icon", "geometry")],
    class = c("sf", "tbl", "data.frame"),
    sf_column = "geometry",
    agr = factor(
      c(
        place_id = NA_character_,
        name = NA_character_,
        categories = NA_character_,
        icon = NA_character_
      ),
      levels = c("constant", "aggregate", "identity")
    )
  )

  # return sf object back to R
  res
}

# Construct a bounding box for EPSG 4326
construct_bbox <- function(xmin, ymin, xmax, ymax) {
  structure(
    c(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
    crs = EPSG4326
  )
}
