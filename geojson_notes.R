# source: https://rstudio.github.io/leaflet/json.html
# first approach is to use either geojsonio or rgdal (packages) to read GeoJSON/TopoJSON as sp objects. 
# Then, you can use the full functionality of polygons, markers, colors, legends, etc.

library(geojsonio)
library(leaflet)

# reading in annual wave density geojson file 

annual <- geojsonio::geojson_read("nrel-vbl_wef_allreg_ann.json", what = "sp", parse = TRUE)

## output is a BUNCH OF SHIT including (we think) everything we need
## bunch of javascript, retains geometries

# Or use the rgdal equivalent:
# nycounties <- rgdal::readOGR("json/nycounties.geojson", "OGRGeoJSON")

pal <- colorNumeric("viridis", NULL)

leaflet(annual) %>%
  addTiles() %>%
  addPolygons(stroke = FALSE, smoothFactor = 0.3, fillOpacity = 1,
              fillColor = ~pal(log10(pop)),
              label = ~paste0(county, ": ", formatC(pop, big.mark = ","))) %>%
  addLegend(pal = pal, values = ~log10(pop), opacity = 1.0,
            labFormat = labelFormat(transform = function(x) round(10^x)))

# other geoJson resources:
# https://cran.r-project.org/web/packages/geojsonR/vignettes/the_geojsonR_package.html
# https://gis.stackexchange.com/questions/226760/parse-geojson-file-in-r
