library(leaflet)
library(shiny)
library(ggplot2)

# example data frame 
wxstn_df <- data.frame(Site = c("a", "a", "b"), Latitude = c(44.1, 44.1, 37), Longitude = c(-110.2, -110.2, -112.7), Month = c(1,2,1), Temp_avg = c(10, 18, 12))

ui <- fluidPage(column(7, leafletOutput("wsmap", height = "600px")),
                column(5, plotOutput("plot", height = "600px"))
)

server <- function(input, output) {
  
  ## leaflet map
  output$wsmap <- renderLeaflet({
    leaflet() %>% 
      addTiles() %>% 
      addCircleMarkers(data = wxstn_df, ~unique(Longitude), ~unique(Latitude), layerId = ~unique(Site), popup = ~unique(Site)) 
  })
  
  # generate data in reactive
  ggplot_data <- reactive({
    site <- input$wsmap_marker_click$id
    wxstn_df[wxstn_df$Site %in% site,]
  })
  
  output$plot <- renderPlot({
    ggplot(data = ggplot_data(), aes(Month, Temp_avg)) +
      geom_line()
  }) 
}

shinyApp(ui, server)