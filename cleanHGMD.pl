#!/usr/bin/perl

use strict;
use warnings;

my $hgmd_file = $ARGV[0]; # downloaded hgmd file
my $outfile = $ARGV[1]; # outfile

open(OUT, "+>", $outfile); #opening outfile in order to write to it

#opening inpu file
open(FILE, $hgmd_file) or die "Could not open $hgmd_file\n";
while (<FILE>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #splitting input line by tabs
    
    #if the line contains an indel or is from chromosome X or Y, do not print
    if ($line[3] =~ m/.{2,}/ || $line[4] =~ m/.{2,}/ || $line[0] =~ m/X/ || $line[0] =~ m/Y/)
    {
        next;
    }
    else
    {
        print OUT "$_\n"; #print line
    }
}
