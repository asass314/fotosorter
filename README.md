** sortdigicam.pl copies fotos taken at the same day to a folder named by the day**


The Perl program "sortdigicam.pl" opens a directory and reads all file names into a list.
It runs through the list and reads the creation date of the JPG/THM/MOV file and sorts them
to a directory in the form of yyyy_mm_dd. If the directory does not exist the scrip will create one.
The script does not change the orgininal files.

Prerequisites:

The perl modul  "Image::ExifTool" from CPAN from Phil Harvey  is required.
Install the modul with
    perl -MCPAN -e 'install Image::ExifTool'


Usage:
perl sortdigicam.pl readDirectory writeDirectory
perl sortdigicam.pl readDirectory 


=======================================================================================================

** sortdigicamVer22.pl copies fotos to a folder e.g. output and adds the date to the foto name **


Prerequisites:

The perl modul  "Image::ExifTool" from CPAN from Phil Harvey  is required.
Install the modul with
    perl -MCPAN -e 'install Image::ExifTool'

Usage:

easiest way: 

Got the directory with your fotos and run:  perl sortdigicamVer22.pl

Or

perl sortdigicam.pl readDirectory writeDirectory
perl sortdigicam.pl readDirectory 

Samples:
1)takes the current directory for input / output perl sortdigicam.pl   
2) with two different input / output directories
perl sortdigicamVer22.pl /home/andre/fotos /home/andre/newfotos  
3) with a directory for input / output
perl sortdigicam.pl /home/andre/fotos

