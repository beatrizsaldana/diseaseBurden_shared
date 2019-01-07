library(readr)

averages <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_color.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(averages)

test = NAT
roh = SROH
#averages$test2=averages$IBS^2

color=averages$Color

fit_admix=lm(roh ~ test)
stats <- summary(fit_admix)
coeff <- stats$coefficients
par(mar=c(5,5,3,3))
plot(roh ~ test, type = 'p', ylim=c(0, 1e08), col=color, cex = 1, lwd = 2, xlab='Native American Ancestry', ylab='SROH', cex.lab=1.7, cex.axis=1.3, las=0)
#text(roh ~ test, labels = POPULATION, pos = 3, cex=1.5)
mtext(paste0('y = ',round(coeff[2,1]),'x ','+ ',round(coeff[1,1]),'   |   r^2 = ',format(round(stats$adj.r.squared, 3), nsmall = 2),'   |   p-value < 2.2e-16'), side = 3, line = 0.5, cex = 1.5, las=1)
abline(fit_admix, lwd=2)