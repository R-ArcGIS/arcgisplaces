use extendr_api::prelude::*;
use serde_esri::places::{
    query::PlaceResponse, AdditionalLocations, Address, Category, ChainInfo, ContactInfo, Hours,
    IconDetails, Point, Rating, SocialMedia,
};

// pub struct PlaceDetails {

//     pub additional_locations: Option<AdditionalLocations>,
//     pub address: Option<Address>,
//     pub categories: Option<Vec<Category>>,
//     pub chains: Option<Vec<ChainInfo>>,
//     pub contact_info: Option<ContactInfo>,
//     pub description: Option<String>,
//     pub hours: Option<Hours>,
//     pub icon: Option<IconDetails>,
//     pub location: Option<Point>,
//     pub name: Option<String>,
//     pub place_id: String,
//     pub rating: Option<Rating>,
//     pub social_media: Option<SocialMedia>,
// }

// Hours is a hierarchy:
// Hours -> HoursByDay
// HoursByDay -> TimeRange

fn parse_rating(x: Option<Rating>) -> Robj {
    match x {
        Some(xx) => {
            let price = xx.price.map_or(Strings::from(Rstr::na()), |p| {
                Strings::from(format!("{p:?}"))
            });
            data_frame!(price = price, user = xx.user)
        }
        None => data_frame!(price = Strings::from(Rstr::na()), Rfloat::na()),
    }
}

fn parse_social_media(x: Option<SocialMedia>) -> Robj {
    match x {
        Some(xx) => {
            data_frame!(
                facebook_id = xx.facebook_id,
                instagram = xx.instagram,
                twitter = xx.twitter
            )
        }
        None => {
            data_frame!(
                facebook_id = Strings::from(Rstr::na()),
                instagram = Strings::from(Rstr::na()),
                twitter = Strings::from(Rstr::na())
            )
        }
    }
}
extendr_module! {
    mod place_details;
}
