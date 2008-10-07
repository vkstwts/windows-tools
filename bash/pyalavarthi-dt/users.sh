#!/bin/bash.exe
tail -200 $WINDCHILL9/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 }'
tail -f $WINDCHILL9/Apache/logs/access.log | gawk '$3 !~ /-/ {print substr($4,2) " " $3 }'