#!/usr/bin/perl

## scirpt to comcatenate all sample IDs and population IDs into one file

use strict;
use warnings;

#commandLine arguments
my $infile = $ARGV[0]; # list of fils
my $outfile = $ARGV[1]; # outfile

#vairables
my @filenames;

#open outfile
open(OUT, "+>", $outfile);

print OUT "#SAMPLE_ID\tPOPULATION";

#open infile
open(FILE, $infile) or die "Could not open $infile\n";
while (<FILE>)
{
    #get rid of end line symbols
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    push @filenames, $_;
}

for (my $i = 0; $i < scalar @filenames; $i++)
{
	my @pop = split(/_/,$filenames[$i]);
	my $population = uc $pop[0];

	#open files
	open(FILE1, $filenames[$i]) or die "Could not open $filenames[$i]\n";
	while (<FILE1>)
	{
		#get rid of end line symbols
	    $_ =~ s/\n//g; #remove end line symbol
	    $_ =~ s/\r//g; #remove carriage return
	    
	    #split line into array called 'line'
	    my @line = split (/\t/,$_);

	    for (my $j = 0; $j < scalar @line; $j++)
	    {
	    	print OUT "\n$line[$i]\t$population";
	    }
	}
}