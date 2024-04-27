use crate::as_is_col;
use extendr_api::prelude::*;
use serde_esri::places::CategoryDetails;

#[extendr]
/// Parse /categories/{categoryId} results vectorized
/// @keywords internal
fn parse_category_details(x: Strings) -> List {
    x.into_iter()
        .map(|xi| {
            if xi.is_na() {
                ().into_robj()
            } else {
                let cat_dets = serde_json::from_str::<CategoryDetails>(xi.as_str());
                if cat_dets.is_ok() {
                    category_details_to_df(cat_dets.unwrap())
                } else {
                    {
                        ().into_robj()
                    }
                }
            }
        })
        .collect::<List>()
}

// Takes a `CategoryDetails` struct and converts it into a data.frame
fn category_details_to_df(x: CategoryDetails) -> Robj {
    let full_label = Strings::from_values(x.full_label).into_robj();

    let icon_url = x.icon.map_or(Strings::from(Rstr::na()), |i| {
        Strings::from(Rstr::from(i.url))
    });

    let parents = x
        .parents
        .map_or(Strings::from(Rstr::na()), |p| Strings::from_values(p));

    data_frame!(
        category_id = x.category_id,
        full_label = as_is_col(full_label),
        icon_url = icon_url,
        parents = as_is_col(parents)
    )
    .into()
}

extendr_module! {
    mod category_details;
    fn parse_category_details;
}

// Too slow and unneeded. No parallelization here
// #[extendr]
// fn category_details_(
//     category_id: Strings,
//     icon: Option<String>,
//     language: Option<String>,
//     url: &str,
//     token: &str,
// ) -> List {
//     let client = PlacesClient::new(url, token);

//     let icon = if let Some(icon) = icon {
//         match icon.as_str() {
//             "svg" => Some(Icon::Svg),
//             "png" => Some(Icon::Png),
//             "cim" => Some(Icon::Cim),
//             _ => None,
//         }
//     } else {
//         None
//     };

//     category_id
//         .into_iter()
//         .map(|ci| {
//             let params = CategoryQueryParams {
//                 category_id: ci.to_string(),
//                 icon: icon.clone(),
//                 language: language.clone(),
//             };

//             let res = client.category_details(params);
//             match res {
//                 Ok(cd) => category_details_to_df(cd),
//                 Err(_) => ().into_robj(),
//             }
//         })
//         .collect::<List>()
// }
