use extendr_api::prelude::*;
mod categories;
mod category_details;
mod nearpoint;
mod place_details;
mod within_extent;

use serde_esri::places::{Category, NullablePoint, PlaceResult, Point};

// Convert a point to an sfg point
pub fn location_to_sfg(x: Option<Point>) -> Robj {
    match x {
        Some(place) => {
            let Point { x, y } = place;
            Doubles::from_values([x, y])
                .into_robj()
                .set_class(&["XY", "POINT", "sfg"])
                .unwrap()
        }
        None => Doubles::from_values([Rfloat::na(), Rfloat::na()])
            .into_robj()
            .set_class(&["XY", "POINT", "sfg"])
            .unwrap(),
    }
}

pub fn nullable_point_to_sfg(x: Option<NullablePoint>) -> Robj {
    match x {
        Some(place) => {
            let NullablePoint { x, y } = place;
            Doubles::from_values([x, y])
                .into_robj()
                .set_class(&["XY", "POINT", "sfg"])
                .unwrap()
        }
        None => Doubles::from_values([Rfloat::na(), Rfloat::na()])
            .into_robj()
            .set_class(&["XY", "POINT", "sfg"])
            .unwrap(),
    }
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

// Create an object that can be used in a column of a dataframe
pub fn as_is_col(x: impl IntoRobj) -> Robj {
    let robj = x.into_robj();
    List::from_values([robj])
        .into_robj()
        .set_class(&["AsIs"])
        .unwrap()
}

// Macro to generate exports.
// This ensures exported functions are registered with R.
// See corresponding C code in `entrypoint.c`.
extendr_module! {
    mod arcgisplaces;
    use categories;
    use category_details;
    use nearpoint;
    use place_details;
    use within_extent;
}
