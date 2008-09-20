#!/bin/bash.exe
tail -f /cygdrive/d/ptc/Windchill9/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 }'