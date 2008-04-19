#!/usr/bin/python

import os
import subprocess as G

dirName = 'win'
def printInfo():
	print 'Available space  :'+aspace
	print 'Used space       :'+uspace

p = G.Popen('df -h', shell=True, stdout=G.PIPE)
lines = p.stdout.readlines()
for line in lines:
	#print line
	if dirName  in line:
		# print line
		current = line.split()
		print  'Available Disk space :'+ current[5]+'\t'+current[3]
		break
p = G.Popen('df -h | grep ptc | head -1 ',shell=True, stdout=G.PIPE)
lines = p.stdout.readlines()
for line in lines:
	current = line.split()
	aspace = current[3]
	usapce = current[2]
	# print 'Available space  :'+current[3]
	# print 'Used space       :'+current[2]
printInfo

