select * FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,11498308)
select count(*) FROM OWNINGREPOSITORYLOCALOBJECT 
select * from wtorganization where ida2a2 in (11498306,13131132)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,11498308)

create table orgcontainer_bak as (select * from orgcontainer);
delete from orgcontainer where name not like "%Bloom%";
select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),'%') from orgcontainer where ida2a2<>1568
select count(*) from remoteobjectinfo where classnamekeya3 like '%WTOrganization'
select * from remoteobjectinfo where remoteobjectid like 'o=supplier1%'
select * from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2<>1568)
delete from remoteobjectinfo where remoteobjectid like '%Fox Thermal Instruments%'
create table remoteobjectinfo_bak as (select * from remoteobjectinfo);
select * from wtorganization where name like '%3M-test';
delete  from wtorganization where name like '%3M-test';
select * from wtorganization where name like '%BOSCH';
delete  from wtorganization where name like '%BOSCH';
commit;

select * from wtorganization where ida3domainref in (select ida3d2containerinfo from orgcontainer where ida2a2<>1568) ;
select * from wtorganization where name in (select namecontainerinfo from orgcontainer where ida2a2<>1568) ;

select distinct classnamea5 from accesspolicyrule
select * from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561
delete from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561

select distinct classnamekeyb3 from wtaclentry
select * from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>1568
delete from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>1568

select distinct CLASSNAMEKEYCONTAINERREFEREN from administrativedomain
select * from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568
delete from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568
commit;


select * from wtgroup where ida2a2=4838393;
select * from wtgroup where ida2a2=4838401;
select * from wtgroup where ida3domainref in ( select ida3domainref from wtgroup where ida2a2 in (4838393,4770671,4791361,4837069,4838561,4838807,4839419,4839565,4839811,4770193));
delete from wtgroup where ida3domainref in ( select ida3domainref from wtgroup where ida2a2 in (4838393,4770671,4791361,4837069,4838561,4838807,4839419,4839565,4839811,4770193));

select * from wtgroup where ida3domainref in ( select ida2a2 from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568);
delete from wtgroup where ida3domainref in ( select ida2a2 from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568);

select distinct CLASSNAMEKEYCONTAINERREFEREN from administrativedomain
select * from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568
delete from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>1568

select distinct classnamekeyb3 from wtaclentry
select * from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>1568
delete from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>1568

select distinct classnamea5 from accesspolicyrule
select * from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561
delete from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561

select * from wtorganization where name in (select namecontainerinfo from orgcontainer where ida2a2<>1568) ;
delete from wtorganization where name in (select namecontainerinfo from orgcontainer where ida2a2<>1568) ;

select * from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2<>1568)
delete from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2<>1568)

select namecontainerinfo from orgcontainer where ida2a2<>1568
delete from orgcontainer where ida2a2<>1568

select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy'

select * from orgcontainer where ida2a2=1568
select * from wtorganization where ida2a2=477
select * from wtgroup where ida2a2=5689;

select * from administrativedomain where ida2a2=5849

select * from wtgroup where name like '%}Supplier Administrators';
delete from wtgroup where name like '%}Supplier Administrators';

Update WTGroup set ida3domainref = 5849 where ida2a2= 5689;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5677;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5680;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5686;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5683;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5707;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5698;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5695;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5701;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5737;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5728;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5725;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5731;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5722;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5713;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5710;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5716;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5755;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5740;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5743;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5749;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5752;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5746;

DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (5156859,4770157,4837033,4838525,4838771,4838983,4839529,4839675,4770635)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (871626,12292244,12292265,1460813,16196723,26251529,26251522)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (4791325,4838379)

select * from wtuser where name like 'warehouse'
delete from wtuser where name like 'warehouse'
select * from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'warehouse');
delete from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'warehouse');

select * from wtuser where name like 'nils@nxrev.com'
delete from wtuser where name like 'nils@nxrev.com'
select * from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'nils@nxrev.com');
delete from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'nils@nxrev.com');

