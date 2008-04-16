
# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    alias dir='ls --color=auto --format=vertical'
    alias vdir='ls --color=auto --format=long'
fi

# some more ls aliases
alias ll='ls -ltrp'
alias la='ls -Al'
alias l='ls -CF'
alias lll='ls -ltrp | less'

#Generc Aliases
alias bashrc='kwrite ~/.bashrc &'
alias aliases='kwrite ~/.bash_aliases &'
alias sbash='source ~/.bashrc && source ~/.bash_aliases'
alias apt='sudo apt-get install'
alias remove='sudo apt-get remove'
alias search='apt-cache search'
alias thist='tail -f ~/.bash_history'
alias hg='history | egrep'

#alias twit='curl -u prathap:pwd -d status="$1" https://twitter.com/statuses/update.xml'
#alias gwho='wget -q -O- who/$1 | egrep mailto | gawk \'{print $1"\t"$2}\''
alias gwho='wget -q -O- "http://who/$1" | egrep mailto'

#machine specific aliases
alias p4config='kwrite /home/prathapy/.p4config &'
alias jmeter='/opt/jakarta-jmeter-2.3.1/bin/jmeter.sh & '
alias squirrel='/home/prathapy/SQuirreL/squirrel-sql.sh &'
alias synergy='synergys --daemon --restart --config /opt/synergy-1.3.1/synergy.conf'
alias tcat='tail -f /home/prathapy/google/tomcat5.5/logs/catalina.out'
alias tstart='/home/prathapy/google/tomcat5.5/bin/tstart.sh'
alias tstop='/home/prathapy/google/tomcat5.5/bin/tstop.sh'
alias cdoc='pushd /home/prathapy/google/documents'
alias cdow='pushd /home/prathapy/google/downloads'

alias logs='find . -name "*log*" -print'
alias ulso='ls -ltrp ./*/*'
alias ulsa='ls -ltrp ../../archive/*'
alias uca='cat ../../archive/* | grep *'
alias uco='cat ./*/* | grep *'
alias ulsag='ls -ltrp ../../archive/* | grep'
#alias wstart='/opt/ptc/windchill/bin/windchill --javaargs=-Djava.protocol.handler.pkgs=HTTPClient start & '
#alias wstop='/opt/ptc/windchill/bin/windchill stop &'
#alias tstart='/opt/ptc/tomcat/bin/wttomcat_start &'
#alias tstop='/opt/ptc/tomcat/bin/wttomcat_stop &'
#alias astart='/opt/ptc/apache/bin/apachectl startssl &'
#alias astop='/opt/ptc/apache/bin/apachectl stop &' 
#alias tcat='tail -f /opt/ptc/tomcat/logs/catalina.out'
#alias taccess='tail -f /opt/ptc/apache/logs/access_log'

alias sstart='synergys --daemon --restart --config /opt/synergy-1.3.1/synergy.conf &'

alias sshf='ssh -qX frostbite'
alias sshh='ssh -qX heatstroke'
alias sshy='ssh -qX hyperthermia'

#screen commands
alias sls='screen -ls'
alias sat='screen -r -x $1'


#Frostbite
alias fssh='ssh -qX frostbite'
alias fmlog='ssh -qX frostbite "tail -f \`ls -trC1 /opt/ptc/windchill/logs/MethodServer*.log | tail -1\`"'
#alias fmblog='ssh -qX frostbite "tail -f \`ls -trC1 /opt/ptc/windchill/logs/MethodServer*.log | tail -2\`"'
alias fblog='ssh -qX frostbite "tail -f \`ls -trC1 /opt/ptc/windchill/logs/BackgroundMethodServer*.log | tail -1\`"'
alias fcat='ssh -qX frostbite "tail -f /opt/ptc/tomcat/logs/catalina.out"'
alias faccess='ssh -qX frostbite "tail -f /opt/ptc/apache/logs/access_log"'
alias ferror='ssh -qX frostbite "tail -f /opt/ptc/apache/logs/error_log"'
#alias fusers='ssh -qX frostbite "tail -f/opt/ptc/apache/logs/access_log | nawk \'$3 !~ /-/ {print$3  substr\($4,2\)}\' "'
#tail -f /opt/ptc/apache/logs/access_log | nawk '$3 !~ /-/ {print$3 " " substr($4,2) }'
alias fcpu='ssh -qX frostbite prstat'

#Heatstroke
alias hssh='ssh -qX heatstroke'
alias hmlog='ssh -qX heatstroke "tail -f \`ls -trC1 /opt/ptc/windchill/logs/MethodServer*.log | tail -1\`"'
alias hblog='ssh -qX heatstroke "tail -f \`ls -trC1 /opt/ptc/windchill/logs/BackgroundMethodServer*.log | tail -1\`"'
alias hcat='ssh -qX heatstroke "tail -f /opt/ptc/tomcat/logs/catalina.out"'
alias haccess='tail -f /mnt/heat/apache/logs/access_log'
alias herror='tail -f /mnt/heat/apache/logs/error_log'
alias hcpu='ssh -qX heatstroke.corp.google.com prstat'

#Hyperthermia
alias ymlog='ssh -qX hyperthermia "tail -f \`ls -trC1 /opt/ptc/windchill/logs/MethodServer*.log | tail -2\`"'

