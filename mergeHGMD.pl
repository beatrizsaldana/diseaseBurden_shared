#!/usr/bin/perl

## script to join the hgmd_inheritance and hgmd_dbnsfp tables

use strict;
use warnings;

my $hgmd_score = $ARGV[0];
my $hgmd_inheritance = $ARGV[1];
my $outfile = $ARGV[2];

#store hgmd_inheritance in arrays
my @hgmd_inheritance_chr;
my @hgmd_inheritance_pos;
my @hgmd_inheritance_ref;
my @hgmd_inheritance_alt;
my @hgmd_inheritance_inh;

open(FILE2, $hgmd_inheritance) or die "Could not open $hgmd_inheritance\n";
while (<FILE2>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one

    my @line = split (/\t/,$_);

    $line[0] =~ s/chr//g; #remove 'chr'

	push @hgmd_inheritance_chr, $line[0];
	push @hgmd_inheritance_pos, $line[1];
	push @hgmd_inheritance_ref, $line[3];
	push @hgmd_inheritance_alt, $line[4];
	push @hgmd_inheritance_inh, $line[6];
}

my $size_of_hgmd_inheritance = scalar @hgmd_inheritance_pos;

open(OUT, "+>", $outfile);

open(FILE1, $hgmd_score) or die "Could not open $hgmd_score\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one

    my $counter = 0;

    my @line = split (/\t/,$_);

	print OUT $_;

	$line[0] =~ s/chr//g; #remove 'chr'

	for (my $i = 0; $i < $size_of_hgmd_inheritance; $i++)
	{
		if ($hgmd_inheritance_chr[$i] < $line[0])
		{
			next;
		}
		elsif ($hgmd_inheritance_chr[$i] > $line[0])
		{
			last;
		}
		elsif ($hgmd_inheritance_chr[$i] == $line[0])
		{
			if ($hgmd_inheritance_pos[$i] < $line[1])
			{
				next;
			}
			elsif ($hgmd_inheritance_pos[$i] > $line[1])
			{
				last;
			}
			elsif ($hgmd_inheritance_pos[$i] == $line[1])
			{
				if ($hgmd_inheritance_ref[$i] eq $line[3] && $hgmd_inheritance_alt[$i] eq $line[4])
				{
					if ($counter == 0)
					{
						print OUT "\t$hgmd_inheritance_inh[$i]";
						$counter++;
					}
					else
					{
						print OUT ", $hgmd_inheritance_inh[$i]";
					}
					
				}
			}
			else
			{
				next;
			}
		}
		else
		{
			next;
		}
	}
	print OUT "\n";
}
