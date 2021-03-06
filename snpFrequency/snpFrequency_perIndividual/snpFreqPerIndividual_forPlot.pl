#!/usr/bin/perl

use strict;
use warnings;

my $listOfFilesIn = $ARGV[0]; #list of files (\n separated)
my $outfile = $ARGV[1];

my @listOfFiles;

open(FILE1, $listOfFilesIn) or die "Could not open $listOfFilesIn\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    push @listOfFiles, $_;
}

open(OUT, "+>", $outfile);

print OUT "#SAMPLEID\tHOMOZYGOUS\tPOPULATION\tGROUP\tCOLOR";

for (my $i = 0; $i < scalar @listOfFiles; $i++)
{
	my @pop = split (/_/, $listOfFiles[$i]);
	my $population = uc $pop[3];
	$population =~ s/\.TXT//g;
	my $group;
	my $color;
	
	if ($population eq 'ACB' || $population eq 'ASW' || $population eq 'CLM' || $population eq 'MXL' || $population eq 'PEL' || $population eq 'PUR')
    {
    	$group = 'Admixed';
    	$color = '#3A7532';
    }
    elsif ($population eq 'ESN' || $population eq 'YRI')
    {
    	$group = 'African';
    	$color = '#4D4989';
    }
    elsif ($population eq 'GBR' || $population eq 'IBS')
    {
    	$group = 'European';
    	$color = '#F59C2B';
    }
    elsif ($population eq 'CAI' || $population eq 'SAI')
    {
    	$group = 'Nat. Amer.';
    	$color = '#F72A32';
    }

	open(FILE, $listOfFiles[$i]) or die "Could not open $listOfFiles[$i]\n";
	while (<FILE>)
	{
	    if ($_ =~ m/^#/)
	    {
	    	next;
	    }
	    else
	    {
	    	$_ =~ s/\n//g; #remove end line symbol if there is one
		    $_ =~ s/\r//g; #remove carriage return if there is one
		    
		    my @line = split (/\t/,$_); #split line into array

		    print OUT "\n$line[0]\t$line[2]\t$population\t$group\t$color";
	    }
	}
}
