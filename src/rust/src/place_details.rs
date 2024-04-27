use crate::{as_is_col, categories_to_df, location_to_sfg, nullable_point_to_sfg};
use extendr_api::prelude::*;
use serde_esri::places::{
    query::PlaceResponse, AdditionalLocations, Address, Category, ChainInfo, ContactInfo, Hours,
    HoursByDay, IconDetails, PlaceDetails, Point, Rating, SocialMedia, TimeRange,
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

#[extendr]
fn parse_place_details(x: Strings) -> List {
    x.into_iter()
        .map(|xi| {
            if xi.is_na() {
                ().into_robj()
            } else {
                parse_place_details_single(xi.as_str())
            }
        })
        .collect::<List>()
}

fn parse_place_details_single(x: &str) -> Robj {
    let res = serde_json::from_str::<PlaceResponse>(x);
    match res {
        Ok(place) => parse_place_details_(place.place_details),
        Err(_) => ().into_robj(),
    }
}

fn parse_place_details_(x: PlaceDetails) -> Robj {
    let PlaceDetails {
        additional_locations,
        address,
        categories,
        chains,
        contact_info,
        description,
        hours,
        icon,
        location,
        name,
        place_id,
        rating,
        social_media,
    } = x;

    let (drop_off, front_door, road, roof) = match additional_locations {
        Some(locs) => {
            let drop = nullable_point_to_sfg(locs.drop_off);
            let front = nullable_point_to_sfg(locs.front_door);
            let road = nullable_point_to_sfg(locs.road);
            let roof = nullable_point_to_sfg(locs.roof);

            (drop, front, road, roof)
        }
        None => {
            let null = nullable_point_to_sfg(None);
            (null.clone(), null.clone(), null.clone(), null)
        }
    };

    let Address {
        admin_region,
        census_block_id,
        country,
        designated_market_area,
        extended,
        locality,
        neighborhood,
        po_box,
        postcode,
        post_town,
        region,
        street_address,
    } = if let Some(addr) = address {
        addr
    } else {
        Address {
            admin_region: None,
            census_block_id: None,
            country: None,
            designated_market_area: None,
            extended: None,
            locality: None,
            neighborhood: None,
            po_box: None,
            postcode: None,
            post_town: None,
            region: None,
            street_address: None,
        }
    };

    let chains = match chains {
        Some(cc) => {
            let chain_names = cc.into_iter().map(|c| Rstr::from(c.name));
            Strings::from_iter(chain_names)
        }
        None => Strings::from(Rstr::na()),
    };

    let (email, fax, telephone, website) = match contact_info {
        Some(ci) => (ci.email, ci.fax, ci.telephone, ci.website),
        None => (None, None, None, None),
    };

    let icon_url = icon.map_or(Strings::from(Rstr::na()), |i| {
        Strings::from(Rstr::from(i.url))
    });

    let (facebook_id, instagram, twitter) = match social_media {
        Some(sm) => (sm.facebook_id, sm.instagram, sm.twitter),
        None => (None, None, None),
    };

    let (price, user) = match rating {
        Some(r) => {
            let price = Strings::from(Rstr::from(format!("{:?}", r.price)));
            (price, r.user)
        }
        None => (Strings::from(Rstr::na()), None),
    };

    data_frame!(
        place_id = place_id,
        name = name,
        description = description,
        street_address = street_address,
        extended = extended,
        po_box = po_box,
        neighborhood =
            as_is_col(neighborhood.map_or(Strings::from(Rstr::na()), |n| Strings::from_values(n))),
        census_block_id = census_block_id,
        locality = locality,
        designated_market_area = designated_market_area,
        post_town = post_town,
        postcode = postcode,
        region = region,
        country = country,
        admin_region = admin_region,
        drop_off = as_is_col(drop_off),
        front_door = as_is_col(front_door),
        roof = as_is_col(roof),
        road = as_is_col(road),
        categories = as_is_col(categories_to_df(categories.map_or(vec![], |f| f))),
        chains = as_is_col(chains),
        email = email,
        fax = fax,
        telephone = telephone,
        website = website,
        hours = as_is_col(parse_hours(hours)),
        icon_url = icon_url,
        facebook_id = facebook_id,
        instagram = instagram,
        twitter = twitter,
        price = price,
        user = user,
        location = as_is_col(location_to_sfg(location))
    )
}

fn parse_hours(x: Option<Hours>) -> Robj {
    match x {
        Some(xx) => {
            data_frame!(
                opening_text = xx.opening_text,
                opening = as_is_col(parse_hours_by_day(xx.opening)),
                popular = as_is_col(parse_hours_by_day(xx.popular))
            )
        }
        None => {
            data_frame!(
                opening_text = Strings::from(Rstr::na()),
                opening = as_is_col(parse_hours_by_day(None)),
                popular = as_is_col(parse_hours_by_day(None))
            )
        }
    }
}

fn parse_hours_by_day(x: Option<HoursByDay>) -> Robj {
    if x.is_none() {
        return data_frame!(
            day_of_week = Strings::from(Rstr::na()),
            from = Strings::from(Rstr::na()),
            to = Strings::from(Rstr::na())
        );
    }

    let x = x.unwrap();

    let sunday = parse_time_range("Sunday", x.sunday);
    let monday = parse_time_range("Monday", x.monday);
    let tuesday = parse_time_range("Tuesday", x.tuesday);
    let wednesday = parse_time_range("Wednesday", x.wednesday);
    let thursday = parse_time_range("Thursday", x.thursday);
    let friday = parse_time_range("Friday", x.friday);
    let saturday = parse_time_range("Saturday", x.saturday);

    let dow = Strings::from_iter(
        sunday
            .0
            .into_iter()
            .chain(monday.0.into_iter())
            .chain(tuesday.0.into_iter())
            .chain(wednesday.0.into_iter())
            .chain(thursday.0.into_iter())
            .chain(friday.0.into_iter())
            .chain(saturday.0.into_iter()),
    );

    let from = Strings::from_iter(
        sunday
            .1
            .into_iter()
            .chain(monday.1.into_iter())
            .chain(tuesday.1.into_iter())
            .chain(wednesday.1.into_iter())
            .chain(thursday.1.into_iter())
            .chain(friday.1.into_iter())
            .chain(saturday.1.into_iter()),
    );

    let to = Strings::from_iter(
        sunday
            .2
            .into_iter()
            .chain(monday.2.into_iter())
            .chain(tuesday.2.into_iter())
            .chain(wednesday.2.into_iter())
            .chain(thursday.2.into_iter())
            .chain(friday.2.into_iter())
            .chain(saturday.2.into_iter()),
    );

    data_frame!(day_of_week = dow, from = from, to = to)
}

fn parse_time_range(day: &str, x: Option<Vec<TimeRange>>) -> (Vec<Rstr>, Vec<Rstr>, Vec<Rstr>) {
    let times = match x {
        Some(x) => {
            let n = x.len();
            let mut from = Vec::with_capacity(n);
            let mut to = Vec::with_capacity(n);

            for time in x {
                from.push(Rstr::from(time.from));
                to.push(Rstr::from(time.to));
            }
            (vec![Rstr::from(day); n], from, to)
        }
        None => (vec![Rstr::from(day)], vec![Rstr::na()], vec![Rstr::na()]),
    };
    times
}

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
    fn parse_place_details;
}
