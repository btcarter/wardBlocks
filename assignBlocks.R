# Author: Benjamin Carter
# date: 2019-08-28
# objective: assign blocks to ward addresses

#### Set the environment ####
# libraries to load
PACKAGES=list("sp","rgdal","rgeos","ggmap","raster")
lapply(PACKAGES,library,character.only=TRUE)

# files and paths
OUTPUT = file.path("~","Box","alu")               # destination directory for the output
SOURCE = file.path("~","Box","alu","spatialData") # directory with source shapefiles
A <- file.path(SOURCE,"84606_addresses.shp")      # path to addresses point shapefile
B <- file.path(SOURCE,"wardBlocks.shp")           # path to ward blocks shapefile
DIR <- file.path(OUTPUT,"directory.txt")

#### execute ####

# read data
A <- readOGR(A) # read in addresses
B <- readOGR(B) # read in blocks

# cropping
C <- over(A,B)
A$Block <- C$block # adds a block variable to address point data
D <- A[B,] # crops point data to only ward addresses

# save a table with the data
write.table(D@data,file = file.path(OUTPUT,"addresses.txt"), append = FALSE, sep = "\t", row.names = FALSE, col.names = TRUE)

# add block assignments to ward directory
DIR <- read.delim(DIR,header = TRUE, stringsAsFactors = FALSE)  # load directory
DIR$TEST <- gsub("North","N",DIR$ADDRESS, ignore.case = TRUE) # fix cardinal directions
DIR$TEST <- gsub("East","E",DIR$TEST, ignore.case = TRUE)
DIR$TEST <- gsub("West","W",DIR$TEST, ignore.case = TRUE)
DIR$TEST <- gsub("South","S",DIR$TEST, ignore.case = TRUE)
DIR$TEST <- gsub("\\s\\#\\d*","",DIR$TEST, ignore.case = TRUE) # remove apartment numbers
DIR$UTAddPtID <- gsub("(\\d+)\\s(\\w)\\s(.*), Provo, Utah.*","PROVO | \\1 \\2 \\3",DIR$TEST) # parse address column to UTAddPtID format
DIR$UTAddPtID <- toupper(DIR$UTAddPtID) # convert to uppercase
DIR$TEST <- NULL

E <- D@data
E$UTAddPtID <- as.character(E$UTAddPtID)

# get block assignments
F <- merge(DIR,E, all.x = TRUE)
