library(shiny)
library(shinydashboard)
library(leaflet) 
library(ggplot2)

##POINT IN POLYGON




library(sf)

# going ahead and using it for what we need it for, before we load the other packages, again to make things easier

boston_neighborhood <- read_sf("Data/Boston_Neighborhoods/Boston_Neighborhoods.shp")
ma_tract <- read_sf("Data/ma_tract/tl_2018_25_tract.shp")

library(tidyverse)
library(leaflet)
library(USAboundaries)
library(maps)
library(leaflet.extras)
library(fivethirtyeight)
library(zipcode)
library(ggmap)
library(mosaic)



#add after hours variable to ProvidersData_earlyed_462019 to get ProvidersData_earlyed_4112019
EECMaster49 <- read_csv("Data/ProvidersData_earlyed_4112019.csv")


#Filtering
EECMaster49 <- EECMaster49 %>%
  filter(City %in% boston_neighborhood$Name | City=="Boston")
names(EECMaster49) <- gsub(" ", "_", names(EECMaster49))
#glimpse(EECMaster49)


#MA TRACT

ma_tract <- ma_tract %>%
  st_transform(crs = "+init=epsg:4326")

ma_tract_base_map <- leaflet(ma_tract,
                             options = leafletOptions(minZoom = 11))  %>%
  addProviderTiles("CartoDB.Positron")  %>%
  addPolygons(weight = 2, fillOpacity = .1, fillColor = "#000000") %>%
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5)

ma_tract_base_map

library(rgeos)
library(sp)
library(rgdal)

bos.map <- readOGR("Data/ma_tract/tl_2018_25_tract.shp", layer="tl_2018_25_tract")

# Better to set longitudes as the first column and latitudes as the second
dat <- EECMaster49
# Assignment modified according
coordinates(dat) <- ~ lon + lat
# Set the projection of the SpatialPointsDataFrame using the projection of the shapefile
proj4string(dat) <- proj4string(bos.map)

classification<-over(dat, bos.map)
#add back geometry
ma_tract$ALAND<-as.factor(ma_tract$ALAND)
classification$ALAND<-as.factor(classification$ALAND)
ma_tract$AWATER <- as.factor(ma_tract$AWATER)
classification$AWATER <-as.factor(classification$AWATER)
classification2<-left_join(classification,ma_tract, on = "GEOID")
colnames(classification) <- paste(colnames(classification), "tract", sep = "_")
colnames(classification2) <- paste(colnames(classification2), "tract", sep = "_")

#could not add geometry column since it is what makes shapefile a shapefile and will mess up the exported csv data
masterdataframe_tract <- cbind(classification, EECMaster49)




#add Neighborhood to tract masterdataframe


library(rgeos)
library(sp)
library(rgdal)



bos.map <- readOGR("Data/Boston_Neighborhoods/Boston_Neighborhoods.shp", layer="Boston_Neighborhoods")

# Better to set longitudes as the first column and latitudes as the second
dat <- masterdataframe_tract
# Assignment modified according
coordinates(dat) <- ~ lon + lat
# Set the projection of the SpatialPointsDataFrame using the projection of the shapefile
proj4string(dat) <- proj4string(bos.map)

classification3<-over(dat, bos.map)

boston_neighborhood$OBJECTID<-as.factor(boston_neighborhood$OBJECTID)
classification3$OBJECTID<-as.factor(classification3$OBJECTID)


#add back geometry
classification4<-left_join(classification3,boston_neighborhood, on = "Neighborho")
colnames(classification4) <- paste(colnames(classification4), "neighborho", sep = "_")
colnames(classification3) <- paste(colnames(classification3), "neighborho", sep = "_")

#exclude geometry since it messes the dataset when exporting it
masterdataframe_tract_neighborho <- cbind(classification3, masterdataframe_tract)



#without geometry
tractneighborho<-masterdataframe_tract_neighborho%>%
  select(Name_neighborho,Neighborho_neighborho,NAMELSAD_tract,GEOID_tract)

tractneighborho<-tractneighborho[!duplicated(tractneighborho[,'GEOID_tract']),]




#add back geometry
masterdataframe_tract_g <- cbind(classification2, EECMaster49)
masterdataframe_tract_neighborho_g <- cbind(classification4, masterdataframe_tract_g)

tractneighborho_geo<-masterdataframe_tract_neighborho_g%>%
  select(Name_neighborho,Neighborho_neighborho,geometry_neighborho,NAMELSAD_tract,GEOID_tract,geometry_tract)

tractneighborho_geo<-tractneighborho_geo[!duplicated(tractneighborho_geo[,'GEOID_tract']),]

####CAPACITY MAPS FINAL


library(tidycensus)
library(tidyverse)
library(ggplot2)
library(tigris)
library(sf)
library(mosaic)
library(leaflet)
library(leaflet.extras)


boston_neighborhood <- read_sf("Data/Boston_Neighborhoods/Boston_Neighborhoods.shp")
tractneighborho <- read.csv("Data/tractneighborho.csv")
api_key <- "8fa9f8cc6afff6f16cfa41d92974f406a35636a6"
census_api_key(api_key)


