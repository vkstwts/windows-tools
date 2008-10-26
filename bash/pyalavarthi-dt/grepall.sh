#!/bin/bash.exe
echo "dev1-wt" && cat ~/dev1/Windchill/codebase/wt.properties | grep -in $1 
echo "dev1-service" && cat ~/dev1/Windchill/codebase/service.properties | grep -in $1 
echo "dev1-ie" && cat ~/dev1/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "dev1-db" && cat ~/dev1/Windchill/db/db.properties | grep -in $1

echo "dev2-wt" && cat ~/dev2/Windchill/codebase/wt.properties | grep -in $1
echo "dev2-service" && cat ~/dev2/Windchill/codebase/service.properties | grep -in $1 
echo "dev2-ie" && cat ~/dev2/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "dev2-db" && cat ~/dev2/Windchill/db/db.properties | grep -in $1

echo "training-wt" && cat ~/training/Windchill/codebase/wt.properties | grep -in $1
echo "training-service" && cat ~/training/Windchill/codebase/service.properties | grep -in $1 
echo "training-ie" && cat ~/training/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "training-db" && cat ~/training/Windchill/db/db.properties | grep -in $1

echo "qa1-wt" && cat ~/qa1/Windchill/codebase/wt.properties | grep -in $1
echo "qa1-service" && cat ~/qa1/Windchill/codebase/service.properties | grep -in $1 
echo "qa1-ie" && cat ~/qa1/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "qa1-db" && cat ~/qa1/Windchill/db/db.properties | grep -in $1

echo "qa2-wt" && cat ~/qa2/Windchill/codebase/wt.properties | grep -in $1
echo "qa2-service" && cat ~/qa2/Windchill/codebase/service.properties | grep -in $1 
echo "qa2-ie" && cat ~/qa2/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "qa2-db" && cat ~/qa2/Windchill/db/db.properties | grep -in $1


echo "staging-wt" && cat ~/staging/Windchill/codebase/wt.properties | grep -in $1
echo "staging-service" && cat ~/staging/Windchill/codebase/service.properties | grep -in $1 
echo "staging-ie" && cat ~/staging/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "staging-db" && cat ~/staging/Windchill/db/db.properties | grep -in $1

echo "slave1-wt" && cat ~/slave1/Windchill/codebase/wt.properties | grep -in $1
echo "slave1-service" && cat ~/slave1/Windchill/codebase/service.properties | grep -in $1 
echo "slave1-ie" && cat ~/slave1/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "slave1-db" && cat ~/slave1/Windchill/db/db.properties | grep -in $1

echo "slave2-wt" && cat ~/slave2/Windchill/codebase/wt.properties | grep -in $1
echo "slave2-service" && cat ~/slave2/Windchill/codebase/service.properties | grep -in $1 
echo "slave2-ie" && cat ~/slave2/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "slave2-db" && cat ~/slave2/Windchill/db/db.properties | grep -in $1

echo "slave3-wt" && cat ~/slave3/Windchill/codebase/wt.properties | grep -in $1
echo "slave3-service" && cat ~/slave3/Windchill/codebase/service.properties | grep -in $1 
echo "slave3-ie" && cat ~/slave3/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "slave3-db" && cat ~/slave3/Windchill/db/db.properties | grep -in $1
