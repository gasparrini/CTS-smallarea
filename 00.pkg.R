################################################################################
# R code for the analysis in:
#
#  Gasparrini A. A tutorial on the case time series design for small-area 
#    analysis. BMC Medical Research Methodology. 2022;22:129.
#  https://doi.org/10.1186/s12874-022-01612-x
#
# * an updated version of this code, compatible with future versions of the
#   software, is available at:
#   https://github.com/gasparrini/CTS-smallarea
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
