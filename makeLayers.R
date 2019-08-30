## Author: Benjamin Carter
# date: 2019-08-11
# objective: assign blocks to members based on street address and vector data
# notes - 

# variables
PACKAGES=list("rgdal","raster","ggplot2","rgeos")
DIRECTORY = file.path("~","Dropbox","alu","wardBlocks","directory.txt")
OUTPUT = "~/Box/alu/spatialData"

# load packages
lapply(PACKAGES,library,character.only=TRUE)

#### STATE DATA PREPROCESSING ####

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

#### WARD BLOCK CREATION ####

# make ward block polygons
BLOCKS <- c(paste(OUTPUT,"/block_",LETTERS[1:12],".txt",sep=""))

WARD <- list()
i=1
while (i < length(BLOCKS) + 1) {
  block = BLOCKS[i]
  NAME <- gsub("~\\/Box\\/alu\\/spatialData\\/block_(\\w).txt","\\1",block)
  p <- read.delim(block, header = TRUE)
  p <- Polygon(p, hole=FALSE)
  p <- Polygons(list(p), ID = as.numeric(i))
  WARD <- append(WARD, assign(paste("block_", NAME, sep=""), p))
  i = i + 1
}
  
WARD <- SpatialPolygons(WARD)
proj4string(WARD) <- CRS("+proj=utm +zone=12 +datum=NAD83 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")
df <- read.delim(paste(OUTPUT,"/blockDF.txt",sep=""),header=TRUE,stringsAsFactors = FALSE)
WARD <- SpatialPolygonsDataFrame(WARD,data.frame(df))

writeOGR(WARD,dsn=OUTPUT,layer="wardBlocks",driver="ESRI Shapefile",overwrite_layer = TRUE)
