library(httr2)
library(arcgisutils)


all_cats <- categories()

all_categories <- all_cats |>
  tidyr::unnest_longer(parents) |>
  tidyr::unnest_longer(full_label)

format(object.size(all_categories), "Kb")


