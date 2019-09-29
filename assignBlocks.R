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
F <- merge(DIR,E, all.x = TRUE) # this essentially performs a left join

# tidy up loose ends. Why aren't these getting added?
F$Block[F$UTAddPtID == "383 N 400 E PROVO, UTAH 84606"] <- "B" 
F$Block[F$UTAddPtID == "PROVO | 1338 E 580 N"] <- "K"          
F$Block[F$UTAddPtID == "PROVO | 318 N 400 E"] <- "D"           
F$Block[F$UTAddPtID == "PROVO | 335 N 400 E"] <- "D"           
F$Block[F$UTAddPtID == "PROVO | 346 N 700 E"] <- "G"           
F$Block[F$UTAddPtID == "PROVO | 353 N 800 E"]<- "H"           
F$Block[F$UTAddPtID == "PROVO | 355 N 600 E BSMT"] <- "F"      
F$Block[F$UTAddPtID == "PROVO | 360 N 300 E"] <- "A"           
F$Block[F$UTAddPtID == "PROVO | 378 N 500 E"] <- "E"           
F$Block[F$UTAddPtID == "PROVO | 380 E 400 N"] <- "B"           
F$Block[F$UTAddPtID == "PROVO | 400 E 318 N"] <- "D"           
F$Block[F$UTAddPtID == "PROVO | 421 N BELMONT PLACE"] <- "J"   
F$Block[F$UTAddPtID == "PROVO | 450 N 1130 E"] <- "J"          
F$Block[F$UTAddPtID == "PROVO | 451 E 300 N"] <- "J"           
F$Block[F$UTAddPtID == "PROVO | 476 N 300 E"] <- "J"           
F$Block[F$UTAddPtID == "PROVO | 733 N SEVEN PEAKS BLVD"] <- "L"
# F[is.na(F$Block),] # check for unassigned addresses
KEEP <- c("NAME","AGE","ADDRESS","Block")
F <- F[KEEP] # directory with only needed values

#### SEND TO GOOGLESHEET ####
PACKAGES=list("googlesheets","dplyr")
SHEET="Ward Members by Blocks"
BLOCKS=LETTERS[1:12]

# load/install packages
lapply(PACKAGES,library,character.only=TRUE)

#   make connection to ward googlesheet
GS <- gs_title(SHEET)                                             # register the sheet

#   make block leader worksheets
for (BLOCK in BLOCKS) {
  sheet <- na.omit(F[F[["Block"]]==BLOCK,])
  NAME <- paste("Block ",BLOCK,sep="")
  GS <- GS %>% gs_ws_delete(ws=NAME)
  GS <- GS %>% gs_ws_new(ws_title=NAME,input=sheet)
}
