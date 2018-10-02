#!/usr/bin/perl

### This script will calculate the total number of variants present in an individual, which are also present in the HGMD

### Output file format:

#   | SAMPLE_ID | HETEROZYGOUS | HOMOZYGOUS | TOTAL_HGMD_VARIANTS | TOTAL_TYPED_POSITIONS |
#   |-----------|--------------|------------|---------------------|-----------------------|


# SAMPLE_ID: The ID of the individual in the VCF file
# HETEROZYGOUS: total disease-causing variants present in the individual and the HGMD that are in the homozygous form
#               in other words... total instances of heterozygous-present variants
#               calculation: R|A = +1 , A|R = +1
#                           R = Reference Allele (usually depicted as 0)
#                           A = Alternate Allele (usually depicted as 1)
# HOMOZYGOUS: total disease-causing variants present in the individual and the HGMD that are in the heterozygous form
#             in other words... total instances of homozygous-present variants
#               calculation: A|A = +1
#                           R = Reference Allele (usually depicted as 0)
#                           A = Alternate Allele (usually depicted as 1)
# TOTAL_HGMD_VARIANTS: total number of disease-causing variants present, no matter how they are present
#               calculation: R|A = +1 , A|R = +1 , A|A = +2
#                           R = Reference Allele (usually depicted as 0)
#                           A = Alternate Allele (usually depicted as 1)
# TOTAL_TYPED_POSITIONS: All positions in the VCF file that were typed, per individual
#               calculation: X|X = +2 , X|. = +1 , .|X = +1
#                           X = Anything, except a blank


#############################################################################################################

use strict;
use warnings;

#files
my $vcf_inputFile = $ARGV[0]; #input VCF file
my $hgmd_inputFile = $ARGV[1]; #hgmd input file (clean)
my $outfile = $ARGV[2]; #output file

