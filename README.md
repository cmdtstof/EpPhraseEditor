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
 
