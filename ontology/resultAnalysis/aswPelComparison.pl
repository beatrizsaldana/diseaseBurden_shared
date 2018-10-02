#!/usr/bin/perl

use strict;
use warnings;

#declaring files
my $input = $ARGV[0]; #ontology_snpFreq results
my $percentDifference = $ARGV[1]; #desired percent difference
my $outfile = $ARGV[2]; #output

#variables
my @fullLine;
my @ASW;
my @PEL;
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

        push @ASW, $line[3]; #ASW
        push @PEL, $line[6]; #PEL
    }
}

my $ontology_size = scalar @ASW;

open(OUT, "+>", $outfile); #open output file to write in it
print OUT $top;

for (my $i = 0; $i < $ontology_size; $i++)
{
   if ($ASW[$i] < 0.01 && $PEL[$i] < 0.01)
    {
        next;
    }

    my $difference = abs($ASW[$i] - $PEL[$i]);
    my $average = ($ASW[$i] + $PEL[$i]) / 2;
    my $percentDifference_calculated = $difference / $average;

    if ($percentDifference_calculated >=  $percentDifference)
    {
        print OUT $fullLine[$i];
    }
}

