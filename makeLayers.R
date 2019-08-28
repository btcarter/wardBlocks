## Author: Benjamin Carter
# date: 2019-08-11
# objective: assign blocks to members based on street address and vector data
# notes - 

# variables
PACKAGES=list("rgdal","raster","ggplot2","rgeos","mapview","leaflet","broom")
DIRECTORY = file.path("~","Dropbox","alu","wardBlocks","directory.txt")
OUTPUT = "~/Box/alu/spatialData"

# load packages
lapply(PACKAGES,library,character.only=TRUE)

#### PREPROCESSING ####

# load data
ADDRESSES <- readOGR(file.path("~","Downloads","AddressPoints","AddressPoints.shp"))
ZIPCODES <- readOGR(file.path("~","Downloads","ZipCodes","ZipCodes.shp"))
Aerial1 <- brick(file.path("~","Downloads","12TVK460540","12TVK460540.tif"))
Aerial2 <- brick(file.path("~","Downloads","12TVK440540","12TVK440540.tif"))

# select home zip code information and then unload bigger data
HOME <- ZIPCODES[ZIPCODES[["ZIP5"]]==84606,]
utahCounty <- subset(ADDRESSES,ZipCode==84606)
ADDRESSES <- NULL
ZIPCODES <- NULL

# write new data to file and save
writeOGR(HOME,dsn=OUTPUT,layer="84606_border",driver="ESRI Shapefile")
writeOGR(utahCounty,dsn=OUTPUT,layer="84606_addresses",driver="ESRI Shapefile")

# assemble a composite image for aerial photography and export
AERIAL <- merge(Aerial1,Aerial2)
writeRaster(AERIAL,paste(OUTPUT,"satImage.tif",sep="/"),format="GTiff",overwrite=TRUE)

# make the ward block polygons
dfA <- read.delim(paste(OUTPUT,"block_A.txt",sep="/"),header = TRUE)
dfB <- read.delim(paste(OUTPUT,"block_B.txt",sep="/"),header = TRUE)

# make ward block polygons
BLOCKS <- c(paste(OUTPUT,"/block_",LETTERS[1:12],".txt",sep=""))

WARD <- list()
for (block in BLOCKS) {
  NAME <- gsub("~\\/Box\\/alu\\/spatialData\\/block_(\\w).txt","\\1",block)
  p <- read.delim(block,header = TRUE)
  p <- Polygon(p,hole=FALSE)
  p <- Polygons(list(p),ID = NAME)
  WARD <- append(WARD,assign(paste("block_",NAME,sep=""),p))
}
WARD <- SpatialPolygons(WARD)
proj4string(WARD) <- CRS("+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
# NEED TO MAKE A DF OF INFO FOR THE WARDS POLYGON
WARD <- SpatialPolygonsDataFrame(WARD,data.frame())

writeOGR(WARD,dsn=OUTPUT,layer="blocks",driver="ESRI Shapefile")

# p <- SpatialPolygonsDataFrame(p,data.frame(block=NAME)) use to add data to polygon

# plot stuff - makes map of Utah with addresses
plotRGB(satTEST,r=1,g=2,b=3,main="Provo Peaks 12th Ward")
plot(HOME,add=TRUE)
plot(utahCounty,add=TRUE,col="blue")

