import os
import time
import sys
import subprocess as G

class Dispatcher:
    
    cmd='psexec'
    ddrive='D:'
    edrive='E:'
    win9=edrive+'\\ptc\\Windchill_9.0'
    wind=win9+'\\Windchill'
    unix=win9+'\\UnxUtils\\usr\\local\\wbin\\'

    version=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe version'
    xconf=wind+'\\bin\\xconfmanager.bat -p'
    touch=unix+'touch.exe '+wind+'\\site.xconf'
    property=unix+'cat.exe '+wind+'\\codebase\\wt.properties '+wind+'\\codebase\\service.properties '+wind+'\\codebase\\WEB-INF\\ie.properties '+wind+'\\db\\db.properties | findstr /i'
    winstatus=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe status'

    statusFile='windStatus.bat'
    stageserversFile='stagingServers.txt'
    prodserversFile='prodServers.txt'

    servers = ['\\\\hqdvpttmp01','\\\\hqqapttmp01','\\\\hqqapttmp02','\\\\hqdvpttg01']
    stageservers = ['\\\\hqstptas01','\\\\hqstptws01','\\\\hqstptws02','\\\\hqstptws03']
    prodservers = ['\\\\hqnvptas01','\\\\hqnvptws03','\\\\hqnvptws04','\\\\hqnvptws05','\\\\hqnvptws06']
    allservers = servers + stageservers + prodservers

    def propogateXconf(self,server):
        touchcmd=self.cmd+" "+server+" "+self.touch
        fullcmd=self.cmd+" "+server+" "+self.xconf
        self.runCommand(touchcmd)
        self.runCommand(fullcmd)

    def propogateXconf1(self,serversFile):
        touchcmd=self.cmd+" @"+serversFile+" "+self.touch
        fullcmd=self.cmd+" @"+serversFile+" "+self.xconf
        self.runCommand(touchcmd)
        self.runCommand(fullcmd)

    def findVersion(self,server):
        versioncmd=self.cmd+" "+server+" "+self.version
        self.runCommand(versioncmd)

    def findVersion1(self,serversFile):
        versioncmd=self.cmd+" @"+serversFile+" "+self.version
        self.runCommand(versioncmd)

    def findProperty(self,server):
        searchString = raw_input("Enter Search String :")
        propertycmd=self.cmd+" "+server+" "+self.property+" "+searchString
        self.runCommand(propertycmd)

    def findProperty1(self,serversFile):
        searchString = raw_input("Enter Search String :")
        propertycmd=self.cmd+" @"+serversFile+" "+self.property+" "+searchString
        self.runCommand(propertycmd)
          
    def findServicesStatus(self,server):
        statuscmd=self.cmd+" "+server+" -c "+self.statusFile
        self.runCommand(statuscmd)

    def findServicesStatus1(self,serversFile):
        statuscmd=self.cmd+" @"+serversFile+" -c "+self.statusFile
        self.runCommand(statuscmd)

    def findWindchillStatus(self,server):
        winstatuscmd=self.cmd+" "+server+" "+self.winstatus
        self.runCommand(winstatuscmd)

    def findWindchillStatus1(self,serversFile):
        winstatuscmd=self.cmd+" @"+serversFile+" "+self.winstatus
        self.runCommand(winstatuscmd)
     
    def updateCommands(self,fromDrive, toDrive):
        self.version = self.version.replace(fromDrive,toDrive)
        self.xconf = self.xconf.replace(fromDrive,toDrive)
        self.touch = self.touch.replace(fromDrive,toDrive)
        self.property = self.property.replace(fromDrive,toDrive)
        self.winstatus = self.winstatus.replace(fromDrive,toDrive)
        
    def runCommand(self,command):
        print 'Command :'+ command
        retcode = G.call(command,shell=True)
        print "Return code :" + str(retcode)
     
    def error(self):
        print 'Error'

    def dispatch(self, command):
        mname = command
        if hasattr(self, mname):
            method = getattr(self, mname)
            method1 = getattr(self,mname+"1")
            if serverOption==serversList.index('Staging')+1:
                method1(self.stageserversFile)
            elif serverOption==serversList.index('Production')+1:
                method1(self.prodserversFile)
            elif serverOption==serversList.index('All'):
                method1(self.allservers)
            elif serverOption==serversList.index('Dev'):
                self.updateCommands("E:","D:")
                server = self.servers[serverOption-1]
                method(server)
                self.updateCommands("D:","E:")
            else:
                server = self.servers[serverOption-1]
                method(server)            
        else:
            self.error()

            
serversList  = [ 'Dev','QA1','QA2','Training','Staging','Production','All','Exit'] 
commandsList = [ ['Propogate Xconf','propogateXconf'],
                ['Find Version','findVersion'],
                ['Find Property','findProperty'],
                ['Find Services Status','findServicesStatus'],
                ['Find Windchill Status','findWindchillStatus'],
                ['Change Server','changeServer'],
                ['Exit','Exit'] ]

def printServerOptions():
    print "\n\n Select the server:"
    for index, item in enumerate(serversList):
        print index+1, item

def printActions():
    print "\n\n Select the Action:"
    for index, item in enumerate(commandsList):
        print index+1, item[0]
        
while True:
    printServerOptions()
    serverOption = int(raw_input())
    if serverOption==len(serversList):
        break
    while True:
        print 'Selected Server :'+str(serverOption)
        printActions()
        action = int(raw_input())
        if action==len(commandsList):
            sys.exit()
        elif action==len(commandsList)-1:
            break;
        else:
            d = Dispatcher()
            d.dispatch(commandsList[action-1][1])
