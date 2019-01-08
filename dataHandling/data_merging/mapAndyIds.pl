#!/usr/bin/perl

#script to map andyIDs to 1KGP IDs

use strict;
use warnings;

#command line inputs
my $infile = $ARGV[0]; # file that needs the mapping
my $mappingfile = $ARGV[1]; #file with the mapping information
my $outfile = $ARGV[2]; # outfile

#array declaration
my @ID_1kgp;
my @ID_andy;

#get mapping data
open(MAP, $mappingfile) or die "Could not open $mappingfile\n";
while (<MAP>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs
    
    push @ID_1kgp, $line[0];
    push @ID_andy, $line[1];
}
#opening outfile in order to write to it
open(OUT, "+>", $outfile); 

#open infile
open(FILE, $infile) or die "Could not open $infile\n";
while (<FILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    if ($_ =~ m/^#/)
    {
        print OUT $_;
        next;
    }

    my @line = split (/\t/,$_); #splitting input line by tabs

    for (my $i = 0; $i < scalar @ID_andy; $i++)
    {
        if ($line[0] eq $ID_andy[$i])
        {
            print OUT "\n$ID_1kgp[$i]";
            
            for (my $j = 0; $j < scalar @line - 1; $j++)
            {
                print OUT "\t$line[$j+1]";
            }

            last;
        }
    }
}