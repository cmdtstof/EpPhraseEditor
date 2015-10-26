package EPrints::Plugin::Screen::Admin::GetPhrases;

# 19.10.15/pjw 
#
#



#Hi [~alexhsg]
#I have added a simple admin screen plugin which is on the admin/system tools page (it is the one without the phrases defined.
#
#This is:
#archives/alex/cfg/plugins/EPrints/Plugin/Screen/Admin/GetPhrases.pm
#
#When you click the button it gets all the phrases for the current language and prints some of the details to the error log.
#I used a screen plugin so that the repository was loaded and configured for a language.
#The code that is being used is in: perl_lib/EPrints/Language.pm
#In that module you will see functions for loading phrases from files and getting the fall-back phrase etc.
#The two important calls in my demo are:
#my @phrases = $lang->get_phrase_ids();
#and 
#my( $xml, $fb, $src, $file ) = $lang->_get_phrase( $id );
#
#I hope this helps




@ISA = ( 'EPrints::Plugin::Screen' );

use strict;

sub new
{
	my( $class, %params ) = @_;

	my $self = $class->SUPER::new(%params);
	
	$self->{actions} = [qw/ get_phrases /]; 
		
	$self->{appears} = [
		{ 
			place => "admin_actions_system", 
			position => 1440, 
			action => "get_phrases",
		},
	];

	return $self;
}

sub allow_get_phrases
{
	my( $self ) = @_;

	return $self->allow( "config/regen_abstracts" );
}

sub action_get_phrases
{
	my( $self ) = @_;

	my $repo = $self->{repository};
	
	my $languages = $repo->config( "languages" );
	
	my $outputFile = "/usr/share/eprints3/tmp/alex_phrases.txt";
	open my $fh, '>:encoding(UTF-8)', $outputFile or die "Could not open $outputFile: $!\n";

	foreach my $langid (@$languages) {
		print $fh "#######################lang=$langid\n";
	
	
	}
	
	
	

	
	
#	my $lang = $repo->{lang};
#	my @phrases = $lang->get_phrase_ids();
#	foreach my $id ( @phrases )
#	{
#        	my( $xml, $fb, $src, $file ) = $lang->_get_phrase( $id );
#		print STDERR "phrase $id xml [".$xml."] [".$file."]\n";
#	}
	
       	$self->{processor}->add_message( "message",
			 $repo->xml->create_text_node("phrases send to $outputFile asdfasedf" ),
 		 );
       	$self->{processor}->{screenid} = "Admin";

	
}	




1;


