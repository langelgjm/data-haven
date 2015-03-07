setwd("/Users/gjm/Documents/_Works in Progress/DataHaven/")

# Test if necessary packages are installed, and load them
required_packages <- c("rgdal", "lattice", "shiny", "ggplot2", "RColorBrewer")
required_packages_test <- sapply(required_packages, require, character.only=TRUE)
if (any(ifelse(required_packages_test, FALSE, TRUE))) {
  stop(paste("Missing package", required_packages[! required_packages_test], "\n"))
} else {
  print("Loaded all required packages.\n")
}

# Read survey data
load("DataHavenRecoded.Robj")

# Read GIS data
ct <- readOGR(dsn="maps/Town_Index_shp", layer="TOWN_INDEX")

# Aggregate and merge the two
#town_list <- c("Milford", "Orange", "Woodbridge", "Bethany", "Hamden", "North Haven", "North Branford", "Guilford", "Madison", "Branford", "East Haven", "New Haven", "West Haven")
#town_codes <- c(9,12,13,5,3,11,10,7,8,6,2,1,4)
#gnh <- ct[ct$TOWN %in% town_list,]
gnh$ring <- 3
gnh$ring[gnh$TOWN=="New Haven"] <- 1
gnh$ring[gnh$TOWN %in% c("West Haven", "Hamden", "East Haven")] <- 2
#gnh$town <- NA
#gnh$town_code <- town_codes[match(gnh$TOWN, town_list)]
#myscale <- function(x) {(x - min(x)) / (max(x) - min(x))}
ring_means <- aggregate(dhr, list(dhr$ring), mean, na.rm=TRUE)
gnh_ring_means <- merge(gnh, ring_means, by.x="ring", by.y="ring")
ring_samp_size = as.data.frame(table(dhr$ring))
#ring_samp_size$Freq_scaled = myscale(ring_samp_size$Freq)
#gnh_ring_means <- merge(gnh_ring_means, ring_samp_size, by.x="ring", by.y="Var1")
# Cell sizes too small to plot by town, but code may be useful in the future
#town_means <- aggregate(dhr, list(dhr$town), mean, na.rm=TRUE)
#gnh_town_means <- merge(gnh, town_means, by.x="town_code", by.y="Group.1")
#town_samp_size = as.data.frame(table(dhr$town))
#town_samp_size$Freq_scaled = myscale(town_samp_size$Freq)
#gnh_town_means <- merge(gnh_town_means, town_samp_size, by.x="town_code", by.y="Var1")

radio_factors <- c("gender", "racer", "ring")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$samplesizes <- renderTable({
    if (input$radio == 0) {
      table(dhr$ring, dnn="Freq")
    } else {
      table(dhr$ring, dhr[,radio_factors[as.numeric(input$radio)]],
            dnn=c("Ring", radio_factors[as.numeric(input$radio)]))
    }
  })
  output$map <- renderPlot({
    # Remove the border around the map and legend
    trellis.par.set(axis.line=list(col=NA))
#    if (input$radio == 0) {
    # TODO: adjust the color range to match the variance of means in the data somehow
    spplot(gnh_ring_means, zcol=input$variable,
           col.regions=rainbow(64,start=200/360),
           main=input$variable,
           sp.layout=list("sp.text", coordinates(gnh), gnh$TOWN, cex=0.8, col="black"),
           col=NA)
#    } else {
      # Here we need to reaggregate the dataset to compute new means
      # The aggregation variables need to be ring AND something else
      # Alternatively we need to create new columns that specify mean by group?
      #new_ring_means <- aggregate(dhr, list(dhr$ring, dhr[,input$variable]), mean, na.rm=TRUE)
      #new_gnh <-
      #new_gnh_ring_means <- merge(gnh, new_ring_means, by.x="ring", by.y="ring")
#    }
  })
  output$hist <- renderPlot({
    if (input$radio == 0) {
      ggplot(dhr, aes_string(x=input$variable)) + geom_bar(fill="gray", color="black") + theme_classic()
    } else {
      ggplot(dhr, aes_string(x=input$variable, fill=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"))) + geom_bar(position="dodge") + theme_classic()
    }

  })
  output$boxplot <- renderPlot({
    if (input$radio == 0) {
      ggplot(dhr, aes_string(y=input$variable)) +
        geom_boxplot(aes(x=factor(1))) +
        xlab("Group") +
        coord_flip() +
        theme_classic()
    } else {
      ggplot(dhr, aes_string(y=input$variable,
                             x=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"),
                             fill=paste0("as.factor(", radio_factors[as.numeric(input$radio)], ")"))) +
        geom_boxplot() +
        xlab("Group") +
        coord_flip() +
        theme_classic()
    }
  })
  #output$summary <- renderTable({
  #  data.frame(Statistic=names(summary(dhr[,input$variable])), Value=c(summary(dhr[,input$variable])))
  #}, include.rownames=FALSE)
  output$crosstab <- renderTable({
    if (input$radio == 0) {
      table(dhr[,input$variable], dnn="Freq")
    } else {
      table(dhr[,input$variable], dhr[,radio_factors[as.numeric(input$radio)]])
    }
  })
})
