############  jul GRAPH ################ ################ ################ ################ ################ ################
################ ################ ################ ################ ################ ################

jul_swh <- read_sf ("244-extra/vbl_ssh_allreg_jul", layer = "vbl_ssh_allreg_julPolygon")


############ ################ ################ ################ ################ ################ ################
################ ################ ################ ################ ################ ################

SWH_SB_Cavanaugh1 <- read_csv("SWH_SB_Cavanaugh1.csv")

ext1 <- extent(-120.68, -117.25, 32.15, 34.71) # SOMETHING IS WRONG WITH THIS BOX? # zoe says... is this fixed?
gridsize1 <- 0.083
r1 <- raster(ext1, res=gridsize1)

##make cropped vector for southern california to rasterize; seems easier to crop the vector first rather than cropping the raster after
crop_jul <- st_crop(jul_swh, c(xmin=-120.68, xmax=-117.25, ymin=32.15, ymax=34.71)) #look up exact bounding box from arpa-e ## zoe says agian, is this fixed?

crop_socal_ras2 <- fasterize(crop_jul, r1, field = "jul_ssh") #used cropped vector and new cropped raster; this method appears identical
crop_socal_ras2

kelploss_jul <- (150.422 * crop_socal_ras2) / (3.54 + crop_socal_ras2) ### here we added in equation to convert to kelp loss instead of swh

################ equation information ##########################

#S <- SWH_SB_Cavanaugh1$Max_Wave_Height
#v <- SWH_SB_Cavanaugh1$Percent_Loss
#mm <- data.frame(S,v)
#wave_model <- nls(v ~ Vm * S/(K+S), data = mm, start = list(K = max(mm$v)/2, Vm = max(mm$v)))
#Non-linear equation:
#Macrocystis biomass loss (%) = [150.422 (significant wave height) / (3.54 + significant wave height)

#################################################################


CA <- read_sf("244-extra", layer = "california_county_shape_file") %>% 
  dplyr::select(STATE)

tmap_mode("plot")

jul_map <- tm_shape(kelploss_jul) +
  tm_raster(title = "Heatmap of July Kelp Loss")+
  tm_layout(bg.color = "skyblue",
            legend.position = c("left","bottom"),
            legend.text.color = "white",
            legend.text.size = 0.5)+
  tm_shape(CA)+
  tm_borders("white", lwd = 2)+
  tm_fill("darkgreen")

# check the map
jul_map

## once the graph is finalized:
tmap_save(jul_map, "Kelpinator/www/july.png", height = 10)
