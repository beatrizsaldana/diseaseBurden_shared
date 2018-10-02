#!/usr/bin/perl

#this script counts the number of variants per ontology category

use strict;
use warnings;

#files
my $in_disease_populationFrequency = $ARGV[0]; #results from snpFrequency_joinAll.pl
my $in_ontology = $ARGV[1]; # ontology text file
my $outfile = $ARGV[2];

#arrays containing data
my @freq;
my @keys;
my @diseases_popFreq;
my @diseases_ontology;

#store data in arrays
open(FILE1, $in_disease_populationFrequency) or die "Could not open $in_disease_populationFrequency\n";
my $temp = <FILE1>;
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into array
    my $freq_temp = join('\t', $line[6], $line[7], $line[8], $line[9], $line[10], $line[11], $line[12], $line[13], $line[14], $line[15], $line[16]);

    push @freq, $freq_temp; #store pop frequencies
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

my @snpCount;

for (my $i = 0; $i < $ontology_size; $i++)
{
    $snpCount[$i]=0;
}

#populate the arrays with original disease frequencies
#go through each element of the ontology and check if it has an identical match in the pop freq file
for (my $i = 0; $i < $ontology_size; $i++)
{   
    #go through pop freq file in order to check for exact matches
    for (my $j = 0; $j < $popFreq_size; $j++)
    {
        #if there is a match, and the frequencies are not all zero, count the variant
        if ($diseases_ontology[$i] eq $diseases_popFreq[$j] && $freq[$j] =~ m/[1-9]/)
        {
            $snpCount[$i]+=1;
        }
        else
        {
            next;
        }
    }
}

open(OUT, "+>", $outfile);

print OUT "#KEY\tDISEASE\tSNP_COUNT";

#go through the whole ontology again in order to sum everything up
for (my $i = 0; $i < $ontology_size; $i++)
{
    my $count = 0;
    print OUT "\n$keys[$i]\t$diseases_ontology[$i]";
    #start with one element, and check the whole ontology to see if there are keys that match the element
    #key will match for child nodes
    my $key1 = $keys[$i];
    $key1 =~ s/\./\\\./g;
    for (my $j = 0; $j < $ontology_size; $j++)
    {
        #if a key matches sum up the variant count
        if ($keys[$j] =~ m/^$key1/ && $keys[$j] ne $keys[$i])
        {
            $snpCount[$i]+=$snpCount[$j];
        }
    }
    print OUT "\t$snpCount[$i]";
}
