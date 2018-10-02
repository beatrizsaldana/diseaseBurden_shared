library(readr)
library(reshape2)
library(ggpubr)
library(ggplot2)

snpFreqPerIndividual_complete <- read_delim("snpFreqPerIndividual_hgmdStrict_allPops.txt", delim = "\t", escape_double = F, trim_ws = T)
#snpFreqPerIndividual_diseaseRisk <- read_delim("snpFreqPerIndividual_hgmdStrict_diseaseRisk_allPops.txt", delim = "\t", escape_double = F, trim_ws = T)
#snpFreqPerIndividual_diseaseProtection <- read_delim("snpFreqPerIndividual_hgmdStrict_diseaseProtection_allPops.txt", delim = "\t", escape_double = F, trim_ws = T)

#snpFreqPerIndividual_complete$POPULATION <- factor(snpFreqPerIndividual_complete$POPULATION, levels = snpFreqPerIndividual_complete$POPULATION[order(snpFreqPerIndividual_complete$POPULATION, snpFreqPerIndividual_complete$GROUP)])

plot_snpFreq_complete <- ggboxplot(snpFreqPerIndividual_complete, x="POPULATION", y="HOMOZYGOUS", fill = "white", color="black") +
  geom_point(position = position_jitter(width = 0.25, height = 0), col = snpFreqPerIndividual_complete$COLOR) +
  facet_grid(~GROUP, scale = 'free', space = 'free_x') + 
  theme_shashwat() + theme(legend.position="none") +
  labs(x = NULL, y = "Instances of Homozygosity", title = "Complete HGMD") #+ ylim(c(0,225))

# plot_snpFreq_diseaseRisk <- ggboxplot(snpFreqPerIndividual_diseaseRisk,x="POPULATION",y="HOMOZYGOUS",fill = "white",color="black") +
#   geom_point(position = position_jitter(width = 0.25, height = 0), col = snpFreqPerIndividual_diseaseRisk$COLOR) +
#   facet_grid(~GROUP, scale = 'free', space = 'free_x') +
#   theme_shashwat() + theme(legend.position="none") +
#   labs(x = NULL, y = "Instances of Homozygosity", title = "Disease Risk") + ylim(0, 130)
# 
# plot_snpFreq_diseaseProtection <- ggboxplot(snpFreqPerIndividual_diseaseProtection,x="POPULATION",y="HOMOZYGOUS",fill = "white",color="black") +
#   geom_point(position = position_jitter(width = 0.25, height = 0), col = snpFreqPerIndividual_diseaseProtection$COLOR) +
#   facet_grid(~GROUP, scale = 'free', space = 'free_x') +
#   theme_shashwat() + theme(legend.position="none") +
#   labs(x = NULL, y = "Instances of Homozygosity", title = "Disease Protection") + ylim(0, 30)