#add back geometry
masterdataframe_tract_g <- cbind(classification2, EECMaster49)
masterdataframe_tract_neighborho_g <- cbind(classification4, masterdataframe_tract_g)

tractneighborho_geo<-masterdataframe_tract_neighborho_g%>%
  select(Name_neighborho,Neighborho_neighborho,geometry_neighborho,NAMELSAD_tract,GEOID_tract,geometry_tract)

tractneighborho_geo<-tractneighborho_geo[!duplicated(tractneighborho_geo[,'GEOID_tract']),]



#percentage of children under 6 with all parents in the labor force, 1 for single-parent household, 2 for two-parent household in each census tract in Boston.

#variables for all parents in the labor force (both double & single family households)
laborforcevars <- c("B23008_004", "B23008_010", "B23008_013")

laborforce_under6  <- get_acs(geography = "tract",
                              variables = laborforcevars,
                              survey="acs5",
                              state= "MA",
                              county="Suffolk",
                              geometry=TRUE)

#get a sum of children with all parents in the labor force
laborforce_under6 <- laborforce_under6 %>%
  group_by(GEOID, NAME) %>%
  summarise(laborforcechildren = sum(estimate))

#get the total number of children under 6
under6total <- get_acs(geography = "tract",
                       variables = "B23008_002",
                       survey="acs5",
                       state= "MA",
                       county="Suffolk",
                       geometry=TRUE)

#join the two files (by turning into data frame)
percentage_under_6 <- inner_join(laborforce_under6 %>% as.data.frame(), under6total %>% as.data.frame(), by = "GEOID")

#merge this with neighborhood tract information
colnames(tractneighborho_geo)[5] <- "GEOID"
percentageunder6_neighborhood <- inner_join(percentage_under_6, tractneighborho_geo, by ="GEOID")

#turning back into an sf object
percentageunder6_neighborhood <- percentageunder6_neighborhood %>%
  select(GEOID, Name_neighborho, NAMELSAD_tract, laborforcechildren, estimate, geometry_neighborho, geometry_tract) %>% 
  st_sf(sf_column_name = 'geometry_neighborho')

percentageunder6_tract <- percentageunder6_neighborhood %>%
  select(GEOID, Name_neighborho, NAMELSAD_tract, laborforcechildren, estimate, geometry_neighborho, geometry_tract) %>% 
  st_sf(sf_column_name = 'geometry_tract')

#getting estimates per neighborhood and tract with neighborhood geometry and tract geometry
neighborho_demand <- percentageunder6_neighborhood %>%
  group_by(Name_neighborho) %>%
  summarise(laborforce = sum(laborforcechildren))

neighborho_demand_tract <- percentageunder6_tract %>%
  group_by(NAMELSAD_tract) %>%
  summarise(laborforce = sum(laborforcechildren))






EECNEW5<-read.csv("Data/masterdataframe_tract.csv")

#early ed filter grouped by tract, summarized for capacity
EECNEW5_earlyed_tract <- EECNEW5 %>%
  mutate(early_ed=ifelse(early_ed=="True", TRUE,
                         ifelse(early_ed=="False", FALSE, early_ed))) %>%
  dplyr::filter(early_ed==TRUE) %>%
  group_by(GEOID_tract, NAMELSAD_tract) %>%
  summarise(sum_capacity = sum(Capacity))


EECNEW5_earlyed_tract$GEOID <- as.character(EECNEW5_earlyed_tract$GEOID_tract)

EEC_geometry <- inner_join(EECNEW5_earlyed_tract %>% as.data.frame(), percentage_under_6 %>% as.data.frame(), by = "GEOID")

EEC_geometry <- EEC_geometry %>%
  st_sf(sf_column_name = 'geometry.x')

#merge neighborhood information
EECcapacity <- inner_join(EEC_geometry %>% as.data.frame(), tractneighborho_geo, by ="GEOID")

EEC_neigh_geometry <- EECcapacity %>%
  st_sf(sf_column_name = 'geometry_neighborho')

EEC_tract_geometry <- EECcapacity %>%
  st_sf(sf_column_name = 'geometry_tract')

neighborho_capacity <- EEC_neigh_geometry %>%
  group_by(Name_neighborho) %>%
  summarise(slots = sum(sum_capacity))

neighborho_capacity_tract <- EEC_tract_geometry %>%
  group_by(NAMELSAD_tract.x) %>%
  summarise(slots = sum(sum_capacity))



EEC_census <- inner_join(neighborho_capacity %>% as.data.frame(), neighborho_demand %>% as.data.frame(), by = "Name_neighborho")

EEC_census <- EEC_census %>%
  select(Name_neighborho, slots, laborforce, geometry_neighborho.x) %>%
  st_sf(sf_column_name = 'geometry_neighborho.x') %>%
  mutate(differenceslots = slots-laborforce,
         ratioslots= laborforce/slots,
         more_slots = ifelse(differenceslots>0, "yes", "no"))



