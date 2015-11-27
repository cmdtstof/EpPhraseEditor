#!/usr/bin/perl
package Utili::Encodings;

use warnings;
use strict;
use String::Util 'trim';


use Data::Dumper;
use Text::Iconv;


my $converterU8tU8 = Text::Iconv->new( "UTF8", "UTF8" );    #übernommen ?????


sub checkValue {
	my ($str) = @_;
	
	if (defined $str) {
		$str = $converterU8tU8->convert($str);    # (1)ohne convert utf8>utf8 kommt es falsch!!!???
	
#		$str =~ s/\r//g; #remove formfeed
#		$str =~ s/\t//g; #remove tab
#		$str =~ s/\n//g; #remove newline
		
	}
	
	return $str;
	
}

sub validatePhrase {
	my ($str) = @_;
	
	$str =~ s/'/--thisIsApostrophe--/g;
	$str =~ s/"/--thisIsQuote--/g;
	$str =~ s/;/--thisIsSemiCol--/g;
	
	$str =~ s/\r//g; #remove formfeed
	$str =~ s/\t//g; #remove tab
	$str =~ s/\n//g; #remove newline
			
	return $str;
}

sub reparsePhrase {
	my ($str) = @_;

	$str =~ s/--thisIsApostrophe--/'/g;
	$str =~ s/--thisIsQuote--/"/g;	
	$str =~ s/--thisIsSemiCol--/;/g;	
	return $str;
	 
}
