E:
rd /S /Q E:\ptc\Windchill_9.0\Tomcat\work
rd /S /Q E:\tmp\ptcServlet
rd /S /Q E:\ptc\Windchill_9.0\Windchill\tasks\codebase\com\infoengine\compiledTasks

sc start PTCWindchill
sc start PTCTomcat
sc start Partslink
sc start PTCApache
sc start "Cognos 8"
sc start "Fast Stream"
pause
sc query PTCApache  | findstr /i "state
sc query PTCTomcat | findstr /i "state
sc query PTCWindchill | findstr /i "state
sc query Partslink | findstr /i "state
sc query "Cognos 8" | findstr /i "state
sc query "Fast Stream" | findstr /i "state
