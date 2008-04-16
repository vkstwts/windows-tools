# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# enable color support of ls and also add handy aliases
if [ "$TERM" != "dumb" ]; then
    eval "`dircolors -b`"
    alias ls='ls --color=auto'
    #alias dir='ls --color=auto --format=vertical'
    #alias vdir='ls --color=auto --format=long'
fi


# Set default printer on googleedu*.corp.google.com workstations
#  in Cairo conference room in Mountain View for new hire orientation

#if [ `echo $HOSTNAME | cut -c 1-9` = "googleedu" ]
#then
#  export PRINTER=lpstat
#  export LPDEST=$PRINTER
#fi 
export PRINTER=indianajones
export LPDEST=$PRINTER
export PATH="/home/prathapy/google/scripts:/usr/lib/ruby/gems/1.8/gems/snippits-0.5.1-/bin:$PATH:/opt/csw/bin"

# User specific aliases and functions go here (override system defaults)

# save bash history
shopt -s histappend
PROMPT_COMMAND='history -a'

#Spell check
shopt -s cdspell

# don't put duplicate lines in the history. See bash(1) for more options
export HISTCONTROL=ignoredups
# ... and ignore same sucessive entries.
export HISTCONTROL=ignoreboth

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

export HISTIGNORE="&:ls:[bf]g:exit"

export HISTSIZE=10000
export HISTTMEFORMAT='%A %t'

#Multiple line commands split up in history
shopt -s cmdhist

# A couple of neat extras suggested by commenters
#Press control R in bash, then start typing and you can search through your past #commands much easier than just pressing UP 300 times…
#Alternatively, use
#history | grep "foo"

export EDITOR='kwrite'

#Perforce
export P4CONFIG=.p4config
export P4DIFF="/home/build/public/google/tools/p4diff"
export P4MERGE=/home/build/public/eng/perforce/mergep4.tcl 
export P4EDITOR=$EDITOR



# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

