#!/usr/bin/python

import re

#Search for oink or moo in the file

r = re.compile( r'\s\+\(\(oink\)\|\(moo\)\)\s\+', re.M )
if r.search( open( 'sample.txt' ).read() ):
	print "I spy a cow or pig here.",
else:
	print "Ah, there is no cow or pig here ",