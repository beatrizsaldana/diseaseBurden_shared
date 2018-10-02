#!/usr/bin/perl

#disease ontology for chr_pos

use strict;
use warnings;

#files
my $in_disease_populationFrequency = $ARGV[0]; #results from snpFrequency_joinAll.pl
my $in_ontology = $ARGV[1]; # ontology text file
my $outfile = $ARGV[2];

#arrays containing data
my @chr_pos_popFreq;
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
    my $chrPos_temp = join (':', $line[0], $line[1]); 

    push @chr_pos_popFreq, $chrPos_temp; #store chr:pos of each variant
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

my @chr_pos; #declare array that will contain the chr_pos

#populate the arrays with original disease frequencies
#go through each element of the ontology and check if if has an identical match in the pop freq file
for (my $i = 0; $i < $ontology_size; $i++)
{
    my $disease_checker = 0; #check if the disease in the ontology matches exactly with disease name in pop freq file
    
    #go through pop freq file in order to check for exact matches
    for (my $j = 0; $j < $popFreq_size; $j++)
    {
        #if there is a match, store the chr:pos in vairable
        if ($diseases_ontology[$i] eq $diseases_popFreq[$j])
        {
            if ($disease_checker == 0)
            {
                $chr_pos[$i] = $chr_pos_popFreq[$j];
                $disease_checker = 1; #change the checker to 1 in order to avoid replacing frequencies with zero
            }
            else
            {
                $chr_pos[$i] .= "\t$chr_pos_popFreq[$j]"; #append more chr:pos if they exist
            }
        }
        else
        {
            next;
        }
    }
    #if there was no exact match, chr_pos will equal 'none'
    if ($disease_checker == 0)
    {
        $chr_pos[$i] = 'none';
    }
}

open(OUT, "+>", $outfile);

print OUT "KEY\tDISEASE\tchr_pos";

#go through the whole ontology again in order to sum everything up
for (my $i = 0; $i < $ontology_size; $i++)
{
    print OUT "\n$keys[$i]\t$diseases_ontology[$i]";
    #start with one element, and check the whole ontology to see if there are keys that match the element
    #key will match for child nodes
    my $key1 = $keys[$i];
    $key1 =~ s/\./\\\./g;
    for (my $j = 0; $j < $ontology_size; $j++)
    {
        #if a key matches and there is an rsid corresponding to the disease, print
        if ($keys[$j] =~ m/^$key1/ && $chr_pos[$j] ne 'none')
        {
            print OUT "\t$chr_pos[$j]";
        }
    }
}
