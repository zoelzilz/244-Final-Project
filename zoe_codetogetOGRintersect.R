library(sf)
library(sp)
library(tmap)
library(leaflet)
library(ggrepel)
library(ggspatial)
library(RColorBrewer)
library(fasterize)
library(raster)
library(colorspace)
library(maptools)
library(leaflet.minicharts)
library(rgdal)
library(taRifx.geo)
library(tidyverse)

annual_swh <- read_sf ("244-extra", layer = "vbl_ssh_allreg_annPolygon")
jan_swh <- read_sf ("244-extra/vbl_ssh_allreg_jan", layer = "vbl_ssh_allreg_janPolygon")
feb_swh <- read_sf ("244-extra/vbl_ssh_allreg_feb", layer = "vbl_ssh_allreg_febPolygon")
mar_swh <- read_sf ("244-extra/vbl_ssh_allreg_mar", layer = "vbl_ssh_allreg_marPolygon")
apr_swh <- read_sf ("244-extra/vbl_ssh_allreg_apr", layer = "vbl_ssh_allreg_aprPolygon")
may_swh <- read_sf ("244-extra/vbl_ssh_allreg_may", layer = "vbl_ssh_allreg_mayPolygon")
jun_swh <- read_sf ("244-extra/vbl_ssh_allreg_jun", layer = "vbl_ssh_allreg_junPolygon")
jul_swh <- read_sf ("244-extra/vbl_ssh_allreg_jul", layer = "vbl_ssh_allreg_julPolygon")
aug_swh <- read_sf ("244-extra/vbl_ssh_allreg_aug", layer = "vbl_ssh_allreg_augPolygon")
sep_swh <- read_sf ("244-extra/vbl_ssh_allreg_sep", layer = "vbl_ssh_allreg_sepPolygon")
oct_swh <- read_sf ("244-extra/vbl_ssh_allreg_oct", layer = "vbl_ssh_allreg_octPolygon")
nov_swh <- read_sf ("244-extra/vbl_ssh_allreg_nov", layer = "vbl_ssh_allreg_novPolygon")
dec_swh <- read_sf ("244-extra/vbl_ssh_allreg_dec", layer = "vbl_ssh_allreg_decPolygon")


annual_ogr <- readOGR("244-extra", layer = "vbl_ssh_allreg_annPolygon")
jan_ogr <- readOGR("244-extra/vbl_ssh_allreg_jan", layer = "vbl_ssh_allreg_janPolygon")
feb_ogr <- readOGR ("244-extra/vbl_ssh_allreg_feb", layer = "vbl_ssh_allreg_febPolygon")
beep(1)
##
mar_ogr <- readOGR ("244-extra/vbl_ssh_allreg_mar", layer = "vbl_ssh_allreg_marPolygon")
apr_ogr <- readOGR ("244-extra/vbl_ssh_allreg_apr", layer = "vbl_ssh_allreg_aprPolygon")
may_ogr <- readOGR ("244-extra/vbl_ssh_allreg_may", layer = "vbl_ssh_allreg_mayPolygon")
jun_ogr <- readOGR ("244-extra/vbl_ssh_allreg_jun", layer = "vbl_ssh_allreg_junPolygon")
jul_ogr <- readOGR ("244-extra/vbl_ssh_allreg_jul", layer = "vbl_ssh_allreg_julPolygon")
aug_ogr <- readOGR ("244-extra/vbl_ssh_allreg_aug", layer = "vbl_ssh_allreg_augPolygon")
sep_ogr <- readOGR ("244-extra/vbl_ssh_allreg_sep", layer = "vbl_ssh_allreg_sepPolygon")
oct_ogr <- readOGR ("244-extra/vbl_ssh_allreg_oct", layer = "vbl_ssh_allreg_octPolygon")
nov_ogr <- readOGR ("244-extra/vbl_ssh_allreg_nov", layer = "vbl_ssh_allreg_novPolygon")
dec_ogr <- readOGR ("244-extra/vbl_ssh_allreg_dec", layer = "vbl_ssh_allreg_decPolygon")

harvest_beds <- read_sf("MAN_CA_KelpAdmin", layer = "MAN_CA_KelpAdmin") %>% 
  st_transform(crs = 4326)

harvest_beds_ogr <- readOGR("MAN_CA_KelpAdmin", layer = "MAN_CA_KelpAdmin") 
harvest_beds_ogr <- spTransform(harvest_beds_ogr, CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"))


names(annual_ogr)[names(annual_ogr)=="ann_ssh"] <- "ssh" #this worked
names(jan_ogr)[names(jan_ogr)=="jan_ssh"] <- "ssh"
annJan <- rbind(annual_ogr, jan_ogr, fix.duplicated.IDs = TRUE) #now it works!
#Error in match.names(clabs, names(xi)) : names do not match previous names
#########column names for swh are different, ann_ssh vs. jan_ssh --> need to make match to do rbind
##while this works, I would have to bind one at a time
names(feb_ogr)[names(feb_ogr)=="feb_ssh"] <- "ssh"
annFeb <- rbind(annJan, feb_ogr, fix.duplicated.IDs = TRUE)


ogr_annual_intersect <- annJan %>% 
  intersect(harvest_beds)#non identical CRS again even though they do

ogr_annual_intersect <- annJan %>% #works with this one
  intersect(harvest_beds_ogr) #intersect is in raster package
plot(ogr_annual_intersect) #it worked! I think

ogr_annual_intersect2 <- annFeb %>% #also worked, but is pretty slow. lets make sure leaflet likes these SPDF before I finish the rest of the code
  intersect(harvest_beds_ogr) 

############################ with sf ###############################
beds_swh <- annual_swh %>% 
  st_intersection(harvest_beds)
plot(beds_swh) 
# so this worked but we still probably want to take a mean of the swh in each bed and make new columns for that so that we have one clickable area (each harvest bed) that averages the swh polygons that intersect.  