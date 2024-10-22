############  sep GRAPH ################ ################ ################ ################ ################ ################
################ ################ ################ ################ ################ ################

sep_swh <- read_sf ("244-extra/vbl_ssh_allreg_sep", layer = "vbl_ssh_allreg_sepPolygon")


############ ################ ################ ################ ################ ################ ################
################ ################ ################ ################ ################ ################

SWH_SB_Cavanseph1 <- read_csv("SWH_SB_Cavanseph1.csv")

ext1 <- extent(-120.68, -117.25, 32.15, 34.71) # SOMETHING IS WRONG WITH THIS BOX? # zoe says... is this fixed?
gridsize1 <- 0.083
r1 <- raster(ext1, res=gridsize1)

##make cropped vector for southern california to rasterize; seems easier to crop the vector first rather than cropping the raster after
crop_sep <- st_crop(sep_swh, c(xmin=-120.68, xmax=-117.25, ymin=32.15, ymax=34.71)) #look up exact bounding box from arpa-e ## zoe says agian, is this fixed?

crop_socal_ras2 <- fasterize(crop_sep, r1, field = "sep_ssh") #used cropped vector and new cropped raster; this method appears identical
crop_socal_ras2

kelploss_sep <- (150.422 * crop_socal_ras2) / (3.54 + crop_socal_ras2) ### here we added in equation to convert to kelp loss instead of swh

################ equation information ##########################

#S <- SWH_SB_Cavanseph1$Max_Wave_Height
#v <- SWH_SB_Cavanseph1$Percent_Loss
#mm <- data.frame(S,v)
#wave_model <- nls(v ~ Vm * S/(K+S), data = mm, start = list(K = max(mm$v)/2, Vm = max(mm$v)))
#Non-linear equation:
#Macrocystis biomass loss (%) = [150.422 (significant wave height) / (3.54 + significant wave height)

#################################################################


CA <- read_sf("244-extra", layer = "california_county_shape_file") %>% 
  dplyr::select(STATE)

tmap_mode("plot")

sep_map <- tm_shape(kelploss_sep) +
  tm_raster(title = "September Kelp Biomass Percent Loss")+
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

# check the map
sep_map

## once the graph is finalized:
tmap_save(sep_map, "Kelpinator/www/September.png", height = 10)
