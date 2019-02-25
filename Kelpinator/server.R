#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# called once each session

server <- function(input,output, session){
  # map output for first tab (there are so many ways to do this, WIP)
  output$mymap <- renderLeaflet({
    m <- leaflet() %>%
      addTiles() %>%
      setView(lng=-119.6247004, lat=33.6884588 , zoom=8.06)
    m
    
    
  })
  
  # bar chart output for second tab
  output$barchart <- renderPlot({
    if ( input$day == "Both" ) {
      journeyTimeHist.f(combined)
    } else if ( input$day == "Weekend") {
      journeyTimeHist.f(combined, "Weekend")
    } else if ( input$day == "Weekday") {
      journeyTimeHist.f(combined, "Weekday")
    }
  })
}

