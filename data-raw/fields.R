## code to prepare `fields` dataset goes here

fields <- c("all", "additionalLocations", "additionalLocations:dropOff", "additionalLocations:frontDoor", "additionalLocations:road", "additionalLocations:roof", "address", "address:adminRegion", "address:censusBlockId", "address:country", "address:designatedMarketArea", "address:extended", "address:locality", "address:neighborhood", "address:poBox", "address:postcode", "address:postTown", "address:region", "address:streetAddress", "categories", "contactInfo", "contactInfo:email", "contactInfo:fax", "contactInfo:telephone", "contactInfo:website", "chains", "description", "hours", "hours:opening", "hours:openingText", "hours:popular", "location", "name", "rating", "rating:price", "rating:user", "socialMedia", "socialMedia:facebookId", "socialMedia:instagram", "socialMedia:twitter")


usethis::use_data(fields, overwrite = TRUE)
