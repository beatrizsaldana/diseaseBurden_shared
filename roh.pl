#!/usr/bin/perl

#this script calculates NROH and SROH

use strict;
use warnings;

#files
my $infile = $ARGV[0];
my $outfile = $ARGV[1];

#global variables
my %individuals_nroh;
my %individuals_sroh;

#store data in arrays
open(FILE1, $infile) or die "Could not open $infile\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into array
    my $id = $line[0];
    my $length = $line[2] - $line[1];

    if (exists $individuals_nroh{$id})
    {
        $individuals_nroh{$id} +=1;
        $individuals_sroh{$id} += $length;
    }
    else
    {
        $individuals_nroh{$id} = 1;
        $individuals_sroh{$id} = $length;
    }
}

open(OUT, "+>", $outfile);

print OUT "#Individual_ID\tNROH\tSROH";

foreach my $key (keys %individuals_nroh)
{
    print OUT "\n$key\t$individuals_nroh{$key}\t$individuals_sroh{$key}";
}
