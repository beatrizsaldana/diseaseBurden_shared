#!/usr/bin/perl

### script to append all snpFrequency_singlePop files into one file

use strict;
use warnings;

my $fileList = $ARGV[0]; #list of files with paths of the results of snpFrequency_singlePop.pl
my $outfile = $ARGV[1];

#variable declaration
my @filenames;
my @populations;
my @frequencies;
my @chr;
my @pos;
my @rsid;
my @ref;
my @alt;
my @dis;

#store the name of each population file in an array
open(FILELIST, $fileList) or die "Could not open $fileList\n";
while (<FILELIST>)
{
    chomp $_; #remove end line symbol
    push @filenames, $_; #name array of filenames (one file per array element)
}

my $number_of_files = scalar @filenames; #store the number of files in list

open(FILE0, $filenames[0]) or die "Could not open $filenames[0]\n";
my $temp = <FILE0>;
while (<FILE0>)
{
    chomp $_; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return just in case
    my @line = split (/\t/,$_); #split line

    push @chr, $line[0];
    push @pos, $line[1];
    push @rsid, $line[2];
    push @ref, $line[3];
    push @alt, $line[4];
    push @dis, $line[5];
}

my $length_of_file = scalar @dis;

for (my $i = 0; $i < $number_of_files; $i++)
{
	for (my $j = 0; $j < $length_of_file; $j++)
	{
		$frequencies[$i][$j] = 0;
	}
}

for (my $i = 0; $i < $number_of_files; $i++)
{
	my $variant_count = 0;
	open(FILE1, $filenames[$i]) or die "Could not open $filenames[0]\n";
	while (<FILE1>)
	{
	    $_ =~ s/\n//g; #remove end line symbol
	    $_ =~ s/\r//g; #remove carriage return just in case
	    my @line = split (/\t/,$_); #split line

	    if ($_ !~ m/^[0-9]/)
	    {
	    	push @populations, $line[6];
	    }
	    else
	    {
	    	$frequencies[$i][$variant_count] = $line[6];
	    	$variant_count+=1
	    }
	}
}

open(OUT, "+>", $outfile);

print OUT "CHROMOSOME\tPOSITION\tRSID\tREF\tALT\tDISEASE";

for (my $i = 0; $i < $number_of_files; $i++)
{
	print OUT "\t$populations[$i]";
}

for (my $j = 0; $j < $length_of_file; $j++)
{
    print OUT "\n$chr[$j]\t$pos[$j]\t$rsid[$j]\t$ref[$j]\t$alt[$j]\t$dis[$j]";
    for (my $i = 0; $i < $number_of_files; $i++)
    {
        print OUT "\t$frequencies[$i][$j]";
    }
}
