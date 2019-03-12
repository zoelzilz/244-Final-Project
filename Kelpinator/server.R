#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# called once each session

library(leaflet)
library(shiny)
library(ggplot2)
#library(sf)
library(tidyverse)
library(rgdal)
library(RColorBrewer)

###################################################################################################
#load the data
###################################################################################################

# the map data we need is a SpatialPolygonsDataframe, created in another script 
# (currently in the data_vis_shp.Rmd) and saved as a new SPD

# it is called:
kelp_intersected <- readOGR(".", layer = "kelp_intersected")#%>% 
#fct_relevel(kelp_intersected@data$month, "Annual", "January", "February", "March", "April", "May", "June", "July", "August", "September","October", "November","December" )

#above did not work to relevel, trying instead:
kelp_intersected@data$month <- factor(kelp_intersected@data$month, levels = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December", "Annual"))

kelp_intersected@data$polygonID <- paste(kelp_intersected@data$lon,kelp_intersected@data$lat)
#kelp_intersected@data <- kelp_intersected@data %>% 
#  mutate( polygonID, cbind(lon, lat))

#worked
# ssh is our significant wave height
# kelp_loss is our main response variable

# also loading Tom's kelp data

tomkelp<- read_csv ("kelp_data_Bell.csv")

# we also need the historic kelp bed data, separately i think

harvest_beds <- readOGR("MAN_CA_KelpAdmin", layer = "MAN_CA_KelpAdmin") 
harvest_beds <- spTransform(harvest_beds, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))

############################################################################
# adding some fluff (should go in another script within R file, but not sure what to name that script or how to call)

#creating bins for adding binned color to maps 
#max(kelp_intersected@data$kelp_loss)
#68.37364
#min(kelp_intersected@data$kelp_loss)
#8.423632

# setting up labels
labels <- sprintf(
  "<strong>Kelp Bed: %g</strong><br/> Significant Wave Height: %s ",
  kelp_intersected@data$KelpBed, kelp_intersected@data$ssh #can check everything is calling right polgons by changing to polygonID #
) %>% lapply(htmltools::HTML)

labels2 <- sprintf(
  "<strong>Kelp Bed: %g</strong>",
  harvest_beds@data$KelpBed) %>% 
  lapply(htmltools::HTML)

# setting up popup text
popup <- paste0("<strong> Kelp Biomass (kg of fresh canopy): </strong>",
                tomkelp$Mean_Biomass)

popup2 <- paste0("<strong> Kelp Persistence: </strong>",
                  tomkelp$Kelp_Persistence)

# setting up color palette

#colourCount <- length(unique(kelp_intersected@data$kelp_loss))
#getPalette <- colorRampPalette(brewer.pal(9, "Spectral"))

bins <- seq(8,68, 10) # based on kelp_loss, need to seq from min to max


#defining a color palette, which needs to have at least 68 colors
pal <- colorBin("Spectral", domain = kelp_intersected@data$kelp_loss, bins = bins)

###########################################################################

###################################################################################################

server <- function(input,output, session){

  
  # first tab
  # create the leaflet map 
  
  output$harvestbedmap <- renderLeaflet({
    leaflet(kelp_intersected) %>% 
      addProviderTiles(providers$Esri.WorldImagery) %>% 
      setView(lng = -119.0416309, lat = 33.7494118, zoom = 8) %>%  #pick a prettier basemap
      
      # Kelp Loss polygons (currently not showing all polygons because of layerID)
      addPolygons(data = , 
                  fillColor = ~pal(kelp_loss), #getPalette(colorCount),
                  group = "Kelp Percent Biomass Loss",
                  weight = 2,
                  opacity = 1,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "#666",
                    dashArray = NULL,
                    fillOpacity = 0.7,
                    bringToFront = TRUE
                    ),
                  layerId = ~polygonID,
                  label = labels,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
                  ) %>% 
      
      
      # add a new layer with kelp bed biomass 
      addCircles(data = tomkelp, 
                 radius = ~0.01*Mean_Biomass,
                 color = "yellow",
                 fillColor = "yellow",
                       lng = ~Lon, 
                       lat = ~Lat, 
                       popup =  popup, 
                       group = "Current Kelp Biomass") %>% 
      
      # add a new layer with kelp persistence 
      addCircles(data = tomkelp, 
                 radius = ~3000*Kelp_Persistence,
                 color = "goldenrod",
                 fillColor = "goldenrod",
                 lng = ~Lon, 
                 lat = ~Lat, 
                 popup =  popup2, 
                 group = "Kelp Persistence") %>% 
      
      # add historic kelp beds
      addPolygons(data = harvest_beds, fillColor = "green",
                  group = "Historic Kelp Beds",
                  weight = 2,
                  opacity = 1,
                  color = "green",
                  dashArray = "3",
                  fillOpacity = 0.3,
                  highlight = highlightOptions(
                    weight = 5,
                    color = "darkgreen",
                    dashArray = "",
                    fillOpacity = 0.3,
                    sendToBack = TRUE),
                  label = labels2,
                  labelOptions = labelOptions(
                    style = list("font-weight" = "normal", padding = "3px 8px"),
                    textsize = "15px",
                    direction = "auto")
      ) %>% 
      addLayersControl(baseGroups = c( "Current Kelp Biomass", "Kelp Percent Biomass Loss", "Kelp Persistence"), 
                       overlayGroups = c("Historic Kelp Beds"),
                       options = layersControlOptions(collapsed = FALSE),
                       position = "bottomleft")
      #hideGroup("Current Kelp Biomass")
      #hideGroup("Kelp Percent Biomass Loss")  
      
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
    ggplot(data = ggplot_data() %>% filter(month !="Annual"), aes(month, kelp_loss)) + # idk what the parenthenses do but without them it throws an error about data object being wrong type
      geom_point(stat = "identity")+
      geom_line(group = 1)+
      ylab("Percent Kelp Biomass Loss")+
      xlab("Month")+
      geom_hline(data = ggplot_data() %>% filter(month == "Annual"), aes(yintercept = kelp_loss), linetype = 2, size = 2, colour = "coral", show.legend = TRUE)+
      #scale_linetype_manual(name = "--Annual Kelp Loss", values = c(2))+ 
                            #guide = guide_legend(override.aes = list(color = "coral")))+ #legend wont work
      labs(subtitle = "-- Annual Kelp Loss --")+
      theme(panel.grid.major = element_blank(), 
            panel.grid.minor = element_blank(),
            panel.background = element_blank(), 
            axis.line = element_line(colour = "black"),
            plot.subtitle = element_text( size = 14,face ="bold",hjust = 0.7, vjust = -0.1, color = "coral"),
            axis.text.x=element_text(angle=45, hjust=1))

      #scale_y_continuous(limits = c(0, 70))+  # can't make this consistent, loss hugely different between polygons
      
    
    
     
      #+geom_label(aes(label = KelpBed),color="green") # JUST WANT TO ADD ONE LABEL THAT PRINTS THE KELP BED JESUS
  })
  
  #######################
  # maps output for tab 2
  ########################
  
  output$heatmap <- renderUI({
    if(input$Month == "Annual"){            
      img(height = 700, width = 700, src = "annual.png")
    }                                        
    else if(input$Month == "January"){
      img(height = 700, width = 700, src = "january.png")
    }
    else if(input$Month == "February"){
      img(height = 700, width = 700, src = "february.png")
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

}

