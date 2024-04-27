use extendr_api::prelude::*;
mod nearpoint;

use serde_esri::places::{
    query::{PlacesClient, WithinExtentQueryParams},
    Category, PlaceResult, Point,
};

#[extendr]
fn places_within_extent(
    // search_text: Option<String>,
    xmin: f64,
    ymin: f64,
    xmax: f64,
    ymax: f64,
    token: &str,
) -> List {
    // TODO: categories (make into an R object), icon,
    let client = PlacesClient::new(
        "https://placesdev-api.arcgis.com/arcgis/rest/services/places-service/v1",
        token,
    );

    let params = WithinExtentQueryParams {
        xmin,
        ymin,
        xmax,
        ymax,
        category_ids: None,
        search_text: None,
        icon: None,
    };

    client
        .within_extent(params)
        .unwrap()
        .into_iter()
        .map(|xi| match xi {
            Ok(x) => place_to_df(x),
            Err(_) => ().into_robj(),
        })
        .collect::<List>()
}

// Take a place result and turn it into a dataframe
fn place_to_df(place: PlaceResult) -> Robj {
    let Point { x, y } = place.location;
    let point = Doubles::from_values([x, y])
        .into_robj()
        .set_class(&["XY", "POINT", "sfg"])
        .unwrap();

    let icon = place.icon;
    let icon_url = icon.map_or(Strings::from(Rstr::na()), |i| {
        Strings::from(Rstr::from(i.url))
    });

    let cats = List::from_values([categories_to_df(place.categories)])
        .into_robj()
        .set_class(&["AsIs"])
        .unwrap();

    let geom = List::from_values([point]).set_class(&["AsIs"]).unwrap();
    data_frame!(
        place_id = place.place_id,
        name = place.name,
        distance = place.distance,
        categories = cats,
        icon = icon_url,
        geometry = geom
    )
}

// Define a simple struct to implement IntoDataFrame for
#[derive(Debug, IntoDataFrameRow)]
struct CatDf {
    category_id: String,
    label: String,
}

impl From<Category> for CatDf {
    fn from(value: Category) -> Self {
        CatDf {
            category_id: value.category_id,
            label: value.label,
        }
    }
}

// Turn a vector of categories into a data.frame
fn categories_to_df(categories: Vec<Category>) -> Robj {
    let df = categories
        .into_iter()
        .map(|cat| CatDf::from(cat))
        .collect::<Vec<_>>();

    df.into_dataframe().into_robj()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod arcgisplaces;
    fn places_within_extent;
    use nearpoint;
}
