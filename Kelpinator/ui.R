#
# This is the user-interface definition
#

ui <- fluidPage(
  print("Hello World!")
)

#create base map
leafletOutput("mymap",height = 1000)