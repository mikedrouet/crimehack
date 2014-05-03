## Crime Incident Plots
library(ggplot2)
library(foreign)
library(stringr)
library(lubridate)
library(plyr)
library(xtable)
library(scales)
library(RColorBrewer)
library(ggmap)
 
## gis libraries
library(maptools)
library(sp)
library(rgdal)
library(spatstat)

setwd("~/Rcrimehack")

chicago <- readShapePoly("Neighborhoods_2012/Neighborhoods_2012b") # Read the shapefile (from the 'maptools' library).
chicago <- fortify(chicago) # Organizes data into a neat data frame.

#ggplot(chicago) + geom_polygon(aes(x=long, y=lat, group=group)) # "Filled" map
#ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) # "Outline" map


ggplot(data=chicago, aes(x=long, y=lat, group=group)) +
 geom_polygon(color='gray', fill='lightblue') + 
 coord_equal() + theme_nothing()

##crimes <- read.csv(file="crime_report.csv",head=TRUE,sep=",")
crimes <- read.csv(file="chicrimes_small.csv",head=TRUE,sep=",")
##ggplot(chicago) + geom_path(aes(x=long, y=lat, group=group)) + geom_point(data=crimes, aes(x=X.Coordinate, y=Y.Coordinate))

summary(crimes)

bound_plot <- ggplot(data=chicago, aes(x=long, y=lat, group=group)) +
 geom_polygon(color='gray', fill='white') + 
 coord_equal() + theme_nothing()
 
nbhds_plot <- bound_plot

crimes <- read.csv(file="crime_report.csv",head=TRUE,sep=",")
crimeTypeNames <- crimes$primary_type
crimeTypes <- unique(crimeTypeNames)
crimeDataSubset <- subset(crimes, crimes$primary_type == 'BATTERY')

## Convert lat/long to maryland grid
latlng_df2 <- crimeDataSubset[,c('long','lat')]
latlng_spdf <- SpatialPoints(latlng_df2, 
proj4string=CRS("+proj=longlat +datum=WGS84"))
latlng_spdf_coords <- coordinates(latlng_spdf)
crimeDataSubset$long <-  latlng_spdf_coords[,1]
crimeDataSubset$lat <-  latlng_spdf_coords[,2]

p <- bound_plot + geom_point(data=crimeDataSubset,aes(group=1),colour="green",size=4)
p

p <- nbhds_plot +
stat_density2d(
aes(x = longitude, y = latitude, fill = ..level..,
alpha = ..level..),
size = 2, bins = 4, data = crimeDataSubset,
geom = "polygon")

p <- bound_plot + w

## By crime type
for (crimeType in crimeTypeNames){
## All Incidents Densities
    ttl <- crimeType
    crimeDataSubset <- subset(crimes,
    (description==crimeType))
    p <- nbhds_plot + 
    geom_point(data=crimeDataSubset,aes(group=1), 
        shape='x',
        color=crimeTypes[[crimeType]][[1]],
        alpha='.8', guide=F) +
    stat_density2d(data=crimeDataSubset,aes(group=1), 
    color = crimeTypes[[crimeType]][[2]]) +
    annotate("text", x = 1405000, y = 565000,
    label=paste(
    str_replace_all(str_replace(ttl, '_', '\n'),'_',' ')
    , sep=''), size=8) +
    ggsave(paste('img/',ttl,'.png',sep=''))
}