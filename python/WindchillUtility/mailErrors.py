#!/usr/bin/python

import os
import subprocess as G
import smtplib
import datetime
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText


mailServer="mailgw.nvidia.com"
mailTo=['pyalavarthi@nvidia.com','npamidi@nvidia.com','rajasekaran.p@itcinfotech.com','ysprathap@gmail.com']
#mailTo=['pyalavarthi@nvidia.com']
mailSubject="Urgent!!!  Errors found in Windchill MethodServer logs on "

def sendTextMail(to,subject,text):
    frm = "Windchill <pyalavarthi@nvidia.com>"
    mail = MIMEText(text)
    mail['From'] = frm
    mail['Subject'] =subject
    mail['To'] = to
    smtp = smtplib.SMTP(mailServer)
    smtp.sendmail(frm, [to], mail.as_string())
    smtp.close()


commandsList = [ 'ls.exe -tr \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -in -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws03\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws04\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt']

mesg = MIMEMultipart()
today =datetime.datetime.today()
todayStr = datetime.date.strftime(today,"%m/%d/%y %H:")

#print todayStr
currentMin = datetime.date.strftime(today,"%M")
#print currentMin
startMin = int(currentMin)-14 
#print startMin

mailSubject =  mailSubject+todayStr
filename="\\\\hqdvpttmp01\\ExceptionsInProductionlogs\\WindchillMethodServerErrors_"+todayStr.replace("/","_")+".txt"
f = open(filename,'w')
foundErrors=0
try:
	for command in commandsList:
		p = G.Popen(command, shell=True, stdout=G.PIPE)
		lines = p.stdout.readlines()
		for line in lines:
			while startMin <=int(currentMin):
				if startMin < 10:
					searchTimeStr = todayStr+'0'+str(startMin)
				else:
					searchTimeStr =  todayStr+str(startMin)
				startMin +=1
				#print searchTimeStr
				if(line.find(searchTimeStr)>0):
					foundErrors=1
					f.write(line)
finally:
    f.close()

preambleText='Windchill MethodServer logs are searched for the following error messages and found atleast one of them in the last 15 min.\n\n'

errorsfilename="errors.txt"
errorsFile = open(errorsfilename,'r')
try:
	for line in errorsFile:
		preambleText=preambleText+line
finally:
    f.close()

mesg.preamble=preambleText
mesg.epilogue='\nEnd of log Messages\n'

#foundErrors=1
if foundErrors==1:
	f = open(filename,'r')
	mesg.attach(MIMEText(f.read()))
	#print mesg
	for toaddr in mailTo:
		sendTextMail(toaddr,mailSubject,mesg.as_string())
