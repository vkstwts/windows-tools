sc stop PTCApache
sc stop PTCTomcat
sc stop PTCWindchill
sc stop Partslink
pause
E:
rd /S /Q E:\ptc\Windchill_9.0\Tomcat\work
rd /S /Q E:\tmp\ptcServlet
rd /S /Q E:\ptc\Windchill_9.0\Windchill\tasks\codebase\com\infoengine\compiledTasks

sc query PTCApache  | findstr /i "state
sc query PTCTomcat  | findstr /i "state
sc query PTCWindchill  | findstr /i "state
sc query Partslink  | findstr /i "state
pause

