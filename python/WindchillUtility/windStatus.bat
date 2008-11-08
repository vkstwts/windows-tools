@echo off
rem hostname
echo Apache 
sc query  ptcapache | findstr /i "state "
echo Tomcat
sc query  ptctomcat | findstr /i "state "
echo Windchill
sc query  ptcwindchill | findstr /i "state "
echo Partslink
sc query  Partslink | findstr /i "state "
echo Cognos
sc query  "Cognos 8" | findstr /i "state "
