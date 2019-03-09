## THIS CODE WORKS 3/9 IN CASE WE BREAK THE SERVER ##

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











#THIS CODE WORKS IN CASE WE BREAK THE SERVER#

# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# called once each session

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
    m <- leaflet() %>% 
      addTiles() %>% 
      setView(lng = -118.5204798, lat = 33.95851, zoom = 8.32) #pick a prettier basemap
    m
  })
  
  # bar chart output for first tab
  #output$barchart <- renderPlot({
  # if ( input$day == "Both" ) {
  #   journeyTimeHist.f(combined)
  # } else if ( input$day == "Weekend") {
  #  journeyTimeHist.f(combined, "Weekend")
  # } else if ( input$day == "Weekday") {
  #   journeyTimeHist.f(combined, "Weekday")
  # }
  # })
}



################## this UI code is NOT WORKING but is formatted how we want and has stuff we want

#
# This is the user-interface definition
#
''
shinyUI(navbarPage("Kelpinator",
                   
                   ## This panel needs a clickable map input and a barchart output
                   tabPanel("California Kelp Biomass Explorer",
                            
                            # plot the map
                            leafletOutput("harvestbedmap", height = 1000),
                            div(class="outer",
                                tags$head(
                                  includeCSS("./css/styles.css"))),
                            # add the overlay panel
                            absolutePanel(id = "description",
                                          class = "panel panel-default",
                                          fixed = T,
                                          draggable = T,
                                          top = 90,
                                          left = "auto",
                                          right = 20,
                                          bottom = "auto",
                                          width = "25%",
                                          height = "auto",
                                          # set content of panel
                                          h1("Kelp Harvest Bed Explorer"),
                                          p("This map shows kelp harvest beds in Southern California.")
                            ),
                            sidebarPanel(plotOutput("plot", height = 500)))
),

## This panel needs a radiobutton menu widget input and a heatmap output
tabPanel("Kelp Biomass Loss per Month",
         
         # informative text to accompany widget
         
         fluidRow(column(12,
                         h1("Kelp biomass loss changes seasonally"),
                         p("ploot"),
                         br(),
                         h4("Instructions"),
                         p("Use the radio buttons on the left to chose a month."))),
         
         fluidRow(sidebarPanel(width = 3,
                               h4("Month"),
                               helpText("Choose from the following."),
                               
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
         )),

## This panel needs three separate dropdowns whose responses interact 
tabPanel("Economic Consequence of Kelp Loss")
)
