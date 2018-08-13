#!/usr/bin/perl

#### Script to normalize ontology raw results
#### First you need to run ontology_snpFreq.pl and then ontology_countSnps.pl
#### You will also need a text file containing the population size of the populations in the ontology, in the following format (no headers in file):
#### POPULATION_NAME   SIZE_OF_POPULATION
#### The populations in the text file have to be in the same order as the populations in the ontology

use strict;
use warnings;

#declaring files
my $ontology = $ARGV[0]; #ontology_snpFreq results
my $ontology_snpCount = $ARGV[1]; #number of variants per category (output of ontology_snpCount)
my $population_size = $ARGV[2];  #size of population
my $outfile = $ARGV[3]; #output

#variables
my @snpCount; #array containing the number of SNPs per line of the ontology
my @populationSize; #array containing the size of the populations

#open HGMD file and get data
open(FILE1, $ontology_snpCount) or die "Could not open $ontology_snpCount\n";
my $temp = <FILE1>;
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into columns and put into an array called line

    push @snpCount, $line[2]; #snp count
}

my $snpCountSize = scalar @snpCount; #store size of array

open(FILE2, $population_size) or die "Could not open $population_size\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into columns and put into an array called line

    push @populationSize, $line[1]; #population size
}

my $numberOfPopulations = scalar @populationSize; #store the size of the array

open(OUT, "+>", $outfile); #open output file to write in it

my $count = 0; #to print the header
my $ontologyLineCount = 0; #to count the number of lines in the ontology and match the snpCount ontology array

open(FILE3, $ontology) or die "Could not open $ontology\n";
while (<FILE3>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    #print out the header and move on
    if ($count == 0)
    {
        print OUT $_;
        $count = 1;
    }
    else
    {
        my @line = split (/\t/,$_); #split line into columns and put into an array called line

        print OUT "\n$line[0]\t$line[1]"; #print out the KEY and DISEASE

        #for every population, divide the number by the population size and by the number of snps per category
        for (my $i = 0; $i < $numberOfPopulations; $i++)
        {
            my $popNorm = $line[$i+2] / $populationSize[$i]; #nomalize the number by population size
            
            #if there are no SNPs because no one in the population has any of the variants or because the disease is not in the HGMD, do not normalize by snp count
            if ($snpCount[$ontologyLineCount] == 0)
            {
                 print OUT "\t$popNorm";
            }
            else
            {
                my $popNorm_snpNorm = $popNorm / $snpCount[$ontologyLineCount]; #normalize the number by the number of SNPs in each category
                print OUT "\t$popNorm_snpNorm"; #print out normalized frequency
            }
        }
        $ontologyLineCount++; #increase line counter
    }
}
