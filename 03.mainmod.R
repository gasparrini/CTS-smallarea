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
# MAIN MODELS
################################################################################

################################################################################
# MAIN MODEL ON CASE TIME SERIES DATA

# DEFINE SPLINES OF DAY OF THE YEAR
spldoy <- onebasis(datafull$doy, "ns", df=3)

# DEFINE THE CROSS-BASIS FOR TEMPERATURE FROM THE EXPOSURE HISTORY MATRIX
# NB: USE group TO IDENTIFY LACK OF CONTINUITY IN SERIES BY MSOA AND YEAR
argvar <- list(fun="ns", knots=quantile(datafull$tmean, c(50,90)/100, na.rm=T))
arglag <- list(fun="ns", knots=1)
group <- factor(paste(datafull$MSOA11CD, datafull$year, sep="-"))
cbtmean <- crossbasis(datafull$tmean, lag=3, argvar=argvar, arglag=arglag,
  group=group)
summary(cbtmean)

# DEFINE THE STRATA 
datafull[, stratum:=factor(paste(MSOA11CD, year, month, sep=":"))]

# RUN THE MODEL
# NB: EXCLUDE EMPTY STRATA, OTHERWISE BIAS IN gnm WITH quasipoisson
datafull[,  keep:=sum(dtot)>0, by=stratum]
modfull <- gnm(dtot ~ cbtmean + spldoy:factor(year) + factor(dow), 
  eliminate=stratum, data=datafull, family=quasipoisson, subset=keep)

################################################################################
# MODEL ON AGGREGATED DATA

# RE-DEFINE THE CROSS-BASIS WITH THE SAME PARAMETRISATION
# NB: CAN USE SERIES DIRECTLY INSTEAD THAN MATRIX, BUT USE group FOR YEARS
cbtmeanaggr <- crossbasis(dataggr$tmean, lag=3, argvar=argvar, arglag=arglag,
  group=dataggr$year)

# RUN THE MODEL ON AGGREGATED DATA
modaggr <- glm(dtot ~ cbtmeanaggr + ns(doy, df=3):factor(year) + factor(dow),
  data=dataggr, family=quasipoisson)

################################################################################
# PREDICT AND PLOT

# PREDICT
cpfull <- crosspred(cbtmean, modfull, cen=16)
cpaggr <- crosspred(cbtmeanaggr, modaggr, cen=16)

# PLOT
col <- c("darkgoldenrod3", "aquamarine3")
parold <- par(no.readonly=T)
par(mar=c(4,4,1,0.5), las=1, mgp=c(2.5,1,0))
plot(cpfull, "overall", ylim=c(0.8,1.8), ylab="RR", col=col[1], lwd=1.5,
  xlab=expression(paste("Temperature ("*degree,"C)")), 
  ci.arg=list(col=alpha(col[1], 0.2)))
lines(cpaggr, "overall", ci="area",col=col[2],  lwd=1.5,
  ci.arg=list(col=alpha(col[2], 0.2)))
legend("top", c("Case TS", "Aggregated TS"), lty=1, lwd=1.5, col=col, bty="n",
  inset=0.05, y.intersp=2, cex=0.8)
par(parold)

# SAVE THE PLOT
dev.print(pdf, file="figures/fig4.pdf", width=7, height=4)
