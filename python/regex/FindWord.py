#!/usr/bin/python

import re
#word = 'order'
r = re.compile( r'\bword\b', re.M )
if r.search( open( 'sample.txt' ).read() ):
	print "I finally found what I'm looking for.",
else:
	print "\"word\"s not here, man. ",