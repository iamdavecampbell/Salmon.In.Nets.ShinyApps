#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

# Define UI for application that draws a histogram
shinyUI(fluidPage(

    # Application title
    titlePanel("Salmon in the nets"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            p("Salmon reproduce for this many generations:"),
            sliderInput("generations",
                        "",
                        min = 1,
                        max = 100,
                        value = 5),
            p("The gill-net covers this proportion of the river:"),
            sliderInput("P.net.encounter",
                        "",
                        min = 0,
                        max = 1,
                        value = .25),
            p("The holes in the gill-net will catch all fish who encounter the net and are over this size (in lbs)"),
            sliderInput("NetSize",
                        "",
                        min = 1,
                        max = 10,
                        value = 3)
    ),


        # Show a plot of the generated distribution
        mainPanel(
            p("Salmon, starting with an initial size distribution (darkest line below), encounter gill-nets across a river.  
              Some fish will swim around the nets, but some fish encounter the nets.  
              Fish bigger than the size of the holes in the net will get caught and will not survive to reproduce.
              Smaller fish will swim through the holes in the net and will be able to reproduce.
              Fish fry will be similar in size to their parents, but the size of the fry are random."),
            plotOutput("distPlot"),
            p("Notice how the distribution of fish sizes shrinks well below the gill-net size. Smaller fish are more successful against the nets."),
            h3("limitations"),
            p("Fish may have better survival rates in the ocean if they are larger, but the current model does not consider upwards pressure in size."),
            
            
        )
    )
)
)