select * from wtuser where name like 'makaludave@yahoo.com'
delete from wtuser where name like 'makaludave@yahoo.com'
select * from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'makaludave@yahoo.com');
delete from remoteobjectinfo where ida3a3=( select ida2a2 from wtuser where name like 'makaludave@yahoo.com');


Update wtgroup g set g.ida3domainref = (select ida2a2 from administrativedomain where name = 'Unaffiliated') where not exists (select 1 from administrativedomain d where d.ida2a2=g.ida3domainref); 
Update wtorganization o set o.ida3domainref = (select ida2a2 from administrativedomain where name = 'Unaffiliated') where not exists (select 1 from administrativedomain d where d.ida2a2=o.ida3domainref); 
select * from wtorganization o where ida3domainref  not in (select ida2a2 from administrativedomain d where d.ida2a2=o.ida3domainref); 

select * from team where ida3a2ownership=16196721
select distinct ida3a2ownership  from team

select * from roleprincipalmap where ida3b4 in (871623,1460811,12292263,16196721,26251520,26251527);
delete from roleprincipalmap where ida3b4 in (871623,1460811,12292263,16196721,26251520,26251527);

/*Delete principals */ select * from wtuser where name like '%meggers%'
select * from roleprincipalmap where ida3b4 in (26251520,26251527,871623,1460811,12292242,12731489,19726066,26311632,26311649)
delete from roleprincipalmap where ida3b4 in (26251520,26251527,871623,1460811,12292242,12731489,19726066,26311632,26311649)
select * from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar'))
delete from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar'))
select * from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com')); 
delete from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')); 
select * from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')
delete from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon%','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')

select * from epmdocumentmaster where name='Part-Test'
update epmdocumentmaster set cadname='Part-Test1', name='Part-Test1' where documentnumber='CAD-0001153'


select * from epmdocumentmaster where documentnumber='CAD-0010499'
update epmdocumentmaster set cadname='SS-1610-1-16-1.sldprt' where documentnumber='CAD-0010499'


select distinct ida3a5  from queueentry 
where ida3a5=808466
select count(*) from queueentry where ida3a5=9404
select count(*) from queueentry where targetmethod='queuePublishJob' or targetmethod='doPublishJob'
select distinct classnamekeya5 from queueentry where targetmethod='queuePublishJob'
delete from queueentry where targetmethod='queuePublishJob' or targetmethod='doPublishJob'
delete from queueentry where ida3a5=9404
select distinct targetmethod from queueentry;
select distinct targetmethod from schedulequeueentry;


Update wtorganization o set o.ida3domainref = (select ida2a2 from administrativedomain where name = 'Unaffiliated') where not exists (select 1 from administrativedomain d where d.ida2a2=o.ida3domainref); 

Update WTGroup set ida3domainref = 5849 where ida2a2= 5689;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5677;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5680;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5686;
Update WTGroup set ida3domainref = 5849 where ida2a2= 5683;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5707;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5698;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5695;
Update WTGroup set ida3domainref = 6030 where ida2a2= 5701;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5737;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5728;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5725;
Update WTGroup set ida3domainref = 6392 where ida2a2= 5731;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5722;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5713;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5710;
Update WTGroup set ida3domainref = 6213 where ida2a2= 5716;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5755;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5740;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5743;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5749;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5752;
Update WTGroup set ida3domainref = 6718 where ida2a2= 5746;


DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,11498308)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (871626,12292244,12292265,1460813,26251529,26251522)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (12731491,19726068,26311634,26311651)

set echo off
set verify off
set heading off
set feedback off
set pagesize 600
set term off
column object_name format A40
column object_type format A30
spool C:	emp	emp_recomp_pk.sql
SELECT 'alter package '||object_name||' compile '||';' FROM user_objects WHERE object_type in ('PACKAGE', 'PACKAGE BODY') AND status = 'INVALID';
spool off
set verify on
set heading on
set feedback on
set pagesize 14
set term on
set echo on

select * from remoteobjectinfo where LOWER(remoteobjectid) like '%o=bosch%'