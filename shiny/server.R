setwd("/Users/gjm/Documents/_Works in Progress/DataHaven/")

# Test if necessary packages are installed, and load them
required_packages <- c("rgdal", "lattice", "shiny", "ggplot2")
required_packages_test <- sapply(required_packages, require, character.only=TRUE)
if (any(ifelse(required_packages_test, FALSE, TRUE))) {
  stop(paste("Missing package", required_packages[! required_packages_test], "\n"))
} else {
  print("Loaded all required packages.\n")
}

# Read survey data
attach("DataHavenRecoded.Robj")

# Read GIS data
ct <- readOGR(dsn="maps/Town_Index_shp", layer="TOWN_INDEX")

# Aggregate and merge the two
town_list <- c("Milford", "Orange", "Woodbridge", "Bethany", "Hamden", "North Haven", "North Branford", "Guilford", "Madison", "Branford", "East Haven", "New Haven", "West Haven")
town_codes <- c(9,12,13,5,3,11,10,7,8,6,2,1,4)
gnh <- ct[ct$TOWN %in% town_list,]
gnh$ring <- 3
gnh$ring[gnh$TOWN=="New Haven"] <- 1
gnh$ring[gnh$TOWN %in% c("West Haven", "Hamden", "East Haven")] <- 2
gnh$town <- NA
gnh$town_code <- town_codes[match(gnh$TOWN, town_list)]
myscale <- function(x) {(x - min(x)) / (max(x) - min(x))}
town_means <- aggregate(dhr, list(dhr$town), mean, na.rm=TRUE)
gnh_town_means <- merge(gnh, town_means, by.x="town_code", by.y="Group.1")
town_samp_size = as.data.frame(table(dhr$town))
town_samp_size$Freq_scaled = myscale(town_samp_size$Freq)
gnh_town_means <- merge(gnh_town_means, town_samp_size, by.x="town_code", by.y="Var1")

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
  output$map <- renderPlot({
    spplot(gnh_town_means, zcol=input$variable,
           col.regions=rev(heat.colors(255)),
           main=input$variable,
           sp.layout=list("sp.text", coordinates(gnh_town_means), gnh_town_means$TOWN, cex=0.7))
  })
  output$hist <- renderPlot({
    #hist(dhr[,input$variable], main=input$variable, xlab=input$variable)
    ggplot(dhr, aes_string(x=input$variable)) + geom_bar(fill="gray", color="black") + theme_classic()
  })
  output$summary <- renderTable({
    data.frame(Statistic=names(summary(dhr[,input$variable])), Value=c(summary(dhr[,input$variable])))
  }, include.rownames=FALSE)
})
