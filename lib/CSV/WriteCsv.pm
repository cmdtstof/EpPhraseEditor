package CSV::WriteCsv;

use warnings;
use strict;

use Utili::LogCmdt;

use Data::Dumper;


sub tester {
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"tester" );
	return,
	
}


sub writeCsvPhrases {
	my ($file) = @_;

	unlink $file;
	open my $fh, ">", $file or die "Could not open $file: $!\n"; #encoding!!!!!!
#	open my $fh, ">:raw", $file or die "Could not open $file: $!\n";
#	open my $fh, ">:encoding(UTF-8)", $file or die "Could not open $file: $!\n";
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"create csv file \t$file" );
	
	my @fields = qw(phraseId noWrite);
	my @langList = @EpPhraseEditor::epe_langList; 
	for (my $langId = 0; $langId < @langList; $langId++) {
		push(@fields, $langList[$langId]);
	}	
	
	my $sth = Db::EpeDb::getPhrasesSth();

	#header
	my $last = @fields-1;
	
	for (my $i = 0; $i < @fields; $i++) {
		 print $fh "$EpPhraseEditor::quote_char$fields[$i]$EpPhraseEditor::quote_char";
		 if ($i < $last) {
		 	print $fh $EpPhraseEditor::sep_char;
		 }
	}
	print $fh "\n";

	$last = @fields;
	while(my $result = $sth->fetchrow_hashref){
		
		for (my $i = 0; $i < @fields; $i++) {
			if (defined $result->{$fields[$i]}) {
				print $fh $EpPhraseEditor::quote_char;
				print $fh $result->{$fields[$i]};			
				print $fh $EpPhraseEditor::quote_char;
			}
			if ($i < $last) { print $fh $EpPhraseEditor::sep_char; }
		}
		print $fh "\n";
	}
	
	close $fh;
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"csv file cloesed \t$file" );
	
	return;
}

1;