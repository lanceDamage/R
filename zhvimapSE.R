
#clean up environment
rm(list = ls())

#get some libraries
library(zipcode)
library(ggplot2)
library(maps)
library(viridis)
library(scales)
library(ggmap)
library(choroplethr)
library(noncensus)
library(dplyr)
library(httr)
library(XML)
library(RCurl)
data(counties)

#data
url <- "http://files.zillowstatic.com/research/public/County/County_Zhvi_Summary_AllHomes.csv"
urldata <- GET(url)
zchomes <- read.csv("http://files.zillowstatic.com/research/public/County/County_Zhvi_Summary_AllHomes.csv", header = TRUE, sep = ",")
county_df <- map_data("county")
state_df <- map_data("state")

#creating a data frame of buoys I'd like to plot. Also tring to convert factors which I hope will avert errors I'm getting below.
buoyID.factor <- factor(c(41110,44096))
index.factor <- factor(c(2713480,2791621))
lat.factor <- factor(c(34.141,37.023))
lon.factor <- factor(c(-77.709,-75.810))

buoyID <- as.numeric(as.character(buoyID.factor))
index <- as.numeric(as.character(index.factor))
lat <- as.numeric(as.character(lat.factor))
lon <- as.numeric(as.character(lon.factor))

buoyPassSE <- as.data.frame(buoyID, index, lat, lon, row.names = NULL)

#data formatting so that I'm only focusing on certain states
zchomesCoast <- filter(zchomes, grepl('FL|SC|NC', zchomes$State))
countyCoast_df <- filter(county_df, grepl('florida|south carolina|north carolina', county_df$region))
countyCoastSurf_df <- filter(countyCoast_df, grepl('brevard|onslow|duval|new hanover|volusia|st lucie|indian river', countyCoast_df$subregion))
stateCoast_df <- filter(state_df, grepl('florida|south carolina|north carolina', state_df$region))
colnames(countyCoast_df) <- c("long","lat","group", "order","state","county") #for ggplot
zchomesCoast$county <- tolower(zchomesCoast$RegionName)

#data merge
choropleth <- merge(countyCoast_df, zchomesCoast, by = c("county"))
choropleth <- choropleth[order(choropleth$order), ]

#now for the plotting
ggplot(choropleth, aes(long, lat, group=group), environment = environment())+
  geom_polygon(data=countyCoast_df, aes(long, lat,group=group), fill='#ffffff', colour= alpha("gray", 1 /2))+
  geom_polygon(aes(fill=Zhvi), colour=alpha("gray", 1/2), size = 0.2) +
  geom_polygon(data = state_df, colour = "white", fill=NA)+
  theme(axis.line = element_blank(), axis.text=element_blank(),
        axis.ticks=element_blank(),axis.title=element_blank())+
  scale_fill_gradient(low = '#ffff99', high = '#ff0000',
                      breaks=c(300000,800000,1200000),
                      label = comma)+
 
#this provides an overlay of certain counties of interest to me
  geom_polygon(data = countyCoastSurf_df, aes(long, lat,group=group), fill='#66ff66', colour= (alpha=1))+
  
#I can't get the following points to also show up on this map.
#without this line, the script works.
  geom_point(data = buoyPassSE, aes(x = lon, y = lat, fill = diff, group=group), inherit.aes = FALSE, alpha = 0.8, size = 5, pch = 21) +

  theme_nothing()+ 
  coord_map(xlim = c(-90, -70),ylim = c(25, 37))

