#
# This is the user-interface definition
#
''
shinyUI(navbarPage("Kelpinator (for now)",
                   
                   ## This panel needs a clickable map input and a barchart output
                   tabPanel("Monthly Kelp Biomass Loss by Area",
                            
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
                                          )
                            #mainPanel(plotOutput("barchart", height = 500))),
                            ),
             
                   ## This panel needs a radiobutton menu widget input and a heatmap output
                   tabPanel("Kelp Biomass Loss per Month",
                            
                            # informative text to accompany widget
                            
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


