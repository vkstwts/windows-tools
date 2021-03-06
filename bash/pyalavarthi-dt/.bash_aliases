#source bashrc file
alias sbash='source ~/.bashrc'

#Tail commands
alias taccess='tail -f $WINDCHILL9/Apache/logs/access.log '
alias terror='tail -f $WINDCHILL9/Apache/logs/error.log'
alias tcat='tail -f $WINDCHILL9/Tomcat/logs/PTCTomcat-stdout.log'
alias twin='tail -f $WINDCHILL9/Tomcat/logs/windchill.log'
alias tms='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -1`'
alias tms1='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -2 | head -1`'
alias tms2='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -3 | head -1`'
alias tbms='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/BackgroundMethodServer-*.log | tail -1`'
alias tsm='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/ServerManager*.log | tail -1`'
alias tlogs='tail -f `ls -tr  $WINDCHILL9/Windchill/logs/*Server*.log | tail -6`'
alias tmlogs='tail -f `ls -trC1  $WINDCHILL9/Windchill/logs/*MethodServer-*.log | tail -2`'
alias users='~/users.sh'
alias usersStage='~/usersStage.sh'
alias prodUsers='~/prodUsers.sh'   
alias grepall='~/grepall.sh'
alias gtoday='grep $(date +%d/%b/%Y)'
#alias guser='grep $(date +%Y-%m-%d)/cygdrive/h/ptc/Windchill_9.0/Apache/logs/access.log  /cygdrive/i/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/j/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/k/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/l/ptc/Windchill_9.0/Apache/logs/access.log | gawk \'$3!~/-/ {print $3 }\'| grep $1'

#less commands
alias laccess='less -iMN +G $WINDCHILL9/Apache/logs/access.log'
alias lerror='less -iMN +G $WINDCHILL9/Apache/logs/error.log'
alias lcat='less -iMN +G $WINDCHILL9/Tomcat/logs/PTCTomcat-stdout.log'
alias lwin='less -iMN +G $WINDCHILL9/Tomcat/logs/windchill.log'
alias lms='less -iMN +G `ls -tr  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -1`'
alias lms1='less -iMN +G `ls -tr  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -2`'
alias lbms='less -iMN +G `ls -tr  $WINDCHILL9/Windchill/logs/BackgroundMethodServer-*.log | tail -1`'
alias lsm='less -iMN +G `ls -tr  $WINDCHILL9/Windchill/logs/ServerManager*.log | tail -1`'
alias llogs='less -iMN +G `ls -tr  $WINDCHILL9/Windchill/logs/*Server*.log | tail -6`'
alias lmlogs='less -iMN +G `ls -tr   $WINDCHILL9/Windchill/logs/*MethodServer-*.log | tail -2`'

#list commands
alias ms='ls -trC1  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -1'
alias ms1='ls -trC1  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -2 | head -1'
alias ms2='ls -trC1  $WINDCHILL9/Windchill/logs/MethodServer-*.log | tail -3 | head -1'
alias bms='ls -trC1  $WINDCHILL9/Windchill/logs/BackgroundMethodServer-*.log | tail -1'
alias sm='ls -tr  $WINDCHILL9/Windchill/logs/ServerManager*.log | tail -1'
alias logs='ls -trC1  $WINDCHILL9/Windchill/logs/*Server*.log | tail -10'
alias mlogs='ls -trC1  $WINDCHILL9/Windchill/logs/*MethodServer-*.log | tail -10'
alias access='ls -trC1 $WINDCHILL9/Apache/logs/access.log'
alias error='ls -trC1 $WINDCHILL9/Apache/logs/error.log'
alias tomcat='ls -trC1 $WINDCHILL9/Tomcat/logs/PTCTomcat-stdout.log'
alias win='ls -trC1 $WINDCHILL9/Tomcat/logs/windchill.log'
alias lall='less -iMN ++G `ms` `sm` `cat` `error`'  
#alias lall='less -iMN ++G `ms` `ms1` `sm` `tomcat` `win` `error` `access`'

