#Author Andre Sass
#Version 1.2
#Initial version  
#Date 20100928
#Description:
#All JPG files keep information like their creation date. This information can be read out.
#In contrast to JPG files AVI video format is old and does not contain inforamtion like the 
#date. To overcomes this restriction AVI files come with THM files - Thumbnails. 
#Therefore AVI files can just be sorted with their thumbnails. Many digital cameras save
#videos in avi format with thm files like my Canon Ixus 40
#
#version 1.2
#Date 20120125
#Description:
#New digital cameras using the QuickTime format .mov for videos.
#This script will also copy .mov these files.
#
#
#
#How it works:
#The Perl program "sortdigicam.pl" opens a directory and reads all file names into a list.
#It runs through the list and reads the creation date of the JPG/THM/MOV file and sorts them
#to a directory in the form of yyyy_mm_dd. If the directory does not exist the scrip will create one.
#The script does not change the orgininal files.
#The script has been tested with Canon Ixus 40 and 220HS
#
#Prerequisites
#
#The perl modul  "Image::ExifTool" from CPAN from Phil Harvey  is required.
#Install the modul with
#    perl -MCPAN -e 'install Image::ExifTool'
#
#
#Usage:
#perl sortdigicam.pl readDirectory writeDirectory
#perl sortdigicam.pl readDirectory 
#
#
#Samples:
#1)takes the current directory for input / output
#perl sortdigicam.pl   
#2) with two different input / output directories
#perl sortdigicam.pl /home/andre/fotos /home/andre/newfotos  
#3) with a directory for input / output
#perl sortdigicam.pl /home/andre/fotos
#


#!/usr/bin/perl -w

use IO::File;
use File::Copy;
use Image::ExifTool;

$readDirectory=$ARGV[0];
$writeDirectory=$ARGV[1];




print("\nThis Perl script will search for fotos with .jpg/.JPG/.jpeg/.JPEG endings \n");
print("AVI videos .avi/.AVI  with a corresponding .thm/.THM files\n");
print("and QuickTime videos .mov/.MOV endings\n");
print("it copies them to a directory named after their creating date yyyy_mm_dd.\n");   
print("This script works very well for my fotos and videos taken with a Canon Ixus 40 and Ixus220 \n\n");


#Determine the input directory are and the ouput directory
if((-d $readDirectory) &&(-d $writeDirectory)){
    print ("Read fotos from: " , $readDirectory, "\n");
    print ("Write fotos to:  " , $writeDirectory, "\n");
    }elsif(-d $readDirectory){
      print ("No write directory specified or does not exist\n");
      print ("Read from and write to: ", $readDirectory, "\n");
      $writeDirectory = $readDirectory;
      }else{
           $readDirectory="./";
           $writeDirectory = $readDirectory;
           print ("No read and write directory specified\n");
           print ("Use current directory ",$readDirectory, " to read and write\n");
           }

#open the directory and read all file names
opendir (DIR, "$readDirectory"); 
my @allFiles = readdir DIR;
closedir DIR;


#create an ExifTool object
$exif=new Image::ExifTool;

#sort for jpg files
foreach $file (@allFiles) {

#JPG-Files
#Check file names for jpg/jpeg/JPG/JPEG at the end
#print "\n\n";
if  ( ($file =~ m/jpg$/i) || ($file =~ m/jpeg$/i) )
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $date = $exif->GetValue('CreateDate'); #taken date of the foto

        #modify the data to a format of yyyy_mm_dd	
	$date =~  s/:/_/g ;  #substitute ":" by "_"
	 if ($date =~  /^.{10}/ ) #variable  $& holds the matched first 10 char
	     {$dirname = $&;      #dirname is the date in form of yyyy_mm_dd
		 #print $dirname , "\n";    
		     } 
         $dirname = $writeDirectory.$dirname; #concat string writeDirectory with string dirname to create absolute path
	
	#if no directory with the dirname exists create one 
	 if (! (-d $dirname) ) { 
             print "create ", $dirname, "\n";
             	mkdir  $dirname;
           }
	
	 print ("copy ", $file, " to ",  $dirname, "\n");
	 copy($file, $dirname); 

         #Set directory back 
	 $dirname=""; 
	 
      }

#QuickTime MOV files
#Check file name for mov/MOV at the end

if  ( ($file =~ m/mov$/i) )
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $date = $exif->GetValue('CreateDate'); #taken date of the foto

        #modify the data to a format of yyyy_mm_dd	
	$date =~  s/:/_/g ;  #substitute ":" by "_"
	 if ($date =~  /^.{10}/ ) #variable  $& holds the matched first 10 char
	     {$dirname = $&;      #dirname is the date in form of yyyy_mm_dd
		 #print $dirname , "\n";    
		     } 
         $dirname = $writeDirectory.$dirname; #concat string writeDirectory with string dirname to create absolute path
	
	#if no directory with the dirname exists create one 
	 if (! (-d $dirname) ) { 
             print "create ", $dirname, "\n";
             	mkdir  $dirname;
           }
	
	 print ("copy ", $file, " to ",  $dirname, "\n");
	 copy($file, $dirname); 

         #Set directory back 
	 $dirname=""; 
	 
      }

#AVI Video format plus THM 
#check for THM files which keep the info for the corresponding AVI files
#sort them 
if  ( $file =~ m/THM$/i)
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $date = $exif->GetValue('CreateDate'); #taken date of the THM and AVI
	
	$date =~  s/:/_/g ;  #substitute ":" by "_"
	 if ($date =~  /^.{10}/ ) #variable  $& holds the matched first 10 char
	     {$dirname = $&;
		 #print $dirname , "\n";    
		     } 

	$dirname = $writeDirectory.$dirname; #concat string writeDirectory with string dirname to create absolute path

	#if no directory with the dirname exists create one 
	 if (! (-d $dirname) ) {
             print "create ", $dirname, "\n";
             	mkdir  $dirname;
           }
	 
	 print "copy ", $file, " to ",  $dirname, "\n"; 
	 copy($file, $dirname);  #copies the THM file
	 $file =~  s/THM/AVI/g ;  #substitute "THM" by "AVI"
	 
	 print "copy ", $file, " to ",  $dirname, "\n"; 
	 copy($file, $dirname);  #copies the AVI file

         #Set directory back 
	 $dirname=""; 
      }    

}

