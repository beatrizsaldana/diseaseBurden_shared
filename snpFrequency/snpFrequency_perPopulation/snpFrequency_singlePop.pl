#!/usr/bin/perl

### Script to produce a file containing all of the variants (each line is a variant)
### and the frequency of the disease causing alele for designated population
### +1 for homozygous variant of interest 1|1 and +0 for anything else
### problem with skipping diseases because of dual alt aleles has been fixed
### date created: 2018_06_11

use strict;
use warnings;

my $inFile = $ARGV[0];
my $outfile = $ARGV[1];
my $hgmdData = $ARGV[2];

open(OUT, "+>", $outfile);

print OUT "CHROMOSOME\tPOSITION\tRSID\tREF\tALT\tDISEASE\tFREQUENCY";

#variable declaration
my @hgmd_chr;
my @hgmd_pos;
my @hgmd_rsid;
my @hgmd_ref;
my @hgmd_alt;
my @hgmd_dis;
my @chr;
my @pos;
my @rsid;
my @ref;
my @alt;

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
    push @hgmd_rsid, $line[2];
    push @hgmd_ref, $line[3];
    push @hgmd_alt, $line[4];
    push @hgmd_dis, $line[5];
}

my $hgmd_length = scalar @hgmd_pos;
my $variantCounter = 0;
my $number_of_individuals;

open(FILE1, $inFile) or die "Could not open $inFile\n";
while (<FILE1>)
{
    my $checker=0;
    my $frequency = 0;

    if ($_ =~ m/^##/)
    {
        next;
    }

    chomp $_; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return just in case
    my @line = split (/\t/,$_); #split line

    if ($line[0] =~ m/^#CHROM$/)
    {
        $number_of_individuals = scalar @line;
        $number_of_individuals = $number_of_individuals - 9;
        next;
    }
    elsif ($_ =~ m/^[0-9]/)
    {
        push @chr, $line[0];
        push @pos, $line[1];
        push @rsid, $line[2];
        push @ref, $line[3];
        push @alt, $line[4];

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
                                    $frequency = 0;
                                    $checker = $z+1;
                                    
                                    for (my $b = 0; $b < $number_of_individuals; $b++)
                                    { 
                                        my @block = split (//,$line[$b+9]);
                                        my $x = $block[0];
                                        my $y = $block[2];
                                        
                                        if ($x == $checker && $y == $checker)
                                        {
                                            $frequency+=1;
                                        }
                                    }
                                    print OUT "\n$hgmd_chr[$a]\t$hgmd_pos[$a]\t$hgmd_rsid[$a]\t$hgmd_ref[$a]\t$hgmd_alt[$a]\t$hgmd_dis[$a]\t$frequency";
                                }
                                else
                                {
                                    next;
                                }
                            }
                            last;
                        }
                        elsif ($line[4] eq $hgmd_alt[$a])
                        {
                            $frequency = 0;

                            for (my $b = 0; $b < $number_of_individuals; $b++)
                            { 
                                my @block = split (//,$line[$b+9]);
                                my $x = $block[0];
                                my $y = $block[2];
                                
                                if ($x == 1 && $y == 1)
                                {
                                    $frequency+=1; 
                                }
                            }
                            print OUT "\n$hgmd_chr[$a]\t$hgmd_pos[$a]\t$hgmd_rsid[$a]\t$hgmd_ref[$a]\t$hgmd_alt[$a]\t$hgmd_dis[$a]\t$frequency";
                            last;
                        }
                        elsif ($hgmd_alt[$a] eq $line[3])
                        {
                            $frequency = 0;

                            for (my $b = 0; $b < $number_of_individuals; $b++)
                            {
                                my @block = split (//,$line[$b+9]);
                                my $x = $block[0];
                                my $y = $block[2];

                                if ($x == 0 && $y == 0)
                                {
                                    $frequency+=1; 
                                }
                            }
                            print OUT "\n$hgmd_chr[$a]\t$hgmd_pos[$a]\t$hgmd_rsid[$a]\t$hgmd_ref[$a]\t$hgmd_alt[$a]\t$hgmd_dis[$a]\t$frequency";
                            last;
                        }
                    }
                }
            }
        }
    }
    else
    {
        next;
    }
}
