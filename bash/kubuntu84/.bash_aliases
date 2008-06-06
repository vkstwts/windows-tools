
# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
alias ll='ls -lhtrp'
alias la='ls -Ahl'
alias l='ls -CF'
alias lll='ls -lhtrp | less'

#Generc Aliases
alias bashrc='vi ~/.bashrc '
alias aliases='vi ~/.bash_aliases '
alias sbash='source ~/.bashrc && source ~/.bash_aliases'
alias apt='sudo apt-get install'
alias remove='sudo apt-get remove'
alias search='apt-cache search'
alias thist='tail -f ~/.bash_history'
alias hg='history | egrep'
#find from root directory
alias fr='sudo find  \/ -name $1 -print'
alias kate4='/usr/lib/kde4/bin/kate'
alias kwrite4='/usr/lib/kde4/bin/kwrite'
alias kterm='/usr/lib/kde4/bin/konsole &'

alias sshf='ssh -qX prathapy@frostbite.corp.google.com'
alias sshh='ssh -qX prathapy@heatstroke.corp.google.com'
alias sshy='ssh -qX prathapy@hyperthermia.corp.google.com'
alias sshp='ssh -qX prathapy@prathapy.mtv.corp.google.com'

alias sshfa='ssh -qX prathapy@frostbite.corp.google.com -t screen -r -x all'
alias sshha='ssh -qX prathapy@heatstroke.corp.google.com -t screen -r -x all'
alias sshya='ssh -qX prathapy@hyperthermia.corp.google.com -t screen -r -x all'
alias sshpa='ssh -qX prathapy@prathapy.mtv.corp.google.com -t screen -r -x all'

#BloomEnergy
alias sshc='ssh -qX wcadmin@casagrande'
alias sshw='ssh -qX wcadmin@whitesands'
alias sshm='ssh -qX wcadmin@mesaverde'
alias sshdv='ssh -qX wcadmin@deathvalley'
alias sshdn='ssh -qX wcadmin@denali'

alias lmsite='less  ~/mesa/Windchill/site.xconf'
alias ldsite='less  ~/death/Windchill/site.xconf'
alias ldnsite='less  ~/denali/Windchill/site.xconf'
alias lcsite='less  ~/casa/Windchill/site.xconf'
alias lwsite='less  ~/white/Windchill/site.xconf'
alias lmwt='less  ~/mesa/Windchill/codebase/wt.properties'
alias ldwt='less  ~/death/Windchill/codebase/wt.properties'
alias ldnwt='less  ~/denali/Windchill/codebase/wt.properties'
alias lcwt='less  ~/casa/Windchill/codebase/wt.properties'
alias lwwt='less  ~/white/Windchill/codebase/wt.properties'
alias lmie='less  ~/mesa/Windchill/codebase/WEB-INF/ie.properties'
alias ldie='less  ~/death/Windchill/codebase/WEB-INF/ie.properties'
alias ldnie='less  ~/denali/Windchill/codebase/WEB-INF/ie.properties'
alias lcie='less  ~/casa/Windchill/codebase/WEB-INF/ie.properties'
alias lwie='less  ~/white/Windchill/codebase/WEB-INF/ie.properties'
alias lmdb='less  ~/mesa/Windchill/db/db.properties'
alias lddb='less  ~/death/Windchill/db/db.properties'
alias ldndb='less  ~/denali/Windchill/db/db.properties'
alias lcdb='less  ~/casa/Windchill/db/db.properties'
alias lwdb='less  ~/white/Windchill/db/db.properties'
alias lmser='less  ~/mesa/Windchill/codebase/service.properties'
alias ldser='less  ~/death/Windchill/codebase/service.properties'
alias ldnser='less  ~/denali/Windchill/codebase/service.properties'
alias lcser='less  ~/casa/Windchill/codebase/service.properties'
alias lwser='less  ~/white/Windchill/codebase/service.properties'
alias tmms='tail -f `ls -trC1 ~/mesa/Windchill/logs/MethodServer*.log | tail -1`'
alias tdms='tail -f `ls -trC1 ~/death/Windchill/logs/MethodServer*.log | tail -1`'
alias tdnms='tail -f `ls -trC1 ~/denali/Windchill/logs/MethodServer*.log | tail -1`'
alias tcms='tail -f `ls -trC1 ~/casa/Windchill/logs/MethodServer*.log | tail -1`'
alias twms='tail -f `ls -trC1 ~/white/Windchill/logs/MethodServer*.log | tail -1`'

alias mmesa='sshfs wcadmin@mesaverde.ionamerica.priv:/cygdrive/c/ptc/ mesa/'
alias mwhite='sshfs wcadmin@whitesands.ionamerica.priv:/cygdrive/e/ptc/Windchill9/ white/'
alias mcasa='sshfs wcadmin@casagrande.ionamerica.priv:/cygdrive/e/ptc/Windchill9/ casa/'
alias mdeath='sshfs wcadmin@deathvalley.ionamerica.priv:/cygdrive/c/ptc/ death/'
alias mdenali='sshfs wcadmin@denali.ionamerica.priv:/cygdrive/c/ptc/ denali/'

alias dusers="tail -f ~/denali/Apache/logs/access.log | awk '$3 !~ /-/ {print substr($4,2) \s $3 }'"
#screen commands
alias sls='screen -ls'
alias sat='screen -r -x $1'

#prism commands
alias notes='xulrunner-1.9 /usr/share/prism/application.ini -webapp gnotes@prism.app &'
alias code='xulrunner-1.9 /usr/share/prism/application.ini -webapp code@prism.app &'
alias gmail='/usr/bin/prism-google-mail'
alias greader='/usr/bin/prism-google-reader'
alias gcal='/usr/bin/prism-google-calendar'
alias gtalk='/usr/bin/prism-google-talk'

#jdk
alias cdjava='pushd /usr/lib/jvm/java-6-openjdk/'
