################### output heatmaps ####################

library(sf)
library(tmap)
library(leaflet)
library(ggrepel)
library(ggspatial)
library(RColorBrewer)
library(fasterize)
library(raster)
library(colorspace)
library(ggplot2)
library(rasterVis)
library(rgdal)

### NOTES ###
#
# should we just leave this in wave height? or do we want to go thoruhg the backflipping of converting everything using rae's equation = kelp loss?
#
# if we want to convert, we can use projectRaster, i think, from Lab 7 


############  ANNUAL GRAPH ################

annual_swh <- read_sf ("244-extra", layer = "vbl_ssh_allreg_annPolygon") #244-extra is the folder it's in within this working directory
#annual_swh
SWH_SB_Cavanaugh1 <- read_csv("SWH_SB_Cavanaugh1.csv")

ext1 <- extent(-120.68, -117.25, 32.15, 34.71) # SOMETHING IS WRONG WITH THIS BOX?
gridsize1 <- 0.083
r1 <- raster(ext1, res=gridsize1)

##make cropped vector for southern california to rasterize; seems easier to crop the vector first rather than cropping the raster after
crop_annual <- st_crop(annual_swh, c(xmin=-120.68, xmax=-117.25, ymin=32.15, ymax=34.71)) #look up exact bounding box from arpa-e

crop_socal_ras2 <- fasterize(crop_annual, r1, field = "ann_ssh") #used cropped vector and new cropped raster; this method appears identical
crop_socal_ras2

kelploss_ann <- (150.422 * crop_socal_ras2) / (3.54 + crop_socal_ras2)  #(ADD IN THE EQUATION HERE) ### here we will add in equation and then plot (rae)

#S <- SWH_SB_Cavanaugh1$Max_Wave_Height
#v <- SWH_SB_Cavanaugh1$Percent_Loss
#mm <- data.frame(S,v)
#wave_model <- nls(v ~ Vm * S/(K+S), data = mm, start = list(K = max(mm$v)/2, Vm = max(mm$v)))
#Non-linear equation:
#Macrocystis biomass loss (%) = [150.422 (significant wave height) / (3.54 + significant wave height)
                                  

### well gplot is being a dumb cunt so I'm going to try using tmap

# TO FINALIZE:
## - change input data to kelploss_ann (once it's ready) 
## - figure out what our actual "Southern CA" extent is and adjust crop above
## - copy paste to the rest of the graphs


CA <- read_sf("244-extra", layer = "california_county_shape_file") %>% 
  dplyr::select(STATE)

tmap_mode("plot")

annual_map <- tm_shape(kelploss_ann) +
  tm_raster(title = "Annual Kelp Biomass Percent Loss")+
  tm_layout(bg.color = "cadetblue",
            legend.title.size = 2,
            legend.position = c("left","bottom"),
            legend.text.color = "white",
            legend.text.size = 1.75,
            legend.frame = "white",
            legend.frame.lwd = 2)+
  tm_shape(CA)+
  tm_borders("white", lwd = 2)+
  tm_fill("darkolivegreen")
annual_map

## once the graph is finalized:
tmap_save(annual_map, "Kelpinator/www/annual.png", height = 10)

