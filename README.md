# Effect of Ancestry and Admixture on Autozygosity and the Burden of Heritable Disease
The purpose of this project is to understand the effect of ancestry and admixture on autozygosity and disease burden. This is done by analyzing the distribution of disease causing variants in admixed Latin American Populations.

## Table of Contents
- [Directory Structure](#directory-structure)
- [Important Notes](#important-notes)
- [General Project Protocol](#general-project-protocol)
- [Script Description](#script-description)

## Directory Structure
```
├── README.md
├── PCA/
    ├── plinkCommandsPCA.sh
    ├── prePCAprocess.sh
├── admixtureEntropy/    
    ├── calculateAdmixtureEntropy.pl
    ├── calculateAdmixtureEntropy_unk.pl
├── autozygosity/
    ├── localAncestryMapping
    	├── 1kgpToAndyMapping.pl
	├── calculateAncestryROH.pl
	├── mapROHtoLocalAncestry.pl
    ├── NROH_SROH
    	├── roh.pl
    ├── regressionModels
    	├── exponentialRegression_makeplot_singlemodel.R
	├── linearRegression_makeplot_singlemodel.R
	├── linearRegressionModel_allPoints.R
	├── linearRegressionModel.R
	├── modelSelection.R
	├── nonLinearRegressionModel_allPoints.R
├── dataHandling/
    ├── data_cleaning/
        ├── cleanHGMD.pl
    ├── data_merging/
        ├── addPop.pl
	├── addPopID.pl
	├── addPop_noHead.pl
	├── joinFilesOnID.pl
	├── mapAndyIds.pl
	├── merge2VCFs.pl
        ├── mergeHGMD.pl
	├── sampleID_popID.pl
    ├── data_subsets/
        ├── getHgmdSubset.pl
        ├── getSamplesOfInterestVCF.pl
        ├── hgmdSubset.pl
	├── makeVCFsubset_intersect.pl
        ├── makeVCFsubsets.pl
        ├── vcfSubset_snpFreq_perIndividual.pl
├── ontology/
    ├── ontology_chrPos.pl
    ├── ontology_countSnps.pl
    ├── ontology_normalize.pl
    ├── ontology_snpFreq_nta.pl
    ├── ontology_snpFreq.pl
    ├── ontology.txt
    ├── ontology_zscores.pl
    ├── resultAnalysis/
        ├── ancestryComparison.pl
        ├── aswPelComparison.pl
├── plots/
    ├── PCA.html
    ├── PCA_NTA.html
    ├── generatePlots_boxplot.R
    ├── makePCA.R
    ├── ontologyPlots.R
    ├── pca_dataPruning.sh
├── snpFrequency/
    ├── individualsWithDiseaseCausingVariants.pl
    ├── snpFrequency_perIndividual/
        ├── chrPos_perIndividual_homozygous.pl
        ├── snpFreqPerIndividual_forPlot.pl
        ├── snpFreq_perIndividual.pl
    ├── snpFrequency_perPopulation/
        ├── getIntersect.pl
        ├── snpFrequency_joinAll.pl
        ├── snpFrequency_singlePop.pl
```
## Important Notes

### Acronyms
###### 1KGP - 1000 Genomes Project
###### HGMD - Human Gene Mutation Database
###### NROH - Number of Runs Of Homozygosity
###### ROH - Runs Of Homozygosity
###### SGDP - Simons Genome Diversity Project
###### SROH - Sum Of Runs of Homozygosity
###### VCF -  Variant Calling Format

## General Project Protocol

All scripts are thoroughly described in the [Script Description](#script-description) section of the README. This section explains the general project protocol.

### General Project Protocol Table of Contents
- [Data Preparation](#1-data-preparation)
- [Ancestry and Admixture](#2-ancestry-and-admixture)
- [Autozygosity](#3-autozygosity)
- [Disease Burden](#4-disease-burden)

### 1. Data Preparation

#### Data Preparation Table of Contents
- [HGMD](#HGMD)
- [VCF Files](#vcf-files-from-1kgp-and-sgdp)

#### HGMD
##### Source
*Stenson, Peter D., et al. "Human gene mutation database (HGMD®): 2003 update." Human mutation 21.6 (2003): 577-581.*
##### Data Location
The Human Gene Mutation Database used is located in the genomeTrax mysql database '/data/db/mysql/genomeTrax', and is entered as 'hgmd_2016'.
##### Script Used
- cleanHGMD.pl
- awk 'BEGIN {FS = "\t"}{IGNORECASE = 1}; {if($9 ~ /autosomal recessive/ && $7 ~ /DM/ && $8 ~ /[0-9]/ && $8 >= 0.15){print $0}}' hgmd.txt > hgmd_subset.txt
##### Description
1. Download data of interest from the HGMD. Only entries from HG19 and considered of High Confidence were used.
2. Remove entries that contain indels and entries for the X and Y chromosomes, and removes all duplicated lines.
3. Make subset of interest: polyPhen2 score > 0.15, variant Type = DM, and mode of inheritance must be autosomal recessive 
##### File Location
/data/home/bsaldana3/projects/diseaseBurden/base_data/hgmd/hgmd_complete_clean.txt
#### Notes
The subset with polyphen2 scores, variant type, and autsomal recessive was too stringent, at the moment we are only using variant Type = DM and and mode of inheritance must be autosomal recessive.
More details about the SQL query and output file are given in the Script Description section of README

#### VCF Files (from 1KGP and SGDP)
##### Source
*Siva, Nayanah. "1000 Genomes project." (2008): 256.*
*Mallick, Swapan, et al. "The Simons genome diversity project: 300 genomes from 142 diverse populations." Nature 538.7624 (2016): 201.*
##### Data Location
- The VCF files from the 1KGP used for this project were located in the '/data/home/data/100gp/vcfgz/' directory in the Jordan Lab 'The Beast' server, and VCF files used were the ones with this title: 'ALL.chr\*.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'.
- The VCF file from the SGDP used for this project was located in the '/data/shashwat/SGDP_data/' directory in the Jordan Lab 'The Beast' server, and VCF files used were the ones with this title: 'mergedSimple_sgdp.vcf.gz'.
##### Script Used
The initial VCF files contained all 1KGP individuals and were divided into different chromosomes. So I made a single VCF with only the samples of interest.
- getSamplesOfInterestVCF.pl # To make subsets from Chromosome separated multi VCFs
- cat # concatenate results from getSamplesOfInterestVCF.pl
##### Description
We needed multi-VCF files for the following 1KGP populations: ACB, ASW, CLM, MXL, PEL, PUR, GRB, IBS, ESN, YRI
Ideally there should only be one VCF file containing all samples of interest. Currenly some scripts work with multiple files, others with a single file.

### 2. Ancestry and Admixture

#### Ancestral Fractions and Local Ancestry
This part of the project was done by Dr. Andrew Conley.

#### Admixture Entropy
##### Script Used
- calculateAdmixtureEntropy.pl
- calculateAdmixtureEntropy_unk.pl
##### Description
The script calculates de admixture entropy of all individuals using the following formula: $Admixture Entropy=-\sum f(a) ln(f(a))$
calculateAdmixtureEntropy_unk.pl is the same as calculateAdmixtureEntropy.pl but takes the Unknown Ancestry percentage into account when calculating the admixture entropy.

### 3. Autozygosity

### Autozygosity Table of Contents
- [Runs of Homozygosity](#runs-of-homozygosity)
- [Regression Analysis](#relationship-analysis-regression-models)
- [Local Ancestry Mapping](#relationship-analysis-local-ancestry)

#### Runs of Homozygosity
##### Script Used
- plink --vcf path/to/vcfFile.vcf --homozyg
- akw 'BEGIN{OFS="\t"}{print $2, $7, $8}' plink.hom
- roh.pl
##### Description
Plink is used to calculate the Runs of Homozygosity from a vcf file. The plink output file sometimes is missing fields, so the awk command simply gets the fields needed for NROH and SROH analysis, so that the roh.pl script does not have to account for missing fields. roh.pl calculates the NROH and SROH per individual.

#### Relationship Analysis (Regression models)
##### Scripts Used
- all scripts in the autozygosity/regressionModels directory
##### Description
The purpose of this analysis was to attempt to find a statistically significant relationship between Ancestry and Admixture and Autozygosity. Both linear and non-linear models were built.

#### Relationship Analysis (Local Ancestry)
##### Scripts Used
- 1kgpToAndyMapping.pl (map 1kgp IDs to Local Ancestry IDs)
- calculateAncestryROH.pl (calculate SROH of populations, per local ancestry)
- mapROHtoLocalAncestry.pl
##### Description
First you must map the 1KGP IDs to the IDs in Andy's Local Ancestry results. Then you can run the mapROHtoLOcalAncestry,pl script to map each ROH to a local ancestry. If no single ancestry maps to the ROH, then UNK is assigned to that ROH. After the ROHs have been mapped, you can use the calculateAncestryROH.pl script to calculate the total SROH of each population by the local ancestry it maps to. 

### 3. Disease Burden

#### Disease Burden Table of Contents
- [HGMD Variants Per Individual](#hgmd-variants-per-individual)
- [Individuals With Disease Causing Variants](#individuals-with-disease-causing-variants)
- [Disease Causing Variants per Individual](#disease-causing-variants-per-individual)
- [SNP Frequency per Population](#snp-frequency-per-population)
- [Disease Ontology Curation](#disease-ontology-curation)
- [Disease Ontology VCF subsets](#disease-ontology-vcf-subsets)
- [Disease Ontology Frequency Calculation](#disease-ontology-frequency-calculaiton)
- [Disease Ontology Trait/Disease to Geomic Position](#disease-ontology-traitdisease-to-geomic-position)
- [Disease Ontology Result Normalization](#disease-ontology-result-normalization)
- [Disease Ontology Statistical Analysis](#disease-ontology-statistical-analysis-calculating-z-scores)
- [Disease Ontology Finding Categories of Interest](#disease-ontology-finding-categories-of-interest)
- [Disease Ontology Plots](#disease-ontology-plots)

#### HGMD variants per individual
##### Script Used
- snpFreq_perIndividual.pl
- snpFreqPerIndividual_forPlot.pl
- generatePlots_boxplots.R
##### Description
The script counts the number of variants that are present in the HGMD from each individual. The script compares the position of each variant described in the multi-VCF files with the data in the HGMD database. If the disease-causing allele of the variant is present in the individual's genome, it is counted in the following way:

- Homozygous absent: 0|0 --> +0
- Heterozygous present: 0|1 or 1|0 --> +0
- Homozygous present: 1|1 --> +1

The script outputs one individual per row, with the total sum of disease causing variants present in the individual's genome.
If there is incongruence with the number of typed-positions per individual, the total sum must be divided by the total-typed positions. We did not have to do that since our data was consistent and used vcf subsets.
##### Notes
Older versions of the script calculated Homozygous present as (+2), and Heterozygous present as (+1). Look at the last for loop to check if the variable $homozygous is being divided by 2 (as is should be). snpFreqPerIndividual_forPlot.pl simply organizes the data in a way that makes it easier to make the type of plot that we wanted.

#### Individuals with disease causing variants
##### Script Used
- individualsWithDiseaseCausingVariants.pl
##### Description
The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is a list of the individuals that have the disease-causing allele of the variant (heterozygous or homozygous).

#### Disease Causing Variants per Individual
##### Script Used
- chrPos_perIndividual_homozygous.pl
##### Description
This script outputs a list of variants chr:pos that each individual has present in their genome in homozygous form. Used for making subsets in the past, this script is no longer used, but I have kept it incase we need this information.

#### SNP Frequency per Population
##### Scripts Used
- snpFrequency_singlePop.pl
- getIntersect.pl
- snpFrequency_joinAll.pl
##### Description
The snpFrequency_singlePop.pl scripts counts the number of individuals per populaiton that have the disease-causing allele of the variant present in their genome in homozygous form. The sum is calculated in the following way:
- Homozygous present: 1|1 --> +1
The scripts outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is sum of the frequency of each variant per population.
##### Notes
This used to be a single script. But since we are using data from the 1KGP and SGDP we wanted to avoid accidentally counting extra variants for the different populations.

#### Disease Ontology Curation
An ontology was created by classifying the traits/diseases in the HGMD into hierarchical categories, by hand. No script, sorry.

#### Disease Ontology VCF subsets
##### Script Used
- vcfSubset_snpFreq_perIndividual.pl
###### Description
This script makes subsets of the VCF with diseases that are only present in the 'Disease Risk' category of the Disease Ontology or 'Disease Protection' category of the Disease Ontology. This is helpful for faster frequency calculations or if we need to re-do the analysis.

#### Disease Ontology Frequency Calculation
##### Script Used
- ontology_snpFreq.pl
##### Description
The script first appends the frequency of each trait/disease per population to the ontology, and then sums up the totals per ontology category. The frequency is taken from the output of the snpFrequency.pl script.

#### Disease Ontology Trait/Disease to Geomic Position
##### Script Used
- ontology_chrPos.pl
##### Description
The script first appends the genomic position of variant associated with every HGMD trait/disease, in the chromosome:position format, and then makes a list of all variants per ontology category.

#### Disease Ontology Result Normalization
##### Script Used
- ontology_normalize.pl
##### Description
The script normalizes the results of ontology_snpFreq.pl by the population size and by the number of SNPs per ontology category.

#### Disease Ontology Statistical Analysis (Calculating Z scores)
##### Script Used
- ontology_zscores.pl
##### Description
The script calculates the z-scores of every ontology category. The population standard deviation is used for this calculation.

#### Disease Ontology Finding Categories of Interest
##### Scripts Used
- ancestryComparison.pl
- aswPelComparison.pl
##### Description
The scripts compares the results of the ontology based on ancestral populations and admixed populations. of the ancestral populations, and if there is a significant difference, it will output the categories of interest. The "significance" parameter is inuted by the user (percent difference). We decided to compare ancestral populations to avoid imposing our hypothesis onto the results.

#### Disease Ontology Plots
##### Script Used
- ontologyPlots.R
##### Description
The script generates column (bar) plots for the "categories of interest" in the ontology.


## Script Description

### Get HGMD
```sql
SELECT
  ngs_feature_2016.chromosome,
  ngs_feature_2016.feature_start,
  ngs_feature_2016.rsid,
  hgmd_2016.ref,
  hgmd_2016.alt,
  hgmd_2016.disease,
  hgmd_2016.variantType,
  dbnsfp.dbNSFP_Polyphen2_score,
  orpha.orpha_inheritance
FROM ngs_feature_2016
INNER JOIN hgmd_2016 ON ngs_feature_2016.ngs_feature_no=hgmd_2016.feature_no
INNER JOIN dbnsfp ON ngs_feature_2016.ngs_feature_no=dbnsfp.feature_no
INNER JOIN orpha ON hgmd_2016.ensembl=orpha.ensembl
WHERE ngs_feature_2016.genome='hg19'
AND hgmd_2016.confidence='high'
INTO OUTFILE 'path/to/hgmd.txt';
```
#### Output
|Chromosome | Position | RSID | Ref | Alt | Disease/Trait | variantType | PolyPhen2_score | mode_of_inheritance |
|:---------:|:--------:|:----:|:---:|:---:|:-------------:|:-----------:|:---------------:|:-------------------:|

#### Notes
You can filter out what you do not want (variantType=DM, polyPhen_score>0.15, inheritance=autosomal recessive) with an awk command.

### cleanHGMD.pl
```
./cleanHGMD.pl /path/to/hgmd.txt /path/to/outfile.txt
```
#### Input
HGMD input file must be in the format depicted in the section above
#### Output
Output will be in the same format but with less lines

### getSamplesOfInterestVCF.pl
```
zcat file.vcf.gz | ./getSamplesOfInterestVCF.pl listOfSampleIDs.txt vcf_outfile.txt
```
#### Input
The script will read the output of zcat from the command line, so no need to sirectly input a vcf file.
You will need to make a list of the sample IDs that correspond to the headder of the VCF file.

#### Output
A VCF file with only the columns of the samples of interest.

### snpFreq_perIndividual.pl
```
./snpFreq_perIndividual.pl /path/to/VCFfile.vcf /path/to/hgmd.txt /path/to/output.txt
```
#### Input
VCF file must be a tab-separated multi-VCF file, one variant per line, array of individuals with a '|' separating alleles
HGMD input file must be in the format depicted in the section above
#### Output
| SAMPLE_ID | HETEROZYGOUS | HOMOZYGOUS | TOTAL_HGMD_VARIANTS | TOTAL_TYPED_POSITIONS |
|:---------:|:------------:|:----------:|:-------------------:|:---------------------:|

- SAMPLE_ID: The ID of the individual in the VCF file
- HETEROZYGOUS: total disease-causing HGMD variants present in the individual in heterozygous form
   calculation: R|A = +1 , A|R = +1  
        R = Reference Allele (usually depicted as 0)  
        A = Alternate Allele (usually depicted as 1)

- HOMOZYGOUS: total disease-causing HGMD variants present in the individual in homozygous form
   calculation: A|A = +1  
        R = Reference Allele (usually depicted as 0)  
        A = Alternate Allele (usually depicted as 1)  

- TOTAL_HGMD_VARIANTS: total number of disease-causing variants present, no matter how they are present
   calculation: R|A = +1 , A|R = +1 , A|A = +2  
        R = Reference Allele (usually depicted as 0)  
        A = Alternate Allele (usually depicted as 1)

- TOTAL_TYPED_POSITIONS: All positions in the VCF file that were typed, per individual
   calculation: X|X = +2 , X|. = +1 , .|X = +1  
        X = Anything, except a blank  

### individualsWithDiseaseCausingVariants.pl
```
./individualsWithDiseaseCausingVariants.pl path/to/file.vcf path/to/outfile.txt path/to/hgmd.txt
```

#### Input
- VCF file (one population at a time)
- Outfile name
- HGMD file

#### Output
| CHROMOSOME | POSITION | RSID | REF | ALT | LIST OF SAMPLE IDS |
|:----------:|:--------:|:----:|:---:|:---:|:------------------:|

- LIST OF SAMPLE IDS: the list of individuals that have the variant present

### chrPos_perIndividual_homozygous.pl
```
./chrPos_perIndividual_homozygous.pl path/to/vcfFile.vcf path/to/hgmd.txt path/to/outfile.txt
```

#### Input
- VCF file
- HGMD text file

#### Output
| SAMPLE_ID | LIST_OF_CHR:POS |
|:---------:|:---------------:|

### snpFrequency_singlePop.pl
```
./snpFrequency_singlePop.pl path/to/file.vcf path/to/outfile.txt path/to/hgmd.txt
```

#### Input
- VCF file (one population at a time)
- Outfile name
- HGMD file

#### Output
| CHROMOSOME | POSITION | RSID | REF | ALT | DISEASE | FREQUENCY |
|:----------:|:--------:|:----:|:---:|:---:|:-------:|:---------:|

### getIntersect.pl
Script to get the intersect of two files in order to be able to join them with the next script.

### snpFrequency_joinAll.pl
```
./snpFrequency_joinAll.pl path/to/fileList.txt path/to/VCFintersect.txt path/to/outfile.txt
```

#### Input
- File list: a list of the files containing the results of snpFrequenc_singlePop (including paths)
- Outfile name

#### Output
| CHROMOSOME | POSITION | RSID | REF | ALT | DISEASE | POPULATION 1 | POPULATION 2 | ... |
|:----------:|:--------:|:----:|:---:|:---:|:-------:|:------------:|:------------:|:---:|

- POPULATION X: one column per population, the column contains the frequency of each variant

### ontology_snpFreq.pl
```
./ontology_snpFreq.pl path/to/snpFrequency_joinAll_results.txt path/to/ontology.txt path/to/outfile.txt
```

#### Input
- Results of the snpFrequency_joinAll.txt script
- Ontology text file
- Outfile name

#### Ouput
| KEY | DISEASE | POPULATION 1 | POPULAITON 2 | ... |
|:---:|:-------:|:------------:|:------------:|:---:|

- KEY: The ontology key that corresponds to the disease
- DISEASE: Disease/category name
- POPULATION X: Frequency of each population of the ontology disease/category

### ontology_chrPos.pl
```
./ontology_chrPos.pl path/to/snpFrequency_joinAll_results.txt path/to/ontology.txt path/to/outfile.txt
```

#### Input
- Results of the snpFrequenct_joinAll.txt script
- Ontology text file
- Outfile name

#### Output
| KEY | DISEASE | CHR:POS |
|:---:|:-------:|:-------:|

- KEY: The ontology key that corresponds to the disease
- DISEASE: Disease/category name
- CHR:POS: Lis of chr:pos that correspond to each disease or disease category in the ontology 

### vcfSubset_snpFreq_perIndividual.pl

Before running this script you must make two subsets of the result file of snpFrequency_joinAll.pl script. One subset of the variants that are in the Disease Risk category of the ontology and another for the variants in the Disease Protection category. You can use the result file of the ontology_chrPos.pl script.

```
./vcfSubset_snpFreq_perIndividual.pl path/to/vcfFile.vcf path/to/snpFrequency_joinAll/subset path/to/outfile.txt
```
#### Input
- VCF file
- Subset of snpFrequency_joinAll result

#### Output
VCF file containing only entries in the disease ontology Disease categories.


###

### ancestryComparison.pl

```
./diseaseBurden_shared/ancestryComparison.pl path/to/normalized/ontology_snpFreq.txt difference path/to/outFile.txt
```

#### Input
- Result of the ontology_snpFreq.pl (normalized by population size)
- desired difference

#### Output
Ontology lines where the ancestry difference is larger than the inputed difference

### ontologyPlots.R
#### Script Notes
The ontology categories of interest are hard coded in the script.


## Notes for Myself
- make sure all scripts used are described on README
- Create script to find categories of interest at least two nodes above the terminal nodes