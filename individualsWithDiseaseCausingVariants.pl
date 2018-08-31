#!/usr/bin/perl

### Script to produce a file containing all of the variants (each line is a variant)
### and sample ID of each individual that contains the disease causing variant

use strict;
use warnings;

my $input = $ARGV[0]; #vcf file
my $outfile = $ARGV[1];
my $hgmdData = $ARGV[2]; #hgmd database

open(OUT, "+>", $outfile);

print OUT "CHROMOSOME\tPOSITION\tRSID\tREF\tALT";

#variable declaration
my @hgmd_chr;
my @hgmd_pos;
my @hgmd_ref;
my @hgmd_alt;
my @samples;

#get all hgmd data
open(HGMD, $hgmdData) or die "Could not open $hgmdData\n";
while (<HGMD>)
{
    chomp $_; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_);

    $line[0] =~ s/chr//g;

    push @hgmd_chr, $line[0];
    push @hgmd_pos, $line[1];
    push @hgmd_ref, $line[3];
    push @hgmd_alt, $line[4];
}

my $hgmd_length = scalar @hgmd_pos;

my $number_of_individuals;

open(FILE, $input) or die "Could not open $input\n";
while (<FILE>)
{
    my $checker = 0;
    
    if ($_ =~ m/^##/)
    {
        next;
    }

    if ($_ =~ m/^#CHROM/)
    {
        chomp $_; #remove end line symbol
        $_ =~ s/\r//g; #remove carriage return just in case
        @samples = split (/\t/,$_); #split line

        $number_of_individuals = scalar @samples;
        $number_of_individuals = $number_of_individuals - 9;

        splice @samples, 0, 9;

        next;
    }

    chomp $_; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return just in case
    my @line = split (/\t/,$_); #split line

    if ($line[0] =~ m/[0-9]+/)
    {
	 	print OUT "\n$line[0]\t$line[1]\t$line[2]\t$line[3]\t$line[4]\t";

        for (my $a = 0; $a < $hgmd_length; $a++)
	 	{
            if ($hgmd_chr[$a] < $line[0])
            {
                next;
            }
            elsif ($hgmd_chr[$a] > $line[0])
            {
                last;
            }
            elsif ($hgmd_chr[$a] == $line[0])
            {
                if ($hgmd_pos[$a] < $line[1])
                {
                    next;
                }
                elsif ($hgmd_pos[$a] > $line[1])
                {
                    last;
                }
                if ($hgmd_pos[$a] == $line[1])
                {
                    if ($hgmd_ref[$a] eq $line[3])
                    {
                        if ($line[4] =~ m/,/)
                        {
                            my @altblock = split (/,/,$line[4]);
                            my $altCount = scalar @altblock;

                            for (my $z = 0; $z < $altCount; $z++)
                            {
                                if ($altblock[$z] eq $hgmd_alt[$a])
                                {
                                    $checker = $z+1;
                                }
                            }
                            last;
                        }
                        elsif ($line[4] eq $hgmd_alt[$a])
                        {
                            $checker = 1;
                            last;
                        }
                        elsif ($hgmd_alt[$a] eq $line[3])
                        {
                            $checker = -1;
                            last;
                        }
                    }
                }
            }
        }

        if ($checker > 0)
        {
            for (my $b = 0; $b < $number_of_individuals; $b++)
            { 
                my @block = split (//,$line[$b+9]);
                my $x = $block[0];
                my $y = $block[2];
                
                if ($x !~ m/[0-9]/ && $y !~ m/[0-9]/)
                {
                    next;
                }
                elsif ($x == $checker && $y != $x )
                {
                    print OUT "$samples[$b]\t";
                }
                elsif ($y == $checker && $y != $x)
                {
                    print OUT "$samples[$b]\t";
                }
                elsif ($x == $checker && $y == $checker)
                {
                    print OUT "$samples[$b]\t";
                }
            }
        }
        elsif ($checker < 0)
        {
            for (my $b = 0; $b < $number_of_individuals; $b++)
            {
                my @block = split (//,$line[$b+9]);
                my $x = $block[0];
                my $y = $block[2];

                if ($x !~ m/[0-9]/ && $y !~ m/[0-9]/)
                {
                    next;
                }
                elsif ($x != 0 && $y == 0 )
                {
                    print OUT "$samples[$b]\t";
                }
                elsif ($x == 0 && $y != 0 )
                {
                    print OUT "$samples[$b]\t";
                }
                elsif ($x == 0 && $y == 0)
                {
                    print OUT "$samples[$b]\t";
                }
            }
        }
        elsif ($checker==0)
        {
            next;
        }
    }
    else
    {
        next;
    }
}
