#!/usr/bin/python

# This script finds the disk space utilization details and
# CPU utilization details from sar output files. 
# Sends email to the plm-sysadmins group.

import os
import subprocess as G
import smtplib
from email.MIMEText import MIMEText
import datetime

mailServer="mailgw.nvidia.com"
mailTo=['npamidi@nvidia.com','pyalavarthi@nvidia.com','rajasekaran.p@itcinfotech.com']
mailSubject="Exceptions in Windchill MethodServer logs on "
dirs = ['/opt/ptc','/vault']
days = 7 

def sendTextMail(to,subject,text):
    frm = "Windchill <pyalavarthi@nvidia.com>"
    mail = MIMEText(text)
    mail['From'] = frm
    mail['Subject'] =subject
    mail['To'] = to
    smtp = smtplib.SMTP(mailServer)
    smtp.sendmail(frm, [to], mail.as_string())
    smtp.close()

commandsList = [ 'ls.exe -tr \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -1  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws03\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws04\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -A5 -in Exception']

mesg = ' '
today =datetime.date.today()
todayStr = datetime.date.strftime(today,"%m/%d/%y")
mailSubject =  mailSubject+todayStr
for command in commandsList:
	p = G.Popen(command, shell=True, stdout=G.PIPE)
	lines = p.stdout.readlines()
	for line in lines:
		if(line.find(todayStr)>0):
			mesg = mesg+line
# toaddrs=mailTo.split(",")
# print toaddrs
# mailTo=",".join(toaddrs)
# print mailTo
#print mesg
for toaddr in mailTo:
	sendTextMail(toaddr,mailSubject,mesg)

