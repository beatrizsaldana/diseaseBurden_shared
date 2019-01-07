library(readr)
library(glmulti)

averages <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_color.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(averages)

test = NAT
roh = SROH

#res <- glmulti(yi ~ length + wic + feedback + info + pers + imag + meta, data=dat,
#               level=1, fitfunction=rma.glmulti, crit="aicc", confsetsize=128)


#fit_nonLinear = nls(roh ~ a * test - b * -log(test+0.1), start = c(a=0,b=0))
fit_nonLinear = nls(roh ~ a + b * exp(c * test), start = c(a=2042627.6540387745, b=10176719.109379275, c=1.8056680056420737))
stats <- summary(fit_nonLinear)
coeff <- stats$coefficients
par(mar=c(5,5,3,3))
plot(roh ~ test, type = 'p', ylim=c(0, 1e08), col=averages$Color, cex = 1, lwd = 2, xlab='African Ancestry', ylab='SROH', cex.lab=1.7, cex.axis=1.3, las=0)
#text(roh ~ test, labels = POPULATION, pos = 3, cex=1.5)
#mtext(paste0('y = ',round(coeff[2,1]),'x ','+ ',round(coeff[1,1]),'   |   r^2 = ',format(round(stats$adj.r.squared, 3), nsmall = 2),'   |   p-value < 2.2e-16'), side = 3, line = 0.5, cex = 1.5, las=1)
#abline(lm(roh ~ (test^2)), lwd=2)
#abline(fit_nonLinear, lwd=2)
#lines(test,predict(fit_nonLinear))
curve(fit_nonLinear, from = 0, to = 1)