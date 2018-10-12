#!/usr/bin/perl

#this script joins sample ID + Pop + other stuff (no header)

use strict;
use warnings;

#files
my $infile = $ARGV[0];
my $sampleID_pop = $ARGV[1];
my $outfile = $ARGV[2];

#global variables
my @ids;
my @pops;

open(FILE2, $sampleID_pop) or die "Could not open $sampleID_pop\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\s/,$_); #split line into array 

    push @ids, $line[0];
    push @pops, $line[1];
}

open(OUT, "+>", $outfile);

#store data in arrays
open(FILE1, $infile) or die "Could not open $infile\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\s/,$_); #split line into array

    print OUT "\n$line[0]";

    for (my $i = 0; $i < scalar @ids; $i++)
    {
        if ($line[0] eq $ids[$i])
        {
            print OUT "\t$pops[$i]";
            for (my $j = 0; $j < scalar @line - 1; $j++)
            {
                print OUT "\t$line[$j+1]";
            }
        }
    }
}
