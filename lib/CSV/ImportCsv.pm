package CSV::ImportCsv;

use warnings;
use strict;

use Utili::LogCmdt;
#use Text::CSV;
use Utili::Encodings;

use Data::Dumper;

my $quote_char = '"';
my $sep_char = ";";
my $fromCsv = "fromCsv";


sub tester {
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"tester" );
	return,
	
}

sub importCsvPhrases {
	my ($file) = @_;
	

	my @langList = @EpPhraseEditor::epe_langList;
	my @checkFieldsList = @langList;
	push @checkFieldsList, "noWrite";

#	my $csv = Text::CSV->new({ binary => 1, eol => "\r\n", quote_char => $quote_char, sep_char => $sep_char }) or die "Cannot use CSV: " . Text::CSV->error_diag();
#	my $csv = Text::CSV->new({ binary => 1, eol => "\r\n", sep_char => $sep_char }) or die "Cannot use CSV: " . Text::CSV->error_diag();
#	my $csv = Text::CSV->new({ eol => "\r\n", quote_char => $quote_char, sep_char => $sep_char }) or die "Cannot use CSV: " . Text::CSV->error_diag();

	
	open my $fh, "<", $file or die "Could not open $file: $!\n"; 
#	open my $fh, "<:encoding(UTF-8)", $file or die "Could not open $file: $!\n";
	
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"csv opened \t$file" );

	my @data;
	while (my $line = <$fh>) {
	    chomp $line; #remove newline
	    my @fields = split(/$sep_char/, $line);
	    push @data, \@fields;
	}	

#print Dumper \@data;
#print "$data[0][0]";

	my @header;
	for (my $i = 0; $i < @{$data[0]}; $i++) {
		push(@header, removeQuote( $data[0][$i] ) ); 
	}
	 
#print Dumper \@header;

	for (my $i = 1; $i < @data; $i++) {
#		print "$data[$i]\n";

		my %newFields;
		$newFields{'phraseId'} = removeQuote( $data[$i][0] );
		if ($newFields{'phraseId'}) {


			$newFields{'noWrite'} = removeQuote($data[$i][1]);
			if (undef $newFields{'noWrite'}) {
				if ($newFields{'noWrite'} eq "") { $newFields{'noWrite'} = "0"; }
			} else {
				$newFields{'noWrite'} = "0"; 
			}
				
			for (my $langId = 0; $langId < @langList; $langId++) {
				$newFields{$langList[$langId]} = Utili::Encodings::checkValue( removeQuote($data[$i][$langId+2]) );
			}
				
			if (!Db::EpeDb::phraseIdFound($newFields{'phraseId'})) {
				my $phraseIdx = Db::EpeDb::addPhraseId($newFields{'phraseId'}); 	#if phraseId not exist, add it
				my ($fileId, $language) = Db::EpeDb::getFileId($fromCsv); 
				Db::EpeDb::addUsedIn($fileId, $phraseIdx);
				Utili::LogCmdt::logWrite( ( caller(0) )[3],	"phraseId added\t$newFields{'phraseId'}" );
			}

			my $oldFields = Db::EpeDb::getPhrasesHashref($newFields{'phraseId'});
			my %updateFields;
			for (my $u = 0; $u < @checkFieldsList; $u++) {

#print "$checkFieldsList[$u] : old=$$oldFields{$checkFieldsList[$u]} new=$newFields{$checkFieldsList[$u]}\n";

				if (!defined $$oldFields{$checkFieldsList[$u]}) {$$oldFields{$checkFieldsList[$u]} = "";}
				if (!defined $newFields{$checkFieldsList[$u]}) {$newFields{$checkFieldsList[$u]} = "";}

				if ($$oldFields{$checkFieldsList[$u]} ne $newFields{$checkFieldsList[$u]}) {
					$updateFields{$checkFieldsList[$u]} = $newFields{$checkFieldsList[$u]};
				}
			} #endfor
			if (%updateFields) {
#print "importcsv asdfasdf";
#print Dumper \%updateFields;			
			
			
			Db::EpeDb::updatePhrases($newFields{'phraseId'}, %updateFields);
			Utili::LogCmdt::logWrite( ( caller(0) )[3],	"phrases changed\t$newFields{'phraseId'}" );
			}
		}
		
	}
	close $fh;
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"csv file closed \t$file" );
	return;
}

sub removeQuote {
	my ($str) = @_;
	if ($str) {
#		$str =~ s/$quote_char//g;
		$str = substr $str, 1, -1;
	}
	return $str;
}


1;