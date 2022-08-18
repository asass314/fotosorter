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
#version 1.2.1
#Date 20141025
#Description:
#New digital cameras using mp4 format like Android OS 
#
#version 2.0
#Date 20141026
#Description:
#New design now called sortdigicamVer2.pl
#
#How it works:
#The Perl program "sortdigicamVer2.pl" opens a directory and reads all file names into a list.
#It runs through the list and reads the creation date of the JPG/THM/MOV/MP4 files and copies them
#to the write directory and changes their names to the "created data". 
#The script has been tested with Canon Ixus 40 and 220HS and Android Galaxy S5.
#The script writes also an error.log to the write directory.
#
#
#version 2.1
#Date 20141027
#Description: new file name just adds the created date at front of the old file name
#
#version 2.2
#Description: replace ":" by "_" in filenames as Windows does not accept ":"
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
use File::Path;
use Image::ExifTool;

$readDirectory=$ARGV[0];
$writeDirectory=$ARGV[1];


#Subroutine to create a write directory:
sub create_writedir{
  if( !-d $writeDirectory){
    mkdir $writeDirectory  or die "Failed to create write diectory: $writeDirectory"; 
    print ("Write directory: ",  $writeDirectory, " has been created!\n");
   }
}

#Subroutine to copy files
sub copy_file{
   my ($oldFileName, $newFileName)= @_;
   #if no file with the new name exists copy file to the new file name 
	 if (! (-e $newFileName) ) { 
             print ("Copy: ",$oldFileName , " to: ",$newFileName, "\n"); 
             copy($oldFileName,$newFileName); 
           }
            else { print ("File with name: ", $newFileName, " exists! \n");
                   print ("Foto was taken at same time\n");
                   print ("Check file: ", $oldFileName, "\n");
                   print ("Copy: ",$oldFileName , " to: ",$newFileName."tocheck", "\n"); 
                   print ("--------------------------------------------------------------\n");
                   #write same error message to error.log
                   my $errorlog = $writeDirectory."error.log";
                   open(my $FH, '>>', $errorlog) or die "Could not open file '$errorlog' $!";
                   print $FH ("File with name: ", $newFileName, " exists! \n");
                   print $FH ("Check file: ", $oldFileName, "\n");
                   print $FH ("Copy: ",$oldFileName , " to: ",$newFileName."tocheck", "\n");
                   print $FH ("--------------------------------------------------------------\n");
                   copy($oldFileName,$newFileName."tocheck");
                  }
}



print("\nThis Perl script searchs for fotos and videos and copy them to a write directory. \n"); 
print("The script re-names the fotos and videos to their created date\n");
print("Fotos with endings: .jpg/.JPG/.jpeg/.JPEG \n");
print("AVI videos .avi/.AVI  with a corresponding .thm/.THM files\n");
print("QuickTime videos .mov/.MOV\n");
print("This script works very well for my fotos and videos taken with a Canon Ixus 40 and Ixus220 and Android Galaxy S5 \n");
print("------------------------------------------------------------------------------------------------------------------------\n\n");
print("-------------------------------------Start------------------------------------------------------------------------------\n\n");

#Determine the input directory are and the ouput directory
if((-d $readDirectory) &&(-d $writeDirectory)){
    print ("Read fotos from: " , $readDirectory, "\n");
    print ("Write fotos to:  " , $writeDirectory, "\n");
        
    }elsif(-d $readDirectory){
      print ("No write directory specified or does not exist!\n");
      print ("Read fotos from: " , $readDirectory, "\n");
      print ("Write fotos to: ", $readDirectory."output/", "\n");
      $writeDirectory = $readDirectory."output/";
      create_writedir();
      }else{
           $readDirectory="./";
           $writeDirectory = $readDirectory."output/";
           print ("No read and write directory specified or do not exist!\n");
           print ("Read fotos from current directory: " , $readDirectory, "\n");
           print ("Write fotos to: ", $readDirectory."output/", "\n");
           create_writedir();
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
	 $createDate = $exif->GetValue('CreateDate'); #taken date of the foto
         $createDate =~  s/ /_H/g ;  #substitute " " by "_"
         $createDate =~  s/:/_/g ;  #substitute ":" by "_"
         $newFileName = $createDate."_".$file; #create new file name add date before file name
         #call copy subroutine 
         copy_file($readDirectory.$file,$writeDirectory.$newFileName)
      }



#MP4-Files
#Check file names for mp4/MP4/ at the end
#print "\n\n";
if  ( ($file =~ m/mp4$/i))
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $createDate = $exif->GetValue('CreateDate'); #taken date of the mp4
         $createDate =~  s/ /_H/g ;  #substitute " " by "_"
         $createDate =~  s/:/_/g ;  #substitute ":" by "_"
         $newFileName = $createDate."_".$file; #create new file name
         #call copy subroutine 
         copy_file($readDirectory.$file,$writeDirectory.$newFileName)
      }



#QuickTime MOV files
#Check file name for mov/MOV at the end
if  ( ($file =~ m/mov$/i) )
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $createDate = $exif->GetValue('CreateDate'); #taken date of the mov video
         $createDate =~  s/ /_H/g ;  #substitute " " by "_"
         $createDate =~  s/:/_/g ;  #substitute ":" by "_"
         $newFileName = $createDate."_".$file; #create new file name
         #call copy subroutine 
         copy_file($readDirectory.$file,$writeDirectory.$newFileName)
	 
      }

#AVI Video format plus THM 
#check for THM files which keep the info for the corresponding AVI files
#sort them 
if  ( $file =~ m/THM$/i)
     {#print $file,"\t\t";
	 $exif->ExtractInfo($file);    
	 $createDate = $exif->GetValue('CreateDate'); #taken date of the THM and AVI
         $createDate =~  s/ /_H/g ;  #substitute " " by "_"
         $newFileName = $createDate."_".$file; #create new file name
         #call copy subroutine 
         copy_file($readDirectory.$file,$writeDirectory.$newFileName); #copies the THM file
	 
	 #substitute the ending "THM" by "AVI", the name of the THM and AVI file is the same
	 $file =~  s/THM/AVI/g ;  
	 $newFileName = $createDate."_".$file; #create new file name
	 #call copy subroutine 
         copy_file($readDirectory.$file,$writeDirectory.$newFileName); #copies the AVI file
     }    

}

