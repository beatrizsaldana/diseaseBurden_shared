#!/usr/bin/perl

# Script make VCF file of only the samples of interest from the SGDP data

use strict;
use warnings;

#declaring files
my $sampleIDs = $ARGV[0]; #list of sample IDs
my $outFile = $ARGV[1]; #out VCF
my $dataFile = $ARGV[2]; #in VCF
my $ifh; #to get input from command line pipe

#declaring variables
my @sampleIDarray;
my @sampleIDcolumnNum;
my $numOfColumns;
my $sampleIDcolumnNum_arrayLength;

#open sampleID file
open(FILE1, $sampleIDs) or die "Could not open $sampleIDs\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    push @sampleIDarray, $_; #array of sample IDs
}

my $sampleIDarrayLength = scalar @sampleIDarray;

open(OUT, "+>", $outFile);

if (defined $dataFile)
{
    open $ifh, "<", $dataFile or die $!;
}
else
{
    $ifh = *STDIN;
}
while (<$ifh>)
{
	if ($_ =~ m/^\##/)
    {
        next;
    }
    elsif ($_ =~ m/^\#CHROM/)
    {
    	$_ =~ s/\n//g; #remove end line symbol if there is one
    	$_ =~ s/\r//g; #remove carriage return if there is one

    	my @line = split (/\t/,$_); #split line into columns and put into an array called line
    	$numOfColumns = scalar @line;

    	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]";

    	for (my $i=0; $i < $numOfColumns; $i++)
		{
			for (my $j=0; $j < $sampleIDarrayLength; $j++)
			{
				if ($line[$i] eq $sampleIDarray[$j])
				{
					print OUT "\t$line[$i]";
					push @sampleIDcolumnNum, $i; #array of number of columns of samples
				}
			}
		}

		$sampleIDcolumnNum_arrayLength = scalar @sampleIDcolumnNum;
    }
    else
    {
    	$_ =~ s/\n//g; #remove end line symbol if there is one
    	$_ =~ s/\r//g; #remove carriage return if there is one
    	
    	my @line = split (/\t/,$_); #split line into columns and put into an array called line

    	print OUT "\n$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]";

    	for (my $i=0; $i < $sampleIDcolumnNum_arrayLength; $i++)
    	{
    		my $colNum = $sampleIDcolumnNum[$i];
    		print OUT "\t$line[$colNum]";
    	}
    }
}