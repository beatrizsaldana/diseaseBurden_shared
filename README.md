# Effect of Ancestry and Admixture on Autozygosity and the Burden of Inheritable Disease
The purpose of this project is to understand the effect of ancestry and admixture on autozygosity and disease burden. This is done by analyzing the distribution of disease causing variants in admixed Latin American Populations.

## General Project Protocol

### Data Preparation

#### HGMD
##### Source
*Stenson, Peter D., et al. "Human gene mutation database (HGMD®): 2003 update." Human mutation 21.6 (2003): 577-581.*
##### Script Used
- cleanHGMD.pl
##### Description
1. Download data of interest from the HGMD using getHGMD.sql
2. Remove entries that contain indels and entries for the X and Y chromosomes

#### VCF Files (from 1KGP)
##### Source
*Siva, Nayanah. "1000 Genomes project." (2008): 256.*
##### Script Used
SHASHWAT VCF TOOLS THING
##### Description
We needed multi-VCF files for the following 1KGP populations: ACB, ASW, CLM, MXL, PEL, PUR, GRB, IBS, ESN, YRI
We had multiVCFs containing data for many 1KGP populations; VCFs were divided into separate files determined by chromosome.

### Exploratory Analysis

#### HGMD variants per individual
##### Script Used
snpFreq_perIndividual.pl
##### Description
The script counts the number of variants that are present in the HGMD from each individual. The script compares the position of each variant described in the multi-VCF files with the data in the HGMD database. If the disease-causing allele of the variant is present in the individual's genome, it is counted in the following way:

- Homozygous absent: 0|0 --> +0
- Heterozygous present: 0|1 or 1|0 --> +1
- Homozygous present: 1|1 --> +2

The script outputs one individual per row, with the total sum of disease causing variants present in the individual's genome.
If there is incongruence with the number of typed-positions per individual, the total sum must be divided by the total-typed positions. We did not have to do that since our data was consistent.


#### Individuals with disease causing variants
##### Script Used
individualsWithDiseaseCausingVariants.pl
##### Description
The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is a list of the individuals that have the disease-causing allele of the variant (heterozygous or homozygous).

#### SNP frequency per population
##### Scripts Used
snpFrequency_general.pl
snpFrequency_homozygous.pl
##### Description
The script counts the number of individuals per populaiton that have the disease-causing allele of the variant present in their genome. The sum is calculated in the following way:
- Homozygous absent: 0|0 --> +0
- Heterozygous present: 0|1 or 1|0 --> +1
- Homozygous present: 1|1 --> +2

The script outputs all variants present in both the VCF files and the HGMD, one variant per row, and next to the variant information is sum of the frequency of each variant per population.

### Ontology

#### Ontology Curation
An ontology was created by classifying the traits/diseases in the HGMD into hierarchical categories, by hand. No script, sorry.

#### Ontology Frequency Calculation
##### Script Used
ontology_snpFreq.pl
##### Description
The script first appends the frequency of each trait/disease per population to the ontology, and then sums up the totals per ontology category. The frequency is taken from the output of the snpFrequency.pl script.

#### Ontology Trait/Disease to Geomic Position
##### Script Used
ontology_chrPos.pl
##### Description
The script first appends the genomic position of variant associated with every HGMD trait/disease, in the chromosome:position format, and then makes a list of all variants per ontology category.

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

### snpFrequency_general.pl

### snpFrequency_homozygous.pl

### ontology_snpFreq.pl

### ontology_chrPos.pl