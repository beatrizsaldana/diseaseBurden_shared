#!/usr/bin/perl

#make vcf subsets from a single vcf file
# I never got this script to work, do not use this script, fix later

use strict;
use warnings;
use Data::Dumper;

#command line input
my $sampleIDs = $ARGV[0]; #list of files, one per population (file list seoarated by '\n', containing a tab separated list of sample IDs
my $dataFile = $ARGV[1]; #in VCF
my $ifh; #to get input from command line pipe

my @sampleIDs_fileNames;

#store sample ID filenames in array
open(SAMPLEIDS, $sampleIDs) or die "sampleIDs\n";
while (<SAMPLEIDS>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    push @sampleIDs_fileNames, $_;
}

my %sampleIDs;

for (my $i = 0; $i < scalar @sampleIDs_fileNames; $i++)
{
	open(SAMPLEIDS_FILES, $sampleIDs_fileNames[$i]) or die "$sampleIDs_fileNames[$i]\n";
	while (<SAMPLEIDS_FILES>)
	{
	    $_ =~ s/\n//g; #remove end line symbol
	    $_ =~ s/\r//g; #remove carriage return
	    my @split_pop = split(/_/, $sampleIDs_fileNames[$i]);
	    my $pop = $split_pop[0];

	    my @line = split (/\t/,$_); #split line into array

	    for (my $j = 0; $j < scalar @line; $j++)
	    {
	    	if (defined $sampleIDs{$pop})
	    	{
	    		push @{$sampleIDs{$pop}}, $line[$j];
	    	}
	    	else
	    	{
	    		$sampleIDs{$pop} = [$line[$j]];
	    	}
	    }
	}
}

print Dumper(%sampleIDs);

foreach my $key (keys %sampleIDs)
{
	my $outfile = $key.".vcf";
	open(OUT, "+>", $outfile);

	my $numberOfSamples = scalar @{$sampleIDs{$key}};
	my @sampleIDcolumnNum;

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

	    	print OUT "$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]";

	    	for (my $i=0; $i < scalar @line; $i++)
			{
				for (my $j=0; $j < $numberOfSamples; $j++)
				{
					if ($line[$i] eq ${$sampleIDs{$key}}[$j])
					{
						print OUT "\t$line[$i]";
						push @sampleIDcolumnNum, $i; #array of number of columns of samples
					}
				}
			}
	    }
	    else
	    {
	    	$_ =~ s/\n//g; #remove end line symbol if there is one
	    	$_ =~ s/\r//g; #remove carriage return if there is one
	    	
	    	my @line = split (/\t/,$_); #split line into columns and put into an array called line

	    	print OUT "\n$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t$line[5]\t$line[6]\t$line[7]\t$line[8]";

	    	for (my $i=0; $i < scalar @sampleIDcolumnNum; $i++)
	    	{
	    		my $colNum = $sampleIDcolumnNum[$i];
	    		print OUT "\t$line[$colNum]";
	    	}
	    }
	}
}