#windchill directories
alias cdw='cd $WINDCHILL9/Windchill/'
alias cdc='cd $WINDCHILL9/Windchill/codebase'
alias cdl='cd $WINDCHILL9/Windchill/logs'
alias cda='cd $WINDCHILL9/Apache'                                     
alias cdt='cd $WINDCHILL9/Tomcat'
alias cdh='cd $WINDCHILL9/Aphelion'	
alias cdj='cd $WINDCHILL9/Java'
alias cdr='cd $WINDCHILL9/Reporting'

#grep windchill property files
alias gwt='cat $WINDCHILL9/Windchill/codebase/wt.properties | grep -in $1'
alias gawt='~/grepall.sh $1'
alias gprop='grep -in -f ~/properties.txt $WINDCHILL9/Windchill/codebase/wt.properties'
alias gservice='cat $WINDCHILL9/Windchill/codebase/service.properties | grep -in $1'
alias gie='cat $WINDCHILL9/Windchill/codebase/WEB-INF/ie.properties | grep -in $1'
alias gdb='cat $WINDCHILL9/Windchill/db/db.properties | grep -in $1'
alias gsite='cat $WINDCHILL9/Windchill/site.xconf | grep -inC2 $1'
#alias glogs='ls -trC1  $WINDCHILL9/Windchill/logs/*Server*.log | tail -4 | xargs | cat | grep -in $1'
#alias glogs='cat `logs` | grep -in $1'
alias gmlogs='cat `mlogs` | grep -in $1'
alias gapache='cat $WINDCHILL9/Apache/conf/extra/app*conf | grep -in $1'
alias gaccess='cat $WINDCHILL9/Apache/logs/access.log | grep -in $1'
alias gerror='cat $WINDCHILL9/Apache/logs/error.log | grep -in $1'
alias glogs='tail --lines=1000 `sm` `win` `error` `cat` `ms1` `ms` | grep -A3 -i Exception | less -MN +G'
alias gall='tail --lines=1000 `sm` `win` `error` `cat` `ms1` `ms` | grep -A3 -i $1'
#alias glogs='tail --lines=1000 `sm` `win` `error` `cat` `ms1` `ms` | grep -A3 -i "Exception\|Error" | less -MN +G'

#view property files in notepad
alias nwt='pushd $WINDCHILL9 && notepad "Windchill/codebase/wt.properties" &'
alias nservice='pushd $WINDCHILL9 && notepad "Windchill/codebase/service.properties" &'
alias nie='pushd $WINDCHILL9 && notepad "Windchill/codebase/WEB-INF/ie.properties" &'
alias nweb='pushd $WINDCHILL9 && notepad "Windchill/codebase/WEB-INF/web.xml" &'
alias ndb='pushd $WINDCHILL9 && notepad "Windchill/db/db.properties" &'
alias nsite='pushd $WINDCHILL9 && notepad "Windchill/site.xconf" &'

#view property files in less
alias lwt='less -iMN $WINDCHILL9/Windchill/codebase/wt.properties'
alias lservice='less -iMN $WINDCHILL9/Windchill/codebase/service.properties'
alias lie='less -iMN $WINDCHILL9/Windchill/codebase/WEB-INF/ie.properties'
alias lweb='less -iMN $WINDCHILL9/Windchill/codebase/WEB-INF/web.xml'
alias ldb='less -iMN $WINDCHILL9/Windchill/db/db.properties'
alias lsite='less -iMN $WINDCHILL9/Windchill/site.xconf'


#view apache files in less
alias lap='pushd $WINDCHILL9/Apache/conf/extra && less -iMN app-Windchill* '
alias lcog='pushd $WINDCHILL9/Apache/conf/extra && less -iMN app-cognos*'
alias lhttpd='less -iMN $WINDCHILL9/Apache/conf/httpd.conf'

alias vap='pushd $WINDCHILL9/Apache/conf/extra && vim -p app-Windchill* '
alias vcog='pushd $WINDCHILL9/Apache/conf/extra && vim -p app-cognos*'
alias vhttpd='vim $WINDCHILL9/Apache/conf/httpd.conf'

#ls aliases
alias ll='ls -ltr'
alias la='ls -Al'
alias l='ls -CF'
alias lll='ls -ltr | less -iMN'

