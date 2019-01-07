#!/usr/bin/perl

#script to map 1KGP sample names to Andy's sample names

use strict;
use warnings;
use Data::Dumper;

# command line input
my $ROHfile = 'ROHresults.txt'; # plink.hom
my $sampleIDmapperFile = 'projectToAndyMapping.txt'; # file containing the 1KGP IDs and the Andy/CHRpaint file IDs
my $outfile = 'ROH_andyMapping.txt'; # outfile

################################################################################
# GET ANDY MAPPING DATA AND STORE IN ARRAYS
################################################################################

#ID mapping data
my @mappingID;
my @andyID;

#Get ID mapping data and store it in arrays
open(IDmappingFILE, $sampleIDmapperFile) or die "Could not open $sampleIDmapperFile\n";
while (<IDmappingFILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\s/,$_); #splitting input line by tabs

    push @mappingID, $line[2];
    push @andyID, $line[3];
}

################################################################################
# GET ROH DATA AND STORE IN HASH
################################################################################

open(OUT, "+>", $outfile); #opening outfile in order to write to it

print OUT "#1KGP_ID\tANDY_ID\tCHR\tPOS1\tPOS2";

#get ROH data
open(ROHFILE, $ROHfile) or die "Could not open $ROHfile\n";
while (<ROHFILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs

    for (my $i = 0; $i < scalar @mappingID; $i++)
    {
        if ($line[0] eq $mappingID[$i])
        {
            print OUT "\n$line[0]\t$andyID[$i]\t$line[1]\t$line[2]\t$line[3]";
        }
    }

}