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

echo "qa2" && cat ~/qa2/Windchill/codebase/wt.properties | grep -in $1
echo "qa2-service" && cat ~/qa2/Windchill/codebase/service.properties | grep -in $1 
echo "qa2-ie" && cat ~/qa2/Windchill/codebase/WEB-INF/ie.properties | grep -in $1 
echo "qa2-db" && cat ~/qa2/Windchill/db/db.properties | grep -in $1
