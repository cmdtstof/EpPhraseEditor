#!/usr/bin/perl

package Utili::FileTools;

use warnings;
use strict;

#use Data::Dumper;
use File::Basename;


sub getFileListFromPattern {
#searchDir inkl. / on end!
	my ($searchDir, $filePattern) = @_;
	my $pathFilePattern = $searchDir . $filePattern;
	
	opendir my $dir,  $searchDir or die "Cannot open directory: $!";
	my @files = glob( $pathFilePattern );
	closedir $dir;
	
#	print Dumper \@files;

	return @files;
}

sub getPathFilenamePref {
#returns path/filename without extension
	my ($pathFilename) = @_;

	(my $without_extension = $pathFilename) =~ s/\.[^.]+$//;
#print Dumper $without_extension;
	return $without_extension;
 	
}

sub getFilenameSuffix {
	my ($filename) = @_;
	return fileparse($filename);
	
	
}


	
sub createDir {
	my ($dir) = @_;
	
	unless(-d $dir) {
		mkdir $dir;
	}	
	
	return;
}

sub delFile {
	my ($file) = @_;
	unlink $file;
	return;
	
}



1;