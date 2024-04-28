use crate::place_to_df;
use extendr_api::prelude::*;
use serde_esri::places::{
    query::{PlacesClient, WithinExtentQueryParams},
    Icon,
};

#[extendr]
fn places_within_extent(
    search_text: Nullable<String>,
    category_ids: Nullable<Strings>,
    icon: Nullable<String>,
    xmin: f64,
    ymin: f64,
    xmax: f64,
    ymax: f64,
    token: &str,
    places_url: &str,
) -> Robj {
    // TODO: categories (make into an R object), icon,
    let client = PlacesClient::new(places_url, token);

    // if not null, convert to a vector of strings
    // if null, None
    let category_ids = match category_ids {
        Nullable::NotNull(ids) => Some(
            ids.into_iter()
                .map(|x| x.as_str().to_string())
                .collect::<Vec<String>>(),
        ),
        _ => None,
    };

    let search_text = match search_text {
        Nullable::NotNull(text) => Some(text),
        _ => None,
    };

    let icon = match icon {
        Nullable::NotNull(i) => match i.as_str() {
            "svg" => Some(Icon::Svg),
            "cim" => Some(Icon::Cim),
            "png" => Some(Icon::Png),
            _ => None,
        },
        _ => None,
    };
    let params = WithinExtentQueryParams {
        xmin,
        ymin,
        xmax,
        ymax,
        category_ids: category_ids,
        search_text: search_text,
        icon: icon,
    };

    let within_extent_res = client.within_extent(params);

    if within_extent_res.is_err() {
        return ().into_robj();
    }

    within_extent_res
        .unwrap()
        .into_iter()
        .map(|xi| match xi {
            Ok(x) => place_to_df(x),
            Err(_) => ().into_robj(),
        })
        .collect::<List>()
        .into_robj()
}

extendr_module! {
    mod within_extent;
    fn places_within_extent;
}
