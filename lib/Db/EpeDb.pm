#!/usr/bin/perl
# DBI functions
#

package Db::EpeDb;

use warnings;
use strict;
use DBI;
use XML::Simple qw(:strict);

use Utili::LogCmdt;
use Data::Dumper;
use Utili::FileTools;

my $dbh;

sub tester {



	return;

}


sub dbCreate {
	my ($database) = @_;

	unlink $database; #remove existing
	system("sqlite3", $database, ";");

	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"create db $database" );
	return;	
	
}

sub dbOpen {
### stof003 sqlight
	my ($database) = @_;
	$dbh =
	  DBI->connect( "dbi:SQLite:dbname=$database", "", "",
		{ RaiseError => 1, AutoCommit => 1 } )
	  || die "Could not connect to database: $DBI::errstr";
	Utili::LogCmdt::logWrite( ( caller(0) )[3],	"open db $database" );
	return;

}

sub dbClose {
	$dbh->disconnect();
	Utili::LogCmdt::logWrite( ( caller(0) )[3], "close db" );
	return;

}



sub createTblFiles {
#tblFiles
#- fieldId
#- filename (only from base) 	
	
	
	my $tbl = "tblFiles";

	my $stmt = qq(DROP TABLE IF EXISTS $tbl );
	my $rv   = $dbh->do($stmt);

	$stmt = qq(

CREATE TABLE $tbl (
	`fileId`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`filename`	TEXT,
	`language`	TEXT
);

	);
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl $tbl" );
	return;
}
sub createTblPhrases {
#tblPhrases
#- phraseId
#- langXXX

	my $tbl = "tblPhrases";

	my $stmt = qq(DROP TABLE IF EXISTS $tbl );
	my $rv   = $dbh->do($stmt);

	$stmt = "CREATE TABLE $tbl (
	`idx`	INTEGER PRIMARY KEY AUTOINCREMENT,
	`phraseId`	TEXT,
	`noWrite`	INTEGER default 0";

	my @langList = @EpPhraseEditor::epe_langList;	
	for (my $langId = 0; $langId < @langList; $langId++) {
		$stmt .= ", `$langList[$langId]` TEXT"; 
	}
	$stmt .= ");";

#print "stmt=$stmt\n";

	
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl $tbl" );
	return;
}

sub createTblUsed {
#tblUsed
#- phraseId
#- fileId 

	my $tbl = "tblUsed";

	my $stmt = qq(DROP TABLE IF EXISTS $tbl );
	my $rv   = $dbh->do($stmt);

	$stmt = qq(

CREATE TABLE $tbl (
	`fileId`	INTEGER,
	`phraseIdx`	INTEGER
);

	);
	$rv = $dbh->do($stmt);

	Utili::LogCmdt::logWrite( ( caller(0) )[3], "create tbl $tbl" );
	return;
}


sub getFileId {
	my ($filename) = @_;
	my $sth = $dbh->prepare('SELECT fileId, language FROM tblFiles where filename = ?');
	$sth->execute($filename);
	my $result = $sth->fetchrow_hashref();
	my $fileId = $result->{'fileId'};
	my $language;

	if (!$fileId) {
		$language = parseFileLanguage($filename);
		$fileId = addFile($filename, $language);
	} else {
		$language = $result->{'language'};
	}
	return ($fileId, $language);
}

sub getFileLanguage {
	my ($filename) = @_;
	my $sth = $dbh->prepare('SELECT language FROM tblFiles where filename = ?');
	$sth->execute($filename);
	my $result = $sth->fetchrow_hashref();
	my $language = $result->{'language'};
	return $language;	
}

sub getFileName {
	my ($fileId) = @_;
	my $sth = $dbh->prepare('SELECT filename FROM tblFiles where fileId = ?');
	$sth->execute($fileId);
	my $result = $sth->fetchrow_hashref();
	my $filename = $result->{'filename'};
	return $filename;	
}

sub parseFileLanguage {
	my ($filename) = @_;

	my $searchStr = "/lang/";
	my $index = index($filename, $searchStr);
	my $language = "en"; #default
	if ($index != -1) {
		my $strStart = $index + 6;
		my $strEnd = 2;
		$language = substr($filename, $strStart, $strEnd);
#print "filename=$filename\tlanguage=$language\n";
	}
	return $language;
	
}

