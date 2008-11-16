#!/usr/bin/python

# This script finds the disk space utilization details and
# CPU utilization details from sar output files. 
# Sends email to the plm-sysadmins group.

import os
import subprocess as G
import smtplib
from email.MIMEText import MIMEText
import datetime
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText


mailServer="mailgw.nvidia.com"
mailTo=['pyalavarthi@nvidia.com','npamidi@nvidia.com','mnomura@nvidia.com','rajasekaran.p@itcinfotech.com']
#mailTo=['pyalavarthi@nvidia.com']
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


commandsList = [ 'ls.exe -tr \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -5  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws03\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -10  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws04\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -10  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -10  | xargs grep -A5 -in Exception',
                'ls.exe -tr \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -10  | xargs grep -A5 -in Exception']

mesg = MIMEMultipart()
today =datetime.date.today()
todayStr = datetime.date.strftime(today,"%m/%d/%y")
mailSubject =  mailSubject+todayStr
filename="C:\Temp\WindchillMethodServerExceptions_"+todayStr.replace("/","_")+".txt"
f = open(filename,'w')
try:
	for command in commandsList:
		p = G.Popen(command, shell=True, stdout=G.PIPE)
		lines = p.stdout.readlines()
		for line in lines:
			if(line.find(todayStr)>0):
				# mesg = mesg+line
				f.write(line)
finally:
    f.close()
f = open(filename,'r')
mesg.attach(MIMEText(f.read()))
for toaddr in mailTo:
	sendTextMail(toaddr,mailSubject,mesg.as_string())

