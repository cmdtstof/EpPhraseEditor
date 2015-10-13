#!/usr/bin/perl
# search for id and ref
#

package Search;

use Db::EpeDb;

use File::Find;
use String::Util 'trim';
use Utili::Encodings;
use Data::Dumper;


#search for
#<epp:phrase id=
#<epc:pin name="filename"/>




sub main {
	


#my $dir = "/home/stof/03_Projekte/alex/scr/alex-scr/alex-scr/";
#/home/stof/03_Projekte/alex/scr/alex-scr/alex-scr/lib/lang/en/phrases

 	my @dir;

#TODO search only archive/????*
 	push(@dir, $EpPhraseEditor::epe_scrDir);  
  


	find({ wanted => \&process_file, no_chdir => 1 }, @dir);

	

	return;
}


sub process_file {
    my $filename = $_;
    if (-f $filename) {

		open(F,$filename);
		my @filecontent = <F>;
		close F;
		
#print Dumper \@filecontent;		

		searchPhraseId($filename, @filecontent); ####search for id
        
    }
    return;
}

sub searchPhraseId {
	my ($filename, @filecontent) = @_;

		my $this="<epp:phrase id=";
		my @found=grep /$this/,@filecontent;

		if (@found) {
#print "file=$filename\n";
#print Dumper \@found;

			my $fileId = Db::EpeDb::getFileId($filename);
			if (!$fileId) { die "no fileId return"; }
			my $language = Db::EpeDb::getFileLanguage($filename);
		
			addPhrases($fileId, $language, @found);

		}
		
		return;
}



sub addPhrases {
	my ($fileId, $language, @found) = @_;

	for (my $i = 0; $i < @found; $i++) {
		 
		my $line = trim($found[$i]);
		if ($line =~ /^\s*#/) { next; }  		 #if lines starts with # forget it

		my $phraseId = getPhraseId ($line);
		if ($phraseId eq "") {
#  			Utili::LogCmdt::logWrite( ( caller(0) )[3], "QS INFO empty PhraseId in \t$line" );
		} else {
			my $phrase = getPhrase($line);
 
			Db::EpeDb::addPhrase($fileId, $phraseId, $language, $phrase);
			
		}
		 
	}
	return;
}

sub getPhrase {
	my ($line) = @_;

	#<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>
	#0123456789*123456789*123456789*123456789*123456789*123456789*
	#                16                     39
	#<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>	


	my $phrase = "";

	my $searchStr = '">';
	my $index = index($line, $searchStr);
	if ($index != -1) {
		my $length = length($searchStr);
		my $strStart = $index + $length;
		
		my $searchStr = '</epp:phrase>';
		my $index = index($line, $searchStr);
		if ($index != -1) {
			my $strEnd = $index;
			my $strLength = $strEnd - $strStart;
			$phrase = substr($line, $strStart, $strLength);
			
			#<p>This is a placeholder for the widget '<pin name="widget_id"/>'</p>
			$phrase = Utili::Encodings::validatePhrase ($phrase);
		}
	}
	return $phrase;
}


sub getPhraseId {
	my ($line) = @_;
#<epp:phrase id="epm_fieldname_home_page">Home Page</epp:phrase>	
#<epp:phrase id="org_unit_fieldname_projects_title" ref="project_fieldname_title" />
#<epp:phrase id='$phraseid' xmlns='http://www.w3.org/1999/xhtml' xmlns:epp='http://eprints.org/ep3/phrase' xmlns:epc='http://eprints.org/ep3/control'>".$phrase."</epp:phrase>\n\n";
#<epp:phrase id="lib/searchfield:help_storable" />

	my $phraseId = "";


#forget ></epp:phrase> !!!! >>> should means empty phrase!!!????

	if (index($line, "></epp:phrase>") == -1) {


	my $searchStr = '<epp:phrase id="';
	my $index = index($line, $searchStr);
	if ($index != -1) {
		my $length = length($searchStr);
		my $strStart = $index + $length;
		
		$searchStr = '">';
		$index = index($line, $searchStr);
		if ($index != -1) {
			my $strEnd = $index;
			my $strLength = $strEnd - $strStart;
			$phraseId = substr($line, $strStart, $strLength);
			
		} else {
#			$phraseId = $line; #take the whole line >>> forget it!!!!
		}
	}
	}
	return $phraseId;
}






	
sub stripFilename {
	my ($filename) = @_;
	my $basedir = $EpPhraseEditor::epe_scrDir;
	$filename =~ s/$basedir//;
	return $filename;
}



1;