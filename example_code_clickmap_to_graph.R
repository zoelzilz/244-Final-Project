library(leaflet)
library(shiny)
library(ggplot2)

# example data frame 
wxstn_df <- data.frame(polygonID = c("a", "a", "b"), Latitude = c(44.1, 44.1, 37), Longitude = c(-110.2, -110.2, -112.7), Month = c(1,2,1), Temp_avg = c(10, 18, 12))

ui <- fluidPage(column(7, leafletOutput("wsmap", height = "600px")),
                column(5, plotOutput("plot", height = "600px"))
)

server <- function(input, output) {
  
  ## leaflet map
  output$wsmap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      addCircleMarkers(data = wxstn_df, ~unique(Longitude), ~unique(Latitude), layerId = ~unique(polygonID), popup = ~unique(polygonID)) 
  })
  
  # generate data in reactive
  ggplot_data <- reactive({
    print(input$map_marker_click)
    site <- input$wsmap_marker_click$id
    print(site)
    
    data <- wxstn_df[wxstn_df$polygonID %in% site,]
    print(data)
    data
  })
  
  output$plot <- renderPlot({
    ggplot(data = ggplot_data(), aes(Month, Temp_avg)) +
      geom_bar(stat = "identity")
  }) 
}

shinyApp(ui, server)