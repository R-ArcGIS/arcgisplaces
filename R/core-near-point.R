#' Search for places near a point by radius
#'
#' Finds places that are within a given radius of a specified location. The returned places contain basic data such as name, category and location.
#'
#' @returns
#' An `sf` object with columns
#' - `place_id`: The unique Id of this place. The ID can be passed to `place_details()` to retrieve additional details.
#' - `name`: The name of the place, or point of interest. You can search for places by name using the searchText property
#' - `distance`: A double vector of the distance, in meters, from the place to the search point.
#' - `categories`: A `data.frame` with two columns `category_id` and `label`. Categories are uniquely identified by a categoryId. For example, `17119` identifies a "Bicycle Store" and `10051` identifies a "Stadium". Note that a single place can belong to multiple categories (for example, a petrol station could also have a super-market).
#' - `icon`: A character vector of the URL for an icon for this place or category in either svg, cim or png format.
#' - `geometry`: an `sfc_POINT` object in `EPSG:4326`
#'
#' @references [API Documentation](https://developers.arcgis.com/rest/places/near-point-get)
#'
#' @param x The x coordinate, or longitude, to search from, in WGS84 decimal degrees.
#' @param y The y coordinate, or latitude, to search from, in WGS84 decimal degrees.
#' @param radius Default `1000`. The radius in meters to search for places. Maximum value of `10000`.
#' @param category_id Default `NULL`. A character vector which filters places to those that match the category IDs.
#' @param search_text Default `NULL`. Free search text for places against names, categories etc. Must be a scalar value.
#' @param icon Default `NULL`. Must be one of `"svg"`, `"png"` `"cim"`. Determines whether icons are returned and the type of icon to use with a place or category.
#' @inheritParams arcgisutils::arc_base_req
#' @examples
#' \dontrun{
#' near_point(-117.194769, 34.057289)
#' near_point(139.75, 35.66)
#' }
#' @export
near_point <- function(
    x, y,
    radius = 1000.0,
    search_text = NULL,
    category_id = NULL,
    icon = NULL,
    token = arc_token()) {
  obj_check_token(token)
  # perform input checks
  check_number_decimal(radius, min = 1, max = 10000)
  check_string(search_text, allow_null = TRUE)
  check_character(category_id, allow_null = TRUE)

  search_text <- search_text %||% NA_character_
  category_id <- category_id %||% NA_character_

  if (!is.null(icon)) {
    rlang::arg_match0(icon, c("svg", "png", "cim"))
  }

  if (!rlang::is_double(x)) {
    cli::cli_abort("{.arg x} must be a numeric vector. Found {obj_type_friendly(x)}")
  }

  if (!rlang::is_double(y)) {
    cli::cli_abort("{.arg y} must be a numeric vector. Found {obj_type_friendly(x)}")
  }

  # send query to Rust
  res <- near_point_(
    x,
    y,
    radius,
    category_id,
    search_text,
    token[["access_token"]]
  )

  # combine results
  res <- rbind_results(res)

  if (nrow(res) == 0) {
    return(near_point_ptype())
  }

  # create the sf Object
  res <- structure(
    res,
    class = c("sf", "tbl", "data.frame"),
    sf_column = "geometry",
    agr = factor(
      c(
        place_id = NA_character_,
        name = NA_character_,
        distance = NA_character_,
        categories = NA_character_,
        icon = NA_character_
      ),
      levels = c("constant", "aggregate", "identity")
    )
  )

  # repair geometry
  res[["geometry"]] <- structure(
    res$geometry,
    precision = 0L,
    # bbox = construct_bbox(xmin, ymin, xmax, ymax),
    crs = EPSG4326,
    class = c("sfc_POINT", "sfc")
  )

  # calculate the bounding box
  bbox_raw <- wk::wk_bbox(res[["geometry"]])
  attr(res[["geometry"]], "bbox") <- do.call(construct_bbox, bbox_raw)
  res
}

#' Create a prototype data.frame for the near-point query
#' @keywords internal
#' @noRd
near_point_ptype <- function() {
  geometry <- structure(
    list(),
    precision = 0L,
    bbox = construct_bbox(NA, NA, NA, NA),
    crs = EPSG4326,
    class = c("sfc_POINT", "sfc")
  )

  categories <- data.frame(category_id = character(), label = character())

  data <- data.frame(
    place_id = character(),
    name = character(),
    distance = double(),
    categories = I(categories)
  )

  res <- structure(
    data,
    class = c("sf", "data.frame"),
    sf_column = "geometry",
    agr = factor(
      c(
        place_id = NA_character_,
        name = NA_character_,
        distance = NA_character_,
        categories = NA_character_,
        icon = NA_character_
      ),
      levels = c("constant", "aggregate", "identity")
    )
  )

  res[["geometry"]] <- geometry

  res
}



# # Here's the design:
# # There isn't a way to know how to iterate through the places response
# # by knowing the end number of features, each search will need to be paginated
# # We will implement an iterator in Rust like demonstrated in the Rust cookbook
# # <https://rust-lang-nursery.github.io/rust-cookbook/web/clients/apis.html#consume-a-paginated-restful-api>
# # This will have to be done strictly in Rust
# # Then we will make bindings to this in R
# # We will vectorize this using the Rust function + tokio multithreaded runtime