#variables
my @samples; #multi dimensional array that contains all variant sums per person
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
    my @check_array; #array for when there is more than one alt allele
    my $check_array_length = 0; #variable for when there is more than one alt allele
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
            $samples[$i][0] = 0; #heterozygous
            $samples[$i][1] = 0; #homozygous
            $samples[$i][2] = 0; #total typed positions
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
                                push @check_array, $j+1; #if both alleles are in the hgmd, their numbers will be stored in the array
                            }
                        }

                        $check_array_length = scalar @check_array; #store length of check_array
                        $checker = -2; #mark the checker to know if there was more than 1 alt allele
                        last;
                    }
                    elsif ($line[4] eq $hgmd_alt[$i])
                    {
                        #if there is only one alt allele and it is the same as the alt allele in the hgmd, make the checker = 1
                        $checker = 1;
                        last;
                    }
                    
                    if ($hgmd_alt[$i] eq $line[3])
                    {
                        #if the vcf reference allele is equal to the hgmd alternative allele, make the checker = -1 so that all 0 in vcf are counted as present
                        $checker = -1;
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

        #if the vcf variant was not present in the hgmd, count the typed positions only
        if ($checker == 0)
        {
            #always count the total number of typed positions, even if the allele is not present in the hgmd
            for (my $i = 0; $i < $sampleArrayLength; $i++)
            {
                my @block = split (//,$line[$i+9]); #split the X|X thing in the vcf into array
                my $x = $block[0]; #store the first part in a variable called x
                my $y = $block[2]; #store the second part in a variable called y

                #if the first positon was typed, add 1 to the total typed positions sum
                if ($x =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
                }
                #if the second positon was typed, add 1 to the total typed positions sum
                if ($y =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
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

                #if the first positon was typed, add 1 to the total typed positions sum
                if ($x =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
                }
                #if the second positon was typed, add 1 to the total typed positions sum
                if ($y =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
                }

                if ($x == $checker && $y != $x )
                {
                    $samples[$i][0]+=1; #if only the first position is equal to the checker, add +1 to the heterozygous array
                }
                if ($y == $checker && $y != $x)
                {
                    $samples[$i][0]+=1; #if only the second position is equal to the checker, add +1 to the heterozygous array
                }
                if ($x == $checker && $y == $checker)
                {
                    $samples[$i][1]+=2; #if both the first and second positions are equal to the checker, add +2 to the homozygous array
                }
            }
        }

        #if the vcf reference allele is equal to the hgmd alternative allele, count zeros as ones
        if ($checker == -1)
        {
            for (my $i = 0; $i < $sampleArrayLength; $i++)
            {
        		if ($line[$i+9] =~ /[0-9]\|[0-9]/)
                {
                    $samples[$i][2]+=2;
                }
                my @block = split (//,$line[$i+9]);
        		my $x = $block[0];
        		my $y = $block[2];

                #if the first positon was typed, add 1 to the total typed positions sum
                if ($x =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
                }
                #if the second positon was typed, add 1 to the total typed positions sum
                if ($y =~ /[0-9]/)
                {
                    $samples[$i][2]+=1;
                }
		
                if ($x == 0 && $y != $x)
                {
                    $samples[$i][0]+=1; #if only the first position is zero, add +1 to the heterozygous array
                }
                if ($y == 0 && $y != $x )
                {
                    $samples[$i][0]+=1; #if only the first position is zero, add +1 to the heterozygous array
                }
                if ($x == 0 && $y == 0)
                {
                    $samples[$i][1]+=2; #if both the first and second positions are equal to zero, add +2 to the homozygous array
                }
            }
        }

        #if there was more than 1 alt allele in the vcf
        if ($checker == -2)
        {
            for (my $j = 0; $j < $check_array_length; $j++)
            {
                my $checker = $check_array[$j];
                for (my $i = 0; $i < $sampleArrayLength; $i++)
                { 
                    my @block = split (//,$line[$i+9]); #split the X|X thing in the vcf into array
                    my $x = $block[0]; #store the first part in a variable called x
                    my $y = $block[2]; #store the second part in a variable called y

                    #if the first positon was typed, add 1 to the total typed positions sum
                    if ($x =~ /[0-9]/)
                    {
                        $samples[$i][2]+=1;
                    }
                    #if the second positon was typed, add 1 to the total typed positions sum
                    if ($y =~ /[0-9]/)
                    {
                        $samples[$i][2]+=1;
                    }

                    if ($x == $checker && $y != $x )
                    {
                        $samples[$i][0]+=1; #if only the first position is equal to the checker, add +1 to the heterozygous array
                    }
                    if ($y == $checker && $y != $x)
                    {
                        $samples[$i][0]+=1; #if only the second position is equal to the checker, add +1 to the heterozygous array
                    }
                    if ($x == $checker && $y == $checker)
                    {
                        $samples[$i][1]+=2; #if both the first and second positions are equal to the checker, add +2 to the homozygous array
                    }
                }
            }
        }
    }
}

#open output file in order to write to it
open(OUT, "+>", $outfile);

#write to file
print OUT "###INPUT FILE NAME: $vcf_inputFile";
print OUT "\n##Heterozygous: Total HGMD variants present in heterozygous form";
print OUT "\n##Homozygous: Total HGMD variants present in homozygous form (total instances of homozygosity)";
print OUT "\n#SAMPLE_ID\tHETEROZYGOUS\tHOMOZYGOUS\tTOTAL_HGMD_VARIANTS\tTOTAL_TYPED_POSITIONS";

#print out the totals per person
for (my $i = 0; $i < $sampleArrayLength; $i++)
{
    my $totalHGMD = $samples[$i][0]+$samples[$i][1];
    my $homozygous = $samples[$i][1]/2;
    print OUT "\n$sampleIDs[$i]\t$samples[$i][0]\t$homozygous\t$totalHGMD\t$samples[$i][2]";
}