sub addFile {
	my ($filename, $language) = @_;

	my $sth = $dbh->prepare('INSERT INTO tblFiles (filename, language) VALUES (?, ?)');
	$sth->execute( $filename, $language );

	$sth = $dbh->prepare('SELECT fileId FROM tblFiles where filename = ?');
	$sth->execute($filename);
	my $result = $sth->fetchrow_hashref();
	my $fileId = $result->{'fileId'};
	return $fileId;
}

sub phraseIdFound {
	my ($phraseId) = @_;

	my $sth = $dbh->prepare('SELECT idx, phraseId FROM tblPhrases where phraseId = ?');
	$sth->execute($phraseId);
	my $result = $sth->fetchrow_hashref();
	if ($result) {
		return 1;
	} else {
		return 0;
	}
}


sub updatePhrases {
	my ($phraseId, %fields) = @_;
	my $stmt = "UPDATE tblPhrases SET";
	while ( my ($key, $value) = each(%fields) ) {
        $stmt .= " $key = '$value',"; 
    }	
	chop $stmt;
	$stmt .= " WHERE phraseId = '$phraseId'";	
#print "stmt=$stmt\n";
	my	$sth = $dbh->prepare($stmt);
	$sth->execute();
	return;
}

sub addPhraseId {
	my ($phraseId) = @_;	
	my $sth = $dbh->prepare('INSERT INTO tblPhrases (phraseId) VALUES (?)');
	$sth->execute( $phraseId );
	
	my $phraseIdx = getPhraseIdx($phraseId);
	return $phraseIdx;
}

sub getPhraseIdx {
	my ($phraseId) = @_;
	my $sth = $dbh->prepare('SELECT idx, phraseId FROM tblPhrases where phraseId = ?');
	$sth->execute($phraseId);
	my $result = $sth->fetchrow_hashref();
	my $idx = $result->{'idx'};
	return $idx;
}

sub addPhrase{
	my ($fileId, $phraseId, $language, $phrase) = @_;
	my $idx = getPhraseIdx($phraseId);

	if (!$idx) {
		addPhraseId($phraseId);
		$idx = getPhraseIdx($phraseId);
		Utili::LogCmdt::logWrite( ( caller(0) )[3], "phrase added \t$phraseId" );
	}
	my %fields;
	$fields{$language} = $phrase;
	updatePhrases ($phraseId, %fields);
	addUsedIn($fileId, $idx);
	return;
}

sub addUsedIn {
	my ($fileId, $phraseIdx) = @_;
	my $sth = $dbh->prepare("SELECT fileId, phraseIdx FROM tblUsed where fileId = $fileId and phraseIdx = $phraseIdx");
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	if (!$result) {
		my $sth = $dbh->prepare("INSERT INTO tblUsed (fileId, phraseIdx) VALUES ($fileId, $phraseIdx)");
		$sth->execute();
	}
	return;
}

sub getPhrasesHashref{
	my ($phraseId) = @_;
	my $sth = $dbh->prepare("SELECT * FROM tblPhrases where phraseId = '$phraseId'");
	$sth->execute();
	my $result = $sth->fetchrow_hashref();
	return $result;
	
}


sub getPhrasesSth {
#	my $stmt = "SELECT phraseId, noWrite";
#	my @langList = @EpPhraseEditor::epe_langList;	
#	for (my $langId = 0; $langId < @langList; $langId++) {
#		$stmt .= ", $langList[$langId]"; 
#	}
#	$stmt .= " FROM tblPhrases";
#	my $sth = $dbh->prepare($stmt);
	my $sth = $dbh->prepare("SELECT * FROM tblPhrases");
	$sth->execute();
	return $sth;
}

sub getFilesHash {
	my $sth = $dbh->prepare('SELECT fileId, filename, language FROM tblFiles');
	$sth->execute();
	my @array;
	while ( my $result = $sth->fetchrow_hashref() ) {
		
		push (@array, $result);
	
	}
	
	
	return @array;
}

sub getPhrasesLang {
	my ($language) = @_;

	my $stmt = qq{
SELECT p.idx, p.phraseId, p.$language
 FROM tblPhrases as p
 where (p.$language <> "" or p.$language not null) and NOT p.noWrite
 order by p.phraseId
	};

	my	$sth = $dbh->prepare($stmt);
	$sth->execute();
	return $sth;
}



1;
