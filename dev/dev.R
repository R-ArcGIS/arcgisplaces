library(bslib)
library(shiny)
library(arcgis)
library(bsicons)
library(leaflet)

set_arc_token(auth_key())

map <- leaflet() |>
  addProviderTiles(providers$Esri.WorldGrayCanvas) |>
  setView(-117.16018863360692, 32.70568725886412, 15)

ui <- page_fillable(
  leafletOutput("map"),
  div(
    class = "btn-group position-absolute bg-white mt-4 start-50 translate-middle-x",
    actionButton(
      "grocery",
      bsicons::bs_icon("cart"),
      class = "btn btn-outline-primary",
    ),
    actionButton(
      "coffee",
      class = "btn btn-outline-primary",
      bsicons::bs_icon("cup-hot")
    ),
    actionButton(
      "atms",
      class = "btn btn-outline-primary",
      bsicons::bs_icon("cash-stack")
    ),
    actionButton(
      "parks",
      class = "btn btn-outline-primary",
      bsicons::bs_icon("tree")
    ),
    actionButton(
      "gas",
      class = "btn btn-outline-primary",
      bsicons::bs_icon("fuel-pump")
    )
  )
)

server <- function(input, output, session) {
  output$map <- renderLeaflet(map)

  observeEvent(input$grocery, {
    search_places_helper(input, "grocery store", c("17069", "17070"))
  })

  observeEvent(input$coffee, {
    search_places_helper(input, "coffee shop", c("13035", "17063"))
  })

  observeEvent(input$atms, {
    search_places_helper(input, "bank", "11044")
  })
  observeEvent(input$parks, {
    search_places_helper(input, "park", c("16032", "16035", "16037", "16039"))
  })
  observeEvent(input$gas, {
    search_places_helper(input, "gas station", c("19007", "19006"))
  })
}

shinyApp(ui, server)

search_places_helper <- function(input, search, categories) {
  center <- input$map_center
  search_results <- near_point(
    center$lng,
    center$lat,
    400,
    search_text = search,
    category_id = categories
  )

  # update map with new markers
  leafletProxy(
    "map",
    data = search_results
  ) |>
    clearMarkers() |>
    addMarkers(label = ~name)
}


# Grocery:
#        categoryIds: ["17069", "17070""]
# Coffee:           categoryIds: ["13035", "17063"]
# ATM :11044
# Parks
# ["16032", "16035", "16037", "16039"]
# Feul:           categoryIds: ["19007", "19006"],
# search_results <- near_point(
#   -117.16018863360692, 32.70568725886412,
#   500,
#   category_id = c("13035", "17063")
# )
