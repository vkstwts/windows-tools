
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

alias sshf='ssh -qX prathapy@frostbite.corp.google.com'
alias sshh='ssh -qX prathapy@heatstroke.corp.google.com'
alias sshy='ssh -qX prathapy@hyperthermia.corp.google.com'
alias sshp='ssh -qX prathapy@prathapy.mtv.corp.google.com'

#screen commands
alias sls='screen -ls'
alias sat='screen -r -x $1'

#jobs
#alias ljobs='wget -q -O- "http://www.indeed.com/jobs?as_and=windchill&as_phr=&as_any=&as_not=&as_ttl=&as_cmp=&jt=all&st=&minsal=&radius=50&l=95051&fromage=any&limit=20&sort=date" | egrep "=\"company|jobtitle" | sed 's/<b>//g' | sed 's/<\/b>//g' | awk \'{ print substr(\$0,index(\$0,"\">")+2,index(\$0,"</"\)-index(\$0,"\">")-2)}\''