#transform sf type to work with leaflet
neighborho_demand <- neighborho_demand %>%
  st_transform(crs = "+init=epsg:4326")

neighborho_demand_tract <- neighborho_demand_tract %>%
  st_transform(crs = "+init=epsg:4326")

neighborho_capacity <- neighborho_capacity %>%
  st_transform(crs = "+init=epsg:4326")

neighborho_capacity_tract <- neighborho_capacity_tract %>%
  st_transform(crs = "+init=epsg:4326")

##DEMAND BY TRACT
pal_laborforce <- colorBin("YlOrRd", domain = neighborho_demand_tract$laborforce)
leaflet(neighborho_demand_tract) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_laborforce(laborforce),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_laborforce, 
            values = ~laborforce,
            opacity = 1)

##CAPACITY BY TRACT
pal_slots <- colorBin("YlOrRd", domain = neighborho_capacity_tract$slots)
leaflet(neighborho_capacity_tract) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_slots(slots),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_slots, 
            values = ~slots,
            opacity = 1,
            title="# slots")


#Ratio map
library(RColorBrewer)


## Make vector of colors for values smaller than 0 (20 colors)
rc1 <- colorRampPalette(colors = c("dark green", "white"), space = "Lab")(50)


## Make vector of colors for values larger than 0 (180 colors)
rc2 <- colorRampPalette(colors = c("white", "red"), space = "Lab")(120)

## Combine the two color palettes
rampcols <- c(rc1, rc2)

pal_ratioslots <- colorNumeric(palette = rampcols, domain = EEC_census$ratioslots)
leaflet(EEC_census) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_ratioslots(ratioslots),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_ratioslots, 
            values = ~ratioslots,
            opacity = 1)



EEC_census_bar<- 
  EEC_census[order(EEC_census$ratioslots, decreasing = TRUE),]
head(EEC_census_bar)


library(ggplot2)
ggplot(EEC_census_bar,aes(x =reorder(Name_neighborho,ratioslots), y = ratioslots)) +
  geom_bar(fill="blue", stat="identity") + ggtitle( "Childcare Ratio by Neighborhood")+ xlab("Neighborhoods")+  ylab("Children Under 6 to Available Early Ed Slots Ratio") + geom_hline(yintercept=1)+coord_flip()



#####HOURS SUPPLY
#boston neighborhood data!
boston_neighborhood <- read_sf("Data/Boston_Neighborhoods/Boston_Neighborhoods.shp")



## define census API key and set it with census_api_key function

api_key <- "8fa9f8cc6afff6f16cfa41d92974f406a35636a6"
census_api_key(api_key)



#percentage of children under 6 with all parents in the labor force, 1 for single-parent household, 2 for two-parent household in each census tract in Boston.

#variables for all parents in the labor force (both double & single family households)
laborforcevars <- c("B23008_004", "B23008_010", "B23008_013")

laborforce_under6  <- get_acs(geography = "tract",
                              variables = laborforcevars,
                              survey="acs5",
                              state= "MA",
                              county="Suffolk",
                              geometry=TRUE)

#get a sum of children with all parents in the labor force
laborforce_under6 <- laborforce_under6 %>%
  group_by(GEOID, NAME) %>%
  summarise(laborforcechildren = sum(estimate))

#get the total number of children under 6
under6total <- get_acs(geography = "tract",
                       variables = "B23008_002",
                       survey="acs5",
                       state= "MA",
                       county="Suffolk",
                       geometry=TRUE)

percentage_under_6 <- inner_join(laborforce_under6 %>% as.data.frame(), under6total %>% as.data.frame(), by = "GEOID")

#turning back into an sf object
percentage_under_6 <- percentage_under_6 %>%
  st_sf(sf_column_name = 'geometry.x')

#turn two numbers into a percentage
percentage_under_6 <- percentage_under_6 %>%
  mutate(percent_working = laborforcechildren/estimate*100)


EECNEW5<-read.csv("Data/masterdataframe_tract.csv")
EECNEW5_others_tract <- read.csv("Data/datatract.csv")
EEC_earlyed <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE, Weekdays_off_hours==TRUE)


#early ed and weekdays off hours filter grouped by tract, summarized for capacity
EECNEW5_hours_tract <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE & Weekdays_off_hours == TRUE) %>%
  group_by(GEOID_tract, NAMELSAD_tract) %>%
  summarise(sumcapacity_weekdaysoff = sum(Capacity))


EECNEW5_hours_tract$GEOID <- as.character(EECNEW5_hours_tract$GEOID_tract)

EEC_geometry <- inner_join(EECNEW5_hours_tract %>% as.data.frame(), percentage_under_6 %>% as.data.frame(), by = "GEOID")

EEC_geometry <- EEC_geometry %>%
  select(GEOID, NAME.x,sumcapacity_weekdaysoff, geometry.x) %>%
  st_sf(sf_column_name = 'geometry.x')


#early ed and weekdays off hours filter grouped by tract, summarized for capacity
EECNEW5_hours_tract_no <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE & Weekdays_off_hours == FALSE) %>%
  group_by(GEOID_tract, NAMELSAD_tract) %>%
  summarise(sumcapacity_weekdaysoff = 0)


