#
# This is the user-interface definition
#
''
shinyUI(navbarPage("Kelpinator (for now)",
                   ## This panel needs a clickable map input and a barchart output
                   tabPanel("Kelp Biomass Loss per Month",
                            fluidRow(column(12,
                                            h1("Kelp biomass loss changes seasonally"),
                                            p("."),
                                            br(),
                                            h4("Instructions"),
                                            p("Use the radio buttons on the left to chose a month."))),
                            hr(),
                            fluidRow(sidebarPanel(width = 3,
                                                  h4("Month"),
                                                  helpText("Chose from the following."),
                                                  radioButtons("Month", NULL,
                                                               c("January" = "January",
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
                                     mainPanel(plotOutput("barchart", height = 500)))
                   ),
                            #sidebarPanel([inputs for the first tab]),
                            #mainPanel([outputs for the first tab])
                   ),
             
                   ## This panel needs a dropdown menu widget input and a heatmap output
                   tabPanel("Second tab name",
                            #sidebarPanel([inputs for the second tab]),
                            #mailPanel([outputs for the second tab])
                   ),
                   tabPanel("Economic Consequence of Kelp Loss")
))




#create base map
leafletOutput("mymap",height = 1000)