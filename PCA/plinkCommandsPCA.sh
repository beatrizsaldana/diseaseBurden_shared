#!/bin/bash

## plink commands to prune data and do PCA

plink --vcf ../base_data/VCF_files/completeVCF/sgdp_head.vcf.gz --maf 0.01 --indep-pairwise 50 5 0.05 --out sgdp/sgdp_head_prunned.vcf.gz

# plink --vcf ../../../base_data/VCF_files/sgdp_1kgp/allSamples_1kgp_sgdp.vcf --maf 0.01 --indep-pairwise 50 5 0.05 --out LDpruning/allSamples_1kgp_sgdp

plink --vcf ../../../base_data/VCF_files/completeVCF/sgdp_head.vcf.gz --genome gz --out IBDpruning/sgdp_head --extract LDpruning/sgdp_head_prunned.vcf.gz.prune.in 

# plink --vcf ../../../base_data/VCF_files/sgdp_1kgp/allSamples_1kgp_sgdp.vcf --genome gz --out IBDpruning/allSamples_1kgp_sgdp --extract LDpruning/allSamples_1kgp_sgdp.prune.in

plink --vcf ../../../base_data/VCF_files/completeVCF/sgdp_head.vcf.gz --extract ../../plink_pruning/sgdp/LDpruning/sgdp_head_prunned.vcf.gz.prune.in --pca var-wts --out sgdp_head

## I will get an *.eigenvec file which will contain my PC