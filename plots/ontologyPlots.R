# input file is the resulting file of the ontology_snpFreq.pl script

library(ggplot2)
library(readr)
library(reshape2)

snpFreq <- read_delim("out_ontology_snpFreq_popSizeNormalized_snpCountNormalized.txt", delim = "\t", escape_double = F, trim_ws = T)

moltenSnpFreq <- melt(snpFreq)

moltenSnpFreq$Groups <- "Undefined"
moltenSnpFreq[moltenSnpFreq$variable %in% c("ACB", "ASW", "CLM", "MXL", "PEL", "PUR"),]$Groups <- "Admixed"
moltenSnpFreq[moltenSnpFreq$variable %in% c("YRI", "ESN"),]$Groups <- "African"
moltenSnpFreq[moltenSnpFreq$variable %in% c("IBS", "GBR"),]$Groups <- "European"
moltenSnpFreq[moltenSnpFreq$variable %in% c("NTA"),]$Groups <- "Native American"

moltenSnpFreq <- moltenSnpFreq[complete.cases(moltenSnpFreq),]

moltenSnpFreq$Colors <- "#FFFFFF"
moltenSnpFreq[moltenSnpFreq$Groups=="Admixed",]$Colors <- "green"
moltenSnpFreq[moltenSnpFreq$Groups=="African",]$Colors <- "blue"
moltenSnpFreq[moltenSnpFreq$Groups=="European",]$Colors <- "yellow"
moltenSnpFreq[moltenSnpFreq$Groups=="Native American",]$Colors <- "red"

zScore <- read_delim("out_ontology_snpFreq_popSizeNormalized_snpCountNormalized_zscore.txt", delim = "\t", escape_double = F, trim_ws = T)

moltenzScore <- melt(zScore)

moltenzScore$Groups <- "Undefined"
moltenzScore[moltenzScore$variable %in% c("ACB", "ASW", "CLM", "MXL", "PEL", "PUR"),]$Groups <- "Admixed"
moltenzScore[moltenzScore$variable %in% c("YRI", "ESN"),]$Groups <- "African"
moltenzScore[moltenzScore$variable %in% c("IBS", "GBR"),]$Groups <- "European"
moltenzScore[moltenzScore$variable %in% c("NTA"),]$Groups <- "Native American"

moltenzScore <- moltenzScore[complete.cases(moltenzScore),]

moltenzScore$Colors <- "#FFFFFF"
moltenzScore[moltenzScore$Groups=="Admixed",]$Colors <- "green"
moltenzScore[moltenzScore$Groups=="African",]$Colors <- "blue"
moltenzScore[moltenzScore$Groups=="European",]$Colors <- "orange"
moltenzScore[moltenzScore$Groups=="Native American",]$Colors <- "red"

# interesting_key <- c("Diseases", "Disease: reduced/decreased risk, protection against, survival", "Fungal infectious diseases", "Herpes simplex", "Hepatitis", "Human immunodeficiency virus infectious disease",   "Skin cancer", )

interesting_keys <- c("1", "6", "1.2.4.", "1.2.5.", "6.1.3.", "1.2.6.1.", "1.2.6.4.", "6.1.5.4.", "1.6.1.2.3.1.", "6.5.1.2.1.1.", "6.5.1.2.1.1.5.", "6.2.6.3.", "1.4.2.3.13.1.", "6.3.2.2.4.1.", "6.2.1.4.1.2.2.", "1.3.1.10.5.", "6.2.1.4.3.", "1.3.8.1.")

for (term_name in interesting_keys){
  ggplot(moltenSnpFreq[moltenSnpFreq$KEY==as.character(term_name),], aes(variable, value, fill = Colors)) + 
    geom_col() + 
    facet_grid(~Groups, scale = 'free', space = 'free_x') + 
    theme_shashwat() + 
    labs(x = "Populations", y = "Normalized Frequencies", title = paste(term_name, head(moltenSnpFreq[moltenSnpFreq$KEY==term_name,]$DISEASE, 1)))
  ggsave(paste("plots/", term_name, "_", gsub("/", "_", gsub(",", "_", head(moltenSnpFreq[moltenSnpFreq$KEY==term_name,]$DISEASE, 1))), "_freqs.pdf", sep=""), width = 7, height = 7, useDingbats = F)
  ggplot(moltenzScore[moltenzScore$KEY==as.character(term_name),], aes(variable, value, fill = Colors)) + 
    geom_col() + 
    facet_grid(~Groups, scale = 'free', space = 'free_x') + 
    theme_shashwat() + 
    labs(x = "Populations", y = "z Score", title = paste(term_name, head(moltenSnpFreq[moltenSnpFreq$KEY==term_name,]$DISEASE, 1)))
  ggsave(paste("plots/", term_name, "_", gsub("/", "_", gsub(",", "_", head(moltenSnpFreq[moltenSnpFreq$KEY==term_name,]$DISEASE, 1))), "_zScores.pdf", sep=""), width = 7, height = 7, useDingbats = F)
}