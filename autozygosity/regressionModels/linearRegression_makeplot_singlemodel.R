library(readr)
library(reshape2)
library(ggplot2)

data_imported <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_color.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(data_imported)

x = NAT
y = SROH
color_data=data_imported$Color

model <- lm(y ~ x)

stats <- summary(model)
coeff <- stats$coefficients

prd <- data.frame(x = seq(0, 1, by = 0.1))

result <- prd
result$model <- predict(model, newdata = prd)

result <-  melt(result, id.vars = "x", value.name = "fitted")
ggplot(result, aes(x = x, y = fitted)) +
  theme_bw() +
  geom_point(data = data_imported, aes(x = x, y = y), color=color_data) +
  geom_line(size = 1) +
  labs(x = "Native American Ancestry", y = "SROH", title = paste0('y = ',round(coeff[1,1]), ' + ', round(coeff[2,1]),'x','   |   r^2 = ',format(round(stats$adj.r.squared, 3), nsmall = 2),'   |   p-value < 2.2e-16')) + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))

