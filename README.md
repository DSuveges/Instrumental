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
