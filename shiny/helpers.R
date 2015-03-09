library(shiny)
library(ggplot2)
library(rgdal)
library(lattice)

# Test if necessary packages are installed, and load them; not necessary for shinyapps
#required_packages <- c("rgdal", "lattice", "shiny", "ggplot2")
#required_packages_test <- sapply(required_packages, require, character.only=TRUE)
#if (any(ifelse(required_packages_test, FALSE, TRUE))) {
#  stop(paste("Missing package", required_packages[! required_packages_test], "\n"))
#} else {
#  print("Loaded all required packages.\n")
#}

# Read survey data
attach("data/DataHavenRecoded.Rdata")
# Read GIS data
ct <- readOGR(dsn="data/maps/Town_Index_shp", layer="TOWN_INDEX")
# Subset GIS data to Greater New Haven area
town_list <- c("Milford", "Orange", "Woodbridge", "Bethany", "Hamden", "North Haven", "North Branford", "Guilford", "Madison", "Branford", "East Haven", "New Haven", "West Haven")
gnh <- ct[ct$TOWN %in% town_list,]

# Create ring codes for GIS data
gnh$ring <- 3
gnh$ring[gnh$TOWN=="New Haven"] <- 1
gnh$ring[gnh$TOWN %in% c("West Haven", "Hamden", "East Haven")] <- 2
town_codes <- c(9,12,13,5,3,11,10,7,8,6,2,1,4)
# Cell sizes too small to plot by town, but may be useful in the future
gnh$town <- town_codes[match(gnh$TOWN, town_list)]

# string variables that correspond to radio button group selections
radio_factors <- c("gender", "racer", "ring", "town")
geo_factors <- c("ring", "town")

# Function to return an aggregated spatial polygon dataframe with specified variables
get_geo_df <- function(varname, geoname, groupname=NA) {
  # Eventually let it auto-decide to choose mode for categorical vars
  if (is.na(groupname)) {
    myformula <- reformulate(termlabels=geoname, response=varname)
    mydata <- aggregate(myformula, data=dhr, FUN=mean)
  }
  else {
    myformula <- reformulate(termlabels=c(geoname, groupname), response=varname)
    mydata <- aggregate(myformula, data=dhr, FUN=mean)
    mydata <- reshape(mydata, v.names=varname, idvar=geoname, timevar=groupname, direction="wide")
  }
  merge(gnh, mydata, by=geoname)
}
