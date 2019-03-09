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
library(rgdal)

###################################################################################################
#load the data
# the data we need is a SpatialPolygonsDataframe, created in another script 
# (currently in the data_vis_shp.Rmd) and saved as a new SPD

# it is called:
kelp_intersected <- readOGR(dsn = ".", layer = "kelp_intersected")

# ssh is our significant wave height
# kelp_loss is our main response variable

############################################################################
# adding some fluff (should go in another script within R file, but not sure what to name that script or how to call)

#creating bins for adding binned color to maps # not even remotely necessary #

#max(kelp_intersected@data$kelp_loss)
#68.37364

#min(kelp_intersected@data$kelp_loss)
#8.423632

bins <- seq(8,68, 1) # based on kelp_loss, need to seq from min to max


# defining a color palette, which needs to have at least 68 colors
pal <- colorBin("YlOrRd", domain = kelp_intersected@data$kelp_loss, bins = bins)

# setting up labels
labels <- sprintf(
  "<strong>Kelp Bed: %g</strong><br/> Significant Wave Height: %s ",
  kelp_intersected@data$KelpBed, kelp_intersected@data$polygonID #eventually change back to ssh
) %>% lapply(htmltools::HTML)

###########################################################################

###################################################################################################

server <- function(input,output, session){
  
  # maps output for SECOND tab
 
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
    else if(input$Month == "March"){
      img(height = 700, width = 700, src = "march.png")
    }
    else if(input$Month == "April"){
      img(height = 700, width = 700, src = "april.png")
    }
    else if(input$Month == "May"){
      img(height = 700, width = 700, src = "May.png")
    }
    else if(input$Month == "June"){
      img(height = 700, width = 700, src = "june.png")
    }
    else if(input$Month == "July"){
      img(height = 700, width = 700, src = "july.png")
    }
    else if(input$Month == "August"){
      img(height = 700, width = 700, src = "August.png")
    }
    else if(input$Month == "September"){
      img(height = 700, width = 700, src = "September.png")
    }
    else if(input$Month == "October"){
      img(height = 700, width = 700, src = "October.png")
    }
    else if(input$Month == "November"){
      img(height = 700, width = 700, src = "November.png")
    }
    else if(input$Month == "December"){
      img(height = 700, width = 700, src = "December.png")
    }
    
  })
  
  # first tab
  # create the leaflet map 
  
  output$harvestbedmap <- renderLeaflet({
    leaflet(kelp_intersected) %>% 
      addTiles() %>% 
      setView(lng = -118.5204798, lat = 33.95851, zoom = 8.32) %>%  #pick a prettier basemap
      addPolygons(data =, fillColor = ~pal(kelp_loss),
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
                  layerId = ~polygonID,
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
    print(input$harvestbedmap_shape_click)
    kelp <- input$harvestbedmap_shape_click$id
    print(kelp)
    
    data <- kelp_intersected@data[kelp_intersected@data$polygonID %in% kelp,]
    print(data)
    data
    
  })
  
  
  output$plot <- renderPlot({
    ggplot(data = ggplot_data(), aes(month, kelp_loss)) + # idk what the parenthenses do but without them it throws an error about data object being wrong type
      geom_bar(stat = "identity")
    
  })
}

