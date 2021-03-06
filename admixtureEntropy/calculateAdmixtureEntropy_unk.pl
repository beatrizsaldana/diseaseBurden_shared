#!/usr/bin/perl

#script to calculate the admixture entropy of all individuals in file /data/home/bsaldana3/projects/diseaseBurden/base_data/populationInformation/allAncFractions.txt
#with unknown fraction

use strict;
use warnings;

#command line inputs
my $infile = $ARGV[0]; # allAncFractions.txt
my $outfile = $ARGV[1]; # outfile

#global variable declaration
my $afr;
my $eur;
my $nam;
my $unk;
my $sum;
my $sum_unk;

#opening outfile in order to write to it
open(OUT, "+>", $outfile);

#remove indels and X/Y chromosomes
open(FILE, $infile) or die "Could not open $infile\n";
while (<FILE>)
{
    #variable initialization
    my $afr=0;
    my $eur=0;
    my $nam=0;
    my $unk=0;
    my $sum=0;
    my $sum_unk=0;

    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs

    #skip header
    if ($_ =~ m/^ID/)
    {
        print OUT "#".$_."\tAdmixtureEntropy\tAdmixtureEntropy_unk";
        next;
    }

    #calculate the admixture entropy: H = -sum(ancestryFraction * ln(ancestryFraction))
    if ($line[2] == 0)
    {
        $afr = 0;
    }
    elsif ($line[2] != 0)
    {
        $afr = $line[2] * log($line[2]);
    }
    
    if ($line[3] == 0)
    {
        $eur = 0;
    }
    elsif ($line[3] != 0)
    {
        $eur = $line[3] * log($line[3]);
    }

    if ($line[4] == 0)
    {
        $nam = 0;
    }
    elsif ($line[4] != 0)
    {
        $nam = $line[4] * log($line[4]);
    }

    if ($line[5] == 0)
    {
        $unk = 0;
    }
    elsif ($line[5] != 0)
    {
        $unk = $line[5] * log($line[5]);
    }

    $sum_unk = $afr + $eur + $nam + $unk;
    $sum_unk = $sum_unk * -1;

    $sum = $afr + $eur + $nam;
    $sum = $sum * -1;

    print OUT "\n$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$sum\t$sum_unk";
}
