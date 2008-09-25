select * from wtorganization where ida2a2=5156857
DELETE from wtorganization where ida2a2=5156857

select * FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,4770635,4770157,4791325,4837033,4838379,4838525,4838771,4838983,4839529,4839675,11498308)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,4770635,4770157,4791325,4837033,4838379,4838525,4838771,4838983,4839529,4839675,11498308)
select * FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (5156859,871626,12292244,12292265,1460813,26251529,26251522)
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (5156859,871626,12292244,12292265,1460813,26251529,26251522)
/* Delete users and related references */
select * from roleprincipalmap where ida3b4 in (1460811,871623,12292242,12292263,26251520,26251527)
delete  from roleprincipalmap where ida3b4 in (1460811,871623,12292242,12292263,26251520,26251527)
select * from MyPageQueryable where ida3b5 in (1460811,871623,12292242,12292263,26251520,26251527)
delete from MyPageQueryable where ida3b5 in (1460811,871623,12292242,12292263,26251520,26251527)
/* Dont delete folders and cabinet. information only.
select * from Subfolder where ida3b7 in (1460811,871623,12292242,12292263,26251520,26251527)
delete from Subfolder where ida3b7 in (1460811,871623,12292242,12292263,26251520,26251527)
select * from Cabinet where ida3b6 in (1460811,871623,12292242,12292263,26251520,26251527)
delete from Cabinet where ida3b6 in (1460811,871623,12292242,12292263,26251520,26251527)*/

select * from  remoteobjectinfo where ida3a3 in (1460811,871623,12292242,12292263,26251520,26251527)
delete from  remoteobjectinfo where ida3a3 in (1460811,871623,12292242,12292263,26251520,26251527)

select * from  wtuser where ida2a2 in (1460811,871623,12292242,12292263,26251520,26251527)
delete from  wtuser where ida2a2 in (1460811,871623,12292242,12292263,26251520,26251527)


select * from  remoteobjectinfo where ida3a3 in  (10699396,11625910,7106607)
delete from  remoteobjectinfo where ida3a3 in (10699396,11625910,7106607)

select * from  wtgroup where ida2a2 in (10699396,11625910,7106607)
delete from  wtgroup where ida2a2 in  (10699396,11625910,7106607)

select * from  wtgroup where ida2a2 in (10699396,11625910,7106607)
select * from   remoteobjectinfo where remoteobjectid like  '%477_%' ida2a2 in  (10699396,11625910,7106607)


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

To fix the unique constraint error.
update epmcadnamespace set cadname ='ss-1610-1-16_obsolete.sldprt' where ida3a3=9083693;



create table wtdatedeffectivity_bak as (select * from wtdatedeffectivity);
delete from wtdatedeffectivity;
select count(*) from wtdatedeffectivity;

select * from wfassignedActivity where ida3a5 in (13744032)
delete from wfassignedActivity where ida3a5 in (13744032)

/*Orgcontainer cleanup */
/*Delete references from wfprocess,wfassignedactivity,axlcontext,wtaclentry,CreatorsLink,SupplierAdministratorLink,FilteredDynamicEnumSet,SubFolder,Cabinet,TypeBasedRule */
select * from wfprocess where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wfprocess where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from wfassignedactivity where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wfassignedactivity where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from axlcontext where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from axlcontext where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from wtaclentry where  classnamekeyb3 like '%OrgContainer' and ida3b3 not  in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wtaclentry where classnamekeyb3 like '%OrgContainer' and ida3b3 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from CreatorsLink where classnamekeyrolebobjectref like '%OrgContainer' and ida3b5 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from CreatorsLink where classnamekeyrolebobjectref like '%OrgContainer' and ida3b5 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from SupplierAdministratorLink where classnamekeyroleaobjectref like '%OrgContainer' and ida3a5 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from SupplierAdministratorLink where classnamekeyroleaobjectref like '%OrgContainer' and ida3a5 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from FilteredDynamicEnumSet where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from FilteredDynamicEnumSet where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from SubFolder where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from SubFolder where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from Cabinet where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from Cabinet where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from TypeBasedRule where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from TypeBasedRule where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

select d1.name,d1.classnamekeycontainerreferen,d1.ida3containerreference,d.name,d.classnamekeycontainerreferen,d.ida3containerreference,r.* from fvpolicyrule r, AdministrativeDomain d,AdministrativeDomain d1 where r.classnamekeya5 like '%ReplicaVault' and d.ida2a2=r.ida3a2b5 and d1.ida2a2=r.ida3domainref 
select * from PDMLinkProduct where ida2a2=5543585
select count(*) from queueentry where ida3a5=9404
select * from queueentry where ida3a5=9404
select distinct targetmethod from queueentry where ida3a5=9404
select * from derivedimage where ida2a2 in (18857969,13064149,13487414,18677699,23197940,9716875,14209663,14209685)