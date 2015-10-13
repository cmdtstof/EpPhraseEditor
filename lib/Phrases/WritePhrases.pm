package Phrases::WritePhrases;

use warnings;
use strict;

use Utili::LogCmdt;
use Utili::FileTools;
use Data::Dumper;

my $fh;


sub main {
	
	my @langList = @EpPhraseEditor::epe_langList;
	
	my $outputDir = $EpPhraseEditor::epe_outputDir . "lang";
	Utili::FileTools::createDir($outputDir);




	for (my $i = 0; $i < @langList; $i++) { 
		
		my $language = $langList[$i];
		my $langDir = $outputDir . "/" . $language;
		Utili::FileTools::createDir($langDir);
		my $file = $langDir . "/" . $EpPhraseEditor::epe_phraseFile;

		createFile($file);
		
		writeHeader();
		
		
		#get all phrases
		#sort by file
		#where phrase is not empty or NULL

		my $sth = Db::EpeDb::getPhrasesLang($language);
#SELECT p.idx, p.phraseId, p.language

	while ( my $result = $sth->fetchrow_hashref() ) {
		
#print Dumper \$result;

		my $phraseId = $result->{'phraseId'};
		my $phrase = $result->{$language};
		$phrase = Utili::Encodings::reparsePhrase($phrase);

#print "phraseId=$phraseId\tphrase=$phrase\n";
		
		writePhrase($phraseId, $phrase);
		
		
	} 



#	my $filename = Db::EpeDb::getFileName(1);
		
		

		writeFooter();
		closeFile($file);
		
		
		 
	}
	return;	
}



#<epp:phrase id="Plugin/Screen/User/Homepage_Alex/Embed:title">Embedding Your Profile</epp:phrase>
#<epp:phrase id="Plugin/Screen/User/Homepage_Alex/Embed:embed_content">
#<p>It is possible to embed your MePrints profile into other pages. So long as your profile is publically visible then you just need to add the following code to another page and your MePrints profile will appear on that page.</p>
#<pre>
#	&lt;script type="text/javascript" src="<pin name="embed_url"/>"&gt; &lt;/script&gt;
#</pre>
#</epp:phrase>

sub writePhrase {
	my ($phraseId, $phrase) = @_;

	print $fh qq{<epp:phrase id="$phraseId">$phrase</epp:phrase>\n};	
	
	return;
}


sub createFile {
	my ($filename) = @_;

	Utili::FileTools::delFile($filename);
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"create phrase file\t$filename" );
	open $fh, ">", $filename or die "$filename: $!";

	return; 
}

sub closeFile {
	my ($filename) = @_;
	close $fh;
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"close phrase file\t$filename");
	return
}

sub writeHeader {
	
	my $time = localtime;
	
	print $fh qq{<?xml version="1.0" encoding="UTF-8" standalone="no" ?>
<!DOCTYPE phrases SYSTEM "entities.dtd">

<!-- 
Phrase File for EPrints Repository $EpPhraseEditor::epe_archive
autogenerated by cmdt.ch EpPhraseEditor
$time
-->

<epp:phrases xmlns="http://www.w3.org/1999/xhtml" xmlns:epp="http://eprints.org/ep3/phrase" xmlns:epc="http://eprints.org/ep3/control">

};
	return;
}

sub writeFooter {
	print $fh qq{

</epp:phrases>
};
	return;
}




1;