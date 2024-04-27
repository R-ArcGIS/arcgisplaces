# These are the possible fields that can be requested for a place
# all
# additionalLocations
# additionalLocations:dropOff
# additionalLocations:frontDoor
# additionalLocations:road
# additionalLocations:roof
# address
# address:adminRegion
# address:censusBlockId
# address:country
# address:designatedMarketArea
# address:extended
# address:locality
# address:neighborhood
# address:poBox
# address:postcode
# address:postTown
# address:region
# address:streetAddress
# categories
# contactInfo
# contactInfo:email
# contactInfo:fax
# contactInfo:telephone
# contactInfo:website
# chains
# description
# hours
# hours:opening
# hours:openingText
# hours:popular
# location
# name
# rating
# rating:price
# rating:user
# socialMedia
# socialMedia:facebookId
# socialMedia:instagram
# socialMedia:twitter
place_id <- "37f1062ae1c3d37511003e382b08ca32"

get_place_details <- function(
    place_id, requested_fields = "all",
    icon = NULL, token = arc_token()) {
  # TODO: vectorize
  # tokens are required
  obj_check_token(token)

  if (!is.null(icon)) {
    # TODO change multiple = TRUE when vectorization occurs
    rlang::arg_match(icon, c("svg", "cim", "png"), multiple = FALSE)
  }

  # get the places url
  base_url <- places_url()

  # create the base request
  # TODO: do this in a vectorized manner
  b_req <- arc_base_req(
    base_url, token,
    path = paste0("places/", place_id),
    query = c("f" = "json", icon = icon, requestedFields = requested_fields),
  )

  req <- httr2::req_url_query(b_req, icon = icon)

  resp <- httr2::req_perform(req)
  res <-
    RcppSimdJson::fparse(httr2::resp_body_string(resp))[[1]]
  res$placeDetails
}

# Flatten Address
# use categories_to_df() to create a data.frame
# flat map over chain info
# flatten contactInfo
# flatten social media
# Hours by day, should be made into a single dataframe
# cols: day, from, to
# res$hours$popular
