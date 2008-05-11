#!/usr/bin/python

import os
import subprocess as G

dirs = ['/opt/ptc','/vault']
days = 7 

def sendmail(mesg):
    SENDMAIL = "/usr/sbin/sendmail" # sendmail location
    p = os.popen("%s -t" % SENDMAIL, "w")
    p.write("To: ysprathap@gmail.com\n")
    p.write("From: windchill@google.com\n")
    p.write("Subject: Frostbite system monitoring information\n")
    p.write("\n") # blank line separating headers from body
    p.write(mesg)
    sts = p.close()
    if sts != None:
        print "Sendmail exit status", sts

#Find Disk Usage details.
p = G.Popen('df -h', shell=True, stdout=G.PIPE)
lines = p.stdout.readlines()
mesg = 'Disk space Utilization details '
for line in lines:
    #print line
    current = line.split()
    for dir in dirs:
        if current and len(current)>5 and dir == current[5]:
            mesg = mesg + '\n\nPath : '+ current[5]+ '\nUsed space :'+ current[2]+ '\nAvailable  :'+ current[3]
            break

#Find Performance details using sar
p = G.Popen('ls /var/adm/sa/sa[0-9]* | tail -'+str(days)+' | xargs', shell=True, stdout=G.PIPE) 
lines = p.stdout.readlines()
mesg = mesg + '\n\n\nCPU Utilization details\n'
for line in lines:
    print line
    sarFiles = line.split()
    usr = 0
    sys = 0
    wio = 0
    idle = 0
    for sarFile in sarFiles: 
    	cmd = 'sar -f '+sarFile+' | grep Average'
    	#print cmd
    	g=G.Popen(cmd, shell=True, stdout=G.PIPE) 
    	avg= g.stdout.readline()
    	#print avg
        util = avg.split()
        usr = usr + int(util[1])
        sys = sys + int(util[2])
        wio = wio + int(util[3])
        idle = idle + int(util[4])

mesg = mesg + '\nAverage user utilization : '+str(usr/days)
mesg = mesg + '\nAverage system utilization : '+str(sys/days)
mesg = mesg + '\nAverage wio utilization : '+str(wio/days)
mesg = mesg + '\nAverage idle  : '+str(idle/days)

print mesg
sendmail(mesg)
