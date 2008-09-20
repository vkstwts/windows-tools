#!/bin/bash.exe
cat /cygdrive/d/ptc/Windchill9/Apache/logs/denali_access.log | gawk '$3 !~ /-/ {print substr($4,2,11) " " $3}' | sort -k1 -k2 | uniq 