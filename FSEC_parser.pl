#!/usr/bin/perl

# This script was written to organize the exported chromatographyc traces generated by the Shimadzu RX-10AXL Fluorescence detector

# Function:
   # Opens all files with .txt extension in the working directory (one experiment may generated 10-50 traces all saved in individual files)
   # The program collects data from the first channel only - that has the GFP fluorescence
   # the GFP fluorescence is organized into columns named after the input ascii file.
   # The first coumn is the elution time (in minutes)
   # As the dataset is usually extremely dense, there is an option to restrict sampled data.
   # the data restriction can be set by the -p switch: setting -p to 2 means every second points will be kept
   # the default value of the restriction is -p 1 meaning it keeps all datapoints.

# usage:
      # $>.FSEC_process_v2.1.pl -p [points to keep] -o [OUTPUT file]

my $version = 'v.2.1'; # last modified 07.03.2013
      # Code optimization
      # User can set the name of the output file, by default, the name will be "FSEC_OUTFILE.csv"
      # When specifying the outputfile, do not add extension! It will be automaticly .csv!
      # .txt removed from the output column headers

# version v.2.0 05.21.2013
      # Minor code optimization
      # Code more robust

# version v.1.5 01.13.2012
      # Instead writing out many files, data conbined into one large table
      # The number of points we want to keep can be adjusted with the -p switch

# version v.0.1 01.13.2012
      # Batch file conversion - deals with all txt files in the working directory
      # Outputfile is named after the ascii file, with the csv extension.

use warnings;
use strict;
use Getopt::Std;

our ($opt_p, $opt_o) = "";
getopt('p:o:');

print "program version:\t $version\n";

# By default we keep all points, but if -p is specified the keep_point variable will change
our $keep_point = "1";
if ( $opt_p ) {
   $opt_p =~ s/\s//g;
   $keep_point = $opt_p if $opt_p =~ /[0-9]+/;
}
print "Program keeps every:\t $keep_point points\n";

# By default the outputfile name will be FSEC_OUTFILE
our $outfilename = "FSEC_OUTFILE";
if ( $opt_o ) {
   $opt_o =~ s/\s//g;
   $outfilename = $opt_o;
}
print "Output file name:\t $outfilename.csv\n";

# Read working directory, get list of files, gather files with the .txt extension
my $dir         = ".";
my @filelist    = ();

opendir (DIR, $dir) or die$!;
while (my $file = readdir(DIR)){

    # The second criteria is avoid output files of previous runs, from being procesed as input files
    if ($file =~ /\.txt$/){
        unshift (@filelist, $file);
    }
}
closedir (DIR);

print "txt files in the folder: ", scalar(@filelist),"\n\n\n";
# Open output file
open (OUTFILE, ">", "$outfilename.csv") or die print "Output file could not be opened!!\n";

# Main loop, called for each file with the requested extension
our %fluorescence_values = ();

foreach my $file (@filelist){
    print "Processing: $file\n";
    &files($file);
    $file =~ s/\s/_/g;
}


print OUTFILE "time,";
foreach my $file (@filelist){
    print OUTFILE substr($file,0,-4),","; # Writes filename as column header, except the extension is removed
}
print OUTFILE "\n";

foreach my $time (sort {$a <=> $b} keys %fluorescence_values ){
    print OUTFILE "$time,";
    print OUTFILE join (",", @{$fluorescence_values{$time}});
    print OUTFILE "\n";
}
close OUTFILE;


sub files {
    my $filename = $_[0];
    open (INFILE, "<", "$filename");
    my $i = "0";

    foreach my $line (<INFILE>){

        # In the regexp, we have to deal with the '-' sign of the negative emissions. Can cause trouble.
         if ($line =~ /^([0-9\.]+)\s+([0-9\-\.]+)\s+[\n\r]/){
            $i++;
            # applying filter:
            if ($i/$keep_point == int($i/$keep_point)){
                push(@{$fluorescence_values{$1}},$2);
            }
        }

        # As we reach this line we have to stop data collection, as that belongs to the other channel!!
        elsif ($line =~ /LC Status Trace\(Pump A Pressure\)/) {
           $i = "0";
           return
        }
    }
    close INFILE;
}
