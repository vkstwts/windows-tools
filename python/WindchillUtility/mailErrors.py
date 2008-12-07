#!/usr/bin/python

import os
import subprocess as G
import smtplib
import datetime
import time
from email.MIMEMultipart import MIMEMultipart
from email.MIMEText import MIMEText


mailServer="mailgw.nvidia.com"
#mailTo=['pyalavarthi@nvidia.com','npamidi@nvidia.com','rajasekaran.p@itcinfotech.com','ysprathap@gmail.com']
mailTo=['pyalavarthi@nvidia.com']
mailSubject="Urgent!!!  Errors found in Windchill MethodServer or Tomcat logs on "

def sendTextMail(to,subject,text):
    frm = "Windchill <pyalavarthi@nvidia.com>"
    mail = MIMEText(text)
    mail['From'] = frm
    mail['Subject'] =subject
    mail['To'] = to
    smtp = smtplib.SMTP(mailServer)
    smtp.sendmail(frm, [to], mail.as_string())
    smtp.close()

commandsList = [ 'ls.exe -tr \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -2  | xargs grep -n -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -n -ferrors.txt',
                'ls.exe -tr \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -n -ferrors.txt']
				# ,
                # 'ls.exe -tr \\\\hqnvptws03\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt',
                # 'ls.exe -tr \\\\hqnvptws04\\E$\\ptc\\Windchill_9.0\\Windchill\\logs\\MethodServer-* | tail.exe -4  | xargs grep -in -ferrors.txt']
tomcatCommandsList = ['grep -n -ferrors.txt  \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\PTCTomcat-stdout.log',
					  'grep -n -ferrors.txt  \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\windchill.log',
					  'grep -n -ferrors.txt  \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\PTCTomcat-stdout.log',
					  'grep -n -ferrors.txt \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\windchill.log',
					  'grep -n -ferrors.txt  \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\PTCTomcat-stdout.log',
					  'grep -n -ferrors.txt  \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Tomcat\\logs\\windchill.log']

apacheCommandsList = [ 'tail -1000  \\\\hqnvptas01\\E$\\ptc\\Windchill_9.0\\Apache\\logs\\access.log | gawk "$3!~/-/ && $12>9999999"',
                'tail -5000  \\\\hqnvptws05\\E$\\ptc\\Windchill_9.0\\Apache\\logs\\access.log | gawk "$3!~/-/ && $12>9999999"',
                'tail -5000  \\\\hqnvptws06\\E$\\ptc\\Windchill_9.0\\Apache\\logs\\access.log | gawk "$3!~/-/ && $12>9999999"']


mesg = MIMEMultipart()
today =datetime.datetime.today()
#todayStr = datetime.date.strftime(today,"%m/%d/%y %H:")
todayStr = str(today.month)+"/"+str(today.day)+"/"+str(today.year)[2:]+" "+datetime.date.strftime(today,"%H:")

tomcatTodayStr = datetime.date.strftime(today,"%Y-%m-%d %H:")

currentMin = datetime.date.strftime(today,"%M")

filename="\\\\hqdvpttmp01\\ExceptionsInProductionlogs\\WindchillMethodServerErrors_"+todayStr.replace("/","_").replace(" ","__").replace(":","_")+currentMin+".txt"
print filename
f = open(filename,'w')
foundErrors=0
try:
	for command in commandsList+tomcatCommandsList:
		p = G.Popen(command, shell=True, stdout=G.PIPE)
		lines = p.stdout.readlines()
		print command
		for line in lines:
			startMin = int(currentMin)-14 
			while startMin <=int(currentMin):
				if startMin < 10:
					searchTimeStr = todayStr+'0'+str(startMin)
					tomcatSearchTimeStr = tomcatTodayStr+'0'+str(startMin)
				else:
					searchTimeStr =  todayStr+str(startMin)
					tomcatSearchTimeStr =  tomcatTodayStr+str(startMin)
				startMin +=1
				if((line.find(searchTimeStr)>0) or (line.find(tomcatSearchTimeStr)>0)):
					print line
					foundErrors=1
					f.write(line)
	foundErrors=1
	if foundErrors==1:
		f.write('\n')
		f.write('\n Time Consuming Requests from Apache logs in the last 15 min\n')
		for command in apacheCommandsList:
			startIndex=command.find('hqnvpt')
			f.write('\n From server '+command[startIndex:startIndex+10]+'\n')			
			p = G.Popen(command, shell=True, stdout=G.PIPE)
			lines = p.stdout.readlines()
			for line in lines:
				startMin = int(currentMin)-14 
				while startMin <=int(currentMin):
					if startMin < 10:
						tomcatSearchTimeStr = tomcatTodayStr+'0'+str(startMin)
					else:
						tomcatSearchTimeStr =  tomcatTodayStr+str(startMin)
					startMin +=1
					if((line.find(tomcatSearchTimeStr)>0)):
						print line
						foundErrors=1
						f.write(line)
		
finally:
    f.close()
print todayStr
print searchTimeStr
print tomcatSearchTimeStr

mailSubject =  mailSubject+searchTimeStr
preambleText='Windchill MethodServer and Tomcat logs are searched for the following error messages and found atleast one of them in the last 15 min.\n\n'

errorsfilename="errors.txt"
errorsFile = open(errorsfilename,'r')
try:
	for line in errorsFile:
		preambleText=preambleText+line
finally:
    f.close()

preambleText=preambleText+"\n You can find the attached log messages in the following file.\n"+filename
mesg.preamble=preambleText
mesg.epilogue='\nEnd of log Messages\n'

if foundErrors==1:
	f = open(filename,'r')
	mesg.attach(MIMEText(f.read()))
	for toaddr in mailTo:
		sendTextMail(toaddr,mailSubject,mesg.as_string())
else:
	#print filename 
	os.remove(filename)
