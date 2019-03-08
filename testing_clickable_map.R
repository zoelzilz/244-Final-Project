library(leaflet)
library(shiny)
library(ggplot2)
library(sf)
library(tidyverse)

# our shapefile data
annual_swh <- read_sf ("244-extra", layer = "vbl_ssh_allreg_annPolygon")
jan_swh <- read_sf ("244-extra/vbl_ssh_allreg_jan", layer = "vbl_ssh_allreg_janPolygon")
feb_swh <- read_sf ("244-extra/vbl_ssh_allreg_feb", layer = "vbl_ssh_allreg_febPolygon")
mar_swh <- read_sf ("244-extra/vbl_ssh_allreg_mar", layer = "vbl_ssh_allreg_marPolygon")
apr_swh <- read_sf ("244-extra/vbl_ssh_allreg_apr", layer = "vbl_ssh_allreg_aprPolygon")
may_swh <- read_sf ("244-extra/vbl_ssh_allreg_may", layer = "vbl_ssh_allreg_mayPolygon")
jun_swh <- read_sf ("244-extra/vbl_ssh_allreg_jun", layer = "vbl_ssh_allreg_junPolygon")
jul_swh <- read_sf ("244-extra/vbl_ssh_allreg_jul", layer = "vbl_ssh_allreg_julPolygon")
aug_swh <- read_sf ("244-extra/vbl_ssh_allreg_aug", layer = "vbl_ssh_allreg_augPolygon")
sep_swh <- read_sf ("244-extra/vbl_ssh_allreg_sep", layer = "vbl_ssh_allreg_sepPolygon")
oct_swh <- read_sf ("244-extra/vbl_ssh_allreg_oct", layer = "vbl_ssh_allreg_octPolygon")
nov_swh <- read_sf ("244-extra/vbl_ssh_allreg_nov", layer = "vbl_ssh_allreg_novPolygon")
dec_swh <- read_sf ("244-extra/vbl_ssh_allreg_dec", layer = "vbl_ssh_allreg_decPolygon")


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
ogr_annual_intersect2

# can easily view and access dataframe within using 
ogr_annual_intersect2@data <- ogr_annual_intersect2@data %>% 
  mutate(random_variable = sample(1:50, 1893, replace = TRUE))

# ssh is our significant wave height


ogr_annual_intersect2


ui <- fluidPage(column(7, leafletOutput("harvestbedmap", height = "1000")),
                column(5, plotOutput("plot", height = "600px"))
)

################
# adding some fluff (should go in another script within R file)

#creating bins for adding binned color to maps # not even remotely necessary #

bins <- c(0, 10, 20, 50, Inf) # based on the random variable I added

# defining a color palette, again, unnecessary 
pal <- colorBin("YlOrRd", domain = ogr_annual_intersect2@data$random_variable, bins = bins)

server <- function(input, output) {
  
  ## leaflet map
  output$harvestbedmap <- renderLeaflet({
    leaflet(ogr_annual_intersect2) %>% 
      addTiles() %>% 
      addPolygons(fillColor = ~pal(random_variable),
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
                    bringToFront = TRUE)
        
      )
      #addCircleMarkers(data = harvest_beds, ~unique(lon), ~unique(lat), layerId = ~unique(KelpBed), popup = ~unique(KelpBed)) 
  })
  
  # generate data in reactive
  #ggplot_data <- reactive({
   # bed <- input$harvestbedmap_polygon_click$id
    #harvest_beds[harvest_beds$KelpBed %in% bed,]
  #})
  
  #what we need is for this reactive to pull from another dataframe
  
  #output$plot <- renderPlot({
   # ggplot(data = ggplot_data(), aes(random_variable)) +
    #  geom_bar()
  #}) 
}

shinyApp(ui, server)