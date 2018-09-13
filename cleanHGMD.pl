#!/usr/bin/perl

#script to remove indels and entries for the X and Y chromosomes from hgmd
#this script will also check for and get rid of duplicate lines

use strict;
use warnings;

my $hgmd_file = $ARGV[0]; # downloaded hgmd file
my $outfile = $ARGV[1]; # outfile

my @completeLine;

#remove indels and X/Y chromosomes
open(FILE, $hgmd_file) or die "Could not open $hgmd_file\n";
while (<FILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs
    
    #if the line contains an indel or is from chromosome X or Y, do not print
    if ($line[3] =~ m/.{2,}/ || $line[4] =~ m/.{2,}/ || $line[0] =~ m/X/ || $line[0] =~ m/Y/)
    {
        next;
    }
    else
    {
        push @completeLine, $_;
    }
}

#remove duplicate lines
for (my $i=0; $i < scalar @completeLine; $i++)
{
    for (my $j=$i+1; $j < scalar @completeLine; $j++)
    {
        if ($completeLine[$i] eq $completeLine[$j])
        {
            splice @completeLine, $j, 1; #remove entry number 'j' from array
        }
    }
}

open(OUT, "+>", $outfile); #opening outfile in order to write to it

my $sizeOfArray = scalar @completeLine;

for (my $i=0; $i < $sizeOfArray; $i++)
{
    print OUT "$completeLine[$i]\n"; #print out the array
}
