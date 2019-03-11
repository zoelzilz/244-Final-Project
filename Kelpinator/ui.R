#
# This is the user-interface definition
#
''
shinyUI( navbarPage("Kelpinator",
                    
                    ##define tabs used
                    #introduction splash
                    tabPanel("App Overview",
                             includeMarkdown("./md/intro.Rmd"),
                             hr()
                             ),
                   
                   ## This panel needs a clickable map input and a barchart output
                   tabPanel("California Kelp Biomass Explorer",
                            
                            # plot the map
                            leafletOutput("harvestbedmap", height = 1000),
                           
                            # add the header/info panel
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
                                          p("This map shows", em("Macrocystis pyrifera"), "harvest beds in Southern California. Use the buttons below to toggle between interactive visualization of kelp biomass loss due to wave activity throughout the year, or to visualize current kelp biomass in each historical kelp bed. You can also choose to show or hide the historical kelp beds.")
                            ),
                            
                            #panel with the plot
                            absolutePanel(id = "plot",
                                          class = "panel panel-default",
                                          fixed = T,
                                          draggable = T,
                                          top = 350,
                                          left = "auto",
                                          right = 20,
                                          bottom = "auto",
                                          width = "25%",
                                          height = "auto",
                                          plotOutput("plot", height = 500))
                   ),
                   
                   ## This panel has a radiobutton menu widget input and a heatmap output
                   tabPanel("Kelp Biomass Loss per Month",
                            
                            # this tab needs to be so much nicer looking
                            
                            fluidRow(column(12,
                                            h1("Kelp biomass loss changes seasonally"),
                                            #p("."),
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
                            ),
                            
                            ## This panel needs three separate dropdowns whose responses interact 
                            tabPanel("Economic Consequence of Kelp Loss")
                   )))

