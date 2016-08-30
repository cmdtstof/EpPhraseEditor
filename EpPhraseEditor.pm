#!/usr/bin/perl -Ilib 

################################################
# EPrints Phrase Editor (epe)
#  
# read phrases into db
# export phrases into csv 
# import csv into db
# write phrase file from db (maybe?)
#
#
#


#########how it works
#use exportPhrases.pl on dev and move files to ~/import/alex/lang/xx



#1. import phrases

#***with sqlitebrowser
#2. change phrases and noWrite (don't forget to „Write Changes“!!!)

#***with csv, LO calc
#2. gen csv
#3. open csv with LO calc >>>> , and " ++++mark quoted field as text!!!!
#4. change phrases and noWrite
#5. save
#6. import csv

#***gen phrase file


#!!!! changed phrases in perl (import phrases) and csv will always be updated !!!
# before importing phrases new from perl >>> import csv
# import phrases from perl
# write csv 


######todo
#TODO when re-importing phrases from csv, removed phraseId should be removed from db (for code as well?) 




package EpPhraseEditor;
use warnings;
use strict;
use Data::Dumper;





##############################################################################
# Define some constants
#

our $quote_char = '"';
our $sep_char = ";";



#our $epe_scrDir			= "/home/stof/03_Projekte/alex/scr/alex-scr/alex-scr/";	# EPrints base source directory
our $epe_archive		= "alex"; #archive id >>> "archives/alex/cfg/lang";
our @epe_langList 		= qw(en de); #list for language to search/write for !!!db must be adapted!!!!

our $epe_importDir		= "../import/";  #import dir for exportPhrases files = $epe_importDir . $epe_archive
our $epe_logDir			= "../log/";	#log dir
our $epe_outputDir   	= "../output/";   		# outputdir csv = $epe_importDir . $epe_archive
my $epe_dbDir			= "../db/";		#sqlight db dir

our $epe_writeLog 		= 1;				#1=write logfile and entries
our $epe_stderrOutput 	= 1;				# 1=logfile output will also be sended to stderr

#our $epe_testData		= 0;				#1=use testdata for phrase import
#if ($epe_testData) {
#	$epe_archive		= "testdata"; #archive id >>> "archives/alex/cfg/lang";
#} 

my $epe_dbName			= "epephrases_" . $epe_archive . ".db";
my $epe_database 		= $epe_dbDir . $epe_archive . "/" . $epe_dbName;	
my $epe_csvPhrases		= $epe_outputDir . $epe_archive . "/" . $epe_archive . "_phrases.csv";
our $epe_phraseFile		= "zzz_" . $epe_archive . "_genPhrases.xml";




#####what do to #######################
my $epe_createDb 		= 0;    #1=create db
my $epe_getPhrased		= 0;	#1=get phrases and refs(used) from all files

my $epe_analyze			= 0;	#1=analyze phrases !!!! not used yet !!!

my $epe_writeCsv		= 0;	#1=write csv from db

my $epe_importCsv		= 1;	#1=import csv into db

my $epe_writePhraseFile	= 1;	#1=write phrase file for language





############# init ##################


use Utili::LogCmdt;
Utili::LogCmdt::logOpen();



############# get options ##################






################# testing ##################




################## create db ##################

if ($epe_createDb) {


		use Db::EpeDb;
		
		Db::EpeDb::dbCreate($epe_database);
		Db::EpeDb::dbOpen($epe_database);

		Db::EpeDb::createTblFiles();
		Db::EpeDb::createTblPhrases();
		Db::EpeDb::createTblUsed();

		Db::EpeDb::dbClose();
	
}


########### get phrases and refs #################

if ($epe_getPhrased) {
	
	use Db::EpeDb;
	Db::EpeDb::dbOpen($epe_database);
	
	my $importDir = $epe_importDir . $epe_archive;
	use Phrases::ImportPhrases;
	Phrases::ImportPhrases::import($importDir);
	
	
#	use Search;
#	Search::main();
#	
	
	Db::EpeDb::dbClose();
	
}

########### analyze #################

if ($epe_analyze) {

	use Db::EpeDb;
	Db::EpeDb::dbOpen($epe_database);

	use Analyze::Analyzer;
	Analyze::Analyzer::main();

	Db::EpeDb::dbClose();
	
}
		

########### write csv #################

if ($epe_writeCsv) {

	use Db::EpeDb;
	Db::EpeDb::dbOpen($epe_database);

	use CSV::WriteCsv;
	CSV::WriteCsv::writeCsvPhrases($epe_csvPhrases);
		
	Db::EpeDb::dbClose();
	
}	


########### import csv #################

if ($epe_importCsv) {

	use Db::EpeDb;
	Db::EpeDb::dbOpen($epe_database);

	use CSV::ImportCsv;
	CSV::ImportCsv::importCsvPhrases($epe_csvPhrases);
	
		
	Db::EpeDb::dbClose();
	
}	

########### write phrase file #################

if ($epe_writePhraseFile) {

	use Db::EpeDb;
	Db::EpeDb::dbOpen($epe_database);

	use Phrases::WritePhrases;
	Phrases::WritePhrases::main();
		
	Db::EpeDb::dbClose();
	
}	






########### #################



Utili::LogCmdt::logClose();

1;

