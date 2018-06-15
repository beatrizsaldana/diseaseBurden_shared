# Effect of Ancestry and Admixture on Autozygosity and the Burden of Inheritable Disease
The purpose of this project is to understand the effect of ancestry and admixture on autozygosity and disease burden. This is done by analyzing the distribution of disease causing variants in admixed Latin American Populations.

## General Project Protocol

#### Data Preparation

##### HGMD
###### Source
*Stenson, Peter D., et al. "Human gene mutation database (HGMD®): 2003 update." Human mutation 21.6 (2003): 577-581.*
###### Scripts Used
- getHGMD.sql
- cleanHGMD.pl
###### Description
1. Download data of interest from the HGMD using getHGMD.sql
2. Remove entries that contain indels and entries for the X and Y chromosomes

##### VCF Files (from 1KGP)
###### Source
*Siva, Nayanah. "1000 Genomes project." (2008): 256.*
###### Script Used
SHASHWAT VCF TOOLS THING
###### Description
We needed multi-VCF files for the following 1KGP populations: ACB, ASW, CLM, MXL, PEL, PUR, GRB, IBS, ESN, YRI
We had multiVCFs containing data for many 1KGP populations; VCFs were divided into separate files determined by chromosome.

#### Exploratory Analysis

##### HGMD variants per individual
###### Script Used
allVariantsZygosity.pl
###### Description
The script counts the number of variants that are present in the HGMD from each individual. The script compares the position of each variant described in the multi-VCF files with the data in the HGMD database. If the disease-causing allele of the variant is present in the individual's genome, it is counted in the following way:
Homozygous absent: 0|0 --> +0
Heterozygous present: 0|1 or 1|0 --> +1
Homozygous present: 1|1 --> +2
The script outputs one individual per row, with the total sum of disease causing variants present in the individual's genome.
If there is incongruence with the number of typed-positions per individual, the total sum must be divided by the total-typed positions. We did not have to do that since our data was consistent.


##### Individuals with disease causing variants
###### Script Used
individualsWithDiseaseCausingVariants.pl
###### Description
The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is a list of the individuals that have the disease-causing allele of the variant (heterozygous or homozygous).

##### SNP frequency per population
###### Scripts Used
snpFrequency_general.pl
snpFrequency_homozygous.pl
###### Description
The script counts the number of individuals per populaiton that have the disease-causing allele of the variant present in their genome. The sum is calculated in the following way:
Homozygous absent: 0|0 --> +0
Heterozygous present: 0|1 or 1|0 --> +1
Homozygous present: 1|1 --> +2
The script then di
The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is sum of the frequency of each variant per population.

#### Ontology

##### Ontology Curation
An ontology was created by classifying the traits/diseases in the HGMD into hierarchical categories, by hand. No script, sorry.

##### Ontology Frequency Calculation
###### Script Used
ontology_snpFreq.pl
###### Description
The script first appends the frequency of each trait/disease per population to the ontology, and then sums up the totals per ontology category. The frequency is taken from the output of the snpFrequency.pl script.

##### Ontology Trait/Disease to Geomic Position
###### Script Used
ontology_chrPos.pl
###### Description
The script first appends the genomic position of variant associated with every HGMD trait/disease, in the chromosome:position format, and then makes a list of all variants per ontology category.

#### Data Analysis