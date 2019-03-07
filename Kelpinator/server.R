#
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
        img(height = 500, width = 300, src = "annual.png")
      }                                        
    else if(input$Month == "January"){
      img(height = 500, width = 300, src = "jan.png")
    }
    else if(input$Month == "February"){
      img(height = 500, width = 300, src = "feb.png")
    }
    
    
  })
  
  # first tab
  # create the leaflet map 
  
  output$harvestbedmap <- renderLeaflet({
    m <- leaflet() %>% 
      addTiles() %>% 
      setView(lng = -118.5204798, lat = 33.95851, zoom = 8.32) #pick a prettier basemap
    m
    )}
  
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

