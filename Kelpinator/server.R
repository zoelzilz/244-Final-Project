#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# called once each session

library(leaflet)
library(shiny)
library(ggplot2)
library(sf)
library(tidyverse)

###################################################################################################
#load the data
# the data we need is a SpatialPolygonsDataframe, created in another script (currently in the data_vis_shp.Rmd)

# it is called:
ogr_annual_intersect2

# can easily view and access dataframe within using 
ogr_annual_intersect2@data <- ogr_annual_intersect2@data %>% 
  mutate(random_variable = sample(1:50, 1893, replace = TRUE))

# ssh is our significant wave height


ogr_annual_intersect2
#

#creating bins for adding binned color to maps # not even remotely necessary #

bins <- seq(1,3, 0.05) # based on sig wave height, need smaller bins


# defining a color palette, again, unnecessary 
pal <- colorBin("YlOrRd", domain = ogr_annual_intersect2@data$ssh, bins = bins)

# setting up labels
labels <- sprintf(
  "<strong>Kelp Bed: %g</strong><br/> Significant Wave Height: %s ",
  ogr_annual_intersect2@data$KelpBed, ogr_annual_intersect2@data$ssh
) %>% lapply(htmltools::HTML)

###################################################################################################

server <- function(input,output, session){
  
  # maps output for second tab
  #reactive_month <- eventReactive(input$radioButtons,
                                 # {})
  output$heatmap <- renderUI({
    if(input$Month == "Annual"){            
        img(height = 700, width = 700, src = "annual.png")
      }                                        
    else if(input$Month == "January"){
      img(height = 700, width = 700, src = "jan.png")
    }
    else if(input$Month == "February"){
      img(height = 700, width = 700, src = "feb.png")
    }
    
    
  })
  
  # first tab
  # create the leaflet map 
  
  output$harvestbedmap <- renderLeaflet({
    leaflet(ogr_annual_intersect2) %>% 
      addTiles() %>% 
      setView(lng = -118.5204798, lat = 33.95851, zoom = 8.32) %>%  #pick a prettier basemap
      addPolygons(data =, fillColor = ~pal(ssh),
                  weight = 2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = "",
                    fillOpacity = 0.7,
                    bringToFront = TRUE),
                  layerId = ~unique(ssh),
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
                  
      )
    #addCircleMarkers(data = harvest_beds, ~unique(lon), ~unique(lat), layerId = ~unique(KelpBed), popup = ~unique(KelpBed)) 
  })
  
  # generate data in reactive
  ggplot_data <- reactive({
    #print(input$harvestbedmap_shape_click)
    sigwave <- input$harvestbedmap_shape_click$id
    ogr_annual_intersect2@data[ogr_annual_intersect2@data$ssh %in% sigwave,]
  })
  
  
  output$plot <- renderPlot({
    ggplot(data = ggplot_data(), aes(ssh)) +
      geom_bar()
  })
}

