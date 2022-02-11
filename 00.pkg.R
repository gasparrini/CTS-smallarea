################################################################################
# ANALYSIS OF SMALL-AREA DATA WITH THE CASE TIME SERIES DESIGN
################################################################################

################################################################################
# LOAD THE PACKAGES
################################################################################

library(data.table) # HANDLE LARGE DATASETS
library(dlnm) ; library(gnm) ; library(splines) # MODELLING TOOLS
library(sf) ; library(terra) # HANDLE SPATIAL DATA
library(exactextractr) # FAST EXTRACTION OF AREA-WEIGHTED RASTER CELLS
library(dplyr) ; library(tidyr) # DATA MANAGEMENT TOOLS
library(ggplot2) ; library(patchwork) # PLOTTING TOOLS
