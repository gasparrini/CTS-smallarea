################################################################################
# ANALYSIS OF SMALL-AREA DATA WITH THE CASE TIME SERIES DESIGN
################################################################################

################################################################################
# INTERACTION MODELS
################################################################################

# LOAD IMD DATA (BY LSOA) AND LOAS/MSOA LOOKUP TABLE
lndlsoaimd <- read.csv("data/lndlsoaimd.csv")
lookup <- read.csv("data/lookup.csv")

# MERGE AND AVERAGE BY MSOA
lndmsoaimd <- merge(data.table(lookup), lndlsoaimd)[, 
  list(imdscore=mean(imdscore), imdrank=mean(imdrank)), by=MSOA11CD]

# MERGE WITH MAIN DATASET
datafull <- merge(datafull, lndmsoaimd, by="MSOA11CD")

# DEFINE INTERACTION CROSS-BASES WITH LINEAR IMD SCORE
intval <- quantile(lndmsoaimd$imdscore, c(0.25, 0.75))
cbint1 <- cbtmean * (datafull$imdscore - intval[1])
cbint2 <- cbtmean * (datafull$imdscore - intval[2])

# RUN THE MODELS
modint1 <- update(modfull, .~. + cbint1)
modint2 <- update(modfull, .~. + cbint2)

# TEST SIGNIFICANCE OF INTERACTION
anova(modfull, modint1, test="Chisq")

# PREDICT FOR EACH OF THE TWO IMD VALUES
cpint1 <- crosspred(cbtmean, modint1, cen=16)
cpint2 <- crosspred(cbtmean, modint2, cen=16)

# PLOT
col <- c("royalblue", "tomato3")
parold <- par(no.readonly=T)
par(mar=c(4,4,1,0.5), las=1, mgp=c(2.5,1,0))
plot(cpint1, "overall", ylim=c(0.8,2), ylab="RR", col=col[1], lwd=1.5,
  xlab=expression(paste("Temperature ("*degree,"C)")), 
  ci.arg=list(col=alpha(col[1], 0.2)))
lines(cpint2, "overall", ci="area",col=col[2],  lwd=1.5,
  ci.arg=list(col=alpha(col[2], 0.2)))
legend("top", c("Low IMD score", "High IMD score"), lty=1, lwd=1.5, col=col,
  bty="n", inset=0.05, y.intersp=2, cex=0.8)
par(parold)

# SAVE THE PLOT
dev.print(pdf, file="figures/fig5.pdf", width=7, height=4)
