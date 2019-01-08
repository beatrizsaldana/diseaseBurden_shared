#!/usr/bin/perl

#join files on Sample ID

use strict;
use warnings;

#command line inputs
my $infile1 = $ARGV[0]; # larger file to which you will add the data from the other file (it is assumed that the first field is ID)
my $infile2 = $ARGV[1]; # file that contains the data that will be added to the first file (it is assumed that the first two Fields are ID and POPULATION)
my $outfile = $ARGV[2]; # outfile

#array declaration
my @file2_IDs;
my @file2_data;
my $file2_head;

#file2
open(FILE2, $infile2) or die "Could not open $infile2\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs
    
    if ($_ =~ m/^#/)
    {
        for (my $i = 0; $i < scalar @line - 2; $i++)
        {
            $file2_head.="\t".$line[$i+2];
        }  
        next;
    }

    push @file2_IDs, $line[0];
    
    my $data='';
    
    for (my $i = 0; $i < scalar @line - 2; $i++)
    {
        $data.="\t".$line[$i+2]; #it is assumed that the first two fields are ID and POPULATION, which should already be in the other file
    }

    push @file2_data, $data;
}

#opening outfile in order to write to it
open(OUT, "+>", $outfile); 

#open infile
open(FILE1, $infile1) or die "Could not open $infile1\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    if ($_ =~ m/^#/)
    {
        print OUT "$_$file2_head";
        next;
    }

    print OUT "\n$_";
    my @line = split (/\t/,$_); #splitting input line by tabs

    for (my $i = 0; $i < scalar @file2_IDs; $i++)
    {
        if ($file2_IDs[$i] eq $line[0])
        {
            print OUT "$file2_data[$i]";
        }
        else
        {
            next;
        }
    }

}