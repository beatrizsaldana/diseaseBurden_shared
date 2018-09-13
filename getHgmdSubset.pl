#!/usr/bin/perl

use strict;
use warnings;

my $chrPosIn = $ARGV[0];
my $hgmd = $ARGV[1];
my $outfile = $ARGV[2];

my @chr;
my @pos;

open(FILE1, $chrPosIn) or die "Could not open $chrPosIn\n";
while (<FILE1>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    
    my @line = split (/\t/,$_);

    for (my $i = 0; $i < scalar @line; $i++)
    {
    	my @temp = split(/:/,$line[$i]);
    	push @chr, $temp[0];
    	push @pos, $temp[1];
    }
}

open(OUT, "+>", $outfile);

open(HGMD, $hgmd) or die "Could not open $hgmd\n";
while (<HGMD>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    
    my @line = split (/\t/,$_);

    $line[0] =~ s/chr//g;

    for (my $i = 0 ; $i < scalar @pos; $i++)
    {
    	if ($line[0] == $chr[$i] && $line[1] == $pos[$i])
    	{
    		print OUT "$_\n";
    		last;
    	}
    }
}