library(httr2)
library(arcgisutils)



data_frame <- function(x, call = rlang::caller_env()) {
  check_data_frame(x, call = call)
  structure(x, class = c("tbl", "data.frame"))
}


places_url <- function() {
  if (Sys.getenv("PLACES_ENV") == "dev") {
    "https://placesdev-api.arcgis.com/arcgis/rest/services/places-service/v1"
  } else {
    "https://places-api.arcgis.com/arcgis/rest/services/places-service/v1"
  }
}

token <- auth_key(Sys.getenv("PLACES_DEV_KEY"))
set_arc_token(token)
resp <- arc_base_req(places_url(), token, "categories", query = c("f" = "json")) |>
  httr2::req_perform()

# we could store this as an object for quick lookup
# in data-raw
all_categories <- resp |>
  httr2::resp_body_string() |>
  RcppSimdJson::fparse() |> 
  data_frame()
  purrr::pluck(1) |>
  data_frame() |>
  tidyr::unnest_longer(parents) |>
  tidyr::unnest_longer(fullLabel)

all_categories$categoryId
