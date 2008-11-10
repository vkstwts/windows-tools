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
    #property=unix+'cat.exe '+wind+'\\codebase\\wt.properties '+wind+'\\codebase\\service.properties '+wind+'\\codebase\\WEB-INF\\ie.properties '+wind+'\\db\\db.properties | findstr /iN /A:74'
    property=unix+'cat.exe '+wind+'\\codebase\\wt.properties '+wind+'\\codebase\\service.properties '+wind+'\\codebase\\WEB-INF\\ie.properties '+wind+'\\db\\db.properties | grep.exe -in'
    winstatus=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe status'
    tailtomcat=unix+'tail.exe  '+win9+'\\Tomcat\\logs\\PTCTomcat-stdout.log'
    tailapache=unix+'tail.exe  '+win9+'\\Apache\\logs\\error.log'
    lesswt=unix+'less.exe -iMN '+wind+'\\codebase\\wt.properties'
    lessdb=unix+'less.exe -iMN '+wind+'\\db\\db.properties'
    
    statusFile='.\\windStatus.bat'
    stopFile='.\\windStop.bat'
    startFile='.\\windStart.bat'
    stageserversFile='.\\stagingServers.txt'
    prodserversFile='.\\prodServers.txt'
    tailmsFile='.\\tailms.bat'
    
    servers = ['\\\\hqdvpttmp01','\\\\hqstptas01','\\\\hqqapttmp01','\\\\hqqapttmp02','\\\\hqdvpttg01']
    stageservers = ['\\\\hqstptas01','\\\\hqstptws01','\\\\hqstptws02','\\\\hqstptws03']
    prodservers = ['\\\\hqnvptas01','\\\\hqnvptws03','\\\\hqnvptws04','\\\\hqnvptws05','\\\\hqnvptws06']

    allservers = servers + stageservers + prodservers

    def propogateXconf(self,server):
        touchcmd=self.cmd+" "+server+" "+self.touch
        fullcmd=self.cmd+" "+server+" "+self.xconf
        self.runCommand(touchcmd)
        self.runCommand(fullcmd)

    def findVersion(self,server):
        versioncmd=self.cmd+" "+server+" "+self.version
        self.runCommand(versioncmd)

    def findProperty(self,server):
        searchString = raw_input("Enter Search String :")
        propertycmd=self.cmd+" "+server+" "+self.property+" "+searchString
        self.runCommand(propertycmd)

    def findServicesStatus(self,server):
        statuscmd=self.cmd+" "+server+" -c "+self.statusFile
        self.runCommand(statuscmd)

    def stopServices(self,server):
        stopcmd=self.cmd+" "+server+" -c "+self.stopFile
        self.runCommand(stopcmd)

    def startServices(self,server):
        startcmd=self.cmd+" "+server+" -c "+self.startFile
        self.runCommand(startcmd)

    def findWindchillStatus(self,server):
        winstatuscmd=self.cmd+" "+server+" "+self.winstatus
        self.runCommand(winstatuscmd)

    def tailMethodServerLogs(self,server):
        tailmscmd=self.cmd+" "+server+" -c "+self.tailmsFile
        self.runCommand(tailmscmd)

    def tailTomcatLog(self,server):
        tailtomcatcmd=self.cmd+" "+server+" "+self.tailtomcat
        self.runCommand(tailtomcatcmd)

    def tailApacheLog(self,server):
        tailapachecmd=self.cmd+" "+server+" "+self.tailapache
        self.runCommand(tailapachecmd)

    def lessWT(self,server):
        lesswtcmd=self.cmd+" "+server+" "+self.lesswt
        self.runCommand(lesswtcmd)

    def lessDB(self,server):
        lessdbcmd=self.cmd+" "+server+" "+self.lessdb
        self.runCommand(lessdbcmd)

    def changeDriveLetter(self,fromDrive, toDrive):
        self.version = self.version.replace(fromDrive,toDrive)
        self.xconf = self.xconf.replace(fromDrive,toDrive)
        self.touch = self.touch.replace(fromDrive,toDrive)
        self.property = self.property.replace(fromDrive,toDrive)
        self.winstatus = self.winstatus.replace(fromDrive,toDrive)
        self.tailtomcat = self.tailtomcat.replace(fromDrive,toDrive)
        self.tailapache = self.tailapache.replace(fromDrive,toDrive)
        self.lesswt = self.lesswt.replace(fromDrive,toDrive)
        self.lessdb = self.lessdb.replace(fromDrive,toDrive)
        
    def runCommand(self,command):
        print 'Command :'+ command
        retcode = G.call(command,shell=True)
        print "Return code :" + str(retcode)
     
    def error(self):
        print 'No Such Method Error'

    def dispatch(self, command):
        mname = command
        if hasattr(self, mname):
            method = getattr(self, mname)
            if serverOption==serversList.index('Staging')+1:
                method("@"+self.stageserversFile)
            elif serverOption==serversList.index('Production')+1:
                method("@"+self.prodserversFile)
            elif serverOption==serversList.index('All')+1:
                for index, server in enumerate(self.allservers):
                    if(index ==0):
                        self.changeDriveLetter("E:","D:")
                        method(server)
                        self.changeDriveLetter("D:","E:")
                    else :
                        method(server)
            elif serverOption==serversList.index('Dev')+1:
                self.changeDriveLetter("E:","D:")
                server = self.servers[serverOption-1]
                method(server)
                self.changeDriveLetter("D:","E:")
            else:
                server = self.servers[serverOption-1]
                method(server)            
        else:
            self.error()

            
serversList  = [ 'Dev','QA1','QA2','Training','Staging','Production','All'] 
commandsList = [ ['Propogate Xconf','propogateXconf'],
                ['Search Property files','findProperty'],
                ['Tail MethodServer logs','tailMethodServerLogs'],
                ['Tail Tomcat log','tailTomcatLog'],
                ['Tail Apache Error log','tailApacheLog'],
                ['View wt.properties','lessWT'],
                ['View db.properties','lessDB'],
                ['Find Services Status','findServicesStatus'],
                ['Stop Services ','stopServices'],
                ['Start Services ','startServices'],
                ['Find Windchill Version','findVersion'],
                ['Find Windchill Status','findWindchillStatus'],
                ['Change Server','changeServer']]

def printServerOptions():
    print "\n\n Select a server:"
    for index, item in enumerate(serversList):
        print index+1, item
    print "\n Enter 0 to exit"
    
def printActions():
    print "\n Select an action:"
    for index, item in enumerate(commandsList):
        print index+1, item[0]
    print "\n Enter 0  to exit"
    
while True:
    printServerOptions()
    serverOption = int(raw_input())
    if serverOption==0:
        break
    while True:
        print '\n\n Selected Server :'+serversList[serverOption-1]
        printActions()
        action = int(raw_input())
        if action==0:
            sys.exit()
        elif action==len(commandsList):
            break;
        else:
            d = Dispatcher()
            d.dispatch(commandsList[action-1][1])
