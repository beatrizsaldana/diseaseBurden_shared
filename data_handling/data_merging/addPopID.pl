#!/usr/bin/perl

## scirpt to add pop ID to something

use strict;
use warnings;
use Data::Dumper;

#commandLine arguments
my $infile = $ARGV[0]; # list of file
my $sampleID_popID = $ARGV[1];
my $outfile = $ARGV[2]; # outfile

#global variables
my @popID;
my @sampleID;
my @infile_header;
my @infile_line;

#open outfile
open(OUT, "+>", $outfile);

#open infile
open(FILE, $infile) or die "Could not open $infile\n";
while (<FILE>)
{
    #get rid of end line symbols
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    if ($_ =~ m/^#/)
    {
    	@infile_header = split (/\t/,$_);
    	next;
    }
    else
    {
    	push @infile_line, $_;
    }
}

#open sampleID_popID file
open(FILE1, $sampleID_popID) or die "Could not open $sampleID_popID\n";
while (<FILE1>)
{
	#get rid of end line symbols
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return

    if ($_ =~ m/^#/)
    {
    	print OUT $_;
    	for (my $i = 0; $i < scalar @infile_header-1; $i++)
    	{
    		print OUT "\t$infile_header[$i+1]";
    	}
    	
    	next;
    }
    else
    {
		#split line into array called 'line'
	    my @line = split (/\t/,$_);

	    for (my $i = 0; $i < scalar @infile_line; $i++)
	    {
	    	my @infile_split_line = split (/\t/,$infile_line[$i]);

	    	if ($line[0] eq $infile_split_line[0])
	    	{
	    		print OUT "\n$line[0]\t$line[1]";
	    		for (my $j = 1; $j < scalar @infile_split_line - 1; $j++)
		    	{
		    		print OUT "\t$infile_split_line[$i]";
		    	}
	    	}
	    	else
	    	{
	    		next;
	    	}
	    }
    }
}