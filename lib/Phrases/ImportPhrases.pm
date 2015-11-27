#!/usr/bin/perl
# search for id and ref
#

package Phrases::ImportPhrases;

use Db::EpeDb;

use File::Find;
use String::Util 'trim';
use Utili::Encodings;
use Data::Dumper;
use File::Slurp;



my $phraseStartKey = '<epp:phrase id="';
my $phraseStartKeyEnd = '">';
my $phraseEndKey = '</epp:phrase>';

my $phraseStartKeyLength = length($phraseStartKey);
my $phraseStartKeyEndLength = length($phraseStartKeyEnd);



sub import {
	my ($importDir ) = @_;

# 	my @dir;
# 	push(@dir, $importDir);  
#
#print "importPhrases dirs:";
#print Dumper \@dir;
  
#	find({ wanted => \&process_file, no_chdir => 1 }, @dir);
	find({ wanted => \&process_file, no_chdir => 1 }, $importDir);

#?????
#Can't stat Phrases::ImportPhrases: No such file or directory
# at lib/Phrases/ImportPhrases.pm line 36.

	

	return;
}


sub process_file {
    my $filename = $_;
    if (-f $filename) {

		
		my @arrayOfPhrases;
		 
#		open my $fh, $filename or die "Could not open $filename: $!";

		Utili::LogCmdt::logWrite( ( caller(0) )[3],	"parse phrases from file\t$filename" );		
		

		my $fileContent = read_file( $filename );
#print Dumper $fileContent;
		my $fileLength = length($fileContent);
#print "fileLength=$fileLength\n"; 
		
#		my $count;
#		while ($fileContent =~ /$phraseStartKey/g) { $count++ }
#    print "There are $count startkeys in the string\n";
		
		
		my $pos = 0;
		my @found;
		
		while ($pos < $fileLength) {
			my $index = index($fileContent, $phraseStartKey, $pos);
			if ($index != -1) {
				push (@found, $index);
				$pos = $index + 1;
			} else {
				last;
			}
		}
		
		if (@found) {

			my ($fileId, $language) = Db::EpeDb::getFileId($filename); 			#add in db if not exist
			
			for (my $i = 0; $i < @found; $i++) {
				
				my $lineStart = $found[$i];
				my $lineLength;
				
				if ($found[$i+1]) {
					$lineLength = $found[$i+1] - $lineStart; 
				} else {
					$lineLength = $fileLength - $lineStart;
				}
				 
					
#print "*********filename=$filename, lang=$language, phrase $i on pos=$found[$i]\n";
#print ">>>";
#print substr($fileContent, $lineStart, $lineLength);
#print "<<<";
#print "\n";				
				my $line = substr($fileContent, $lineStart, $lineLength);
    			my %newFields = parsePhraseLineAsHash($line);
    			
    			if ($newFields{'phraseId'} and $newFields{'phrase'}) {
    			
#print "***fileId=$fileId, filename=$filename, lang=$language ";    			
#print "$phraseHash{'phraseId'} = $phraseHash{'phrase'} \n";     			
##print Dumper \%phraseHash;

	    			if (!Db::EpeDb::phraseIdFound($newFields{'phraseId'})) {
						my $phraseIdx = Db::EpeDb::addPhraseId($newFields{'phraseId'}); 	#if phraseId not exist, add it
						Db::EpeDb::addUsedIn($fileId, $phraseIdx);
						Utili::LogCmdt::logWrite( ( caller(0) )[3],	"phraseId added\t$newFields{'phraseId'}" );
					}
    			
    				$newFields{'phrase'} = Utili::Encodings::validatePhrase($newFields{'phrase'});
    				
    				my $oldFields = Db::EpeDb::getPhrasesHashref($newFields{'phraseId'});
    			
					my %updateFields;
					
					if ($$oldFields{$language}) {
						if ($$oldFields{$language} ne $newFields{'phrase'} ){
							$updateFields{$language} = $newFields{'phrase'};
						}
						
					} else {
						$updateFields{$language} = $newFields{'phrase'};
					}

					if (%updateFields) {
						$updateFields{'phraseId'} = $newFields{'phraseId'};

						Db::EpeDb::updatePhrases($newFields{'phraseId'}, %updateFields);
						Utili::LogCmdt::logWrite( ( caller(0) )[3],	"phrases changed\t$newFields{'phraseId'}" );					
					}
    			}
			}
		}		
    }
    return;
}

#sub 

sub parsePhraseLineAsHash {
	my ($line) = @_;

 #	#<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>
#	#0123456789*123456789*123456789*123456789*123456789*123456789*
#	#                16                     39
#	#<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>

# lineLength
# phraseId = epm_fieldname_home_page
# phrase = 
# 1) phraseStartKey = '<epp:phrase id="'
#    phraseStartKeyIndex
#    phraseStartKeyLength
# 2) phraseStartKeyEnd = '">'
#    phraseStartKeyEndIndex
#    phraseStartKeyEndLength
# 3) phraseEndKey = '</epp:phrase>'
# 4) phraseEndKeyIndex
# ) phraseIdIndex
# ) phraseIdLength
# ) phraseIndex
# ) phraseLength
	
	
	
	my %phraseHash;

#print "line=$line\n";

#	if (!$line =~ /^\s*#/) {   		 #if lines starts with # forget it
	#	my $line = '<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>';
		
		my $lineLength = length($line);
		my $phraseStartKeyIndex = index($line, $phraseStartKey);
		if ($phraseStartKeyIndex != -1) { #found, else forget
		
			my $phraseEndKeyIndex = index($line, $phraseEndKey);
			if ($phraseEndKeyIndex != -1) { #found, else forget
	
				my $phraseStartKeyEndIndex = index($line, $phraseStartKeyEnd);
				if ($phraseStartKeyEndIndex != -1) { #found, else error!
				
					my $phraseIdIndex = $phraseStartKeyLength;
					my $phraseIdLength = $phraseStartKeyEndIndex - $phraseIdIndex;
					my $phraseId = substr($line, $phraseIdIndex, $phraseIdLength);
#print "phraseId=>$phraseId<\n";
					$phraseHash{'phraseId'} = $phraseId;
	
	
					my $phraseIndex = $phraseStartKeyEndIndex + $phraseStartKeyEndLength;
					my $phraseLength = $phraseEndKeyIndex - $phraseIndex;
					my $phrase = substr($line, $phraseIndex, $phraseLength);
#print "phrase=>$phrase<\n";				  
					$phraseHash{'phrase'} = $phrase;			
					
				} else {
					#error $phraseStartKeyEndIndex not found!
					Utili::LogCmdt::logWrite( ( caller(0) )[3],	"QS INFO parse error in phrase \t$line" );	 
				}
			}
		}
#	}
#print Dumper \%phraseHash;

	return %phraseHash;
}

	


1;