library(leaflet)
library(shiny)
myData <- data.frame(
  lat = c(54.406486, 53.406486),
  lng = c(-2.925284, -1.925284),
  id = c(1,2)
)
ui <- fluidPage(
  leafletOutput("map"),
  p(),
  tableOutput("myTable")
)
server <- shinyServer(function(input, output) {
  data <- reactiveValues(clickedMarker=NULL)
  # produce the basic leaflet map with single marker
  output$map <- renderLeaflet(
    leaflet() %>%
      addProviderTiles("CartoDB.Positron") %>%
      addCircleMarkers(lat = myData$lat, lng = myData$lng, layerId = myData$id)  
  )
  # observe the marker click info and print to console when it is changed.
  observeEvent(input$map_marker_click,{
    print("observed map_marker_click")
    data$clickedMarker <- input$map_marker_click
    print(data$clickedMarker)
    output$myTable <- renderTable({
      return(
        subset(myData,id == data$clickedMarker$id)
      )
    })
  })
})
shinyApp(ui, server)