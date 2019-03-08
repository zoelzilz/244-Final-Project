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
