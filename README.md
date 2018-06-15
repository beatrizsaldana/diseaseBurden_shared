# Project Purpose
To understand the effect of ancestry and admixture on autozygosity and disease burden. This is done by analyzing the distribution of disease causing variants in admixed Latin American Populations.

# General Project Protocol

### Data Preparation

#### HGMD
##### Source
*Stenson, Peter D., et al. "Human gene mutation database (HGMD®): 2003 update." Human mutation 21.6 (2003): 577-581.*
##### Script(s) Used
getHGMD.sql
cleanHGMD.pl
##### Description
1. Download data of interest from the HGMD using getHGMD.sql
2. Remove entries that contain indels and entries for the X and Y chromosomes

#### VCF Files (from 1KGP)
##### Source
*Siva, Nayanah. "1000 Genomes project." (2008): 256.*
##### Script(s) Used
SHASHWAT VCF TOOLS THING
##### Description
We needed multi-VCF files for the following 1KGP populations: ACB, ASW, CLM, MXL, PEL, PUR, GRB, IBS, ESN, YRI
We had multiVCFs containing data for many 1KGP populations; VCFs were divided into separate files determined by chromosome.