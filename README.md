# A tutorial on the case time series design for small-area analysis

A case-study illustration on the application of the case time series design for the analysis of small-area data in environmental epidemiology

------------------------------------------------------------------------

This repository stores the updated R code and data to reproduce the analyisis of the case study presented in the article:

Gasparrini A. A tutorial on the case time series design for small-area analysis. *BMC Medical Research Methodology*. 2022;22:129. DOI: doi.org/10.1186/s12874-022-01612-x. [[freely available here](http://www.ag-myresearch.com/2022_gasparrini_bmcmrm.html)]

### Data

The case study describes an analysis on the association between heat and mortality in two summers (2006 and 2013) in London, UK. The data are provided for 983 middle layer super output areas (MSOAs), which are small census-based aggregations. The mortality data is then linked with gridded daily temperature data, and then with measures of area-level deprivation at lower layer super output areas (LSOAs).

**Note**: The datasets provided here are adapted from the original data available from different repositories (see the article for sources and links). The R script mkdata.R in the folder *addscript* includes the code for reproducing the datasets from the original sources, and it is provided for completeness. The reader must download and store the original data to run this script.

Specifically, the folder *data* includes the following datasets:

-  *lndmsoadeath.csv*: original datasets (as csv file) storing the number of deaths for each MSOA of London in each day, for two age groups.
-   *lndmaxgrid.nc* and *lndmingrid.nc*: 1x1km gridded spatio-temporal data (as NetCDF files) of maximum and minimum temperature, respectively, in the bounding box including London.
-   *lndmsoashp.zip*: spatial boundaries (as zipped shapefiles) of the 983 MSOAs of London.
-   *lndlsoaimd.csv*: dataset (as csv file) of the score and ranking of the Index of multiple deprivation (IMD) for the 32,844 LSOAs of England.
-   *lookup.csv*: lookup table (as CSV file) linking LSOAs to MSOAs.

### R code

The five R scripts reproduces all the steps of the analysis and the full results. Specifically:

-   *00.pkg.R* loads the packages.
-   *01.tsprep.R* prepares the data in a case time series format starting from the original mortality data.
-   *02.linktmean.R* links the gridded temperature data.
-   *03.mainmof.R* performs the main model and a comparison with the standard time series model on fully aggregated data.
-   *04.intmod.R* investigates the differential risks by deprivation score.
