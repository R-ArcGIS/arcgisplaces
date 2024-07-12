library(bslib)
library(shiny)
library(arcgis)
library(bsicons)
library(leaflet)

# you will need an API key:
# https://location.arcgis.com/sign-up/

# authorize your account with arcgisplaces
set_arc_token(auth_key())

# start the base map
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

  observeEvent(input$submit, {
    search_places_helper(input, output, input$search_text, input$categories)
  })

  observeEvent(input$grocery, {
    search_places_helper(input, output, "grocery store", c("17069", "17070"))
  })

  observeEvent(input$coffee, {
    search_places_helper(input, output, "coffee shop", c("13035", "17063"))
  })

  observeEvent(input$atms, {
    search_places_helper(input, output, "bank", "11044")
  })
  observeEvent(input$parks, {
    search_places_helper(input, output, "park", c("16032", "16035", "16037", "16039"))
  })
  observeEvent(input$gas, {
    search_places_helper(input, output, "gas station", c("19007", "19006"))
  })
}


search_places_helper <- function(input, output, search, categories) {
  extent <- input$map_bounds

  search_results <- within_extent(
    extent$west, extent$south, extent$east, extent$north,
    search, categories
  )

  if (nrow(search_results) == 0) {
    return(NULL)
  }

  # update map with new markers
  leafletProxy(
    "map",
    data = search_results
  ) |>
    clearMarkers() |>
    addMarkers(label = ~name)

  output$suggests <- renderUI({
    make_suggestion_list(search_results)
  })
}

make_suggestion_list <- function(suggestions) {
  ul <- tag("ul", c("class" = "list-group shadow-lg"))
  lis <- lapply(suggestions$name, \(.x) {
    htmltools::tag(
      "li",
      c("class" = "list-group-item list-group-item-action border-light text-sm", .x)
    )
  })

  tagSetChildren(ul, lis)
}


shinyApp(ui, server)
