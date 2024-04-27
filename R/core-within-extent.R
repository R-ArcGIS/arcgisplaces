within_extent <- function(xmin, ymin, xmax, ymax, token = arc_token()) {
  results <- rbind_results(
    places_within_extent(xmin, ymin, xmax, ymax, token)
  )

  # TODO return SF object
  # TODO create prototype object
  # TODO return prototype object when 0 results are returned
  # Refer to core-near-point.R
  # repair geometry into sfc
  results[["geometry"]] <- structure(
    results[["geometry"]],
    precision = 0L,
    bbox = construct_bbox(xmin, ymin, xmax, ymax),
    crs = EPSG4326,
    class = c("sfc_POINT", "sfc")
  )

  results
}

# Construct a bounding box for EPSG 4326
construct_bbox <- function(xmin, ymin, xmax, ymax) {
  structure(
    c(xmin = xmin, ymin = ymin, xmax = xmax, ymax = ymax),
    crs = EPSG4326
  )
}