#screen commands
alias sls='screen -ls'
alias sat='screen -r -x $1'

#map windchill9 directory to servers
alias wind='echo $WINDCHILL9'
alias serverlinks='ln -s /cygdrive/t/ptc/Windchill_9.0 ~/training; ln -s /cygdrive/v/ptc/Windchill_9.0 ~/dev1; ln -s /cygdrive/u/ptc/Windchill_9.0 ~/dev2;ln -s /cygdrive/q/ptc/Windchill_9.0 ~/qa1; ln -s /cygdrive/r/ptc/Windchill_9.0 ~/qa2;  ln -s /cygdrive/w/ptc/Windchill_9.0 ~/staging;  ln -s /cygdrive/x/ptc/Windchill_9.0 ~/slave1; ln -s /cygdrive/y/ptc/Windchill_9.0 ~/slave2;  ln -s /cygdrive/z/ptc/Windchill_9.0 ~/slave3'
alias prodlinks='ln -s /cygdrive/h/ptc/Windchill_9.0 ~/prod;  ln -s /cygdrive/i/ptc/Windchill_9.0 ~/prod3;  ln -s /cygdrive/j/ptc/Windchill_9.0 ~/prod4; ln -s /cygdrive/k/ptc/Windchill_9.0 ~/prod5;  ln -s /cygdrive/l/ptc/Windchill_9.0 ~/prod6'
alias training='export WINDCHILL9=~/training;export CDPATH=.:~/training:~/training/Windchill; cd ~/training'
alias dev1='export WINDCHILL9=~/dev1;export CDPATH=.:~/dev1:~/dev1/Windchill; cd ~/dev1'
alias dev2='export WINDCHILL9=~/dev2;export CDPATH=.:~/dev2:~/dev2/Windchill; cd ~/dev2'
alias qa1='export WINDCHILL9=~/qa1;export CDPATH=.:~/qa1:~/qa1/Windchill; cd ~/qa1'
alias qa2='export WINDCHILL9=~/qa2;export CDPATH=.:~/qa2:~/qa2/Windchill; cd ~/qa2'
alias staging='export WINDCHILL9=~/staging;export CDPATH=.:~/staging:~/staging/Windchill; cd ~/staging'
alias slave1='export WINDCHILL9=~/slave1;export CDPATH=.:~/slave1:~/slave1/Windchill; cd ~/slave1'
alias slave2='export WINDCHILL9=~/slave2;export CDPATH=.:~/slave2:~/slave2/Windchill; cd ~/slave2'
alias slave3='export WINDCHILL9=~/slave3;export CDPATH=.:~/slave3:~/slave2/Windchill; cd ~/slave3'
alias prod='export WINDCHILL9=~/prod; cd ~/prod'
alias prod3='export WINDCHILL9=~/prod3; cd ~/prod3'
alias prod4='export WINDCHILL9=~/prod4; cd ~/prod4'
alias prod5='export WINDCHILL9=~/prod5; cd ~/prod5'
alias prod6='export WINDCHILL9=~/prod6; cd ~/prod6'

#alias usercount='gawk \'{print $3}\' WINDCHILL9/Apache/logs/access.log | sort -n | uniq -c' 

alias top10='du -ha . | sort -n -r | head -n 10'
alias catr='cat -v -t -e $1'
alias squote='curl -Is slashdot.org | egrep "^X-(F|B)" | cut -d \- -f 2'
lsnew() { ls -lt ${1+"$@"} | head -20; }

#date related
alias today='date -d "today" +%m-%d-%y'
alias tomorrow='date -d "tomorrow" +%m-%d-%y'
alias yesterday='date -d "yesterday" +%m-%d-%y'
alias lastweek='date -d "-1 week" +%m-%d-%y'
alias nextweek='date -d "1 week" +%m-%d-%y'
alias lastmonth='date -d "-1 month" +%m-%d-%y'
alias nextmonth='date -d "1 month" +%m-%d-%y'
alias lastmonday='date -d "-1 monday" +%m-%d-%y'
alias nextmonday='date -d "1 monday" +%m-%d-%y'
