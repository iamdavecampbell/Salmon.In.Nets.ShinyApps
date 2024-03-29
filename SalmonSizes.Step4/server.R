
#

library(shiny)
library(tidyverse)

shinyServer(function(input, output) {
    # include some dynamic text.  Here I get the server to produce text output
    # and I use it to print the values within the ui using "textOutput"
    #These are just inputs that are brought to the server and then rendered as part of the ui
    output$initialPopulationSize <- renderText({ input$initialPopulationSize })
    
    output$P.net.encounter <- renderText({ input$P.net.encounter })
    
    output$reproduction.rate <- renderText({ input$reproduction.rate })
    
    
    output$distPlot <- renderPlot({
        N = input$initialPopulationSize # number of fish to start
        T = input$generations # generations
        FishSizeSD = 1        #sd for fish
        #512 is the default number of increments for density
        FishDensityThatWeKeep = matrix(NA, nrow=512,ncol=T, dimnames = list(NULL, paste("Gen",1:T,sep=".")))
        LivingFishSize = rnorm(N, mean = 6, sd = FishSizeSD)# in lbs, size of current fish distribution.
        FishDensityThatWeKeep[,"Gen.1"]= density(LivingFishSize, from = 0, to = 10)$y*(as.numeric(input$Density.Plot.Indicator)*(N-1)+1) #Current density of fish unscaled back into frequency
        
        for(generation in 2:T){

            EncounterNet = runif(length(LivingFishSize))<input$P.net.encounter ###### FROM INPUT
            SurviveIfInNet = LivingFishSize<input$NetSize         #fish this size or larger get caught if they encounter the net
            Fish.At.Last.Gen = data.frame(LivingFishSize, EncounterNet, SurviveIfInNet)
            Fish.Parents.For.Next.Gen = Fish.At.Last.Gen%>% filter(EncounterNet==FALSE | (EncounterNet ==TRUE & SurviveIfInNet ==TRUE) & LivingFishSize>0)%>%
                                        dplyr::select(LivingFishSize)
            #this ensures that only survivors can reproduce and that the population stays constant in count.
            Fish.Parents.For.Next.Gen.Size = Fish.Parents.For.Next.Gen[sample(1:nrow(Fish.Parents.For.Next.Gen),
                                                                              size=rpois(n=1,lambda=nrow(Fish.Parents.For.Next.Gen)*input$reproduction.rate),
                                                                              replace=TRUE) ,1]
            LivingFishSize = rnorm(length(Fish.Parents.For.Next.Gen.Size),mean = Fish.Parents.For.Next.Gen.Size, sd = FishSizeSD)
            FishDensityThatWeKeep[,generation] = density(LivingFishSize, from = 0, to = 10)$y*
                                      (as.numeric(input$Density.Plot.Indicator)*(length(Fish.Parents.For.Next.Gen.Size)-1)+1)
                
        }
        # Add in the x values to go with the density
        FishDensityThatWeKeep  = as_tibble(FishDensityThatWeKeep) %>% mutate(fishmass = density(LivingFishSize, from = 0, to = 10)$x)
        ylabel=c("Frequency","Density") # sneaky trick to allow for the radio button selection of type of plot.  Define this and use it below for the label
        FishDensityThatWeKeep %>% pivot_longer(names_to = "Generation", # reshape the tibble for plotting
                                               values_to = "DensityOfMass",
                                                col = -fishmass) %>%
            mutate(Generation = as.numeric(gsub(Generation,pattern = "Gen.",replacement = "")))%>%
        ggplot( aes(x = fishmass, y = DensityOfMass, colour = Generation )) +
            geom_point()+
            geom_vline(xintercept = input$NetSize, lwd=3,col="red")+
            ggtitle("Distribution of salmon weight in each generation after responding to Gill-net pressure")+
            labs(y = ylabel[1+as.numeric(input$Density.Plot.Indicator)],x="weight of fish in lbs")# see above where ylabel is defined.

    })

})
