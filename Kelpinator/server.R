#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# called once each session

server <- function(input,output, session){
}

output$mymap <- renderLeaflet({
  m <- leaflet() %>%
    addTiles() %>%
    setView(lng=-119.6247004, lat=33.6884588 , zoom=8.06)
  m
})