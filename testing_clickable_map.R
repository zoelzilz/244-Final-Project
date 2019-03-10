library(leaflet)
library(shiny)
library(ggplot2)
#library(sf)
library(tidyverse)
library(rgdal)


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

# can easily view and access dataframe within using @
# kelp_loss is our dependent variable
# do NOT View() the entire shapefile!!
# only View(kelp_intersected@data) or in pieces because this badboy WILL take 15 minutes to load and then crash your computer

ui <- fluidPage(column(7, leafletOutput("harvestbedmap", height = "1000")),
                column(5, plotOutput("plot", height = "600px"))
)

############################################################################
# adding some fluff (should go in another script within R file)

#creating bins for adding binned color to maps # not even remotely necessary #

max(kelp_intersected@data$kelp_loss)
#68.37364

min(kelp_intersected@data$kelp_loss)
#8.423632

bins <- seq(8,68, 1) # based on kelp_loss, need to seq from min to max


# defining a color palette, which needs to have at least 68 colors
pal <- colorBin("YlOrRd", domain = kelp_intersected@data$kelp_loss, bins = bins)

# setting up labels
labels <- sprintf(
  "<strong>Kelp Bed: %g</strong><br/> Significant Wave Height: %s ",
  kelp_intersected@data$KelpBed, kelp_intersected@data$polygonID
) %>% lapply(htmltools::HTML)

###########################################################################

server <- function(input, output) {
  
  ## leaflet map
  output$harvestbedmap <- renderLeaflet({
    leaflet(kelp_intersected) %>% 
      addTiles() %>% 
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
                  layerId = ~polygonID, # had to remove ~unique(polygonID) because it FUCKED EVERYTHING UP
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

shinyApp(ui, server)

# it's not working because layerID = ~unique(kelp_bed) is TOO UNIQUE. it will not return
# FIXED

# it's still returning only one bar (annual) and I'm not sure why 
# FIXED!! ~unique(polygonID) was also too unique, seems like being too unique is the theme here

# also the data frame it prints consistently has the wrong kelp bed 
# fixed by above

# minor problem: some small amount of polygons have disappeared since i fixed the last thing
# major problem: it's super ugly, and rae wants to make it a line graph
