#' Return the name and category ID of all categories, or categories which satisfy a filter
#'
#' A category describes a type of place, such as "movie theater" or "zoo". The places service has over 1,000 categories (or types) of place. The categories fall into ten general groups: Arts and Entertainment, Business and Professional Services, Community and Government, Dining and Drinking, Events, Health and Medicine, Landmarks and Outdoors, Retail, Sports and Recreation, and Travel and Transportation.
#'
#' The categories are organized into a hierarchical system where a general category contains many more detailed variations on the parent category. For example: "Travel and Transportation" (Level 1), "Transport Hub" (Level 2), "Airport" (Level 3) and "Airport Terminal" (Level 4). The hierarchy has up to 5 levels of categories.
#'
#' @inheritParams near_point
#' @inheritParams category_details
#' @export
#' @references [API Documentation](https://developers.arcgis.com/rest/places/categories-get/)
#' @examples
#' \dontrun{
#' categories("Coffee Shop")
#' }
#' @returns
#'
#' A `data.frame` with columns:
#' - `category_id`: the unique identifier for the category
#' - `full_label`: a list of character vectors containing all labels for the category
#' - `icon_url`: a character vector containing the icon URL if present
#' - `parents`: a list of character vectors containing the parent `category_id` values
#'
categories <- function(
    search_text = NULL,
    icon = NULL,
    language = NULL,
    token = arc_token()) {
  base_req <- arc_base_req(
    places_url(),
    token,
    "categories",
    query = c(
      "f" = "json",
      icon = icon,
      language = language,
      filter = search_text
    )
  )
  resp <- httr2::req_perform(
    base_req,
    error_call = rlang::caller_env()
  )

  # parse result and combine into a single data frame with list cols
  res <- data_frame(
    rbind_results(
      parse_categories(httr2::resp_body_string(resp))
    )
  )

  res[["full_label"]] <- unclass(res[["full_label"]])
  res[["parents"]] <- unclass(res[["parents"]])
  res
}
