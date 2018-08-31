#!/usr/bin/perl

### script make a base file for snpFrequency_joinAll.pl (base file will contain the intersect of all files in snpFrequency_singlePop)

use strict;
use warnings;

my $file1 = $ARGV[0];
my $file2 = $ARGV[1];
my $outfile = $ARGV[2];

#variable declaration
my @chr1;
my @pos1;
my @rsid1;
my @ref1;
my @alt1;
my @dis1;
my @chr2;
my @pos2;
my @rsid2;
my @ref2;
my @alt2;
my @dis2;

#store the information of File1 in arrays
open(FILE1, $file1) or die "Could not open $file1\n";
while (<FILE1>)
{
	if ($_ =~ m/^\CHROMOSOME/)
    {
        next;
    }
    else
    {
    	$_ =~ s/\n//g; #remove end line symbol if there is one
    	$_ =~ s/\r//g; #remove carriage return if there is one
    	my @line = split (/\t/,$_); #split line into columns and put into an array called line

    	push @chr1, $line[0];
    	push @pos1, $line[1];
    	push @rsid1, $line[2];
    	push @ref1, $line[3];
    	push @alt1, $line[4];
    	push @dis1, $line[5];
    }

}

my $file1_rowNum = scalar @pos1;

#store the information of File1 in arrays
open(FILE2, $file2) or die "Could not open $file2\n";
while (<FILE2>)
{
	if ($_ =~ m/^\CHROMOSOME/)
    {
        next;
    }
    else
    {
    	$_ =~ s/\n//g; #remove end line symbol if there is one
    	$_ =~ s/\r//g; #remove carriage return if there is one
    	my @line = split (/\t/,$_); #split line into columns and put into an array called line

    	push @chr2, $line[0];
    	push @pos2, $line[1];
    	push @rsid2, $line[2];
    	push @ref2, $line[3];
    	push @alt2, $line[4];
    	push @dis2, $line[5];
    }

}

my $file2_rowNum = scalar @pos2;

open(OUT, "+>", $outfile);
print OUT "#CHROMOSOME\tPOSITION\tRSID\tREF\tALT\tDISEASE";

for (my $i = 0; $i < $file1_rowNum; $i++)
{
	for (my $j = 0; $j < $file2_rowNum; $j++)
	{
		if ($chr1[$i] > $chr2[$j])
		{
			next;
		}
		elsif ($chr1[$i] < $chr2[$j])
		{
			last;
		}
		elsif ($chr1[$i] == $chr2[$j])
		{
			if ($pos1[$i] > $pos2[$j])
			{
				next;
			}
			elsif ($pos1[$i] < $pos2[$j])
			{
				last;
			}
			elsif ($pos1[$i] == $pos2[$j])
			{
				if ($ref1[$i] eq $ref2[$j] && $alt1[$i] eq $alt2[$j])
				{
					print OUT "\n$chr1[$i]\t$pos1[$i]\t$rsid1[$i]\t$ref1[$i]\t$alt1[$i]\t$dis1[$i]"
				}
				elsif ($ref1[$i] eq $alt2[$j] && $alt1[$i] eq $ref2[$j])
				{
					print OUT "\n$chr1[$i]\t$pos1[$i]\t$rsid1[$i]\t$ref1[$i]\t$alt1[$i]\t$dis1[$i]"
				}
				else
				{
					next;
				}
			}
		}
	}
}
