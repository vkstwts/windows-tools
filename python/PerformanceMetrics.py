#!/usr/bin/python

import os
import subprocess as G

dirName = '/usr/local/google'

def sendmail(mesg):
    SENDMAIL = "/usr/sbin/sendmail" # sendmail location
    p = os.popen("%s -t" % SENDMAIL, "w")
    p.write("To: ysprathap@gmail.com\n")
    p.write("From: ysprathap@gmail.com\n")
    p.write("Subject: test email\n")
    p.write("\n") # blank line separating headers from body
    p.write(mesg)
    sts = p.close()
    if sts != 0:
        print "Sendmail exit status", sts


p = G.Popen('df -h', shell=True, stdout=G.PIPE)
lines = p.stdout.readlines()
for line in lines:
	#print line
	if dirName  in line:
		# print line
		current = line.split()
                mesg = 'Disk space Utilization details \n'
		mesg = mesg + 'Path       :'+ current[5]+ '\nUsed space :'+ current[2]+ '\nAvailable  :'+ current[3]
                sendmail(mesg)
		break

