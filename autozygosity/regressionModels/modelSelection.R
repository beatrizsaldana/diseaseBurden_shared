library(readr)
library(reshape2)
library(ggplot2)

data <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_color.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(data)

x = NAT
y = SROH
#color=averages$Color

#plot(y ~ x, type = 'p', ylim=c(0, 1e08), col=color, cex = 1, lwd = 2, xlab='Native American Ancestry', ylab='SROH', cex.lab=1.7, cex.axis=1.3, las=0)

mdl1 <- lm(y ~ x)
mdl2 <- lm(y ~ x + I(x^2))
mdl3 <- lm(y ~ x + I(x^2) + I(x^3))
mdl4 <- lm(y ~ I(x^2))
mdl5 <- lm(y ~ I(exp(x)))

prd <- data.frame(x = seq(0, 1, by = 0.1))

result <- prd
result$mdl1 <- predict(mdl1, newdata = prd)
result$mdl2 <- predict(mdl2, newdata = prd)
result$mdl3 <- predict(mdl3, newdata = prd)
result$mdl4 <- predict(mdl4, newdata = prd)
result$mdl5 <- predict(mdl5, newdata = prd)

result <-  melt(result, id.vars = "x", variable.name = "model",
                value.name = "fitted")
ggplot(result, aes(x = x, y = fitted)) +
  theme_bw() +
  geom_point(data = averages, aes(x = x, y = y)) +
  geom_line(aes(color = model), size = 1)