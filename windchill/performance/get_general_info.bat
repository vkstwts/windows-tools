@echo off
REM **** Save Windows Windows current information in timestamped files

  
set timestamp=2008-09-03_0900
REM 10:51:39.61 Tue 05/29/2007

@echo timestamp=%timestamp%

md "%timestamp%"
cd "%timestamp%"

tasklist /V                                    >"%timestamp%_tasklist_v.txt"
tasklist /M                                    >"%timestamp%_tasklist_m.txt"
tasklist /SVC                                  >"%timestamp%_tasklist_svc.txt"

systeminfo                                     >"%timestamp%_systeminfo.txt"
systeminfo /fo TABLE                           >"%timestamp%_systeminfo_table.txt"

netstat -a                                     >"%timestamp%_netstat-a.txt"
netstat -es                                    >"%timestamp%_netstat-es.txt"
netstat -o                                    >"%timestamp%_netstat-ob.txt"

WMIC PROCESS get /ALL                          >"%timestamp%_wmic_process_all.txt"
WMIC PROCESS get /ALL /VALUE                   >"%timestamp%_wmic_process_value.txt"
WMIC PROCESS get Processid,Commandline /VALUE  >"%timestamp%_wmic_process_PidCmd.txt"

cd ..