EECNEW5_hours_tract_no$GEOID <- as.character(EECNEW5_hours_tract_no$GEOID_tract)

EEC_geometry_no <- inner_join(EECNEW5_hours_tract_no %>% as.data.frame(), percentage_under_6 %>% as.data.frame(), by = "GEOID")

EEC_geometry_no <- EEC_geometry_no %>%
  select(GEOID, NAME.x,sumcapacity_weekdaysoff, geometry.x) %>%
  st_sf(sf_column_name = 'geometry.x')



#making palettes
pal2 <- colorBin("YlOrRd", domain = EEC_geometry$sumcapacity_weekdaysoff)
infant_pal <- colorFactor(palette = c("green"),
                          levels = c(TRUE))
#making palettes
pal3 <- colorBin("GREY", domain = EEC_geometry_no$sumcapacity_weekdaysoff)

#transform sf type to work with leaflet
EEC_geometry <- EEC_geometry %>%
  st_transform(crs = "+init=epsg:4326")

#make map
map_yes <- leaflet(EEC_geometry) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(data = EEC_geometry_no,fillColor = ~pal3(sumcapacity_weekdaysoff),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(fillColor = ~pal2(sumcapacity_weekdaysoff),
              weight = 1,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>%
  addLegend("topleft", 
            pal = pal2, 
            values = ~sumcapacity_weekdaysoff,
            title = "Capcacity of weekdays off hour providers by tract",
            opacity = 1)%>%
  addCircleMarkers(data = EEC_earlyed,
                   ~lon,
                   ~lat,
                   radius = 0.5,
                   opacity = .4,
                   color = ~infant_pal(Weekdays_off_hours),
                   group = "Show providers with after school care for early ed",
                   label = ~as.character(Name))%>%
  addLayersControl(overlayGroups = c("Show providers with off-hour childcare for early ed during weekdays"))

EEC_weekend <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE, Weekend_off_hours==TRUE)


# #early ed and weekend off hours filter grouped by tract, summarized for capacity. No available slot during weekend
# EECNEW5_hours_tract <- EECNEW5 %>%
#   filter(early_ed==TRUE & Weekend_off_hours == TRUE) %>%
#   group_by(GEOID_tract, NAMELSAD_tract) %>%
#   summarise(sumcapacity_weekendoff = sum(Capacity))
# EECNEW5_hours_tract$GEOID <- as.character(EECNEW5_hours_tract$GEOID_tract)
# 
# EEC_geometry <- inner_join(EECNEW5_hours_tract %>% as.data.frame(), percentage_under_6 %>% as.data.frame(), by = "GEOID")
# 
# EEC_geometry <- EEC_geometry %>%
#   select(GEOID, NAME.x,sumcapacity_weekendoff, geometry.x) %>%
#   st_sf(sf_column_name = 'geometry.x')

#early ed and weekdays off hours filter grouped by tract, summarized for capacity
EECNEW5_hours_tract_no <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE & Weekend_off_hours == FALSE) %>%
  group_by(GEOID_tract, NAMELSAD_tract) %>%
  summarise(sumcapacity_weekendoff = sum(Capacity))


EECNEW5_hours_tract_no$GEOID <- as.character(EECNEW5_hours_tract_no$GEOID_tract)

EEC_geometry_no <- inner_join(EECNEW5_hours_tract_no %>% as.data.frame(), percentage_under_6 %>% as.data.frame(), by = "GEOID")

EEC_geometry_no <- EEC_geometry_no %>%
  select(GEOID, NAME.x,sumcapacity_weekendoff, geometry.x) %>%
  st_sf(sf_column_name = 'geometry.x')

#making palettes
pal2 <- colorBin("YlOrRd", domain = EEC_geometry$sumcapacity_weekendoff)
infant_pal <- colorFactor(palette = c("green"),
                          levels = c(TRUE))
#making palettes
pal3 <- colorBin("YlOrRd", domain = EEC_geometry_no$sumcapacity_weekendoff, reverse = FALSE)

#transform sf type to work with leaflet
EEC_geometry_no <- EEC_geometry_no %>%
  st_transform(crs = "+init=epsg:4326")

#make map
leaflet(EEC_geometry_no) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal3(sumcapacity_weekendoff),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>%
  addLegend("topleft", 
            pal = pal3, 
            values = ~sumcapacity_weekendoff,
            title = "Weekdays_offhours",
            opacity = 1)%>%
  addCircleMarkers(data = EEC_earlyed,
                   ~lon,
                   ~lat,
                   radius = 0.5,
                   opacity = .4,
                   color = ~infant_pal(Weekend_off_hours),
                   group = "Show providers with weekend care for early ed",
                   label = ~as.character(Name))%>%
  addLayersControl(overlayGroups = c("Show providers with after school care for early ed"))


###HOURS DEMAND
#data/APIS

#Read in boston neighborhood data
boston_neighborhood <- read_sf("Data/Boston_Neighborhoods/Boston_Neighborhoods.shp")


