#!/usr/bin/perl

# This program was written to parse exported FPLC files.
# One FPLC run can contain multiple runs, where the first injection starts the timer
# Then the timer goes on util hitting END.
# Upon exporting the trace, the time of all injections are saved in the third column.
# This program creates a list, where the first column is the elution volume
# Subsequent columns are the traces of different injections.

# usage:
    # >FPLC_Parser_v1.1.pl <INFILE> > <OUTFILE>
    # Infile is the exported ASCII format generatd by Unicorn software.
    # Output is a list where the first column is the time (in minutes), the outher columns are the absorbance values of
    # Each injections (in mAU units).

# v 1.1 2013.07.05
    # Code optimization
    # Commenting

# v. 1.0 2012.11.17
    # All functionality is implemented - At first all datapoints are collected,
    # then the serie is brokend down to pieses corresponding each injections.
    # the input and output secification is quite low-end, but works just fine.

##### Comment about the algorytm ##############################################
## It might sounds reasonable to do the splitting on the flight, but that may cause dataloss:
## You can start the next run before finishing the datacollection of the previous run
## This is possible, as you can count on the void volume of the colunms
###############################################################################



use warnings;
use strict;

my @injections  = (); # An array with injection times.
my %trace       = (); # This variable will filled by all values!

foreach (<>){

    # discard header lines
    if ($_ =~ /^\S/){ next }

    # collect injection times. (Carefully, as those lines have absorbance values as well!)
    if ($_ =~ /\s+(\d+\.\d+)\s+([-]*\d+\.\d+)\s+(\d+\.\d+)/){

        # $1 - Time
        # $2 - Absorbance
        # $3 - Time of injections.
        push (@injections, $3);
        $trace{$1} = $2;
    }

    # Collect data points.
    if ($_ =~ /\s+(\d+\.\d+)\s+([-]*\d+\.\d+)/){

        # $1 - Time
        # $2 - Absorbance
        $trace{$1} = $2;
    }

}

# Calculate run length - As injections are started manually, the length can vary.
# To make it sure that all split will contain the sufficient amount of data,
# At first the length of the longest run is collected.
my $runlength = &RunLength(@injections);

# Submit collected data to parser (trace, injections, run length)
&Parse(\@injections,\%trace,$runlength);

# Spliting
sub Parse {

    # Loading variables.
    my @injection   = @{$_[0]};
    my %trace       = %{$_[1]};
    my $runlength   = $_[2];
    my @table       = ();

    # Walking through the trace.
    foreach my $timepoints (sort {$a <=> $b} keys %trace){
        # print "$timepoints\t$trace{$timepoints}\n"
        for ( my $i = "0"; $i < scalar(@injection); $i ++){
            if (($timepoints >= $injections[$i]) and ($timepoints < $injections[$i] + $runlength)){
                push (@{$table[$i]}, $trace{$timepoints});
            }
        }
    }

    my @TimeSteps   = sort {$a <=> $b} keys(%trace);

    for (my $timestep = 0;  $TimeSteps[$timestep] < $runlength; $timestep ++){
        print "$TimeSteps[$timestep]\t";

        for (my $injection = "0"; $injection < scalar(@table); $injection ++){
            if (${$table[$injection]}[$timestep]){
                print "${$table[$injection]}[$timestep]\t";
            }
            else {
                print "\t";
            }
        }

        print "\n";
    }
}

# Calculate the legth of a run
sub RunLength {
    # get list of injections
    my @injections = @_;

    # Calculate time difference between each injection
    my $maxtime = "0";

    for (my $i = "0"; $i < scalar (@injections) - 1; $i++){
        if ($injections[$i+1] - $injections[$i] > $maxtime){
            $maxtime = $injections[$i+1] - $injections[$i];
        }
    }

    # Return with the longest distance.
    return $maxtime;
}

