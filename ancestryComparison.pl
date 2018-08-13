#!/usr/bin/perl

use strict;
use warnings;

#declaring files
my $input = $ARGV[0]; #ontology_snpFreq results
my $percentDifference = $ARGV[1]; #desired percent difference
my $outfile = $ARGV[2]; #output

#variables
my @fullLine;
my @ESN;
my @IBS;
my @GBR;
my @YRI;
my $top;

my $counter = 0;

#open HGMD file and get data
open(FILE, $input) or die "Could not open $input\n";
while (<FILE>)
{
    if ($counter == 0)
    {
        $top = $_;
        $counter = 1;
    }
    else
    {
        push @fullLine, $_; #store full line
        $_ =~ s/\n//g; #remove end line symbol
        $_ =~ s/\r//g; #remove carriage return
        my @line = split (/\t/,$_); #split line into columns and put into an array called line

        push @ESN, $line[8]; #afro
        push @IBS, $line[9]; #euro
        push @GBR, $line[10]; #euro
        push @YRI, $line[11]; #afro
    }
}

my $ontology_size = scalar @ESN;

open(OUT, "+>", $outfile); #open output file to write in it
print OUT $top;

for (my $i = 0; $i < $ontology_size; $i++)
{
    my $afro_average = ($ESN[$i] + $YRI[$i]) / 2;
    my $euro_average = ($GBR[$i] + $IBS[$i]) / 2;

    if ($afro_average == 0 && $euro_average < 0.05)
    {
        next;
    }
    if ($euro_average == 0 && $afro_average < 0.05)
    {
        next;
    }

    my $afroEuro_difference = abs($afro_average - $euro_average);
    my $afroEuro_average = ($afro_average + $euro_average) / 2;

    my $percentDifference_calculated = $afroEuro_difference / $afroEuro_average;

    if ($percentDifference_calculated >=  $percentDifference)
    {
        print OUT $fullLine[$i];
    }
}

