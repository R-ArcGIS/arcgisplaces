use crate::as_is_col;
use extendr_api::prelude::*;
use serde_esri::places::query::CategoriesResponse;

#[extendr]
fn parse_categories(x: &str) -> Robj {
    let categories = serde_json::from_str::<CategoriesResponse>(x);

    if categories.is_err() {
        return ().into_robj();
    }

    categories
        .unwrap()
        .categories
        .into_iter()
        .map(|ci| {
            let labs = as_is_col(ci.full_label);
            let parents = as_is_col(
                ci.parents
                    .map_or(Strings::from(Rstr::na()), |v| Strings::from_values(v)),
            );

            let icon_url = ci.icon.map_or(Strings::from(Rstr::na()), |i| {
                Strings::from(Rstr::from(i.url))
            });

            data_frame!(
                category_id = ci.category_id,
                full_label = labs,
                icon_url = icon_url,
                parents = parents
            )
        })
        .collect::<List>()
        .into()
}

extendr_module! {
    mod categories;
    fn parse_categories;
}
