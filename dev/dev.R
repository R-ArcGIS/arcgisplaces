system.time({
  res <- places_within_extent(
    139.74,
    35.65,
    139.75,
    35.66,
    Sys.getenv("PLACES_DEV_KEY")
  )
})

# xmin = 139.74
# ymin = 35.65
# xmax = 139.75
# ymax = 35.66

x <- within_extent(
  139.74,
  35.65,
  139.75,
  35.66,
  Sys.getenv("PLACES_DEV_KEY")
)

sf::st_combine(x$geometry) |>
  sf::st_centroid() |>
  sf::st_coordinates()

