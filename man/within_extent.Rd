% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/core-within-extent.R
\name{within_extent}
\alias{within_extent}
\title{Search for places within an extent (bounding box).}
\usage{
within_extent(
  xmin,
  ymin,
  xmax,
  ymax,
  search_text = NULL,
  category_id = NULL,
  icon = NULL,
  token = arc_token()
)
}
\arguments{
\item{xmin}{The minimum x coordinate, or longitude, of the search extent in \code{EPSG:4326.}}

\item{ymin}{The minimum y coordinate, or latitude, of the search extent in \code{EPSG:4326}}

\item{xmax}{The maximum x coordinate, or longitude, of the search extent in \code{EPSG:4326}.}

\item{ymax}{The maximum y coordinate, or latitude, of the search extent in \code{EPSG:4326}}

\item{search_text}{Default \code{NULL}. Free search text for places against names, categories etc. Must be a scalar value.}

\item{category_id}{Default \code{NULL}. A character vector which filters places to those that match the category IDs.}

\item{icon}{Default \code{NULL}. Must be one of \code{"svg"}, \code{"png"} \code{"cim"}. Determines whether icons are returned and the type of icon to use with a place or category.}

\item{token}{an object of class \code{httr2_token} as generated by \code{\link[arcgisutils:auth_code]{auth_code()}}
or related function}
}
\value{
An \code{sf} object with columns
\itemize{
\item \code{place_id}: The unique Id of this place. The ID can be passed to \code{place_details()} to retrieve additional details.
\item \code{name}: The name of the place, or point of interest. You can search for places by name using the searchText property
\item \code{categories}: A \code{data.frame} with two columns \code{category_id} and \code{label}. Categories are uniquely identified by a categoryId. For example, \code{17119} identifies a "Bicycle Store" and \code{10051} identifies a "Stadium". Note that a single place can belong to multiple categories (for example, a petrol station could also have a super-market).
\item \code{icon}: A character vector of the URL for an icon for this place or category in either svg, cim or png format.
\item \code{geometry}: an \code{sfc_POINT} object in \code{EPSG:4326}
}
}
\description{
The \verb{/places/within-extent} request searches for places within an extent (bounding box).
}
\details{
You must supply the \code{xmin}, \code{ymin}, \code{xmax} and \code{ymax} coordinates to define the extent. The maximum width and height of an extent that can be used in a search is 20,000 meters.

You can also provide multiple categories or search text to find specific types of places within the extent.

Note: You cannot permanently store places. Please see the \href{https://developers.arcgis.com/documentation/mapping-apis-and-services/deployment/terms-of-use/}{Terms of use}.

Note: Query parameters are case-sensitive.
}
\examples{
\dontrun{
within_extent(
  139.74,
  35.65,
  139.75,
  35.66,
  category_ids = "10001"
)
}
}
\references{
\href{https://developers.arcgis.com/rest/places/within-extent-get/}{API Documentation}
}
