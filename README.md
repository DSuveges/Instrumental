Instrumental
============

Collection of scripts to parse instrumental output to a more user friendly format

__kinetic_parser.pl__ 
* A script to parse kinetic data produced by the plate reader (VersaMax microplate reader, Molecular Devices) at Coughlin lab. The output data structure is not complicated, but almost impossible to extract data manually. 
* The script identifies the well coordinate and collects the absorbance value correspondig to each well for each timesteps and reorder it in a table, where the first column is the time, and the subsequent columns are the time dependent absorbances to one column. The first row is the header.
* Output is a csv file printed onto the standard output. A short report is also generated to the standard error.
* No additional packages is required.
* Sample files representing time and plate formats are also included

Usage: `$kinetic_perser.pl <INFILE> >OUTFILE`

__FSEC_parser.pl__
* This script processes the output of the Shimadzu RX-10AXL Fluorescence detector
* This machine in our lab is connected with an autosampler chromatography system therefore one single experiment can yield tens of different output files.
* The text files are named by the chromatograpy software and are stored in a designated folder.
* This script reads all the text files in a given folder and extracts the fluorescence values.
* The output is a csv file easy to read by most downstream data analysis software (default file name is FSEC_OUTFILE.csv)
* The output file contains a table where the columns are fluorescence data from the text files (headers are from the name of the text files), rows are elution volumes in minutes
* with the -p switch a samplig frequency can be set. 1 - gives all the points, 2 - gives every second point (default is 1).

Usage: `$FSEC_parser.pl -p [points to keep] -o [output filename]`

__FPLC_parser.pl__
* This script processes the chromatographic trace exported by the AKTA system Unicorn software
* Often multiple gelfiltrations are saved into 
* The aim of the program is to split a single trace into pieces corresponding to individual injections.
