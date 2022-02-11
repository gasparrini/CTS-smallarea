################################################################################
# ANALYSIS OF SMALL-AREA DATA WITH THE CASE TIME SERIES DESIGN
################################################################################

################################################################################
# PUT TOGETHER THE DATA
################################################################################

# LOAD THE PACKAGES
library(terra) ; library(sf)
library(readxl) ; library(dplyr) ; library(data.table)

################################################################################
# ADMINISTRATIVE AREAS

# IDENTIFY LONDON MSOA IN MORTALITY DATA
source <- "V:/VolumeQ/AGteam/ONS/msoadeath20062013/"
file <- paste0("numberofdailydeathsbymiddlesuperoutputareasmsoasoflondon",
  "july2006july2013andjuly2016.xls")
lndmsoadeath <- as.data.frame(read_excel(paste0(source, file), sheet=2, skip=9))
seqmsoa <- sort(unique(lndmsoadeath$`MSOA Code`))

# LOOKUP LSOA-MSOA
source <- "V:/VolumeQ/AGteam/ONS/geography/lookup"
file <- paste0("Output_Area_to_Lower_Layer_Super_Output_Area_to_Middle_Layer_",
  "Super_Output_Area_to_Local_Authority_District_(December_2011)_Lookup_in_",
  "England_and_Wales.csv")
lookup <- read.csv(paste(source, file, sep="/")) |>
  select(LSOA11CD, MSOA11CD) |> unique() |> 
  merge(data.frame(MSOA11CD=seqmsoa))

################################################################################
# GEOGRAPHICAL MSOA BOUNDARIES

# LOAD MSOA SHAPEFILES FOR ALL ENGLAND & WALES (ROUGH GENERALISED)
source <- "V:/VolumeQ/AGteam/ONS/geography/shapefiles"
file <- paste0("Middle_Layer_Super_Output_Areas_(December_2011)_Boundaries_",
  "Generalised_Clipped_(BGC)_EW_V3")
file.copy(paste0(source, "/MSOA/", file, "-shp.zip"), getwd())
unzip(zipfile=paste0(file,"-shp.zip"), exdir=getwd())
ewmsoashp <- st_read(paste0(file, ".shp"))[2]
file.remove(list.files()[grep(file, list.files(), fixed=T)])

# RESTRICT TO LONDON
all(seqmsoa %in% ewmsoashp$MSOA11CD)
lndmsoashp <- ewmsoashp[ewmsoashp$MSOA11CD %in% seqmsoa,]
rm(ewmsoashp)

################################################################################
# TEMPERATURE GRIDDED DATA

# SELECT NCDF FILES WITH TEMPERATURE DATA
ncfiles <- paste0("V:/VolumeQ/AGteam/MetData/Netcdf/ukcp18_1kmgrid_v1030/", 
  c("tasmax", "tasmin"), "/yearly_files/", c("tasmax", "tasmin"),
  "_hadukgrid_uk_1km_day_", rep(c(2006, 2013), each=2), ".nc")

# STACK THE RASTERS FOR YEARLY FILES AND SELECT THE SUMMER MONTHS
dates <- c(seq(as.Date("2006/01/01"), as.Date("2006/12/31"), by=1), 
  seq(as.Date("2013/01/01"), as.Date("2013/12/31"), by=1))
submonth <- which(month(dates) %in% unique(lndmsoadeath$Month))
tmaxgrid <- subset(Reduce(c,lapply(ncfiles[c(1,3)], rast)), submonth)
tmingrid <- subset(Reduce(c,lapply(ncfiles[c(1,3)+1], rast)), submonth)

# SET PROJECTIONS, ALL KNOWN TO BE AS BRITISH NATIONAL GRID
crs(tmaxgrid) <- crs(tmingrid) <- st_crs(lndmsoashp) <- "EPSG:27700"

# CROP TO THE EXTENT OF LONDON (OUTWARDS TO INCLUDE ANY TOUCHING CELL)
lndtmaxgrid <- crop(tmaxgrid, extent(lndmsoashp), snap="out")
lndtmingrid <- crop(tmingrid, extent(lndmsoashp), snap="out")
rm(tmaxgrid, tmingrid)

################################################################################
# IMD

# LOAD IMD FOR 2015
source <- "V:/VolumeQ/AGteam/GOV/England/IMD/2015"
file <- paste0("File_7_ID_2015_All_ranks__deciles_and_scores_for_the_Indices_",
  "of_Deprivation__and_population_denominators.csv")

# EXTRACT SCORE AND RANK
lndlsoaimd <- read.csv(paste(source, file, sep="/")) |>
  select(1, 5, 6) |> rename(LSOA11CD=1, imdscore=2, imdrank=3)

################################################################################
# SAVE THE DATA

# SAVE MSOA SHAPEFILES IN ZIP FORMAT
st_write(lndmsoashp, "lndmsoashp.shp")
files <- list.files()[grep("lndmsoashp", list.files(), fixed=T)]
zip("data/lndmsoashp.zip", files)
file.remove(files)

# SAVE THE OTHER DATA
write.csv(lndmsoadeath, file="data/lndmsoadeath.csv", row.names=F)
write.csv(lookup, file="data/lookup.csv", row.names=F)
writeCDF(lndtmaxgrid, filename="data/lndtmaxgrid.nc", overwrite=TRUE) 
writeCDF(lndtmingrid, filename="data/lndtmingrid.nc", overwrite=TRUE) 
write.csv(lndlsoaimd, file="data/lndlsoaimd.csv", row.names=F)

