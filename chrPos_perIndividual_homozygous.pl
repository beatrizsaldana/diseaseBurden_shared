#!/usr/bin/perl

### This script will print out a list of all the HGMD variants in homozygous form each person has in their genome


#############################################################################################################

use strict;
use warnings;

#files
my $vcf_inputFile = $ARGV[0]; #input VCF file
my $hgmd_inputFile = $ARGV[1]; #hgmd input file (clean)
my $outfile = $ARGV[2]; #output file

#variables
my @samples; #array that contains list of chr:pos
my @sampleIDs; #array of the IDs of the samples
my $sampleArrayLength; #number of people in population
my @hgmd_chr;
my @hgmd_pos;
my @hgmd_ref;
my @hgmd_alt;

my $linecount = 0;

open(HGMD, $hgmd_inputFile) or die "Could not open $hgmd_inputFile\n";
while (<HGMD>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line by tabs

    $line[0] =~ s/chr//g; #remove the 'chr' from the chromosome column

    push @hgmd_chr, $line[0]; #store chromosome number
    push @hgmd_pos, $line[1]; #store position
    push @hgmd_ref, $line[3]; #store ref alele
    push @hgmd_alt, $line[4]; #store alt alele
}

my $hgmd_length = scalar @hgmd_pos; #get length of hgmd_* arrays


open(OUT, "+>", $outfile); #open output file to write to

#open VCF files
open(VCF, $vcf_inputFile) or die "Could not open $vcf_inputFile\n";
while (<VCF>)
{
    my $linecount+=1; #count the lines in the vcf file
    my $checker = 0; #the checker will indicate the allele the individual has (0 = ref, 1 = first alt, 2 = second alt, etc)
    my $chrpos = 0;

    $_ =~ s/\n//g;; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_);

    if ($_ =~ m/^\##/)
    {
        next; #skip file headders
    }
    elsif ($_ =~ m/^#CHROM/)
    {
        push @sampleIDs, @line; # store main headder in array
        splice @sampleIDs, 0, 9; # remove the non-population entries of the headder
        $sampleArrayLength = scalar @sampleIDs; # store number of individuals in population/vcf

        #initialize array of samples (individuals)
        for (my $i = 0; $i < $sampleArrayLength; $i++)
        {
            $samples[$i] = 'none';
        }
    }
    else
    {
        #for every entrie in the VCF file, search HGMD for position match (chromosome, then position, then allele)
        for (my $i = 0; $i < $hgmd_length; $i++)
        {
            if ($hgmd_chr[$i] < $line[0])
            {
                next; #keep looking
            }
            elsif ($hgmd_chr[$i] > $line[0])
            {
                last; #end loop, you have gone too far
            }
            elsif ($hgmd_chr[$i] eq $line[0])
            {
                #if the chromosome matches, look for matching position
                if ($hgmd_pos[$i] < $line[1])
                {
                    next; #keep looking
                }
                elsif ($hgmd_pos[$i] > $line[1])
                {
                    last; #end loop, you have gone too far
                } 
                if ($hgmd_pos[$i] == $line[1])
                {
                    #if chromosome and position match, look at 'alt' allele
                    if ($line[4] =~ m/,/)
                    {
                        #if there is more than one 'alt' allele, parse the 'alt' alleles into an array
                        my @altblock = split (/,/,$line[4]); #split alt alleles into array
                        my $altCount = scalar @altblock; #store number of alt alleles 

                        #check if the alt aleles match entry in hgmd
                        for (my $j = 0; $j < $altCount; $j++)
                        {
                            if ($altblock[$j] eq $hgmd_alt[$i])
                            {
                                $checker = 1;
                                $chrpos = join (':', $hgmd_chr[$i], $hgmd_pos[$i]);
                            }
                        }

                        last;
                    }
                    elsif ($line[4] eq $hgmd_alt[$i])
                    {
                        #if there is only one alt allele and it is the same as the alt allele in the hgmd, make the checker = 1
                        $checker = 1;
                        $chrpos = join (':', $hgmd_chr[$i], $hgmd_pos[$i]);
                        last;
                    }
                    
                    if ($hgmd_alt[$i] eq $line[3])
                    {
                        #if the vcf reference allele is equal to the hgmd alternative allele, make the checker = -1 so that all 0 in vcf are counted as present
                        $checker = -1;
                        $chrpos = join (':', $hgmd_chr[$i], $hgmd_pos[$i]);
                        last;
                    }
                    
                    if ($checker != 0)
                    {
                        #if the there has been a match in the hgmd, stop looking
                        last;
                    }
                }
                else
                {
                    next;
                }
            }
        }

        #if the vcf variant was present in the hgmd:
        if ($checker > 0)
        { 
            for (my $i = 0; $i < $sampleArrayLength; $i++)
            { 
                my @block = split (//,$line[$i+9]); #split the X|X thing in the vcf into array
                my $x = $block[0]; #store the first part in a variable called x
                my $y = $block[2]; #store the second part in a variable called y

                if ($x == $checker && $y == $checker)
                {
                    $samples[$i] .= "\t$chrpos";
                }
            }
        }
        elsif ($checker == -1)
        {
            for (my $i = 0; $i < $sampleArrayLength; $i++)
            {
                my @block = split (//,$line[$i+9]);
        		my $x = $block[0];
        		my $y = $block[2];

                if ($x == 0 && $y == 0)
                {
                    $samples[$i] .= "\t$chrpos";
                }
            }
        }
        elsif ($checker == 0)
        {
            next;
        }
    }
}

#open output file in order to write to it
open(OUT, "+>", $outfile);

#write to file
print OUT "###INPUT FILE NAME: $vcf_inputFile";
print OUT "\n";
print OUT "\n##This file contains the sample ID of the individual and a list of the HGMD variants in the individual's genome.";
print OUT "\n##Variants listed were those found in homozygous form.";
print OUT "\n";
print OUT "\n#SAMPLE_ID\tVARIANTS";

#print out the totals per person
for (my $i = 0; $i < $sampleArrayLength; $i++)
{
    print OUT "\n$sampleIDs[$i]\t$samples[$i]";
}
