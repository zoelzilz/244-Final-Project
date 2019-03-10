library(leaflet)
library(shiny)
library(ggplot2)
library(sf)
library(tidyverse)


# not using this data ##########################################################

#harvest_beds <- read_sf("MAN_CA_KelpAdmin", layer = "MAN_CA_KelpAdmin") %>% 
#st_transform(crs = 4326) %>% 
#mutate(lon = map_dbl(geometry, ~st_centroid(.x)[[1]]),
#     lat = map_dbl(geometry, ~st_centroid(.x)[[2]])) %>% 
#mutate(random_variable = sample(1:50, 87, replace = TRUE))



# START TO READ APP CODE HERE #
##############################################################################################################
# the data we need is a SpatialPolygonsDataframe, created in another script (currently in the data_vis_shp.Rmd)

# it is called:
kelp_intersected <- readOGR(".", layer = "kelp_intersected")

kelp_intersected@data$month <- factor(kelp_intersected@data$month, levels = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))


ui <- fluidPage(column(7, leafletOutput("harvestbedmap", height = "1000")),
                column(5, plotOutput("plot", height = "600px"))
)

############################################################################
# adding some fluff (should go in another script within R file)

#creating bins for adding binned color to maps # not even remotely necessary #

bins <- seq(1,3, 0.05) # based on sig wave height, need smaller bins


# defining a color palette, again, unnecessary 
pal <- colorBin("YlOrRd", domain = kelp_intersected@data$ssh, bins = bins)

# setting up labels
labels <- sprintf(
  "<strong>Kelp Bed: %g</strong><br/> Significant Wave Height: %s ",
  kelp_intersected2@data$KelpBed, kelp_intersected2@data$ssh
) %>% lapply(htmltools::HTML)

###########################################################################

server <- function(input, output) {
  
  ## leaflet map
  output$harvestbedmap <- renderLeaflet({
    leaflet(kelp_intersected2) %>% 
      addTiles() %>% 
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
    kelp_intersected2@data[kelp_intersected2@data$ssh %in% sigwave,]
  })
  
  
  output$plot <- renderPlot({
    ggplot(data = ggplot_data(), aes(ssh)) +
      geom_bar()
  }) 
}

shinyApp(ui, server)