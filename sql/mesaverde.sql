select CADName  from EPMCadNameSpace;
SELECT LOWER(CADName),ida3b3,IDA3A3 from EPMCadNameSpace where LOWER(CADName) in (select LOWER(CADName) from EPMCadNameSpace group by LOWER(CADName) having count(*)>2);
select LOWER(CADName),COUNT(*) from EPMCadNameSpace group by LOWER(CADName) having count(*)>2
UPDATE EPMCADNamespace SET CADName = LOWER(CADName);

select name,documentnumber from epmdocumentmaster where name like '%-1610-1-16%';
select cadname,name,documentnumber,ida2a2 from epmdocumentmaster where ida2a2 in ('9083693','29907');

update epmcadnamespace set cadname ='ss-1610-1-16_obsolete.sldprt' where ida3a3=9083693;
create table wtdatedeffectivity_bak as (select * from wtdatedeffectivity);
delete from wtdatedeffectivity;

select count(*) from wtdatedeffectivity;

select * from AdministrativeDomain where ida2a2=4770163
delete from typebasedrule where ida3domainref=4770163

select count(*) from epmdocument where statecheckoutinfo not like 'c/i'
select * from epmdocument where statecheckoutinfo not like 'c/i'

select * from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')