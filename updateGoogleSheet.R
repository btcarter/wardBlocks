# Author: Benjamin Carter
# date: 2019-08-10
# objective: update the ward google sheet Ward Members by block.
# notes - this script will require you to authenticate tidyverse for your Google Drive the first time it is run.

# variables
PACKAGES=list("googlesheets","dplyr")
SHEET="Ward Members by Blocks"
BLOCKS=toupper(letters[1:12])
DIRECTORY=file.path("~","Dropbox","alu","wardBlocks","directory.txt") # path to current ward directory text file

# load/install packages
lapply(PACKAGES,library,character.only=TRUE)

# execute
#   make connection to ward googlesheet
GS <- gs_title(SHEET)                                             # register the sheet
CAPTAINS <- gs_read(GS,ws="Leader Assignments")                   # get the list of block captains
GS_DIR <- gs_read(GS,ws="allMembers")

#   update ward directory
DIRECTORY <- read.delim(DIRECTORY,header=TRUE)
GS <- GS %>% gs_ws_delete(ws="Directory")
GS <- GS %>% gs_ws_new(ws_title = "Directory",input=DIRECTORY)

#   make block leader worksheets
blsheets <- function(BLOCK,DIRECTORY,GOOGLESHEET){
  sheet <- DIRECTORY[DIRECTORY[["Block"]]==BLOCK]
  NAME <- paste("Block ",BLOCK)
  GOOGLESHEET <- GOOGLESHEET %>% gs_ws_delete(ws=NAME)
  GOOGLESHEET <- GOOGLESHEET %>% gs_ws_new(ws_title=NAME,input=sheet)
  return(print(paste("uploaded ",BLOCK)))
}

lapply(BLOCKS,blsheets,DIRECTORY=DIRECTORY,GOOGLESHEET=GS,character.only=TRUE)

