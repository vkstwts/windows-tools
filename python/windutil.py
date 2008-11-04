import os
import time
import sys

#Define Global Variables
cmd='psexec'
ddrive='D:'
edrive='E:'
win9=edrive+'\\ptc\\Windchill_9.0'
wind=win9+'\\Windchill'
unix=win9+'\\UnxUtils\\usr\\local\\wbin\\'

version=wind+'\\bin\\windchill.exe version'
xconf=wind+'\\bin\\xconfmanager.bat -p'
touch=unix+'touch.exe '+wind+'\\site.xconf'
property=unix+'cat.exe '+wind+'\\codebase\\wt.properties '+wind+'\\codebase\\service.properties '+wind+'\\codebase\\WEB-INF\\ie.properties '+wind+'\\db\\db.properties | findstr /i'

statusFile='C:\\Dev\\bin\\windStatus.bat'
stageserversFile='C:\\Dev\\bin\\stagingServers.txt'
prodserversFile='C:\\Dev\\bin\\prodServers.txt'

servers = ['\\\\hqdvpttmp01','\\\\hqqapttmp01','\\\\hqqapttmp02','\\\\hqdvpttg01']
stageservers = ['\\\\hqstptas01','\\\\hqstptws01','\\\\hqstptws02','\\\\hqstptws03']
prodservers = ['\\\\hqnvptas01','\\\\hqnvptws03','\\\\hqnvptws04','\\\\hqnvptws05','\\\\hqnvptws06']
allservers = servers + stageservers + prodservers
server = '\\\hqdvpttmp01'

 
def propogateXconf(server):
    touchcmd=cmd+" "+server+" "+touch
    fullcmd=cmd+" "+server+" "+xconf
    print "Running on Server :"+server
    os.system(touchcmd)
    os.system(fullcmd)

def propogateXconf1(servers):
    for server in servers:
        propogateXconf(server)

def findVersion(server):
    versioncmd=cmd+" "+server+" "+version
    print "Running on Server :"+server
    os.system(versioncmd)

def findVersion1(servers):
    for server in servers:
        findVersion(server)

def findProperty(server,searchString):
    propertycmd=cmd+" "+server+" "+property+" "+searchString
    print "Running on Server :"+server
    os.system(propertycmd)

def findProperty1(servers,searchString):
    for server in servers:
        findProperty(server,searchString)
         
def findStatus(server):
    statuscmd=cmd+" "+server+" -c "+statusFile
    print "Running on Server :"+server
    print "statuscmd :"+statuscmd
    os.system(statuscmd)

def findStatus1(serversFile):
    statuscmd=cmd+" @"+serversFile+" -c "+statusFile
    print "Running on Server :"+server
    os.system(statuscmd)

def updateCommands(fromDrive, toDrive):
    global version
    global xconf
    global touch
    global property
    version = version.replace(fromDrive,toDrive)
    xconf = xconf.replace(fromDrive,toDrive)
    touch = touch.replace(fromDrive,toDrive)
    property = property.replace(fromDrive,toDrive)

def runCommands():
    propogateXconf(server)

DEV = 1
QA1 = 2
QA2 = 3
TRAINING = 4
STAGING  = 5
PRODUCTION = 6
ALL = 7
EXIT = 8
def printServers():
    print "Select the server:"
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
FIND_STATUS     = 4
CHANGE_SERVER   = 5
EXIT_ACTIONS    = 6
def printActions():
    print "Select the Action:"
    print str(PROPOGATE_XCONF)+".Propogate Xconf"
    print str(FIND_VERSION)+".Find Version"
    print str(FIND_PROPERTY)+".Find Property"
    print str(FIND_STATUS)+".Find Status"
    print str(CHANGE_SERVER)+".Change Server"
    print str(EXIT_ACTIONS)+".Exit"
        
while True:
    printServers()
    serverOption = int(raw_input())
    if serverOption==EXIT:
        break
    while True:
        printActions()
        action = int(raw_input())
        if action==EXIT_ACTIONS:
            sys.exit()
        elif action==PROPOGATE_XCONF:
            if serverOption==STAGING:
                propogateXconf1(stageservers)
                continue
            elif serverOption==PRODUCTION:
                propogateXconf1(prodservers)
                continue
            elif serverOption==ALL:
                propogateXconf1(allservers)
                continue
            elif serverOption==DEV:
                updateCommands(edrive,ddrive)
                server = servers[serverOption-1]
                propogateXconf(server)
                updateCommands(ddrive,edrive)
                continue
            server = servers[serverOption-1]
            propogateXconf(server)
        elif action==FIND_VERSION:
            if serverOption==STAGING:
                findVersion1(stageservers)
                continue
            elif serverOption==PRODUCTION:
                findVersion1(prodservers)
                continue
            elif serverOption==ALL:
                findVersion1(allservers)
                continue
            elif serverOption==DEV:
                updateCommands("E:","D:")
                server = servers[serverOption-1]
                findVersion(server)
                updateCommands("D:","E:")
                continue
            server = servers[serverOption-1]
            findVersion(server)
        elif action==FIND_PROPERTY:
            searchString = raw_input("Enter Search String :")
            if serverOption==STAGING:
                findProperty1(stageservers,searchString)
                continue
            elif serverOption==PRODUCTION:
                findProperty1(prodservers,searchString)
                continue
            elif serverOption==ALL:
                findProperty1(allservers,searchString)
                continue
            elif serverOption==DEV:
                updateCommands("E:","D:")
                server = servers[serverOption-1]
                findProperty(server,searchString)
                updateCommands("D:","E:")
                continue
            server = servers[serverOption-1]
            findProperty(server,searchString)
        elif action==FIND_STATUS:
            if serverOption==STAGING:
                findStatus1(stageserversFile)
                continue
            elif serverOption==PRODUCTION:
                findStatus1(prodserversFile)
                continue
            elif serverOption==ALL:
                findStatus1(allservers)
                continue
            elif serverOption==DEV:
                updateCommands("E:","D:")
                server = servers[serverOption-1]
                findStatus(server)
                updateCommands("D:","E:")
                continue
            server = servers[serverOption-1]
            findStatus(server)
        elif action==CHANGE_SERVER:
            break    


##class Dispatcher:
##
##    def do_get(self): 
##
##    def do_put(self): 
##
##    def error(self): 
##
##    def dispatch(self, command):
##        mname = 'do_' + command
##        if hasattr(self, mname):
##            method = getattr(self, mname)
##            method()
##        else:
##            self.error()