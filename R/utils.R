EPSG4326 <- structure(
  list(
    input = "EPSG:4326",
    wkt = 'GEOGCRS["WGS 84",\n    ENSEMBLE["World Geodetic System 1984 ensemble",\n        MEMBER["World Geodetic System 1984 (Transit)"],\n        MEMBER["World Geodetic System 1984 (G730)"],\n        MEMBER["World Geodetic System 1984 (G873)"],\n        MEMBER["World Geodetic System 1984 (G1150)"],\n        MEMBER["World Geodetic System 1984 (G1674)"],\n        MEMBER["World Geodetic System 1984 (G1762)"],\n        MEMBER["World Geodetic System 1984 (G2139)"],\n        ELLIPSOID["WGS 84",6378137,298.257223563,\n            LENGTHUNIT["metre",1]],\n        ENSEMBLEACCURACY[2.0]],\n    PRIMEM["Greenwich",0,\n        ANGLEUNIT["degree",0.0174532925199433]],\n    CS[ellipsoidal,2],\n        AXIS["geodetic latitude (Lat)",north,\n            ORDER[1],\n            ANGLEUNIT["degree",0.0174532925199433]],\n        AXIS["geodetic longitude (Lon)",east,\n            ORDER[2],\n            ANGLEUNIT["degree",0.0174532925199433]],\n    USAGE[\n        SCOPE["Horizontal component of 3D system."],\n        AREA["World."],\n        BBOX[-90,-180,90,180]],\n    ID["EPSG",4326]]'
  ),
  class = "crs"
)


places_url <- function() {
  if (Sys.getenv("PLACES_ENV") == "dev") {
    "https://placesdev-api.arcgis.com/arcgis/rest/services/places-service/v1"
  } else {
    "https://places-api.arcgis.com/arcgis/rest/services/places-service/v1"
  }
}


data_frame <- function(x, call = rlang::caller_env()) {
  check_data_frame(x, call = call)
  structure(x, class = c("tbl", "data.frame"))
}

compute_sfc_bbox <- function(x) {
  bb <- unclass(wk::wk_bbox(x))
  structure(unlist(bb[1:4]), crs = EPSG4326)
}


