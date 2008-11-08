import os
import time
import sys
import subprocess as G

class Dispatcher:
    #Define Global Variables
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

    statusFile='C:\\Dev\\bin\\windStatus.bat'
    stageserversFile='C:\\Dev\\bin\\stagingServers.txt'
    prodserversFile='C:\\Dev\\bin\\prodServers.txt'

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
          
    def findStatus(self,server):
        statuscmd=self.cmd+" "+server+" -c "+self.statusFile
        self.runCommand(statuscmd)

    def findStatus1(self,serversFile):
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
    ##    p = G.Popen(command, shell=True, stdout=G.PIPE)
    ##    lines = p.stdout.readlines()
    ##    for line in lines:
    ##        print line
    
    def error(self):
        print 'Error'

    def dispatch(self, command):
        mname = command
        if hasattr(self, mname):
            method = getattr(self, mname)
            method1 = getattr(self,mname+"1")
            if serverOption==STAGING:
                method1(self.stageserversFile)
            elif serverOption==PRODUCTION:
                method1(self.prodserversFile)
            elif serverOption==ALL:
                method1(self.allservers)
            elif serverOption==DEV:
                self.updateCommands("E:","D:")
                server = self.servers[serverOption-1]
                method(server)
                self.updateCommands("D:","E:")
            else:
                server = self.servers[serverOption-1]
                method(server)            
        else:
            self.error()
            

DEV = 1
QA1 = 2
QA2 = 3
TRAINING = 4
STAGING  = 5
PRODUCTION = 6
ALL = 7
EXIT = 8
def printServers():
    print "\n\n Select the server:"
    print str(DEV)+".Dev"
    print str(QA1)+".QA1"
    print str(QA2)+".QA2"
    print str(TRAINING)+".Training"
    print str(STAGING)+".Stage"
    print str(PRODUCTION)+".Production"
    print str(ALL)+".All"
    print str(EXIT)+".Exit"

PROPOGATE_XCONF = 1
FIND_VERSION    = 2
FIND_PROPERTY   = 3
FIND_SERVICES_STATUS     = 4
FIND_WINDCHILL_STATUS = 5
CHANGE_SERVER   = 6
EXIT_ACTIONS    = 7
def printActions():
    print "\n\n Select the Action:"
    print str(PROPOGATE_XCONF)+".Propogate Xconf"
    print str(FIND_VERSION)+".Find Version"
    print str(FIND_PROPERTY)+".Find Property"
    print str(FIND_SERVICES_STATUS)+".Find Services Status"
    print str(FIND_WINDCHILL_STATUS)+".Find Windchill Status"
    print str(CHANGE_SERVER)+".Change Server"
    print str(EXIT_ACTIONS)+".Exit"
        
while True:
    printServers()
    serverOption = int(raw_input())
    if serverOption==EXIT:
        break
    while True:
        print 'Selected Server :'+str(serverOption)
        printActions()
        action = int(raw_input())
        d = Dispatcher()
        if action==EXIT_ACTIONS:
            sys.exit()
        elif action==PROPOGATE_XCONF:
            d.dispatch('propogateXconf')
        elif action==FIND_VERSION:
            d.dispatch('findVersion')
        elif action==FIND_PROPERTY:
            d.dispatch('findProperty')
        elif action==FIND_SERVICES_STATUS:
            d.dispatch('findStatus')
        elif action==FIND_WINDCHILL_STATUS:
            d.dispatch('findWindchillStatus')
        elif action==CHANGE_SERVER:
            break    