#!/usr/bin/perl

#### Script to calculate the zscores of the ontology frequencies
#### First you need to run ontology_snpFreq.pl and then normalizeOntology.pl

use strict;
use warnings;

#declaring files
my $normalizedOntology = $ARGV[0]; #normalizeOntology.pl results
my $outfile = $ARGV[1]; #output

my $count = 0; #variable to print header

open(OUT, "+>", $outfile); #open output file to write in it

open(FILE, $normalizedOntology) or die "Could not open $normalizedOntology\n";
while (<FILE>)
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
        if ($_ !~ m/^[0-9]/)
        {
            next;
        }

        my @line = split (/\t/,$_); #split line into columns and put into an array called line

        print OUT "\n$line[0]\t$line[1]"; #print out the KEY and DISEASE

        my $temp = scalar @line;
        my $numberOfPopulations = $temp - 2;
        my $sum = 0;

        for (my $i = 0; $i < $numberOfPopulations; $i++)
        {
            $sum = $sum + $line[$i+2];
        }
        
        my $mean = $sum/$numberOfPopulations;
        my @sub;

        for (my $i = 0; $i < $numberOfPopulations; $i++)
        {
            my $dist = ($line[$i+2] - $mean);
            $sub[$i] = $dist**2;
        }

        my $sum_square = 0;

        for (my $i = 0; $i < $numberOfPopulations; $i++)
        {
            $sum_square = $sum_square + $sub[$i];
        }

        my $total_mean = $sum_square/$numberOfPopulations;
        my $stdv = sqrt($total_mean);

        for (my $i = 0; $i < $numberOfPopulations; $i++)
        {
            if ($stdv == 0)
            {
                print OUT "\t0";
            }
            else
            {
                my $z_score = ($line[$i+2] - $mean)/$stdv;
                print OUT "\t$z_score";
            }
        }
    }
}
