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
# LINK GRIDDED TEMPERATURE DATA
################################################################################

################################################################################
# LOAD SHAPEFILES OF MSOA IN LONDON AND GRIDDED TEMPERATURE DATA

# LOAD MSOA BOUNDARIES
unzip("data/lndmsoashp.zip")
lndmsoashp <- st_read("lndmsoashp.shp")
files <- list.files()[grep("lndmsoashp", list.files(), fixed=T)]
file.remove(files)

# LOAD MIN/MAX GRIDDED TEMPERATURE DATA (TWO NETCDF FILES) AND COMPUTE TMEAN
lndtmingrid <- rast("data/lndtmingrid.nc")
lndtmaxgrid <- rast("data/lndtmaxgrid.nc")
lndtmeangrid <- (lndtmingrid + lndtmaxgrid) /2

################################################################################
# PLOT THE MAPS OF AVERAGE SEASONAL GRIDDED TEMPERATURE

# PLOT THE MAPS
# - START FROM THE RASTER OBJECT AND AGGREGATE LAYERS BY YEAR
# - INCLUDE IN A DATAFRAME WITH THE RELATED CELL COORDINATES
# - THEN RESHAPE TO LONG AND RENAME YEAR LABELS
# - FINALLY PLOT THE GRIDDED VALUES AND SUPERIMPOSED MSOA BOUNDARIES
lndtmeangrid |>
  tapp(year(seqdate), mean) |>
  as.data.frame(xy=T) |>
  pivot_longer(cols=3:4, names_to="year", values_to="tmean") |>
  mutate(year=factor(year, labels=unique(year(seqdate)))) |>
  ggplot(aes(x=x, y=y, fill=tmean)) +
  geom_raster(na.rm=T) +
  geom_sf(data=lndmsoashp, col=1, size=0.2, fill=NA, inherit.aes=F) +
  scale_fill_distiller(palette="YlOrRd", direction=1, na.value='white') + 
  guides(fill=guide_colourbar(barwidth=0.7, barheight=9)) +
  labs(x="Longitude", y="Latitude", fill="\u00B0C") +
  theme_minimal() +
  facet_wrap(~year)

# SAVE THE PLOT
ggsave("figures/fig2.pdf", width=10, height=4)

################################################################################
# LINK TEMPERATURE DATA

# COMPUTE THE AREA-WEIGHTED AVERAGE OF CELLS INTERSECTING EACH MSOA
#tmeanmsoa <- raster::extract(lndtmeangrid, lndmsoashp, weights=T, fun=mean, na.rm=T)
lndtmeanmsoa <- exact_extract(lndtmeangrid, lndmsoashp, fun="mean")
dimnames(lndtmeanmsoa) <- list(seqmsoa, as.character(seqdate))

# MERGE WITH MAIN DATASETS (EXPLOIT ORDERED SEQUENCES)
datafull$tmean <- c(t(lndtmeanmsoa))
dataggr <- merge(dataggr, datafull[, list(tmean=mean(tmean)), by=date])
# 
# # CREATE LAGGED ENVIRONMENTAL SERIES BY MSOA
# datafull[, paste("tmean", 1:3, sep="_"):=data.table::shift(tmean, 1:3),
#   by=MSOA11CD]

################################################################################
# STATISTICS OF VARIATION IN TEMPERATURE

# TEMPORAL (BETWEEN-DAY): AVERAGE SD ACROSS DAYS BY MSOA
# SPATIAL (BETWEEN-MSOA): AVERAGE SD ACROSS MSOA BY DAY
mean(datafull[, list(sd=sd(tmean)), by=MSOA11CD]$sd)
mean(datafull[, list(sd=sd(tmean)), by=date]$sd)

################################################################################
# PLOT THE MAPS OF DAILY TEMPERATURE ACROSS MSOA

# DEFINE FUNCTION TO CREATED EXTENDED HEAT COLOURS
fcol <- colorRampPalette(c(heat.colors(8, rev=T), paste0("red",2:4)))

# PLOT THE MAPS FOR THREE CONSECUTIVE DAYS
lndmsoashp %>%
  merge(subset(datafull, date %in% seqdate[43:45])) |>
  ggplot() +
  geom_sf(aes(fill=tmean), size=0.2, col=1) +
  scale_fill_gradientn(colours=fcol(10)) + 
  guides(fill=guide_colourbar(title.position="left", barwidth=15,
    barheight=0.5)) +
  labs(fill="\u00B0C") +
  coord_sf() +
  theme_void() +
  theme(legend.position="bottom") +
  facet_wrap(~date, nrow=1, labeller=function(x) format(x, format="%d %B %Y"))

# SAVE THE PLOT
ggsave("figures/fig3.pdf", width=10, height=3.5)
