#!/bin/bash

## steps to go from the plink output, to the output needed to plot the PCA

awk '{if ($1 != $2){print $1"_"$2}else{print $1}}' fileName.eigenvec > sampleIDs.txt

cat fileName.eigenvec | cut --complement  -d " " -f 1,2 > matrix.txt

paste -d " " sampleIDs.txt matrix.txt > fileName_good.eigenvec

../../../diseaseBurden_shared/data_handling/data_merging/addPop_noHead.pl fileName_good.eigenvec ../../../base_data/populationInformation/allSamplesForProject_IDandPop.txt fileName_good_pop.txt

awk 'BEGIN{FS="\t"; OFS="\t"}{if($2 == "ACB"){$2 = "#006837"}else if($2 == "ESN"){$2 = "#4D4989"}else if($2 == "YRI"){$2 = "#2A2570"}else if($2 == "GBR"){$2 = "#F59C2B"}else if($2 == "IBS"){$2 = "#DCA153"}else if($2 == "CAI"){$2 = "#F72A32"}else if($2 == "SAI"){$2 = "#DE5257"}else if($2 == "ASW"){$2 = "#31A354"}else if($2 == "CLM"){$2 = "#78C679"}else if($2 == "MXL"){$2 = "#ADDD8E"}else if($2 == "PEL"){$2 = "#D9F0A3"}else if($2 == "PUR"){$2 = "#FFFFCC"} print $0}' fileName_good_pop.txt > fileName_good_pop_color.txt

awk 'BEGIN{FS="\t"; OFS="\t"}{print "\042" $2 "\042", $3, $4}' fileName_good_pop_color.txt > fileName_good_pop_color_threeCols.txt

## don't forget to add the header "Color \t PC1 \t PC2"