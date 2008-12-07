PATHS="/export/home /home"

AWK=/usr/bin/awk

DU="/usr/bin/du -ks"

GREP=/usr/bin/grep

DF="/usr/bin/df -k"

TR=/usr/bin/tr

SED=/usr/bin/sed

CAT=/usr/bin/cat

MAILFILE=/tmp/mailviews$$

MAILER=/bin/mailx

mailto="all@company.com" 

for path in $PATHS

do

	DISK_AVAIL=`$DF $path |  $GREP -v "Filesystem" | $AWK '{print $5}'|$SED 's/%//g'` 

	if [ $DISK_AVAIL -gt 90 ];then

		echo "Please clean up your stuff\n\n" > $MAILFILE

		$CAT $MAILFILE | $MAILER -s "Clean up stuff" $mailto	

	fi

done 