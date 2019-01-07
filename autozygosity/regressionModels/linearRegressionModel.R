library(readr)

averages <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_average.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(averages)

test = IBS
roh = SROH
averages$test2=averages$IBS^2

fit_admix=lm(roh ~ test + test2)
stats <- summary(fit_admix)
coeff <- stats$coefficients
par(mar=c(5,5,3,3))
plot(roh ~ test, type = 'p', ylim=c(0, 4.6e07), col='forestgreen', pch=16, cex = 2, xlab='Native American Ancestry', ylab='SROH', cex.lab=1.7, cex.axis=1.3, las=0)
text(roh ~ test, labels = POPULATION, pos = 3, cex=1.5)
mtext(paste0('y = ',round(coeff[2,1]),'x ','+ ',round(coeff[1,1]),'   |   r^2 = ',format(round(stats$adj.r.squared, 3), nsmall = 2),'   |   p-value = 0.0126'), side = 3, line = 0.5, cex = 1.5, las=0)
abline(fit_admix, lwd=2)