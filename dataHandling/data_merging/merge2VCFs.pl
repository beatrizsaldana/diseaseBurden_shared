#!/usr/bin/perl

use strict;
use warnings;

#files
my $vcf1 = $ARGV[0]; #input VCF file
my $vcf2 = $ARGV[1]; #input VCF file
my $outfile = $ARGV[2]; #output file (merged vcfs)

#variables
my @completeLine;
my $completeHead;
my @chr;
my @pos;
my @ref;
my @alt;
my @vcf2Head;

open(VCF1, $vcf1) or die "Could not open $vcf1\n";
while (<VCF1>)
{
	$_ =~ s/\n//g;; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

	if ($_ =~ m/^\##/)
	{
	    next; #skip file headers
	}
	elsif ($_ =~ m/^#CHROM/)
	{
	    $completeHead = $_; # store main header in array
	}
	else
	{
		push @completeLine, $_;
		my @line = split (/\t/,$_);
		push @chr, $line[0];
		push @pos, $line[1];
		push @ref, $line[3];
		push @alt, $line[4];
	}
}

#open output file in order to write to it
open(OUT, "+>", $outfile);

open(VCF2, $vcf2) or die "Could not open $vcf2\n";
while (<VCF2>)
{
	$_ =~ s/\n//g;; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    my @completeLine_vcf2;

	if ($_ =~ m/^\##/)
	{
	    next; #skip file headers
	}
	elsif ($_ =~ m/^#CHROM/)
	{
	    push @vcf2Head, $_; # store main header in array
        splice @vcf2Head, 0, 9; # remove the non-population entries of the header
        print OUT $completeHead;
        for (my $i = 0; $i < scalar @vcf2Head; $i++)
        {
        	print OUT "\t$vcf2Head[$i]";
        }
        
	}
	else
	{
		push @completeLine_vcf2, $_; # store main header in array
        splice @completeLine_vcf2, 0, 9; # remove the non-population entries of the header
        my @line = split (/\t/,$_);
        
		for (my $i = 0; $i < scalar @pos; $i++)
		{
			if ($chr[$i] < $line[0])
            {
                next; #keep looking
            }
            elsif ($chr[$i] > $line[0])
            {
                last; #end loop, you have gone too far
            }
            elsif ($chr[$i] == $line[0])
            {
            	#if the chromosome matches, look for matching position
                if ($pos[$i] < $line[1])
                {
                    next; #keep looking
                }
                elsif ($pos[$i] > $line[1])
                {
                    last; #end loop, you have gone too far
                } 
                elsif ($pos[$i] == $line[1])
                {
                	if($ref[$i] eq $line[3] && $alt[$i] eq $line[4])
                	{
                		print OUT "\n$completeLine[$i]\t$completeLine_vcf2[$i]";
                	}
                }
            }
		}
	}
}
