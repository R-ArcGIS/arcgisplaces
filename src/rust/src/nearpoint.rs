use crate::place_to_df;
use extendr_api::prelude::*;
use serde_esri::places::query::{NearPointQueryParams, PlacesClient};

#[extendr]
fn near_point_(
    x: f64,
    y: f64,
    radius: Option<f64>,
    category_id: Strings,
    search_text: Option<String>,
    // icon: Option<Icon>,
    token: &str,
) -> List {
    // TODO: categories (make into an R object), icon,
    let client = PlacesClient::new(
        "https://placesdev-api.arcgis.com/arcgis/rest/services/places-service/v1",
        token,
    );

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

    let res = client
        .near_point(params);

    if let Err(e) = res {
        eprintln!("{}", e.to_string());
        return list!()
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
