#!/usr/bin/perl

# A script to parse kinetic data produced by the plate reader (VersaMax microplate reader, Molecular Devices) at Coughlin lab.
# The output data structure is not complicated, but almost impossible to extract data manually.
# What the program does is to collect the absorbance value correspondig to each well for each timesteps and reorder it in a table

# Usage:
# $./Kinetic_parser.pl Infile    >Outfile

# (c) Daniel Suveges
    # Lifetime support guaranteed! :)
    # if having problems with the script, please send input file and script to: suvi.dani@gmail.com

# v 3.0 2014.03.31
    # Complete redesign
    # Finds out if the file is saved in a plate or time format
    # Supports both saving options
    # Reading the data is separated from the parsing itself
    # Writing the output is separated into a specific subroutine
    # Multiple experiments are supported only if the time setting is not changed

# v 2.5 2013.06.28
    # An error is fixed: real labeling of the wells.
    # Deals with multiple experiments!!!
    # Time format is in minutes with decimal values instead of the min:sec format

# v 2.0 2011.10.04
    # Trained to get all possible 96 well data, but returns only those that actually filled
    # Cleaning input data is not required

# v 1.0 2011.09.30
    # Very primitive form, but works anyway


our $version    = "3.0";

use strict;
use warnings;


# Reading files line by line
my @lines = ();
foreach (<>){
    # A line can be separeted by \r or \n
    push(@lines,split(/[\r\n+]/,$_));
}

my @DataRows    = ();
my $FormatType  = "TimeFormat";
foreach my $line (@lines){

    # Find out format type:
    if ($line =~ /\s+(\S+)Format/) {
        $FormatType = $1;
        print STDERR "Data was saved in $FormatType Format. Processed accordingly.\n";
    }

    # collect data rows, lines, that starts with whitespaces or numbers
    if ($line =~ /^[\s\d+T]/) {
        push (@DataRows, $line);
    }
}


# Parsing datafile according to the Format
my $OrderedData = "";
if ($FormatType eq "Plate") {
    $OrderedData = &Plate(@DataRows)
}
elsif ($FormatType eq "Time"){
    $OrderedData = &Time(@DataRows)
}

# Printing the ordered data to the standard output
&PrintData($OrderedData);

sub Time {
    my @lines = @_;
    my %returnhash = ();

    my $firstline = shift (@lines);
    my @firstfields = split("\t", $firstline);

    foreach my $line (@lines){
        my @fields = split ("\t", $line);

        push(@{$returnhash{"Time"}}, $fields[0]); # The time is the first element of the row

        # Walking along the line :)
        for (my $i = 2; $i < scalar (@fields); $i ++){
            if ($fields[$i]) {
                my $wellID = $firstfields[$i];
                push(@{$returnhash{$wellID}}, $fields[$i])
            }

        }
    }

    return \%returnhash
}

sub Plate {
    my @lines       = @_;
    shift(@lines);        # Get rid of the first row (just labels, we don't need that).
    my $time        = ""; # Keep track of the time, as not all line has info about it.

    my @Letter      = qw(A B C D E F G H); # Rows are labelled with letters from A to H
    my $Well_Letter = "";  # the actual letter of a given well
    my $linecounter = "0"; # Linecounter keeps track which row we are on the plate (A-H)


    my %returnhash  = (); # This has will contain all the data in an organized format.

    # Processing all lines
    foreach my $line (@lines){
        my @fields      = split(/\t/, $line);

        # The time value is only once per plate is displayed that is the first row (A)
        if ($fields[0]) {
            $time = $fields[0];
            push(@{$returnhash{"Time"}},$time);
            $linecounter = 0;
            $Well_Letter = $Letter[$linecounter];
        }

        # It it is not the first row of the plate (from B to H)
        else {
            $linecounter ++;
            $Well_Letter = $Letter[$linecounter];
        }

        # Once we know which row we are at, we can fill the hash with data
        for ( my $i = 2; $i < scalar(@fields); $i++){
            # Defining the well coordinate
            if ($fields[$i]) {
                my $column = $i - 1;
                my $Coordinate = $Well_Letter.$column;
                push(@{$returnhash{$Coordinate}}, $fields[$i]);
            }
        }
    }

    return (\%returnhash);
}

# The data structure is the same of both method, so a common printing function is used
# Data structure:
    # Hash = (
    #    "time" => [t1, t2, t3 ... tn];
    #    "well_1" => [abs1, abs2, abs3 ... absn],
    #    ...
    #    "well_n" => [abs1, abs2, abs3 ... absn],
    #)
sub PrintData {
    my %HashData = %{$_[0]};

    # We separate the time values from the absorbances
    my @time_row = @{$HashData{"Time"}};
    delete $HashData{"Time"};

    # Generating a short report:
    print STDERR "Following wells were read: ", join(",", sort keys %HashData), "\n";
    print STDERR "Last timepoint: $time_row[-1]\n";
    print STDERR "Number of timepoints: ", scalar (@time_row), "\n";

    # Writing the first row (header) of the output
    print "Time";
    foreach my $WellID (sort keys %HashData){
        print ",$WellID";
    }
    print "\n";

    # Reading the data
    for (my $i = 0; $i < scalar(@time_row); $i ++){
        print "$time_row[$i]";
        foreach my $WellID (sort keys %HashData){
            print ",${$HashData{$WellID}}[$i]";
        }
        print "\n";
    }
}
