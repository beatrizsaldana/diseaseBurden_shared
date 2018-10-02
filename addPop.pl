#!/usr/bin/perl

#this script joins sample ID + Pop + other stuff

use strict;
use warnings;

#files
my $infile = $ARGV[0];
my $sampleID_pop = $ARGV[1];
my $outfile = $ARGV[2];

#global variables
my @infile_ids;
my $infile_head = '';
my @infile_lines;


#store data in arrays
open(FILE1, $infile) or die "Could not open $infile\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line into array
    my $infile_line = '';

    if ($_ =~ m/^#/)
    {
        for (my $i = 0; $i < scalar @line - 1; $i++)
        {
            $infile_head.="\t".$line[$i+1];
        }  
        next;
    }
    else
    {
        push @infile_ids, $line[0];
        for (my $i = 0; $i < scalar @line - 1; $i++)
        {
            $infile_line.="\t".$line[$i+1];
        }

        push @infile_lines, $infile_line;
    }
}

open(OUT, "+>", $outfile);

print OUT "#ID\tPOPULATION$infile_head"; 

open(FILE2, $sampleID_pop) or die "Could not open $sampleID_pop\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\s/,$_); #split line into array 

    print OUT "\n$_";
    for (my $i = 0; $i < scalar @infile_ids; $i++)
    {
        if ($infile_ids[$i] eq $line[0])
        {
            print OUT "$infile_lines[$i]";
        }
        else
        {
            next;
        }
    }
}
