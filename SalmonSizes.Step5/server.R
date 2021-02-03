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
# require(gridExtra,lib.loc="/srv/shiny-server/dave-apps/Impact of Fishing Gear on Salmon Size")
# require(ggpubr,lib.loc="/srv/shiny-server/dave-apps/Impact of Fishing Gear on Salmon Size")
library(gridExtra)

shinyServer(function(input, output) {

    output$initialPopulationSize <- renderText({ input$initialPopulationSize })
    
    output$P.net.encounter <- renderText({ input$P.net.encounter })
    
    output$reproduction.rate <- renderText({ input$reproduction.rate })
    
    plots2make = reactive({
        N = input$initialPopulationSize # number of fish to start
        T = input$generations # generaions
        FishSizeSD = 1        #sd for fish
        #512 is the default number of increments for density
        FishDensityThatWeKeep = matrix(NA, nrow=512,ncol=T, dimnames = list(NULL, paste("Gen",1:T,sep=".")))
        LivingFishSize = rnorm(N, mean = 6, sd = FishSizeSD)# in lbs, size of current fish distribution.
        FishDensityThatWeKeep[,"Gen.1"]= density(LivingFishSize, from = 0, to = 10)$y*(as.numeric(input$Density.Plot.Indicator)*(N-1)+1) #Current density of fish unscaled back into frequency
        Npop = c(N, rep(NA, T-1))
        CaughtBiomass= rep(NA, T)
        SurvivingBiomass= c(sum(LivingFishSize), rep(NA, T-1))
        for(generation in 2:T){
            
            EncounterNet = runif(length(LivingFishSize))<input$P.net.encounter ###### FROM INPUT
            SurviveIfInNet = LivingFishSize<input$NetSize         #fish this size or larger get caught if they encounter the net
            
            
            Fish.At.Last.Gen = data.frame(LivingFishSize, EncounterNet, SurviveIfInNet)
            CaughtBiomass[generation-1] =  Fish.At.Last.Gen%>% filter(EncounterNet ==TRUE & SurviveIfInNet ==FALSE & LivingFishSize>0)%>%
                dplyr::select(LivingFishSize) %>% sum() #total mass of caught fish
            Fish.Parents.For.Next.Gen = Fish.At.Last.Gen%>% filter(EncounterNet==FALSE | (EncounterNet ==TRUE & SurviveIfInNet ==TRUE) & LivingFishSize>0)%>%
                dplyr::select(LivingFishSize)
            #this ensures that only survivors can reproduce and that the population stays constant in count.
            Fish.Parents.For.Next.Gen.Size = Fish.Parents.For.Next.Gen[sample(1:nrow(Fish.Parents.For.Next.Gen),
                                                                              size=rpois(n=1,lambda=nrow(Fish.Parents.For.Next.Gen)*input$reproduction.rate),
                                                                              replace=TRUE) ,1]
            Npop[generation] = length(Fish.Parents.For.Next.Gen.Size)
            LivingFishSize = rnorm(Npop[generation],mean = Fish.Parents.For.Next.Gen.Size, sd = FishSizeSD)
            FishDensityThatWeKeep[,generation] = density(LivingFishSize, from = 0, to = 10)$y*
                (as.numeric(input$Density.Plot.Indicator)*(Npop[generation]-1)+1)
            SurvivingBiomass[generation] = sum(LivingFishSize)
            
        }
        # Add in the x values to go with the density
        FishDensityThatWeKeep  = as_tibble(FishDensityThatWeKeep) %>% mutate(fishmass = density(LivingFishSize, from = 0, to = 10)$x)%>% 
            gather(key = Generation,
            value = DensityOfMass,
          -fishmass)
        
        ByGen = data.frame(generation = 1:T, Population.Count = Npop, SurvivingBiomass=SurvivingBiomass, CaughtBiomass=CaughtBiomass) 
        
        return(list(FishDensityThatWeKeep=FishDensityThatWeKeep,ByGen=ByGen))
    })
    
        
        
        output$DensPlot = renderPlot({
            ylabel=c("Frequency","Density")
            plots2make()$FishDensityThatWeKeep%>%
            mutate(Generation = as.numeric(gsub(Generation,pattern = "Gen.",replacement = "")))%>%
            ggplot( aes(x = fishmass, y = DensityOfMass, colour = Generation )) +
            geom_point()+
            geom_vline(xintercept = input$NetSize, lwd=3,col="red")+
            ggtitle("Distribution of salmon weight in each generation after responding to Gill-net pressure")+
            labs(y = ylabel[1+as.numeric(input$Density.Plot.Indicator)],x="weight of fish in lbs")
        })
        
        
        

        output$PopPlot = renderPlot({
            plots2make()$ByGen %>%
            ggplot( aes(x = generation, y = Population.Count )) +
            geom_line(,colour="blue")+
            geom_point()+
            ggtitle("Population count")+
            labs(y = "Generation",x="Total fish population count")
        })
        
        output$BioMassAll = renderPlot({
            plots2make()$ByGen %>%
                gather(key = BiomassType,
                       value = Biomass,
                       -generation,-Population.Count)%>%
            ggplot( aes(x = generation, y = Biomass,colour=BiomassType )) +
                    geom_line()+
                    geom_point()+
                    ggtitle("Total Biomass of fish remaining for next generation")+
                    labs(y = "Generation",x="Surviving fish biomass")
                })
        
        # 
        # output$Biomass = renderPlot({
        #     plots2make()$ByGen%>%
        #     ggplot( aes(x = generation)) +
        #     geom_line(aes( y = SurvivingBiomass ),colour="blue")+
        #     geom_point(aes( y = SurvivingBiomass ))+
        #     ggtitle("Total mass of fish remaining for next generation")+
        #     labs(y = "Generation",x="Surviving fish biomass")
        # })
        # 
        # output$Caughtmass = renderPlot({
        #     plots2make()$ByGen%>%
        #     ggplot( aes(x = generation)) +
        #     geom_line(aes( y = CaughtBiomass ),colour="blue")+
        #     geom_point(aes( y = CaughtBiomass ))+
        #     ggtitle("Total mass of fish caught in the Gill-net in each time step")+
        #     labs(y = "Generation",x="Biomass of caught fish")
        # })
    
    # })
    

})
