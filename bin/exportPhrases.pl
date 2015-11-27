#!/usr/bin/perl -w

# 22.10.15/cm with the help of pjw



use FindBin;
use lib "$FindBin::Bin/../perl_lib";


use strict;

use Data::Dumper;

use EPrints;

my $outputFileBase = "/tmp/alex_phrases_export";


my $ep = EPrints->new();
my $repo = $ep->repository("alex");


my $languages = $repo->config( "languages" );
#print Dumper \$languages; # de, en


foreach my $langid (@$languages) {
	
	my $outputFile = $outputFileBase . "_$langid.txt";
	open my $fh, '>:encoding(UTF-8)', $outputFile or die "Could not open $outputFile: $!\n";

print "***write phrases into file: $outputFile\n";

	my $lang = $repo->get_language($langid);
	my @phrases = $lang->get_phrase_ids(); #=item $phraseids = $language->get_phrase_ids( $fallback )
	
	foreach my $phraseid (@phrases) { 
		
		my( $xml, $fb, $src, $file ) = $lang->_get_phrase( $phraseid );	
#		print $fh "$xml\t$fb\t$src\t$file\n";
		print $fh "$xml\n";
        
	}

	
	close $fh;
}

$repo->terminate();
exit;

