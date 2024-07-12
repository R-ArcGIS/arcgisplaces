library(bslib)
library(shiny)
library(arcgis)
library(bsicons)
library(leaflet)

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
  })
}

shinyApp(ui, server)

# Coffee: cup-hot-fill
# ATM: cash-stack

search_places_helper <- function(input, categories) {
  center <- input$map_center
  res <- near_point(
    center$lng,
    center$lat,
    500,
    category_id = categories
  )
}

# Grocery:
#        categoryIds: ["17069", "17070", "17071", "17072", "17073", "17077"]
# Coffee:           categoryIds: ["13035", "17063"]
# ATM :11044
# Parks
# ["16032", "16035", "16037", "16039"]
# Feul:           categoryIds: ["19007", "19006"],
