# This script will general block captain briefs using the Google Sheet and template R markdown

# variables
PACKAGES <- c("googlesheets","dplyr")
PACKAGES=list("googlesheets","dplyr")
SHEET="Ward Members by Blocks"
TEMPLATE=file.path("~","Dropbox","alu","wardBlocks","blockBriefTemplate.Rmd")
# OUT_DIR=file.path("~","Box","alu","briefs")
OUT_DIR=file.path("~","Downloads")

# load packages
lapply(PACKAGES,library,character.only = TRUE)

GS <- gs_title(SHEET)
CAPS <- gs_read(GS,"Leader Assignments")


for (cap in CAPS$Leaders) {
  block <- CAPS$Block[CAPS$Leaders == cap]
  roster <- gs_read(GS,paste("Block",block,sep = " "))
  roster <- roster[,-4]
  # render
  rmarkdown::render(
    input = TEMPLATE,
    output_dir = OUT_DIR,
    output_file = paste(block,".pdf",sep=""),
    output_format = "pdf_document",
    params = list(
      captain = cap,
      block = block,
      roster = roster
    )
    )
  print(paste("finished block",block,sep=" "))
  Sys.sleep(20)
}
