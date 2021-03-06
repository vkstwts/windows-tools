import os
import time
import sys
import subprocess as G
import urllib2
import httplib


class Dispatcher:
    
    cmd='psexec'
    ddrive='D:'
    edrive='E:'
    win9=edrive+'\\ptc\\Windchill_9.0'
    wind=win9+'\\Windchill'
    unix=win9+'\\UnxUtils\\usr\\local\\wbin\\'

    version=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe version'
    xconf=wind+'\\bin\\xconfmanager.bat -p'
    xconfAdd=wind+'\\bin\\xconfmanager.bat -t codebase/wt.properties -p -s '
    xconfReset=wind+'\\bin\\xconfmanager.bat -t codebase/wt.properties -p --reset '
    xconfUndefine=wind+'\\bin\\xconfmanager.bat -t codebase/wt.properties -p --undefine '
    touch=unix+'touch.exe '+wind+'\\site.xconf'
    property=unix+'cat.exe '+wind+'\\codebase\\wt.properties '+wind+'\\codebase\\service.properties '+wind+'\\codebase\\WEB-INF\\ie.properties '+wind+'\\codebase\\com\\ptc\\windchill\\esi\\esi.properties '+wind+'\\db\\db.properties | grep.exe -in'
    ''' can also use command windchill wt.manager.RemoteManagerServer'''
    winstatus=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe status' 
    winmethodstatus=wind+'\\bin\\windchill.exe --java='+win9+'\\Java\\bin\\java.exe wt.method.RemoteMethodServer'
    tailtomcat=unix+'tail.exe  '+win9+'\\Tomcat\\logs\\PTCTomcat-stdout.log'
    tailapache=unix+'tail.exe  '+win9+'\\Apache\\logs\\error.log'
    lesswt=unix+'less.exe -iMN '+wind+'\\codebase\\wt.properties'
    lessdb=unix+'less.exe -iMN '+wind+'\\db\\db.properties'
    sysinfo='systeminfo | grep -i -e "OS" -e "memory" -e "processor"'
    glogs='ls.exe -tr '+wind+'\\logs\\MethodServer-* | tail.exe -2 | xargs.exe grep.exe -in -A4 '
    echourl='/Windchill/servlet/WindchillGW/wt.httpgw.HTTPServer/echo'
    protocol='http://'
    domain='nvidia.com'
    
    statusFile='.\\windStatus.bat'
    stopFile='.\\windStop.bat'
    startFile='.\\windStart.bat'
    stageserversFile='.\\stagingServers.txt'
    prodserversFile='.\\prodServers.txt'
    devengserversFile='.\\devEngServers.txt'
    tailmsFile='.\\tailms.bat'
    
    monoservers = ['\\\\hqdvpttmp01','\\\\hqqapttmp01','\\\\hqqapttmp02','\\\\hqdvpttg01']
    devengservers = ['\\\\hqdvptas01','\\\\hqdvptws01','\\\\hqdvptws02']
    stageservers = ['\\\\hqstptas01','\\\\hqstptws01','\\\\hqstptws02','\\\\hqstptws03']
    prodservers = ['\\\\hqnvptas01','\\\\hqnvptws05','\\\\hqnvptws06','\\\\hqnvptws07']

    allservers = monoservers + stageservers + prodservers

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

    def addProperty(self,server):
        propertyNameAndValue = raw_input("Ex: wt.inf.container.SiteOrganization.name=\"ACME Corporation\"\nEnter the Property name and value as shown above: ")
        addpropertycmd=self.cmd+" "+server+" "+self.xconfAdd+" "+propertyNameAndValue
        self.runCommand(addpropertycmd)
        

    def undefineProperty(self,server):
        propertyName = raw_input("Ex: wt.inf.container.SiteOrganization.name \nEnter the Property name as shown above: ")
        undefinepropertycmd=self.cmd+" "+server+" "+self.xconfUndefine+" "+propertyName
        self.runCommand(undefinepropertycmd)

    def resetProperty(self,server):
        propertyName = raw_input("Ex: wt.inf.container.SiteOrganization.name \nEnter the Property name as shown above: ")
        resetpropertycmd=self.cmd+" "+server+" "+self.xconfReset+" "+propertyName
        self.runCommand(resetpropertycmd)

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
        winmethodstatuscmd=self.cmd+" "+server+" "+self.winmethodstatus
        self.runCommand(winmethodstatuscmd)

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

    def findSystemInfo(self,server):
        sysinfocmd=self.cmd+" "+server+" "+self.sysinfo
        self.runCommand(sysinfocmd)

    def searchMSLogs(self,server):
        searchString = raw_input("Enter Search String :")
        glogscmd=self.cmd+" "+server+" \'"+self.glogs+"\' "+searchString
        self.runCommand(glogscmd)

    def pingServer(self,server):
        if serverOption==serversList.index('Staging')+1:
            self.protocol='https://'
            for node in self.stageservers:
                self.pingNode(node)
        elif serverOption==serversList.index('Production')+1:
            self.protocol='https://'
            for node in self.prodservers:
                self.pingNode(node)
        else:
            self.protocol='http://'
            self.pingNode(server)

    def pingNode(self,server):
        echourlString =server[2:]+'.'+self.domain
        print echourlString
        try:
            conn = httplib.HTTPConnection(echourlString,80)
            print self.echourl
            conn.request("GET", self.echourl)
            r1 = conn.getresponse()
            print r1.status, r1.reason
        except Exception, e:
            if hasattr(e, 'reason'):
                print 'We failed to reach a server.'
                print 'Reason: ', e.reason
            elif hasattr(e, 'code'):
                print 'The server couldn\'t fulfill the request.'
                print 'Error code: ', e.code
            else:
                print 'Exception occured'+str(e)
            
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
        
    def printNodes(self,servers):
        print "\n\n Select a Node:"
        for index, item in enumerate(servers):
            print index+1, item[2:]
            if(index == len(servers)-1):
                print index+2, 'All'
        print "\n Enter 0 to exit"	
        
    def dispatchCluster(self,method,servers,serversFile):
        self.printNodes(servers)
        nodeOption = int(raw_input())
        print 'Node :'+ str(nodeOption)
        if nodeOption==0:
            sys.exit()
        elif nodeOption==len(servers)+1:
            print 'Calling all nodes'
            method("@"+serversFile)
        else:
            server = servers[nodeOption-1]
            method(server)   
            
    def dispatch(self, command):
        mname = command
        if hasattr(self, mname):
            method = getattr(self, mname)
            if serverOption==serversList.index('Staging')+1:
                self.dispatchCluster(method,self.stageservers,self.stageserversFile)
            elif serverOption==serversList.index('Production')+1:
                self.dispatchCluster(method,self.prodservers,self.prodserversFile)
            elif serverOption==serversList.index('DevEng')+1:
                self.dispatchCluster(method,self.devengservers,self.devengserversFile)
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
                server = self.monoservers[serverOption-1]
                method(server)
                self.changeDriveLetter("D:","E:")
            else:
                server = self.monoservers[serverOption-1]
                method(server)            
        else:
            self.error()

            
