#!/usr/bin/perl

##script to make a subset of a vcf using an intersect file chr, pos, ref, alt of desired variants

use strict;
use warnings;

#files
my $intersectFile = $ARGV[0]; #file with chr, po, ref, and alt desired
my $vcf = $ARGV[1]; #input VCF file
my $outfile = $ARGV[2]; #output file (merged vcfs)

#variables
my @chr;
my @pos;
my @ref;
my @alt;

open(FILE, $intersectFile) or die "Could not open $intersectFile\n";
while (<FILE>)
{
	$_ =~ s/\n//g;; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    if ($_ =~ m/^#/)
    {
        next;
    }

	my @line = split (/\t/,$_);
	push @chr, $line[0];
	push @pos, $line[1];
	push @ref, $line[2];
	push @alt, $line[3];
}

#open output file in order to write to it
open(OUT, "+>", $outfile);

my $j = 0;

open(VCF, $vcf) or die "Could not open $vcf\n";
while (<VCF>)
{
	$_ =~ s/\n//g;; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

	if ($_ =~ m/^\#/)
	{
	    print OUT $_; #skip file headers
	}
	else
	{
        my @line = split (/\t/,$_);

        
		for (my $i = $j; $i < scalar @pos; $i++)
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
                		print OUT "\n$_";
                        $j = $i;
                	}
                }
            }
		}
	}
}
