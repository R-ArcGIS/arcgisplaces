# system.time({
#   res <- places_within_extent(
#     139.74,
#     35.65,
#     139.75,
#     35.66,
#     Sys.getenv("PLACES_DEV_KEY")
#   )
# })

# xmin = 139.74
# ymin = 35.65
# xmax = 139.75
# ymax = 35.66

# x <- within_extent(
#   139.74,
#   35.65,
#   139.75,
#   35.66,
#   category_ids = "10001"
# )


# # This should return 0 rows
# x <- within_extent(
#   0,
#   0,
#   1,
#   1,
# )