serversList  = [ 'Dev','QA1','QA2','DevEng','Training','Staging','Production','All'] 
commandsList = [ ['Propogate Xconf','propogateXconf'],
                ['Search Property files','findProperty'],
                ['Add/Update Property ','addProperty'],
                ['Undefine Property ','undefineProperty'],
                ['Reset Property ','resetProperty'],
                ['Ping server','pingServer'],
                ['Find Services Status','findServicesStatus'],
                ['Stop Services ','stopServices'],
                ['Start Services ','startServices'],
                ['Find Windchill Version','findVersion'],
                ['Find Windchill Status','findWindchillStatus'],
                ['Change Server','changeServer']]

'''Other possible functions
['Search Log files','searchMSLogs'],
['Tail MethodServer logs','tailMethodServerLogs'],
['Tail Tomcat log','tailTomcatLog'],
['Tail Apache Error log','tailApacheLog'],
['View wt.properties','lessWT'],
['View db.properties','lessDB'],
['Find System Info','findSystemInfo'],'''
                

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
    try:
        serverOption = int(raw_input())
    except ValueError:
        print '\n\n\n\n ****** Please enter a numeric value ******'
        continue 
    if serverOption==0:
        break
    elif serverOption>len(serversList):
        print '\n\n\n\n ****** Please enter valid entry ******'
        continue
    while True:
        print '\n\n Selected Server :'+serversList[serverOption-1]
        printActions()
        try:
            action = int(raw_input())
        except ValueError:
            print '\n\n\n\n ****** Please enter a numeric value ******'
            continue  
        if action==0:
            sys.exit()
        elif action==len(commandsList):
            break;
        elif action>0 and action<len(commandsList):
            d = Dispatcher()
            d.dispatch(commandsList[action-1][1])
        else:
            print '\n\n\n****** Please enter valid entry ******'
            continue 