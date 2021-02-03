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
    titlePanel("Gill-net pressure on pink salmon size"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            p("Beginning with a population of size:"),
            
            numericInput("initialPopulationSize", "", 10000, 1000, 20000, 1000),
            p("Consider Salmon reproducing for this many generations under constant gill-net conditions:"),
            sliderInput("generations",
                        "",
                        min = 1,
                        max = 100,
                        value = 5,
                        step=1),
            p("The probability of a fish encountering a gill-net is:"),
            sliderInput("P.net.encounter",
                        "",
                        min = 0,
                        max = 1,
                        value = .25,
                        step = .05),
            p("The holes in the gill-net will catch all fish who encounter the net and are over this size (in lbs)"),
            sliderInput("NetSize",
                        "",
                        min = 1,
                        max = 10,
                        value = 6,
                        step = .5),
            p("The average fish who lives to spawn will produce this many surviving offspring:"),
            sliderInput("reproduction.rate",
                        "",
                        min = .25,
                        max = 2,
                        value = 1.1,
                        step = .01),
            submitButton("Submit")
            
    ),


        # Show a plot of the generated distribution
        mainPanel(
            
            
            p("Salmon, starting with an initial population of size"), textOutput("initialPopulationSize"),
            p("and size distribution (darkest line below), encounter gill-nets across a river with probability "), textOutput("P.net.encounter"),
            p("Some fish will swim around the nets, but some fish encounter the nets.  
              Fish bigger than the size of the holes in the net will get caught and will not survive to reproduce.
              Smaller fish will swim through the holes in the gill-net and spawn an average of"), textOutput("reproduction.rate"),
            p("fish who survive to the next generation.  Fish fry will be similar in size to their parents, but the size of the fry are random."),
            radioButtons("Density.Plot.Indicator", "",
                         c("plot normalized densities" = 1,
                           "plot frequencies per 0.02 lb window" = 0)),
            # plotOutput("distPlot"),
            plotOutput("DensPlot"),
            plotOutput("PopPlot"),
            plotOutput("BioMassAll"),
            # plotOutput("Biomass"),
            # plotOutput("Caughtmass"),
            p("Notice how the distribution of fish sizes shrinks well below the gill-net size. Smaller fish are more successful against the nets."),
            h3("limitations"),
            p("Fish may have better survival rates in the ocean if they are larger, but the current model does not consider upwards pressure in size."),
            p("Fish fry are normally distributed around the mean of their parent (there is no mixing of male and female fish to produce offspring).  The standard deviation of the fish fry is 1."),

        )
    )
)
)