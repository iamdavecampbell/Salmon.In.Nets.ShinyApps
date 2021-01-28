#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(tidyverse)

shinyServer(function(input, output) {
    output$distPlot <- renderPlot({
        N = 1000 # number of fish to start
        T = 3 # generaions
        P.net.encounter  = .5 #probability of encountering the net
        FishSizeSD = 1        #sd for fish
        NetSize = 6           #fish this size or larger get caught if they encounter the net
        #512 is the default number of increments for density
        FishDensityThatWeKeep = tibble(matrix(NA, nrow=512,ncol=T, dimnames = list(NULL, paste("Gen",1:T,sep=".")))) #ADDED NAMES
        LivingFishSize = rnorm(N, mean = 6, sd = FishSizeSD)# in lbs, size of current fish distribution.
        FishDensityThatWeKeep[,1] = density(LivingFishSize, from = 0, to = 10)$y #Current density of fish <-- moved this out of the loop
        
        for(generation in 2:T){ #<-- NOW BEGINS at generation 2
            
            EncounterNet = runif(N)<P.net.encounter
            SurviveIfInNet = LivingFishSize<NetSize
            Fish.At.Last.Gen = data.frame(LivingFishSize, EncounterNet, SurviveIfInNet)
            Fish.Parents.For.Next.Gen = Fish.At.Last.Gen%>% filter(EncounterNet==FALSE | (EncounterNet ==TRUE & SurviveIfInNet ==TRUE))%>% 
                                        dplyr::select(LivingFishSize)
            #this ensures that only survivors can reproduce and that the population stays constant in count.
            Fish.Parents.For.Next.Gen.Size = Fish.Parents.For.Next.Gen[sample(1:nrow(Fish.Parents.For.Next.Gen),size=N,replace=TRUE) ,1]
            LivingFishSize = rnorm(N,mean = Fish.Parents.For.Next.Gen.Size, sd = FishSizeSD) 
            FishDensityThatWeKeep[,generation] = density(LivingFishSize, from = 0, to = 10)$y #get the density of the fish at the end of the time increment
        }
        # Add in the x values to go with the density
        FishDensityThatWeKeep  = FishDensityThatWeKeep %>% mutate(fishmass = density(LivingFishSize, from = 0, to = 10)$x)
        # NEW FUNCTION TO COMBINE DATASET FOR PLOTTING
        FishDensityThatWeKeep %>% gather(key = Generation, 
                                                value = DensityOfMass, 
                                                -fishmass) %>%
        ggplot( aes(x = fishmass, y = DensityOfMass, colour = Generation )) +
            geom_point()

    })

})
