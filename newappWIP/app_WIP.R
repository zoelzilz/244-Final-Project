library(leaflet)
library(shiny)
library(ggplot2)
#library(sf)
library(tidyverse)
library(rgdal)
library(forcats)

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
kelp_intersected <- readOGR(".", layer = "kelp_intersected") #%>% 
#fct_relevel(kelp_intersected@data$month, "Annual", "January", "February", "March", "April", "May", "June", "July", "August", "September","October", "November","December" )

#above did not work to relevel, trying instead:
kelp_intersected@data$month <- factor(kelp_intersected@data$month, levels = c("January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"))

#worked


# can easily view and access dataframe within using @
# kelp_loss is our dependent variable
# do NOT View() the entire shapefile!!
# only View(kelp_intersected@data) or in pieces because this badboy WILL take 15 minutes to load and then crash your computer

ui <- navbarPage("Kelpinator", # putting this inside of titlePanel() makes it look super ugly
                 
                 ## This panel has a clickable map input and a barchart output
                 tabPanel("California Kelp Biomass Explorer",
                          
                          # plot the map
                          leafletOutput("harvestbedmap", height = 1000),
                          
                          # aFIX THIS TO MAKE IT LOOK PRETTIER
                          absolutePanel(id = "description",
                                        class = "panel panel-default",
                                        fixed = T,
                                        draggable = T,
                                        top = 40, #was 90
                                        left = "auto",
                                        right = 20,
                                        bottom = "auto",
                                        width = "25%",
                                        height = "auto",
                                        # set content of panel
                                        h1("Kelp Harvest Bed Explorer"),
                                        p("This map shows kelp harvest beds in Southern California. Click__ to interactively view how kelp biomass is lost due to wave activity throughout the year. Click ___ to visualize kelp biomass in each historical kelp bed.")
                          ),
                          
                          #panel with the plot
                          absolutePanel(id = "plot",
                                        class = "panel panel-default",
                                        fixed = T,
                                        draggable = T,
                                        top = 300,
                                        left = "auto",
                                        right = 20,
                                        bottom = "auto",
                                        width = "25%",
                                        height = "auto",
                                        plotOutput("plot", height = 300))
                 ),
                 
              
                 tabPanel("Kelp Biomass Loss per Month",
                          
                          # informative text to accompany widget
                          
                          fluidRow(column(12,
                                          h1("Kelp biomass loss changes seasonally"),
                                          #pr(),
                                          #br(),
                                          h4("Instructions"),
                                          p("Use the radio buttons on the left to chose a month."))),
                          hr(),
                          fluidRow(sidebarPanel(width = 3,
                                                h4("Month"),
                                                helpText("Chose from the following."),
                                                
                                                # input tab2
                                                radioButtons("Month", NULL,
                                                             c("Annual" = "Annual",
                                                               "January" = "January",
                                                               "February" = "February",
                                                               "March" = "March",
                                                               "April" = "April",
                                                               "May" = "May",
                                                               "June" = "June",
                                                               "July" = "July",
                                                               "August" = "August",
                                                               "September" = "September",
                                                               "October" = "October",
                                                               "November" = "November",
                                                               "December" = "December"))),
                                   
                                   # output tab2
                                   mainPanel(uiOutput("heatmap"))
                          )
                 
                 ))

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

# reordering month factor


###########################################################################

server <- function(input, output) {
  
  ## leaflet map
  output$harvestbedmap <- renderLeaflet({
    leaflet(kelp_intersected) %>% 
      addTiles() %>% 
      setView(lng = -118.5204798, lat = 33.95851, zoom = 8.32) %>%
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
                  layerId = ~polygonID, # had to remove ~unique(polygonID) because it FUCKED EVERYTHING UP ## BUT NOW some of the polygons are missing???
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
      geom_point()+
      geom_line(aes(group =1))
  })
  
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

shinyApp(ui, server)

##########################################################################################################
#                                 notes and issues 

# it's not working because layerID = ~unique(kelp_bed) is TOO UNIQUE. it will not return
# FIXED

# it's still returning only one bar (annual) and I'm not sure why 
# FIXED!! ~unique(polygonID) was also too unique, seems like being too unique is the theme here

# also the data frame it prints consistently has the wrong kelp bed 
# fixed by above

# minor problem: some small amount of polygons have disappeared since i fixed the last thing
# major problem: it's super ugly, and rae wants to make it a line graph

# second tab wont show up


