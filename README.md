# Effect of Ancestry and Admixture on Autozygosity and the Burden of Inheritable Disease
The purpose of this project is to understand the effect of ancestry and admixture on autozygosity and disease burden. This is done by analyzing the distribution of disease causing variants in admixed Latin American Populations.

## General Project Protocol

### 1. Data Preparation

#### HGMD
##### Source
*Stenson, Peter D., et al. "Human gene mutation database (HGMD®): 2003 update." Human mutation 21.6 (2003): 577-581.*
##### Data Location
The Human Gene Mutation Database used is located in the genomeTrax mysql database '/data/db/mysql/genomeTrax', and is entered as 'hgmd_2016'.
##### Script Used
- cleanHGMD.pl
##### Description
1. Download data of interest from the HGMD. Only entries from HG19 and considered of High Confidence were used.
2. Remove entries that contain indels and entries for the X and Y chromosomes
##### File Location
/data/home/bsaldana3/projects/diseaseBurden/base_data/hgmd/hgmd_complete_clean.txt
File described in Script Description section of README

#### VCF Files (from 1KGP)
##### Source
*Siva, Nayanah. "1000 Genomes project." (2008): 256.*
##### Data Location
The VCF files used for this project were located in the '/data/home/data/100gp/vcfgz/' directory in the Jordan Lab 'The Beast' server, and VCF files used were the ones with this title: 'ALL.chr\*.phase3_shapeit2_mvncall_integrated_v5a.20130502.genotypes.vcf.gz'.
##### Script Used
SHASHWAT VCF TOOLS THING
##### Description
We needed multi-VCF files for the following 1KGP populations: ACB, ASW, CLM, MXL, PEL, PUR, GRB, IBS, ESN, YRI
We had multiVCFs containing data for many 1KGP populations; VCFs were divided into separate files determined by chromosome.

#### VCF Files (from SGDP)
##### Source
##### Data Location
##### Scripts Used
- SHASHWAT VCF TOOLS AND HGMD INTERSECT
- The sample IDs that are consistent in Metadata and VCF file are the ones called 'Illumina_ID', those were extracted with a simple grep/awk command: grep 'America' SGDP_metadata.txt | awk '{print $2}'
- getSamplesOfInterestVCF.pl

### 2. Exploratory Analysis

#### HGMD variants per individual
##### Script Used
- snpFreq_perIndividual.pl
##### Description
The script counts the number of variants that are present in the HGMD from each individual. The script compares the position of each variant described in the multi-VCF files with the data in the HGMD database. If the disease-causing allele of the variant is present in the individual's genome, it is counted in the following way:

- Homozygous absent: 0|0 --> +0
- Heterozygous present: 0|1 or 1|0 --> +1
- Homozygous present: 1|1 --> +2

The script outputs one individual per row, with the total sum of disease causing variants present in the individual's genome.
If there is incongruence with the number of typed-positions per individual, the total sum must be divided by the total-typed positions. We did not have to do that since our data was consistent.

#### Individuals with disease causing variants
##### Script Used
- individualsWithDiseaseCausingVariants.pl
##### Description
The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is a list of the individuals that have the disease-causing allele of the variant (heterozygous or homozygous).

#### Disease Causing Variants per Individual
##### Script Used
- chrPos_perIndividual_homozygous.pl
##### Description
This script outputs a list of variants chr:pos that each individual has present in their genome in homozygous form.

#### SNP frequency per population
##### Scripts Used
- snpFrequency_singlePop.pl
- snpFrequency_joinAll.pl
##### Description
The scripts counts the number of individuals per populaiton that have the disease-causing allele of the variant present in their genome in homozygous form. The sum is calculated in the following way:
- Homozygous present: 1|1 --> +1

The scripts outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is sum of the frequency of each variant per population.

### 3. Ontology

#### Ontology Curation
An ontology was created by classifying the traits/diseases in the HGMD into hierarchical categories, by hand. No script, sorry.

#### Ontology VCF subsets
##### Script Used
- vcfSubset_snpFreq_perIndividual.pl
###### Description
This script makes subsets of the VCF with diseases that are only present in the 'Disease' category of the Disease Ontology. This is helpful for faster frequency calculations or if we need to re-do the analysis.

#### Ontology Frequency Calculation
##### Script Used
- ontology_snpFreq.pl
##### Description
The script first appends the frequency of each trait/disease per population to the ontology, and then sums up the totals per ontology category. The frequency is taken from the output of the snpFrequency.pl script.

#### Ontology Trait/Disease to Geomic Position
##### Script Used
- ontology_chrPos.pl
##### Description
The script first appends the genomic position of variant associated with every HGMD trait/disease, in the chromosome:position format, and then makes a list of all variants per ontology category.

### 4. Ontology Result Analysis

#### Result Normalization
##### Script Used
- ontology_normalize.pl
##### Description
The script normalizes the results of ontology_snpFreq.pl by the population size and by the number of SNPs per ontology category.

#### Statistical Analysis (Calculating Z scores)
##### Script Used
- ontology_zscores.pl
##### Description
The script calculates the z-scores of every ontology category. The population standard deviation is used for this calculation.

#### Finding Categories of Interest
##### Scripts Used
- ancestryComparison.pl
- aswPelComparison.pl
##### Description
The scripts compares the results of the ontology based on ancestral populations and admixed populations. of the ancestral populations, and if there is a significant difference, it will output the categories of interest. The "significance" parameter is inuted by the user (percent difference). We decided to compare ancestral populations to avoid imposing our hypothesis onto the results.

#### Making Plots
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
	hgmd_2016.ref, hgmd_2016.alt,
	hgmd_2016.disease
FROM ngs_feature_2016
INNER JOIN hgmd_2016 ON ngs_feature_2016.ngs_feature_no=hgmd_2016.feature_no
WHERE ngs_feature_2016.genome='hg19'
AND hgmd_2016.confidence='high'
INTO OUTFILE '/path/to/hgmd.txt';
```
#### Output
|Chromosome | Position | RSID | Ref | Alt | Disease/Trait|
|:---------:|:--------:|:----:|:---:|:---:|:------------:|
|chr1 | 12059084 | rs373107074 | C | T | Charcot-Marie-Tooth disease 2a|
|chr1 | 12059085 | rs140234726 | G | A | Charcot-Marie-Tooth disease 2a|
|chr1 | 12059087 | rs28940295 | C | G | Charcot-Marie-Tooth disease 2a|
| ... | ... | ... | ... | ... | ... |


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


## Notes
- put all of the scripts into a pipeline so that all of this can be done with a single script
- - - Make all scripts accept a list of vcf files instead of whatever they accept now
- - - Edit snpFrequency_singlePop.pl so that it does not need POPULATION as input
- make sure all scripts used are described on README
- Re-do all of this with the new data (Native American)
- Create script to find categories of interest at least two nodes above the terminal nodes

### Statistical tests Notes
Use hypergeometric test for intra-population statistical testing, to find ontology categories that are over represented (important) within each population
Use ANOVA (non parametric) to test inter-population statistical testing, for each ontology category 

ontology enrichment
hypergeomestric test
