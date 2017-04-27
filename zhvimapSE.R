
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
buoyID <- c(41110,44096)
index <- c(2713480,2791621)
lat <- c(34.141,37.023)
lon <- c(-77.709,-75.810)
buoyPassSE <- data.frame(buoyID, index, lat, lon)


#data formatting
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
  
  geom_polygon(data = countyCoastSurf_df, aes(long, lat,group=group), fill='#66ff66', colour= (alpha=1))+
  
  #I can't get the following points to also show up on this map.
  #geom_point(data = buoyPassSE, aes(x = -77.70899963, y = 34.14099884, fill = "red", alpha = 0.8,group = group), inherit.aes=FALSE,size = 5, shape = 21) +
  #geom_point(data = buoyPass, aes(x = -120.45, y = 34.27, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  #geom_point(data = sspotlocs, aes(x = -119.48, y = 34.38, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  #geom_point(data = buoyPass, aes(x = -120.97, y = 34.71, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  #geom_point(data = buoyPass, aes(x = -120.45, y = 34.27, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  #geom_point(data = buoyPass, aes(x = -120.45, y = 34.27, fill = "red", alpha = 0.8), size = 5, shape = 21) +
  
  theme_nothing()+ 
  coord_map(xlim = c(-90, -70),ylim = c(25, 37))
#this is a test of git
