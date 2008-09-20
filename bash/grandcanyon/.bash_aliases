#source profile
alias sprof='source /home/wcadmin/.bash_profile'

alias taccess='tail -f /cygdrive/d/ptc/Windchill9/Apache/logs/access.log'
alias terror='tail -f /cygdrive/d/ptc/Windchill9/Apache/logs/error.log'
alias tms='tail -f `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -1`'
alias tms1='tail -f `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -2`'
alias tbms='tail -f `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/BackgroundMethodServer*.log | tail -1`'
alias tsm='tail -f `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/ServerManager*.log | tail -1`'
alias tlogs='tail -f `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/*Server*.log | tail -6`'
alias tmlogs='tail -f `ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/*MethodServer[0-9]?*.log | tail -2`'

alias lms='less `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -1`'
alias lms1='less `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -2`'
alias lbms='less `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/BackgroundMethodServer*.log | tail -1`'
alias lsm='less `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/ServerManager*.log | tail -1`'
alias llogs='less `ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/*Server*.log | tail -6`'
alias lmlogs='less `ls -tr   /cygdrive/d/ptc/Windchill9/Windchill/logs/*MethodServer[0-9]?*.log | tail -2`'

alias ms='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -1'
alias ms1='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/MethodServer*.log | tail -2'
alias bms='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/BackgroundMethodServer*.log | tail -1'
alias sm='ls -tr  /cygdrive/d/ptc/Windchill9/Windchill/logs/ServerManager*.log | tail -1'
alias logs='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/*Server*.log | tail -6'
alias mlogs='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/*MethodServer[0-9]?*.log | tail -2'

#windchill directories
alias cdw='cd /cygdrive/d/ptc/Windchill9/Windchill/'
alias cdc='cd /cygdrive/d/ptc/Windchill9/Windchill/codebase'
alias cdl='cd /cygdrive/d/ptc/Windchill9/Windchill/logs'
alias cda='cd /cygdrive/d/ptc/Windchill9/Apache'
alias cdt='cd /cygdrive/d/ptc/Windchill9/Tomcat'
alias cdh='cd /cygdrive/d/ptc/Windchill9/Aphelion'
alias cdj='cd /cygdrive/d/ptc/Windchill9/Java'

#grep windchill property files
alias gwt='cat /cygdrive/d/ptc/Windchill9/Windchill/codebase/wt.properties | grep -i $1'
alias gie='cat /cygdrive/d/ptc/Windchill9/Windchill/codebase/WEB-INF/ie.properties | grep -i $1'
alias gdb='cat /cygdrive/d/ptc/Windchill9/Windchill/db/db.properties | grep -i $1'
alias wt='/cygdrive/d/ptc/Windchill9/Windchill/bin/windchill.exe properties wt.properties?$1'
#alias glogs='ls -trC1  /cygdrive/d/ptc/Windchill9/Windchill/logs/*Server*.log | tail -4 | xargs | cat | grep -i $1'
alias glogs='cat `logs` | grep -i $1'
alias gmlogs='cat `mlogs` | grep -i $1'
alias gapache='cat /cygdrive/d/ptc/Windchill9/Apache/conf/extra/app*conf | grep -i $1'
alias gaccess='cat /cygdrive/d/ptc/Windchill9/Apache/logs/access.log | grep -i $1'
alias gerror='cat /cygdrive/d/ptc/Windchill9/Apache/logs/error.log | grep -i $1'


#ls aliases
alias ll='ls -ltr'
alias la='ls -Al'
alias l='ls -CF'
alias lll='ls -ltr | less'

