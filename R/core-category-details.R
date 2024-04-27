#' Get the category details for a category ID.
#'
#' The `/categories/{categoryId}` request returns all the groups to which the category belongs. You must supply a category ID to use this request. Note: Query parameters are case-sensitive.
#'
#' @details
#'
#' ## Language Codes
#'
#' The language codes use the CLDR (Common Locale Data Repository) format string that uses a two letter language code (e.g. "fr" for French) optionally followed by a two letter country code (e.g. "fr-CA" for French in Canada).
#'
#' If an unsupported language code is used, then the service will attempt to fall-back to the closest available language. This is done by stripping regional and extension subtags to find a known language code. For example, French Canadian (fr-CA) is unsupported so this falls back to French fr.
#'
#' Should the fallback fail, then the service will return category names in the default language en for English.
#'
#'
#' @inheritParams near_point
#' @param language Optional case-sensitive parameter to specify the preferred language to.
#' @param .progress Default `TRUE`. Whether a progress bar should be provided.
#' @inheritParams arcgisutils::arc_base_req
#' @references [API Documentation](https://developers.arcgis.com/rest/places/categories-category-id-get)
#'
#' @returns
#' A `data.frame` with columns:
#'
#'  - `category_id`
#'  - `full_label`: a list of character vectors
#'  - `icon_url`: a character vector of the URL to an icon, if available
#'  - `parents`: a list of character vectors indicating the parent category ID
#'
#' @export
#' @examples
#' categories <- c(
#'   "12015", "11172", "15015", "19027", "13309", "16069", "19004",
#'   "13131", "18046", "15048"
#' )
#' category_details(categories)
category_details <- function(
    category_id,
    icon = NULL,
    language = NULL,
    token = arc_token(),
    .progress = TRUE) {
  # input checks, no NA values permitted
  obj_check_token(token)
  check_character(category_id)
  check_string(icon, allow_null = TRUE)
  check_string(language, allow_null = TRUE)

  if (!is.null(icon)) {
    rlang::arg_match0(icon, c("svg", "png", "cim"))
  }

  b_req <- arc_base_req(
    places_url(),
    token,
    "categories",
    query = c("f" = "json")
  )

  all_reqs <- lapply(category_id, function(.x) {
    httr2::req_url_path_append(b_req, .x)
  })

  all_resps <- httr2::req_perform_parallel(
    all_reqs,
    progress = .progress,
    on_error = "continue"
  )

  all_bodies <- all_res <- httr2::resps_data(
    all_resps,
    httr2::resp_body_string
  )

  res_list <- parse_category_details(all_bodies)

  data_frame(
    rbind_results(res_list, .ptype = category_details_ptype())
  )
}


category_details_ptype <- function() {
  data.frame(
    category_id = character(),
    full_label = I(list()),
    icon_url = character(),
    parents = I(list())
  )
}
