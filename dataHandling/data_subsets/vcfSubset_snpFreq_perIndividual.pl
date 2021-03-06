#!/usr/bin/perl

## script to make vcf subset with only disease of the HGMD that are in the Diseases Category of the Ontology

#files
my $vcf_inputFile = $ARGV[0]; #input VCF file
my $snpFreq_input = $ARGV[1]; #subset of the snpFrequency files containing only entries from the Disease and Disease Risk categories in the ontology
my $outfile = $ARGV[2]; #output file

my @snpFreq_chr;
my @snpFreq_pos;
my @snpFreq_ref;
my @snpFreq_alt;


open(SNPFREQ, $snpFreq_input) or die "Could not open $snpFreq_input\n";
while (<SNPFREQ>)
{
    $_ =~ s/\n//g; #remove end line symbol
    $_ =~ s/\r//g; #remove carriage return
    my @line = split (/\t/,$_); #split line by tabs

    push @snpFreq_chr, $line[0]; #store chromosome number
    push @snpFreq_pos, $line[1]; #store position
    push @snpFreq_ref, $line[3]; #store ref alele
    push @snpFreq_alt, $line[4]; #store alt alele
}

my $snpFreqSize = scalar @snpFreq_pos;

open(OUT, "+>", $outfile); #open output file to write to

open(VCF, $vcf_inputFile) or die "Could not open $vcf_inputFile\n";
while (<VCF>)
{
	my $fullThing = $_;
	if ($_ =~ m/^\#/)
    {
        print OUT $_;
    }
    else
    {
	    $_ =~ s/\n//g;; #remove end line symbol
	    $_ =~ s/\r//g; #remove carriage return
	    my @line = split (/\t/,$_);

	    for (my $i = 0; $i < $snpFreqSize; $i++)
	    {
	    	if ($line[0] > $snpFreq_chr[$i])
	    	{
	    		next;
	    	}
	    	elsif ($line[0] < $snpFreq_chr[$i])
	    	{
	    		last;
	    	}
	    	elsif ($line[0] == $snpFreq_chr[$i])
	    	{
	    		if ($line[1] > $snpFreq_pos[$i])
	    		{
	    			next;
	    		}
	    		elsif ($line[1] < $snpFreq_pos[$i])
	    		{
	    			last;
	    		}
	    		elsif ($line[1] == $snpFreq_pos[$i])
	    		{
	    			if ($line[3] eq $snpFreq_ref[$i])
	    			{
	    				if ($line[4] =~ m/,/)
                    	{
	                        #if there is more than one 'alt' allele, parse the 'alt' alleles into an array
	                        my @altblock = split (/,/,$line[4]); #split alt alleles into array
	                        my $altCount = scalar @altblock; #store number of alt alleles 

	                        #check if the alt aleles match entry in hgmd
	                        for (my $j = 0; $j < $altCount; $j++)
	                        {
	                            if ($altblock[$j] eq $snfFreq_alt[$i])
	                            {
	                                print OUT $fullThing;
					last;
				    }
	                        }
                    	}
	    				elsif ($line[4] eq $snpFreq_alt[$i])
	    				{
	    					print OUT $fullThing;
						last;
					}
	    			}
	    		}
	    	}
	    }
    }
}
