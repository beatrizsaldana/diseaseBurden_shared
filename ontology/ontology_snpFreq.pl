#!/usr/bin/perl

### script to sum up the frequencies of each variant for each level of the disease ontology
### includes admixed and reference populations

use strict;
use warnings;

#files
my $in_disease_populationFrequency = $ARGV[0]; #result from snpFrequency_joinAll.pl
my $in_ontology = $ARGV[1]; #ontology text file
my $outfile = $ARGV[2];

#arrays containing data
my @populations;
my @acb;
my @asw;
my @clm;
my @mxl;
my @pel;
my @pur;
my @esn;
my @ibs;
my @gbr;
my @yri;
my @cai;
my @sai;
my @diseases_popFreq;
my @keys;
my @diseases_ontology;

#store data in arrays
open(FILE1, $in_disease_populationFrequency) or die "Could not open $in_disease_populationFrequency\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into array

    if ($line[0] =~ m/^#/)
    {
        next;
    }

    push @acb, $line[6]; #store frequencies for population ACB
    push @asw, $line[7]; #store frequencies for population ASW
    push @cai, $line[8];
    push @clm, $line[9]; #store frequencies for population CLM
    push @esn, $line[10]; #store frequencies for population PUR
    push @gbr, $line[11]; #store frequencies for population GBR
    push @ibs, $line[12]; #store frequencies for population IBS
    push @mxl, $line[13]; #store frequencies for population MXL
    push @pel, $line[14]; #store frequencies for population PEL
    push @pur, $line[15]; #store frequencies for population PUR
    push @sai, $line[16];
    push @yri, $line[17]; #store frequencies for population YRI
    push @diseases_popFreq, $line[5]; #store disease names
}

my $popFreq_size = scalar @diseases_popFreq; #find population frequencies file

#store data in arrays
open(FILE2, $in_ontology) or die "Could not open $in_ontology\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    my @line = split (/\s/,$_,2); #split line into array of two

    push @keys, $line[0]; #store ontology keys in array
    push @diseases_ontology, $line[1]; #store the names of these keys in an array
}

my $ontology_size = scalar @keys; #get size of ontology

my @population_frequencies; #declare array that will contain the frequencies of the ontology

#populate the arrays with original disease frequencies
#go through each element of the ontology and check if if has an identical match in the pop freq file
for (my $i = 0; $i < $ontology_size; $i++)
{
    my $disease_checker = 0; #check if the disease in the ontology matches exactly with disease name in pop freq file
    
    #go through pop freq file in order to check for exact matches
    for (my $j = 0; $j < $popFreq_size; $j++)
    {
        #if there is a match, store the frequencies of each population in array
        if ($diseases_ontology[$i] eq $diseases_popFreq[$j])
        {
            if ($disease_checker == 0)
            {
                $population_frequencies[0][$i] = $acb[$j];
                $population_frequencies[1][$i] = $asw[$j];
                $population_frequencies[2][$i] = $cai[$j];
                $population_frequencies[3][$i] = $clm[$j];
                $population_frequencies[4][$i] = $esn[$j];
                $population_frequencies[5][$i] = $gbr[$j];
                $population_frequencies[6][$i] = $ibs[$j];
                $population_frequencies[7][$i] = $mxl[$j];
                $population_frequencies[8][$i] = $pel[$j];
                $population_frequencies[9][$i] = $pur[$j];
                $population_frequencies[10][$i] = $sai[$j];
                $population_frequencies[11][$i] = $yri[$j];
                $disease_checker = 1; #change the checker to 1 in order to avoid replacing frequencies with zero
            }
            else
            {
                $population_frequencies[0][$i] += $acb[$j];
                $population_frequencies[1][$i] += $asw[$j];
                $population_frequencies[2][$i] += $cai[$j];
                $population_frequencies[3][$i] += $clm[$j];
                $population_frequencies[4][$i] += $esn[$j];
                $population_frequencies[5][$i] += $gbr[$j];
                $population_frequencies[6][$i] += $ibs[$j];
                $population_frequencies[7][$i] += $mxl[$j];
                $population_frequencies[8][$i] += $pel[$j];
                $population_frequencies[9][$i] += $pur[$j];
                $population_frequencies[10][$i] += $sai[$j];
                $population_frequencies[11][$i] += $yri[$j];
            }
        }
        else
        {
            next;
        }
    }
    #if there was no exact match, put a zero for the frequencies
    if ($disease_checker == 0)
    {
        $population_frequencies[0][$i] = 0;
        $population_frequencies[1][$i] = 0;
        $population_frequencies[2][$i] = 0;
        $population_frequencies[3][$i] = 0;
        $population_frequencies[4][$i] = 0;
        $population_frequencies[5][$i] = 0;
        $population_frequencies[6][$i] = 0;
        $population_frequencies[7][$i] = 0;
        $population_frequencies[8][$i] = 0;
        $population_frequencies[9][$i] = 0;
        $population_frequencies[10][$i] = 0;
        $population_frequencies[11][$i] = 0;
    }
}

#go through the whole ontology again in order to sum everything up
for (my $i = 0; $i < $ontology_size; $i++)
{
    #start with one element, and check the whole ontology to see if there are keys that match the element
    #key will match for child nodes
    my $key1 = $keys[$i];
    $key1 =~ s/\./\\\./g;
    for (my $j = 0; $j < $ontology_size; $j++)
    {
        #if a key matches, but is not the exact key itself, sum it up
        if ($keys[$j] =~ m/^$key1/ && $keys[$j] ne $keys[$i])
        {
            $population_frequencies[0][$i] += $population_frequencies[0][$j];
            $population_frequencies[1][$i] += $population_frequencies[1][$j];
            $population_frequencies[2][$i] += $population_frequencies[2][$j];
            $population_frequencies[3][$i] += $population_frequencies[3][$j];
            $population_frequencies[4][$i] += $population_frequencies[4][$j];
            $population_frequencies[5][$i] += $population_frequencies[5][$j];
            $population_frequencies[6][$i] += $population_frequencies[6][$j];
            $population_frequencies[7][$i] += $population_frequencies[7][$j];
            $population_frequencies[8][$i] += $population_frequencies[8][$j];
            $population_frequencies[9][$i] += $population_frequencies[9][$j];
            $population_frequencies[10][$i] += $population_frequencies[10][$j];
            $population_frequencies[11][$i] += $population_frequencies[11][$j];
        }
    }
}

open(OUT, "+>", $outfile);

print OUT "#KEY\tDISEASE\tACB\tASW\tCAI\tCLM\tESN\tGBR\tIBS\tMXL\tPEL\tPUR\tSAI\tYRI";

for (my $i = 0; $i < $ontology_size; $i++)
{
    print OUT "\n$keys[$i]\t$diseases_ontology[$i]\t$population_frequencies[0][$i]\t$population_frequencies[1][$i]\t";
    print OUT "$population_frequencies[2][$i]\t$population_frequencies[3][$i]\t$population_frequencies[4][$i]\t$population_frequencies[5][$i]\t";
    print OUT "$population_frequencies[6][$i]\t$population_frequencies[7][$i]\t$population_frequencies[8][$i]\t$population_frequencies[9][$i]\t$population_frequencies[10][$i]\t$population_frequencies[11][$i]";
}
