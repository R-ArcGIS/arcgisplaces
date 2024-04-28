## code to prepare `all_categories` dataset goes here
library(arcgisplaces)

all_cats <- categories()

all_categories <- all_cats |>
  tidyr::unnest_longer(parents) |>
  tidyr::unnest_longer(full_label)

# TODO
# can i store the category ids for input validation?
# or will that violate terms of service which doesnt permit us
# to store the results of the queries.
# usethis::use_data(all_categories, overwrite = TRUE)
