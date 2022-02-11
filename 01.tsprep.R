################################################################################
# ANALYSIS OF SMALL-AREA DATA WITH THE CASE TIME SERIES DESIGN
################################################################################

################################################################################
# PREPARE TIME SERIES DATA
################################################################################

################################################################################
# LOAD THE ORIGINAL MORTALITY DATA 

# LOAD THE MORTALITY DATA
dataorig <- as.data.table(read.csv("data/lndmsoadeath.csv"))

# RENAME AND CREATE DATE
names(dataorig) <- c("year", "month", "day", "MSOA11CD", "MSOA11NM", "d074",
  "d75plus")
dataorig[, date:=as.Date(paste(year, month, day, sep="/"))]

# DEFINE SERIES OF UNIQUE MSOA AND DATES (CHECK LATTER IS COMPLETE IN 2 SUMMERS)
seqmsoa <- sort(unique(dataorig$MSOA11CD))
seqdate <- sort(unique(dataorig$date))
table(diff(seqdate))

################################################################################
# PREPARE THE CASE TIME SERIES DATASET (STRATIFIED BY MSOA)

# COMPLETE THE ORIGINAL SERIES (INCLUDING DATES WITH NO DEATH)
datafull <- expand.grid(MSOA11CD=seqmsoa, date=seqdate) |>
  data.table() |>
  merge(dataorig[,c(4, 6:8)], all.x=T) |>
  merge(unique(dataorig[,c("MSOA11CD", "MSOA11NM")]), by="MSOA11CD")

# PAD WITH 0 WHEN NO DEATH
datafull[is.na(datafull)] <- 0

# CREATE TOTAL DEATHS, RE-CREATE TIME VARS
datafull[, dtot:=d074+d75plus]
datafull[, `:=`(year=year(date), month=month(date), day=mday(date),
  doy=yday(date), dow=wday(date))]

# ORDER (IMPORTANT FOR KEEPING THE TIME SERIES SEQUENCE BY MSOA)
setkey(datafull, MSOA11CD, date)

################################################################################
# PREPARE THE STANDARD TIME SERIES DATASET IN AGGREGATED FORM

# AGGREGATE BY DATE
dataggr <- datafull[, lapply(.SD, sum), by=date,
  .SDcols=c("d074", "d75plus", "dtot")]

# RE-CREATE TIME VARS
dataggr[, `:=`(year=year(date), month=month(date), day=mday(date),
  doy=yday(date), dow=wday(date))]

################################################################################

# PLOT MORTALITY SERIES BY SELECTED MSOA
set.seed(13041975)
plottsmsoa <- datafull |>
  subset(MSOA11CD %in% sort(sample(seqmsoa, 5)) & year==2006) |>
  ggplot(aes(x=date, y=dtot)) +
  geom_line() +
  geom_point(shape=19) +
  labs(x="Date", y="Deaths") +
  scale_y_continuous(breaks=sort(unique(datafull$dtot))) +
  facet_grid(MSOA11CD~., scales="free_x") +
  theme_bw()

# PLOT AGGREGATED MORTALITY SERIES
plottsaggr <- subset(dataggr, year==2006) |>
  ggplot(aes(x=date, y=dtot)) +
  geom_line() +
  geom_point(shape=19) +
  labs(x="Date", y="Deaths") +
  theme_bw()

# PUT TOGETHER
plottsmsoa + plottsaggr + plot_layout(nrow=2, heights=c(3,1))

# SAVE THE PLOT
ggsave("figures/fig1.pdf", width=5, height=10)
