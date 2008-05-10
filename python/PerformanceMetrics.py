#!/usr/bin/python

import os
import subprocess as G

dirs = ['/opt/ptc','/vault']

def sendmail(mesg):
    SENDMAIL = "/usr/sbin/sendmail" # sendmail location
    p = os.popen("%s -t" % SENDMAIL, "w")
    p.write("To: prathapy@google.com\n")
    p.write("From: prathapy@google.com\n")
    p.write("Subject: Frostbite performance details\n")
    p.write("\n") # blank line separating headers from body
    p.write(mesg)
    sts = p.close()
    if sts != None:
        print "Sendmail exit status", sts


p = G.Popen('df -h', shell=True, stdout=G.PIPE)
lines = p.stdout.readlines()
mesg = 'Disk space Utilization details '
for line in lines:
    #print line
    current = line.split()
    for dir in dirs:
        if current and len(current)>5 and dir == current[5]:
            mesg = mesg + '\nPath : '+ current[5]+ '\tUsed space :'+ current[2]+ '\tAvailable  :'+ current[3]
            break
sendmail(mesg)

