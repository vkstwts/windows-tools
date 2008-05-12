#!/usr/bin/python

import os
import subprocess as G
import smtplib
from email.MIMEText import MIMEText

mailServer="smtp.corp.google.com"
mailTo="prathapy@google.com"
mailSubject="PLM system monitoring details"
dirs = ['/opt/ptc','/vault']
days = 7 

def sendTextMail(to,subject,text):
    frm = "Windchill <windchill@google.com>"
    mail = MIMEText(text)
    mail['From'] = frm
    mail['Subject'] =subject
    mail['To'] = to
    smtp = smtplib.SMTP(mailServer)
    smtp.sendmail(frm, [to], mail.as_string())
    smtp.close()


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

mesg = mesg + '\nAverage user utilization : '+str(usr/days)+'%'
mesg = mesg + '\nAverage system utilization : '+str(sys/days)+'%'
mesg = mesg + '\nAverage wio utilization : '+str(wio/days)+'%'
mesg = mesg + '\nAverage idle cpu : '+str(idle/days)+'%'

print mesg
sendTextMail(mailTo,mailSubject,mesg)
