import win32com.client
import time

def WMIDateStringToDate(dtmDate):
    strDateTime = ""
    if (dtmDate[4] == 0):
        strDateTime = dtmDate[5] + '/'
    else:
        strDateTime = dtmDate[4] + dtmDate[5] + '/'
    if (dtmDate[6] == 0):
        strDateTime = strDateTime + dtmDate[7] + '/'
    else:
        strDateTime = strDateTime + dtmDate[6] + dtmDate[7] + '/'
        strDateTime = strDateTime + dtmDate[0] + dtmDate[1] + dtmDate[2] + dtmDate[3] + " " + dtmDate[8] + dtmDate[9] + ":" + dtmDate[10] + dtmDate[11] +':' + dtmDate[12] + dtmDate[13]
    return strDateTime

strComputer = "."
#strComputer = "\\hqdvpttmp01"
objWMIService = win32com.client.Dispatch("WbemScripting.SWbemLocator")
objSWbemServices = objWMIService.ConnectServer(strComputer,"root\cimv2")
colItems = objSWbemServices.ExecQuery("SELECT * FROM Win32_Process")
for objItem in colItems:
    print "-----------------------"
    commandLine = `objItem.CommandLine`
    if commandLine.lower().find("apachejmeter")>0:
        print "Jmeter found"
        if objItem.Caption != None:
            print "Caption:" + ` objItem.Caption`
        if objItem.CommandLine != None:
            print "CommandLine:" + ` objItem.CommandLine`
        if objItem.CreationDate != None:
            print "CreationDate:" + WMIDateStringToDate(objItem.CreationDate)
        if objItem.Description != None:
            print "Description:" + ` objItem.Description`
        if objItem.ExecutablePath != None:
            print "ExecutablePath:" + ` objItem.ExecutablePath`
        if objItem.ExecutionState != None:
            print "ExecutionState:" + ` objItem.ExecutionState`
        if objItem.Name != None:
            print "Name:" + ` objItem.Name`
        if objItem.ParentProcessId != None:
            print "ParentProcessId:" + ` objItem.ParentProcessId`
        if objItem.ProcessId != None:
            print "ProcessId:" + ` objItem.ProcessId`
        if objItem.Status != None:
            print "Status:" + ` objItem.Status`
        if objItem.TerminationDate != None:
            print "TerminationDate:" + WMIDateStringToDate(objItem.TerminationDate)

time.sleep(25)            
