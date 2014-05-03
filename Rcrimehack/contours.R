
library(ggplot2)
library(foreign)
library(stringr)
library(lubridate)
library(plyr)
library(xtable)
library(scales)
library(RColorBrewer)
library(ggmap)
 
library(maptools)
library(sp)
library(rgdal)
library(spatstat)

setwd("~/Rcrimehack") # Enter the location of your working directory.

chicago <- readShapePoly("Neighborhoods_2012/Neighborhoods_2012b") # Read the shapefile (from the 'maptools' library).
chicago <- fortify(chicago) # Organizes data into a neat data frame.
##ggplot(chicago) + geom_polygon(aes(x=long, y=lat, group=group)) # "Filled" map
##ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) # "Outline" map
 
# city data is not in traditional latitutde and longitudes - in UTM

##crimes <- read.csv("http://data.cityofchicago.org/api/views/qnrb-dui6/rows.csv")
crimes <- read.csv(file="crimes_2013.csv",head=TRUE,sep=",")

##ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) + geom_point(data=crimes, aes(x=X.Coordinate, y=Y.Coordinate))

crimeTypeNames <- crimes$Primary.Type
crimeTypes <- unique(crimeTypeNames)

#crimeDataSubset <- subset(crimes, crimes$Primary.Type == 'THEFT')

crimeSubsets <- list()
for (crimeType in crimeTypes)
{
	crimeSubsets[[crimeType]] <- subset(crimes, crimes$Primary.Type == crimeType)
}

##ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) 
##	+ geom_point(data=crimeDataSubset, aes(x=X.Coordinate, y=Y.Coordinate))
 
##ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) +
	stat_density2d(
	aes(x = X.Coordinate, y = Y.Coordinate, fill = ..level..,
	alpha = ..level..),
	size = 2, bins = 4, data = crimeDataSubset,
	geom = "polygon")


for (crimeType in crimeTypes)
{
	p <- ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) +
			stat_density2d(
				aes(x = X.Coordinate, y = Y.Coordinate, fill = ..level..,
				alpha = ..level..),
				size = 2, bins = 4, data = crimeSubsets[[crimeType]],
				geom = "polygon") + scale_fill_gradient(low='black,high='red') + 
				labs(title=crimeType) + ggsave(paste('img/',crimeType,'.png',sep=''))
}

  
#longitude = X, latitude = Y
##vars <- c("Longitude", "Latitude")
##latlong <- crimes[vars]
##names(latlong) <- c("X","Y")

# Convert it to a sp object
##coordinates(latlong) <- ~ Y + X # longitude first
# Convert it to a sp object
##proj4string(latlong) <- CRS("+proj=longlat +ellps=WGS84 +datum=WGS84")

# Project using spTransform
##utm <- spTransform(latlong, CRS("+proj=utm +zone=11 ellps=WGS84"))


