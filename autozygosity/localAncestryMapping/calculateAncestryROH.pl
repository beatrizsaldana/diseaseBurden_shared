#!/usr/bin/perl

# calculate SROH of populations divided by ancestry

use strict;
use warnings;
use Data::Dumper;

my $input = $ARGV[0]; #output of mapROHtoLocalAncestry.pl script
my $outfile = $ARGV[1]; # outfile

# these arrays will be of length 5 (total, AFR, IBS, NAT, UNK)
my @CLM = [0,0,0,0,0];
my @MXL = [0,0,0,0,0];
my @PEL = [0,0,0,0,0];
my @PUR = [0,0,0,0,0];

open(INFILE, $input) or die "Could not open $input\n";
my $temp = <INFILE>; # skip header
while (<INFILE>)
{
	$_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs

    if ($line[0] =~ m/^CLM/)
    {
    	my $roh_length = $line[3] - $line[2];
    	
    	#add to total
    	$CLM[0]+= $roh_length;

    	if ($line[4] eq 'AFR')
    	{
    		$CLM[1]+= $roh_length;
    	}
    	elsif ($line[4] eq 'IBS')
    	{
    		$CLM[2]+= $roh_length;
    	}
    	elsif ($line[4] eq 'NAT')
    	{
    		$CLM[3]+= $roh_length;
    	}
    	elsif ($line[4] eq 'UNK')
    	{
    		$CLM[4]+= $roh_length;
    	}
    }
    elsif ($line[0] =~ m/^MXL/)
    {
    	my $roh_length = $line[3] - $line[2];
    	
    	#add to total
    	$MXL[0]+= $roh_length;

    	if ($line[4] eq 'AFR')
    	{
    		$MXL[1]+= $roh_length;
    	}
    	elsif ($line[4] eq 'IBS')
    	{
    		$MXL[2]+= $roh_length;
    	}
    	elsif ($line[4] eq 'NAT')
    	{
    		$MXL[3]+= $roh_length;
    	}
    	elsif ($line[4] eq 'UNK')
    	{
    		$MXL[4]+= $roh_length;
    	}
    }
    elsif ($line[0] =~ m/^PEL/)
    {
    	my $roh_length = $line[3] - $line[2];
    	
    	#add to total
    	$PEL[0]+= $roh_length;

    	if ($line[4] eq 'AFR')
    	{
    		$PEL[1]+= $roh_length;
    	}
    	elsif ($line[4] eq 'IBS')
    	{
    		$PEL[2]+= $roh_length;
    	}
    	elsif ($line[4] eq 'NAT')
    	{
    		$PEL[3]+= $roh_length;
    	}
    	elsif ($line[4] eq 'UNK')
    	{
    		$PEL[4]+= $roh_length;
    	}
    }
    elsif ($line[0] =~ m/^PUR/)
    {
    	my $roh_length = $line[3] - $line[2];
    	
    	#add to total
    	$PUR[0]+= $roh_length;

    	if ($line[4] eq 'AFR')
    	{
    		$PUR[1]+= $roh_length;
    	}
    	elsif ($line[4] eq 'IBS')
    	{
    		$PUR[2]+= $roh_length;
    	}
    	elsif ($line[4] eq 'NAT')
    	{
    		$PUR[3]+= $roh_length;
    	}
    	elsif ($line[4] eq 'UNK')
    	{
    		$PUR[4]+= $roh_length;
    	}
    }
}

open(OUT, "+>", $outfile); #opening outfile in order to write to it

print OUT "#POPULATION\tTOTAL_SROH\tAFR_SROH\tIBS_SROH\tNAT_SROH\tUNK_SROH";

print OUT "\nCLM\t$CLM[0]\t$CLM[1]\t$CLM[2]\t$CLM[3]\t$CLM[4]";
print OUT "\nMXL\t$MXL[0]\t$MXL[1]\t$MXL[2]\t$MXL[3]\t$MXL[4]";
print OUT "\nPEL\t$PEL[0]\t$PEL[1]\t$PEL[2]\t$PEL[3]\t$PEL[4]";
print OUT "\nPUR\t$PUR[0]\t$PUR[1]\t$PUR[2]\t$PUR[3]\t$PUR[4]";
