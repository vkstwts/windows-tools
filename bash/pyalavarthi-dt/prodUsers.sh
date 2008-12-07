#!/bin/bash.exe
#tail -200 $WINDCHILL9/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1}'
# tail -f /cygdrive/h/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1 " node 1"}' &
# tail -f /cygdrive/i/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1 " node 3"}' &
# tail -f /cygdrive/j/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1 " node 4"}' &
# tail -f /cygdrive/k/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1 " node 5"}' &
# tail -f /cygdrive/l/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 " " $1 " node 6"}' &
#tail -f /cygdrive/i/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/j/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/k/ptc/Windchill_9.0/Apache/logs/access.log /cygdrive/l/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " " $3 }' 
                                                                                                            
tail -f /cygdrive/h/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " Master  " $3 }' &
tail -f /cygdrive/i/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " Node 3  " $3 }' &
tail -f /cygdrive/j/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " Node 4  " $3 }' &
tail -f /cygdrive/k/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " Node 5  " $3 }' &
tail -f /cygdrive/l/ptc/Windchill_9.0/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,1) " " $5 " " $1 " Node 6  " $3 }' &