#!/usr/bin/perl

## script to calculate the difference between the ancestral populations

use strict;
use warnings;

my $ontology= $ARGV[0]; #out_ontology_snpFreq_notmalized.txt
my $difference = $ARGV[1];
my $outfile = $ARGV[2];

my @afr_num;
my @eur_num;
my @nat_num;

open(OUT, "+>", $outfile);

open(FILE1, $ontology) or die "Could not open $ontology\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    
    my @line = split (/\t/,$_); #split line into elements of array

    #if it is a header
    if ($_ =~ m/^\#/)
    {
    	print OUT $_; #print line

    	#get field number for populations of interest
    	for (my $i = 0; $i < scalar @line; $i++)
    	{
    		if ($line[$i] eq 'ESN' || $line[$i] eq 'YRI')
    		{
    			push @afr_num, $i;
    		}
    		elsif ($line[$i] eq 'GBR' || $line[$i] eq 'IBS')
    		{
    			push @eur_num, $i;
    		}
			elsif ($line[$i] eq 'CAI' || $line[$i] eq 'SAI')
    		{
    			push @nat_num, $i;
    		} 
    		else
    		{
    			next;
    		}
    	}
    	next;
    }
    else
    {
    	my $afr_sum = 0;
    	my $eur_sum = 0;
    	my $nat_sum = 0;

    	for (my $i = 0; $i < scalar @afr_num; $i++)
    	{
    		$afr_sum += $line[$afr_num[$i]];
    	}
    	for (my $i = 0; $i < scalar @eur_num; $i++)
    	{
    		$eur_sum += $line[$eur_num[$i]];
    	}
		for (my $i = 0; $i < scalar @nat_num; $i++)
    	{
    		$nat_sum += $line[$nat_num[$i]];
    	}

    	my $afr_ave = $afr_sum / scalar @afr_num;
    	my $eur_ave = $eur_sum / scalar @eur_num;
    	my $nat_ave = $nat_sum / scalar @nat_num;

    	my $afr_eur_sum = $afr_ave + $eur_ave;
    	my $afr_nat_sum = $afr_ave + $nat_ave;
    	my $nat_eur_sum = $nat_ave + $eur_ave;

    	my $afr_eur = 0;
    	my $afr_nat = 0;
    	my $nat_eur = 0;

    	if ($afr_eur_sum != 0)
    	{
    		$afr_eur = abs($afr_ave - $eur_ave) / ($afr_eur_sum/2);
    	}
    	if ($afr_nat_sum != 0)
    	{
    		$afr_nat = abs($afr_ave - $nat_ave) / ($afr_nat_sum/2);
    	}
    	if ($nat_eur_sum != 0)
    	{
    		my $nat_eur = abs($nat_ave - $eur_ave) / ($nat_eur_sum/2);
    	}
    	
    	if ($afr_eur >= $difference || $afr_nat >= $difference || $nat_eur >= $difference)
    	{
    		print OUT "\n$_";
    	}
    }
}