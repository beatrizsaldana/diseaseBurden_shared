#!/usr/bin/perl

#script to map ROHs to local ancestry

use strict;
use warnings;
use Data::Dumper;

# command line input
my $ROHfile = 'ROH_andyMapping.txt'; # plink.hom
my $chrPaintFileList = 'listOfChrPaintFiles.txt'; # file containig a list of the files with the chromosome painting information in them
my $outfile = 'ROHmapLocalAncestry_out.txt'; # outfile

################################################################################
# GET ROH DATA AND STORE IN HASH
################################################################################

#ROH data
my %ROHsamples;

#get ROH data and store correctly
open(ROHFILE, $ROHfile) or die "Could not open $ROHfile\n";
my $temp = <ROHFILE>; # skip header
while (<ROHFILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs

    if (exists $ROHsamples{$line[1]})
    {
        push @{ $ROHsamples{$line[1]}[0] }, $line[2];
        push @{ $ROHsamples{$line[1]}[1] }, $line[3];
        push @{ $ROHsamples{$line[1]}[2] }, $line[4];
    }
    else
    {
        @{ $ROHsamples{$line[1]}[0] } = $line[2];
        @{ $ROHsamples{$line[1]}[1] } = $line[3];
        @{ $ROHsamples{$line[1]}[2] } = $line[4];

    }
}


################################################################################
# GET FILE NAME/PATHS AND SAMPLE ID OF FILE
################################################################################

# get file list
my @fileList;
my @fileList_ID;


#Get file names of chr paint
open(FILELIST, $chrPaintFileList) or die "Could not open $chrPaintFileList\n";
while (<FILELIST>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\//,$_); #splitting input line by /
    my @temp_array = split (/\_/,$line[8]);

    push @fileList, $_;
    push @fileList_ID, $temp_array[1];
}


################################################################################
# MAP ROH TO ANCESTRY
################################################################################

open(OUT, "+>", $outfile); #opening outfile in order to write to it

print OUT "#ID\tCHR\tPOS1\tPOS2\tANCESTRY";

#Map ROH to Ancestry
foreach my $key (keys(%ROHsamples))
{
    for (my $i = 0; $i < scalar @fileList_ID; $i++)
    {
        if($key eq $fileList_ID[$i])
        {
            open(FILE, $fileList[$i]) or die "Could not open $fileList[$i]\n";
            while (<FILE>)
            {
                $_ =~ s/\n//g; #remove end line symbol
                $_ =~ s/\r//g; #remove carriage return
                my @line = split (/\t/,$_); #splitting input line by /

                for (my $j = 0; $j < scalar @{$ROHsamples{$key}[0]}; $j++)
                {
                    if(@{$ROHsamples{$key}[0]}[$j] < $line[0])
                    {
                        next;
                    }
                    elsif(@{$ROHsamples{$key}[0]}[$j] > $line[0])
                    {
                        last;
                    }
                    elsif(@{$ROHsamples{$key}[0]}[$j] == $line[0])
                    {
                        if(@{$ROHsamples{$key}[1]}[$j] < $line[1])
                        {
                            next;
                        }
                        elsif(@{$ROHsamples{$key}[1]}[$j] >= $line[1] && @{$ROHsamples{$key}[1]}[$j] <= $line[2])
                        {
                            print OUT "\n$key\t@{$ROHsamples{$key}[0]}[$j]\t@{$ROHsamples{$key}[1]}[$j]\t@{$ROHsamples{$key}[2]}[$j]\t$line[3]";
                        }
                    }
                }
            }
        }
    }
}