EECNEW5<-read.csv("Data/masterdataframe_tract.csv")
EEC_earlyed <- EECNEW5 %>%
  mutate(early_ed= ifelse(early_ed=="True", TRUE,
                          ifelse(early_ed=="False", FALSE, early_ed))) %>%
  filter(early_ed==TRUE, Weekdays_off_hours==TRUE)



#Variables

# Early mornings if they leave for work anytime between 12am-6:29am
# Evenings if they leave for work anytime between 11am-3:59pm
# Late Evening/Overnight if they leave for work anytime between 4pm-11:59pm

earlymorning_vars <- c("B08302_002", "B08302_003", "B08302_004", "B08302_005")
evening_vars <- c("B08302_013", "B08302_014")
overnight_vars <- c("B08302_015")

earlymorning <- get_acs(geography = "tract",
                        variables = earlymorning_vars,
                        survey="acs5",
                        state= "MA",
                        county="Suffolk",
                        geometry=TRUE)

earlymorning <- earlymorning %>%
  group_by(GEOID, NAME) %>%
  summarise(sum_earlymorning = sum(estimate))

evening <- get_acs(geography = "tract",
                   variables = evening_vars,
                   survey="acs5",
                   state= "MA",
                   county="Suffolk",
                   geometry=TRUE)

evening <- evening %>%
  group_by(GEOID, NAME) %>%
  summarise(sum_evening = sum(estimate))

overnight <- get_acs(geography = "tract",
                     variables = overnight_vars,
                     survey="acs5",
                     state= "MA",
                     county="Suffolk",
                     geometry=TRUE)


overnight <- overnight %>%
  group_by(GEOID, NAME) %>%
  summarise(sum_overnight = sum(estimate))

total <- get_acs(geography = "tract",
                 variables = "B08302_001",
                 survey="acs5",
                 state= "MA",
                 county="Suffolk")

total <- total %>%
  group_by(GEOID, NAME) %>%
  summarise(sumtotal=sum(estimate))

hours_demand1 <- inner_join(earlymorning %>% as.data.frame(), evening %>% as.data.frame(), by = "GEOID")
hours_demand2 <- inner_join(hours_demand1 %>% as.data.frame(), overnight %>% as.data.frame(), by="GEOID")
hours_demand <- inner_join(hours_demand2, total, by="GEOID")

hours_demand <- hours_demand %>%
  select(GEOID, NAME.x,sum_earlymorning, sum_evening, sum_overnight, sumtotal, geometry) %>%
  st_sf(sf_column_name = 'geometry') %>%
  mutate(percent_early = (sum_earlymorning/sumtotal)*100,
         percent_evening = (sum_evening/sumtotal)*100,
         percent_overnight = (sum_overnight/sumtotal)*100,
         aggregate_raw = sum_earlymorning + sum_evening + sum_overnight,
         aggregate_percent = (sum_earlymorning + sum_evening + sum_overnight)/sumtotal*100)


hours_demand <- hours_demand %>%
  na.omit()


#Maps!!

#transform sf type to work with leaflet
hours_demand <- hours_demand %>%
  st_transform(crs = "+init=epsg:4326")


#Early morning

pal_early <- colorBin("Reds", domain = hours_demand$percent_early)
leaflet(hours_demand) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_early(percent_early),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_early, 
            values = ~percent_early,
            opacity = 1,
            title = "% Early Workers")




pal_evening <- colorBin("Reds", domain = hours_demand$percent_evening)
leaflet(hours_demand) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_evening(percent_evening),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_evening, 
            values = ~percent_evening,
            opacity = 1,
            title = "% Evening Workers")

pal_overnight <- colorBin("Reds", domain = hours_demand$percent_overnight)
leaflet(hours_demand) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_overnight(percent_overnight),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addLegend("topleft", 
            pal = pal_overnight, 
            values = ~percent_overnight,
            opacity = 1,
            title = "% Overnight Workers")
pal_aggregate <- colorBin("YlOrRd", domain = hours_demand$aggregate_raw)
#hours_demand <- hours_demand %>%
#filter(aggregate!=100)

infant_pal <- colorFactor(palette = c("blue"),
                          levels = c(TRUE))

leaflet(hours_demand) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_aggregate(aggregate_raw),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addCircleMarkers(data = EEC_earlyed,
                   ~lon,
                   ~lat,
                   radius = 2.5,
                   opacity = .4,
                   color = ~infant_pal(Weekdays_off_hours),
                   group = "Show providers with after school care for early ed",
                   label = ~as.character(Capacity)) %>%
  addLegend("topleft", 
            pal = pal_aggregate, 
            values = ~aggregate_raw,
            opacity = 1)

pal_aggregate_percent <- colorBin("YlOrRd", domain = hours_demand$aggregate_percent)
#hours_demand <- hours_demand %>%
#filter(aggregate!=100)

