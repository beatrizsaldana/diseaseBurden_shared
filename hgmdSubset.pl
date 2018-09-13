#!/usr/bin/perl

##script to get the HGMD subset desired
##variant type: DM
##mode of inheritance: autosomal recesisve
##polyphen score: higher than 0.15

use strict;
use warnings;

my $hgmd = $ARGV[0];
my $outfile = $ARGV[1];

open(OUT, "+>", $outfile);

open(HGMD, $hgmd) or die "Could not open $hgmd\n";
while (<HGMD>)
{
    $_ =~ s/\n//g; #remove end line symbol if there is one
    $_ =~ s/\r//g; #remove carriage return if there is one
    
    my @line = split (/\t/,$_);

    if (defined $line[6] && defined $line[7] && defined $line[8])
    {
        if ($line[6] eq 'DM')
        {
            if ($line[7] =~ m/^[0-9]+$/)
            {
                if ($line[7] >= 0.15)
                {
                    if ($line[8] =~ m/autosomal recessive/i)
                    {
                        print OUT "$_\n";
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
    else
    {
        next;
    }
}