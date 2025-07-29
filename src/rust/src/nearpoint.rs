use crate::place_to_df;
use extendr_api::prelude::*;
use serde_esri::places::query::{NearPointQueryParams, PlacesClient, PlacesError};

#[extendr]
fn near_point_(
    x: f64,
    y: f64,
    radius: Option<f64>,
    category_id: Strings,
    search_text: Option<String>,
    places_url: &str,
    token: &str,
) -> List {
    // TODO: categories (make into an R object), icon,
    let client = PlacesClient::new(places_url, token);

    let category_id = if category_id.len() == 0 {
        None
    } else {
        let cats = category_id
            .into_iter()
            .map(|si| si.to_string())
            .collect::<Vec<_>>();

        Some(cats)
    };

    let params = NearPointQueryParams {
        x,
        y,
        radius,
        category_id,
        search_text,
        icon: None,
    };

    let res = client.near_point(params);

    if let Err(e) = res {
        let res = match e {
            PlacesError::RequestError(re) => {
                eprintln!("{}", re.to_string());
                list!()
            }
            PlacesError::ApiError(ae) => extendr_api::serializer::to_robj(&ae)
                .unwrap()
                .as_list()
                .unwrap(),
        };

        return res;
    }

    res.unwrap()
        .into_iter()
        .map(|xi| match xi {
            Ok(x) => place_to_df(x),
            Err(_) => ().into_robj(),
        })
        .collect::<List>()
}

extendr_module! {
    mod nearpoint;
    fn near_point_;
}