leaflet(hours_demand) %>%
  addProviderTiles("CartoDB")  %>%
  addPolygons(fillColor = ~pal_aggregate_percent(aggregate_percent),
              weight = 2,
              opacity = .8,
              color = "white",
              dashArray = "3",
              fillOpacity = 0.7) %>%
  addPolygons(data=boston_neighborhood, weight = 2, opacity = 1, fillOpacity=0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
  setView(lng = -71.057083, 
          lat = 42.361145, 
          zoom = 11.5) %>%
  addCircleMarkers(data = EEC_earlyed,
                   ~lon,
                   ~lat,
                   radius = 2.5,
                   opacity = 1,
                   color = ~infant_pal(Weekdays_off_hours),
                   label = ~as.character(Capacity),
                   group= "Show childcare providers with off hours weekday care") %>%
  addLayersControl(overlayGroups = c("Show childcare providers with off hours weekday care")) %>%
  addLegend("topleft", 
            pal = pal_aggregate_percent, 
            values = ~aggregate_percent,
            opacity = 1,
            title="Aggregated Percentage")

##HEADER

header <- dashboardHeader(
  title = "CLU: Childcare",
  dropdownMenu(type = "messages",
               messageItem(
                 from = "Community Labor United",
                 message = "Contact us for more information",
                 href = "http://massclu.org/about/"
               )),
  dropdownMenu(type = "notifications",
               notificationItem(
                 text = "CLU: Care That Works",
                 href = "http://massclu.org/initiatives/#childcare"
               ),
               notificationItem(
                 text = "Childcare Aware",
                 href = "https://www.childcareaware.org/"
               ))
)




## SIDEBAR

sidebar <- dashboardSidebar(
  sidebarMenu(
    
    ## INRODUCTION
    
    menuItem("Introduction",
             tabName = "introduction"),
    
    ## CAPACITY
    
    menuItem("Capacity",
             tabName = "capacity"
    ),
    
    ## HOURS
    
    menuItem("Hours",
             tabName = "hours"
    ),
    
    ##MEHODOLOGY
    
    menuItem("Methodology",
             tabName = "methodology")
  )
)

## BODY

body <- dashboardBody(
  tabItems(
    
    ## INTRODUCTION
    
    tabItem(tabName = "introduction",
            title = "Introduction",
            tags$h1("Community Labor United - Childcare"),
            tags$br(),
            tags$em("Community Labor United is a non-profit organization that is currently working to investigate the negligence in childcare provision for low and middle-income families within the Greater Boston Area, in order to promote reforms within the current system provided by the Department of Early Education and Care. "),
            tags$br(),
            tags$br(),
            tags$br(),
            tags$strong("Overview:"),
            tags$br(),
            tags$br(),
            p("Using interactive maps, the research outlined in this paper highlights two gaps in the current childcare structure:"),
            tags$div(tags$ul(
              tags$li("The first being how the hours that early education childcare providers keep do not support families that work primarily nonstandard schedules."),
              tags$li("The second being how the number of slots for early education provision does not align with the number of children age five and under that live within each neighborhood and census tract."),
              style = "font-size: 15px"),
              p("The interaction between these two gaps drastically impacts the livelihood of working class families and it is our hope that this research will provide evidence that the current system in place needs to be reconstructed, in order to support all households in Massachusetts."),
              p("This research emphasizes early education childcare demands needed for low and middle-income families working nonstandard hours in the Great Boston Area. More specifically, this research focuses on illustrating a disparity in operating hours and capacity for childcare providers on the neighborhood level and census tract level.")
            )
    ),
    
    ## CAPACITY
    
    tabItem(tabName = "capacity",
            tags$h1("Early Ed Childcare Slots to Childcare Needs Comparison"),
            tags$br(),
            tags$br(),
            fluidRow(
              box(
                width = 6,
                title = "Children Under 6 Who Need Childcare",
                em("(per tract)"),
                br(),
                leafletOutput("laborforce_demand"),
                status = "danger"
              ),
              box(
                width = 6,
                title = "Childcare Slots for Early Education Providers",
                em("(per tract)"),
                br(),
                leafletOutput("slots_supply"),
                status = "danger"
              )
            ),
            tags$h1("Ratio of Number of Children to Available Number of Slots"),
            tags$em("(per neighborhood)"),
            fluidRow(
              box(
                width = 7,
                leafletOutput("ratioslots_gap"),
                status = "danger"),
              box(
                width = 5,
                plotOutput("ratioslots_bar"),
                status = "danger"
              )
            )
    ),
    
    ## HOURS
    
    tabItem(tabName = "hours",
            tags$h1("Percent of People Who Work Nonstandard Hours (per tract)"),
            tags$br(),
            tags$br(),
            fluidRow(
              box(
                width = 4,
                title = "Workers with Early Morning Shifts",
                em("leaving home between 12:00am - 6:59am"),
                em(" "),
                br(),
                leafletOutput("percent_early"),
                status = "danger"
              ),
              box(
                width = 4,
                title = "Workers with Early Evening Shifts",
                em("leaving home between 11:00am - 3:59pm"),
                em(" "),
                br(),
                leafletOutput("percent_evening"),
                status = "danger"
              ),
              box(
                width = 4,
                title = "Workers with Late Evening & Overnight Shifts",
                em("leaving home between 4:00pm - 11:59pm"),
                em(" "),
                br(),
                leafletOutput("percent_overnight"),
                status = "danger"
              )
            ),
            tags$h1("Nonstandard Hours Demand"),
            fluidRow(
              box(
                width = 8,
                leafletOutput("aggregate_percent"),
                status = "danger"),
              box(
                width = 4,
                em("The aggregated percentage is the sum of the percentage of people with all nonstandard hours (Monday - Friday, 7:30am - 6:00pm)."),
                p("------"),
                em(" Each dot is a childcare provider. You can hover over each childcare provider to see the number of slots they have available for off-hour weekday care."),
                status = "danger"
              )
            )
    ),
    
    ## METHODOLOGY
    
    tabItem(tabName = "methodology",
            fluidRow(
              column(width = 12,
                     box(
                       title = "Capacity",
                       width = NULL,
                       solidHeader = TRUE, 
                       collapsible = TRUE,
                       collapsed = FALSE,
                       status = "info",
                       tags$br(),
                       tags$strong("Percent of Children Under 6 with All Parents in the Labor Force"),
                       tags$br(),
                       tags$br(),
                       tags$em("This demand variable was created using information provided by the 2016 American Community Survey data, which we accessed through tidycensus in R. All ACS data was filtered for Suffolk County, MA"),
                       tags$br(),
                       tags$br(),
                       tags$div(tags$ul(
                         tags$li("Within the ACS data, there were three distinct variables that recorded number of parents in the labor force with children under 6 for each census tract in the Boston area."),
                         tags$li("ACS variable B23008_004 (number of children under 6 from a 2-parent household with both parents in the labor force),  ACS variables B23008_010 (single working father household), B23008_013 (single working mother household). We then added these values to obtain the count of all children under 6 with all parents in the labor force. "),
                         tags$li("We then extracted the total number of children under 6 per tract (ACS variable B23008_002). We divided the previous sum by this total number of children under 6 to obtain the percent of children under 6 with parents in the labor force."),
                         style = "font-size: 15px"),
                         tags$br(),
                         tags$strong("Capacity for Early Education Provider"),
                         tags$br(),
                         tags$br(),
                         tags$em("This supply variable was created using the EEC dataset given to us by Community Labor United. The dataset was filtered for providers that provide care for children 6 and under (early education care), as this was our focus."),
                         tags$br(),
                         tags$br(),
                         p("To get a sense of the slots available for early education provision, we take the EEC dataset and use Python software to filter only for providers that provide early education childcare based three variables: rates, age, and licensed capacity."),
                         tags$br(),
                         tags$div(tags$ul(
                           tags$li("First, we obtain information on service availability from the Rates variable that list the prices of childcare service for four age groups, including infants, toddlers, preschoolers, and school age. The spread the Rates variable into 4 categorical variables of all age groups to use them as filters later on. After that, we use if statements and dictionary reader in Python to take out providers from the original datasets that only offer price information of cares for school-aged children and therefore only care for school-aged children. "),
                           tags$li("Second, for providers with no Rates data, we use Min Age and Max Age variables to take out providers with “6” as the minimum age. This procedure is based on two assumptions. We assume that providers that have no Rates or Age data and that care for all age groups, including school-age, to be providers for early ed. Accordingly, we consciously overestimated in favor of the current childcare system framework."),
                           style = "font-size: 15px")),
                         tags$br(),
                         tags$br(),
                         tags$strong("Capacity on the Tract and Neighboorhood Levels:"),
                         tags$br(),
                         tags$br(),
                         tags$div(tags$ul(
                           tags$li("First, we geocode the addresses of providers to map out all the providers. We then use the over function in R from rgeo and rgdal packages to figure out which tract or neighborhood on the polygon map each provider is located within. "),
                           tags$li("After that, we use the tidyverse package to group the providers by census tract, and calculated the total number of slots for early education childcare in each tract. We repeat this process for neighborhood so that we also have the total number of slots for early education childcare in each neighborhood. "),
                           tags$li("Finally, we merge these datasets with the respective geometry for each geography, to allow us to map the results."),
                           style = "font-size: 15px")),
                         tags$br(),
                         tags$br(),
                         tags$strong("Ratio of Children to Slots Available"),
                         tags$br(),
                         tags$br(),
                         tags$div(tags$ul(
                           tags$li("Divide the number of children in working families by the number of slots available. These calculations were done by tract and neighborhood. We use data provided by the shapefiles of neighborhoods and tracts figure out which neighborhood each tract is located within.
                                   "),
                           style = "font-size: 15px"))
                         )),
                     box(
                       title = "Hours",
                       width = NULL,
                       solidHeader = TRUE,
                       collapsible = TRUE,
                       collapsed = TRUE,
                       status = "info",
                       tags$br(),
                       tags$strong("Quantification of Nonstandard Work Shifts"),
                       tags$br(),
                       tags$br(),
                       tags$em("This demand variable was created using information provided by the 2016 American Community Survey data, which we accessed through tidycensus in R. All ACS data was filtered for Suffolk County, MA."),
                       tags$br(),
                       tags$br(),
                       tags$p("Based on previous methodology, we split nonstandard hours into three categories:"),
                       tags$div(tags$ul(
                         tags$li("Early morning: leaving for work anytime between 12am-6:29am (corresponds to ACS variables B08302_002, B08302_003, B08302_004, and B08302_005)"),
                         tags$li("Evenings: leaving for work anytime between 11am-3:59pm (corresponds to ACS variables B08302_013 and B08302_014)"),
                         tags$li("Late evenings/overnight: leaving for work anytime between 4pm-11:59pm (corresponds to ACS variable B08302_015)"),
                         style = "font-size: 15px"),
                         tags$p("We divided each of these values by the total number of workers in Suffolk County, to obtain percentage estimates for each nonstandard shift category."),
                         tags$br(),
                         tags$br(),
                         tags$strong("Aggregated Nonstandard Shift Map"),
                         tags$br(),
                         tags$br(),
                         tags$div(tags$ul(
                           tags$li("To create the aggregate map, we added the three nonstandard shift counts to obtain one general nonstandard shift count, and divided this by the total number of workers to obtain an aggregate percentage."),
                           tags$li("We then filtered the EEC dataset to show only providers that provide care outside of nonstandard working hours, 7:30am-6pm, based on 14 variables that show the open and close time on each day of the week (note: the dataset is already filtered for early education providers only). We then showed these providers with the option to see how many off-hour slots are available at that provider."),
                           style = "font-size: 15px"))
                       )
                     )
                       ))
              )
))




## UI 

ui <- dashboardPage(skin = "purple",
                    header = header,
                    sidebar = sidebar,
                    body = body
)
## SERVER

server <- function(input, output) {
  ## CAPACITY
  output$laborforce_demand <- renderLeaflet({
    leaflet(neighborho_demand_tract) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_laborforce(laborforce),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, stroke=TRUE, color="black", label=~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11) %>%
      addLegend("topleft", 
                pal = pal_laborforce, 
                values = ~laborforce,
                opacity = 1,
                title="# Children")
  })
  
  output$slots_supply <- renderLeaflet({
    leaflet(neighborho_capacity_tract) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_slots(slots),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11) %>%
      addLegend("topleft", 
                pal = pal_slots, 
                values = ~slots,
                opacity = 1,
                title = "# Slots")
  })
  
  output$ratioslots_gap <- renderLeaflet({
    leaflet(EEC_census) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_ratioslots(ratioslots),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_ratioslots, 
                values = ~ratioslots,
                opacity = 1,
                title = "Ratio Slots")
  })
  
  output$ratioslots_bar <- renderPlot({
    ggplot(EEC_census_bar, aes(x = reorder(Name_neighborho,ratioslots), y = ratioslots)) +
      geom_bar(fill = "blue", 
               stat = "identity") + 
      ggtitle( "Childcare Ratio by Neighborhood") + 
      xlab("Neighborhoods") +  
      ylab("Children Under 6 to Available Early Ed Slots Ratio") +
      geom_hline(yintercept=1) +
      coord_flip()
  })
  ## HOURS
  output$percent_early <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_early(percent_early),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_early, 
                values = ~percent_early,
                opacity = 1,
                title = "% Early Workers")
  })
  
  output$percent_evening <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_evening(percent_evening),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_evening, 
                values = ~percent_evening,
                opacity = 1,
                title = "% Evening Workers")
  })
  
  output$percent_overnight <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_overnight(percent_overnight),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black", 
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addLegend("topleft", 
                pal = pal_overnight, 
                values = ~percent_overnight,
                opacity = 1,
                title = "% Overnight Workers")
  })
  
  output$aggregate_percent <- renderLeaflet({
    leaflet(hours_demand) %>%
      addProviderTiles("CartoDB")  %>%
      addPolygons(fillColor = ~pal_aggregate_percent(aggregate_percent),
                  weight = 2,
                  opacity = .8,
                  color = "white",
                  dashArray = "3",
                  fillOpacity = 0.7) %>%
      addPolygons(data = boston_neighborhood, 
                  weight = 2, 
                  opacity = 1, 
                  fillOpacity = 0, 
                  stroke = TRUE, 
                  color = "black",
                  label = ~Name) %>% #adding neighborhood data
      setView(lng = -71.057083, 
              lat = 42.361145, 
              zoom = 11.5) %>%
      addCircleMarkers(data = EEC_earlyed,
                       ~lon,
                       ~lat,
                       radius = 2.5,
                       opacity = 1,
                       color = ~infant_pal(Weekdays_off_hours),
                       label = ~as.character(Capacity),
                       group= "Show childcare providers with off hours weekday care") %>%
      addLayersControl(overlayGroups = c("Show childcare providers with off hours weekday care")) %>%
      addLegend("topleft", 
                pal = pal_aggregate_percent, 
                values = ~aggregate_percent,
                opacity = 1,
                title="Aggregated Percentage")
  })
}

## SHINYAPP

shinyApp(ui, server)

