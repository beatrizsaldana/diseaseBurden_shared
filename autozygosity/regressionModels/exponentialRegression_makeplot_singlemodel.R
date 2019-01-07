library(readr)
library(reshape2)
library(ggplot2)

data_imported <- read_delim("R:/Beatriz/Research/DiseaseBurden/Results/admixedPops_ancestryFractions_admixtureEntropy_roh_color.txt", "\t", escape_double = FALSE, trim_ws = TRUE)

attach(data_imported)

x = AFR
y = SROH
color_data=data_imported$Color

model <- nls(y ~ a + b * exp(c * x), start = c(a=7315378.266694634, b=43435172.73394829, c=-18.858918431233974))

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
  labs(x = "Native American Ancestry", y = "SROH", title = paste0('y = ',round(coeff[1,1]), ' + ', round(coeff[2,1]),'e^(',round(coeff[3,1], 2),'x)')) + 
  theme_bw() +
  theme(plot.title = element_text(hjust = 0.5))