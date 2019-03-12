#
# This is the user-interface definition
#
''
shinyUI( navbarPage("Kelpinator",
                    theme = shinytheme("superhero"),
                    
                    ##define tabs used
                    #introduction splash
                    tabPanel("App Overview",
                             fluidRow(
                               sidebarLayout(position = "right", 
                                             sidebarPanel(img(src = "kelp_image.jpg", height="600px", width="300px", align="right")),
                               mainPanel(includeMarkdown("./md/intro.Rmd"),
                             hr()
                            )))),
                             
                   
                   ## This panel needs a clickable map input and a barchart output
                   tabPanel("California Kelp Biomass Explorer",
                            
                            # plot the map
                            leafletOutput("harvestbedmap", height = 623),
                           
                            # add the header/info panel
                            absolutePanel(id = "description",
                                          class = "panel panel-default",
                                          fixed = T,
                                          draggable = T,
                                          top = 100,
                                          left = 20,
                                          right = "auto",
                                          bottom = "auto",
                                          width = "25%",
                                          height = "auto",
                                          # set content of panel
                                          includeMarkdown("./kelp_biomass_explorer_text.Rmd")
                                          
                            ),
                            
                            #panel with the plot
                            absolutePanel(id = "plot",
                                          class = "panel panel-default",
                                          fixed = T,
                                          draggable = T,
                                          top = 100,
                                          left = "auto",
                                          right = 20,
                                          bottom = "auto",
                                          width = "25%",
                                          height = "auto",
                                          plotOutput("plot", height = 300))
                   ),
                   
                   ## This panel has a radiobutton menu widget input and a heatmap output
                   tabPanel("Heatmaps of Monthly Kelp Biomass Loss", 
                            
                            # this tab needs to be so much nicer looking
                            
                            fluidRow(column(12,
                                            h2("Average expected monthly and annual biomass loss for kelp in the Santa Barbara Channel"),
          
                                            h4("Use the radio buttons on the left to chose a month for visualizing kelp loss"),
                                            p())),
                            hr(),
                            fluidRow(sidebarPanel(width = 3,
                                                  h4("Month"),
                                                  helpText("Chose from the following:"),
                                                  
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
                   )))


