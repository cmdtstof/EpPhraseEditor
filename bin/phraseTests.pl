#!/usr/bin/perl -w

# 22.10.15/cm with the help of pjw



use FindBin;
use lib "$FindBin::Bin/../perl_lib";


use strict;

use Data::Dumper;

use EPrints;


my $ep = EPrints->new();
my $repo = $ep->repository("alex");
#print Dumper \$repo;


my $languages = $repo->config( "languages" );
#print Dumper \$languages; # de, en

	my $outputFile = "/usr/share/eprints3/tmp/alex_phrases.txt";
	open my $fh, '>:encoding(UTF-8)', $outputFile or die "Could not open $outputFile: $!\n";


#foreach my $langid (@$languages) {
#
#	print "************************$langid\n"; 


	my $lang = $repo->get_language('en');
	my @phrases = $lang->get_phrase_ids(); #=item $phraseids = $language->get_phrase_ids( $fallback )
	

#	print Dumper \@phrases;
	
#my $phraseid = "archive_title";
my $phraseid = "Plugin/Screen/Admin/UpdateProfileData:ok";



###############_get_phrase >>>> works
######################################################################
# 
# ( $phrasexml, $is_fallback ) = $language->_get_phrase( $phraseid )
#
# Return the phrase for the given id or undef if no phrase is defined,
# and reload the phrase from disk if needed.
#
######################################################################
#	foreach my $phraseid (@phrases) {
		my( $xml, $fb, $src, $file ) = $lang->_get_phrase( $phraseid );	
#		print $fh "$xml\t$fb\t$src\t$file\n";
		print "$xml\t$fb\t$src\t$file\n";
#		<epp:phrase id="Plugin/Screen/EPrint/View/Owner:title">View Item</epp:phrase>           data    /usr/share/eprints3/lib/lang/en/phrases/system.xml
	


###############html_phrase( "title:logged_in" );
#where is html_phrase generated




###################get_phrase_info >>>> works
#=item $info = $lang->get_phrase_info( $phraseid )
#
#Returns a hash describing the phrase $phraseid. Contains:
#
#	langid - the language the phrase is from
#	phraseid - the phrase id
#	xml - the raw XML fragment
#	fallback - whether the phrase was from the fallback language
#	system - whether the phrase was from the system files
#	filename - the file the phrase came from

		my $info = $lang->get_phrase_info ($phraseid);

		while ( my ($key, $value) = each(%$info) ) {
        	print "$key => $value\t";
    	}
		print "\n";

#		my $langid = $info{'langid'};
#		my $phraseid2 = $info{'phraseid'};
#		my $xml = $info{'xml'};
#		my $fallback = $info{'fallback'};
#		my $system = $info{'system'};
#		my $filename = $info{'filename'};
#		
#		print "$langid\t$phraseid2\t$xml\tfallback\t$system\t$filename\n";
		# everything undef except fallback="fallback" ????? 



#################phrase >>>> works

		my $phrase = $lang->phrase ($phraseid);
		
		print "phrase of $phraseid=$phrase\n";













##############has_phrase( $phraseid ) >>> works
######################################################################
=pod

=item $boolean = $language->has_phrase( $phraseid )

Return 1 if the phraseid is defined for this language. Return 0 if
it is only available as a fallback or unavailable.

=cut
######################################################################


	$lang = $repo->get_language('de');
	my $boolean = $lang->has_phrase($phraseid);
	
	if ($boolean) {
		print "$phraseid found in de\n";
	} else {
		print "$phraseid not found in de\n";
	}
	
	








		
#	} #	foreach my $phraseid (@phrases) {












close $fh;

$repo->terminate();
exit;

=head1 COPYRIGHT

=for COPYRIGHT BEGIN

Copyright 2000-2011 University of Southampton.

=for COPYRIGHT END

=for LICENSE BEGIN

This file is part of EPrints L<http://www.eprints.org/>.

EPrints is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

EPrints is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
License for more details.

You should have received a copy of the GNU General Public License
along with EPrints.  If not, see L<http://www.gnu.org/licenses/>.

=for LICENSE END

