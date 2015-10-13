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
	$str = $converterU8tU8->convert($str);    # (1)ohne convert utf8>utf8 kommt es falsch!!!???
	return $str;
	
}

sub validatePhrase {
	my ($str) = @_;
	
	$str =~ s/'/--thisIsApostrophe--/g;
	$str =~ s/"/--thisIsQuote--/g;
	$str =~ s/;/--thisIsSemiCol--/g;
			
	return $str;
}

sub reparsePhrase {
	my ($str) = @_;

	$str =~ s/--thisIsApostrophe--/'/g;
	$str =~ s/--thisIsQuote--/"/g;	
	$str =~ s/--thisIsSemiCol--/;/g;	
	return $str;
	 
}
