
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

#screen commands
alias sls='screen -ls'
alias sat='screen -r -x $1'

#prism commands
alias  notes='xulrunner-1.9 /usr/share/prism/application.ini -webapp gnotes@prism.app &'
alias code='xulrunner-1.9 /usr/share/prism/application.ini -webapp code@prism.app &'
