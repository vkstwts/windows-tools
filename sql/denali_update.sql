select * from remoteobjectinfo where LOWER(remoteobjectid) like '%o=bosch%'

select * from wtuser where ida2a2=12731489
select * from wtuser where ida2a2=26311649

select * from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;
select name,wtpartnumber,ida3organizationreference from manufacturerpartmaster where ida3organizationreference in (select ida2a2 from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') );
select name,wtpartnumber,ida3organizationreference from vendorpartmaster where ida3organizationreference in (select ida2a2 from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') );
select name,wtpartnumber,ida3organizationreference from manufacturerpartmaster where wtpartnumber='0 281 002 571'

select * from wtorganization where name in (select namecontainerinfo from orgcontainer where namecontainerinfo not like 'bloom energy') ;
4,838,377
select * from wtdatedeffectivity;

create table wtdatedeffectivity_bak as (select * from wtdatedeffectivity);
delete from wtdatedeffectivity;
select count(*) from wtdatedeffectivity;

select idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner,count(idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner) from controlbranch having (count9idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner)>1

select idA3masterReference,versionIdA2versionInfo,iterationIdA2iterationInfo,WipPK.getNormalizedWipState(statecheckoutInfo),idA3view,oneOffVersionIdA2oneOffVersi from wtpart where ida3masterreference=23786565
select * from  wtpart where ida3masterreference=23786565
select * from wtpartmaster where ida2a2=23801079
select * from controlbranch where ida3b5=23786565
create table controlbranch_bak as (select * from controlbranch);
create table wtpart_bak as (select * from wtpart where ida3masterreference=23786565);

/* Delete references in logicalidentifiermapentry table */
select * from  LogicalIdentifierMapEntry where classnamekeya5 like '%StringDefinition' and ida3a5 in (9844878,13209038,13209040,13846894,13846896)
delete from LogicalIdentifierMapEntry where ida2a2 in (select ida2a2 FROM LogicalIdentifierMapEntry where classnamekeya5 like '%StringDefinition' and ida3a5 in (9844878,13209038,13209040,13846894,13846896))
select l.* from  LogicalIdentifierMapEntry l, stringdefinition d where classnamekeya5 like '%StringDefinition' and  l.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER') 
delete from LogicalIdentifierMapEntry   where ida2a2 in (select l.ida2a2 FROM LogicalIdentifierMapEntry l, stringdefinition d where l.classnamekeya5 like '%StringDefinition' and l.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER') )
/* Delete attribute constraints*/
select c.* from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5 in (9844878,13209038,13209040,13846894,13846896)
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5 in (9844878,13209038,13209040,13846894,13846896))
select D.NAME,c.* from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER') 
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER') )

/*Delete attributes SystemNumber, RequesterPhone,Severity, SoftwareChangeType*/
select D.NAME,v.* from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER')
select * from  stringdefinition  where name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER')
select * from wttypedefinition where ida2a2 in (select v.ida3a4 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER'))
delete from stringvalue where ida2a2 in (select v.ida2a2 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER'))
delete from stringdefinition  where name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL','AGILENUMBER')


/* Delete references in logicalidentifiermapentry table */
select l.* from  LogicalIdentifierMapEntry l, stringdefinition d where classnamekeya5 like '%StringDefinition' and  l.ida3a5=d.ida2a2 and d.name in ('AGILENUMBER') 
delete from LogicalIdentifierMapEntry   where ida2a2 in (select l.ida2a2 FROM LogicalIdentifierMapEntry l, stringdefinition d where l.classnamekeya5 like '%StringDefinition' and l.ida3a5=d.ida2a2 and d.name in ('AGILENUMBER') )
/* Delete attribute constraints*/
select D.NAME,c.* from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('AGILENUMBER') 
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('AGILENUMBER') )

/*Delete attributes SystemNumber, RequesterPhone,Severity, SoftwareChangeType*/
select D.NAME,v.* from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('AGILENUMBER')
select * from  stringdefinition  where name in ('AGILENUMBER')
select * from wttypedefinition where ida2a2 in (select v.ida3a4 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('AGILENUMBER'))
delete from stringvalue where ida2a2 in (select v.ida2a2 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('AGILENUMBER'))
delete from stringdefinition  where name in ('AGILENUMBER')

/*Delete principals */ 
select * from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com'))
delete from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com'))
select * from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com'))
delete from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com')); 
select * from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com')
delete from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com')


select businessobjectref,name from recentupdate where  name like 'ION%'  and businessobjectref like '%OrgContainer%' 
update recentupdate set name='Bloom Energy' where  name like 'ION%' and businessobjectref like '%OrgContainer%'


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


/*select wtorganizations that have parts. */
select * from manufacturerpartmaster where ida3organizationreference in (select ida2a2 from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') );
update manufacturerpartmaster set ida3organizationreference=5769216 where ida3organizationreference=4838377;
select * from WTOrganization where LOWER(name) like 'bosch';
select O.name, M.* from Manufacturer M, WTOrganization O where M.ida3organizationreference=O.ida2a2 and LOWER(name) like 'bosch';
select * from Manufacturer  where ida3organizationreference=4838377;
delete from Manufacturer  where ida3organizationreference=4838377;

/* ORGANIZATIONS CLEANUP */
/* Delete domain references first */
select * from wtgroup where ida3domainref in ( select ida2a2 from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>(select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'));
delete from wtgroup where ida3domainref in ( select ida2a2 from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference<>(select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'));

/* Delete administrative domains   */
select distinct CLASSNAMEKEYCONTAINERREFEREN from administrativedomain
select * from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from administrativedomain where CLASSNAMEKEYCONTAINERREFEREN like '%OrgContainer%' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

/* Delete ACL entries */
select distinct classnamekeyb3 from wtaclentry
select * from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>(select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wtaclentry where classnamekeyb3 like '%OrgContainer%' and ida3b3<>(select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

/* Delete AccessPolicyRules */
/*TODO : Change the id to org name paramater */
select distinct classnamea5 from accesspolicyrule
select * from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561
delete from accesspolicyrule where classnamea5 like '%OrgContainer%' and ida3a2a5<>1561

/*Dont delete anything related to BOSCH */
/*Delete entries from OwningRepositoryLocalObject*/
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (13131134,4770635,4770157,4791325,4837033,4838379,4838525,4838771,4838983,4839529,4839675,11498308)
select * FROM OWNINGREPOSITORYLOCALOBJECT WHERE ida3b5 IN (select ida2a2 from wtorganization where  LOWER(name) in (select LOWER(namecontainerinfo)  from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') )
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE ida3b5 IN (select ida2a2 from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo)  from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') )

/* Delete wtorganizations */
select * from wtorganization where name in (select (namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;
delete from wtorganization where name in (select (namecontainerinfo)  from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;

/* Delete references from remoteobjectinfo */
select * from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))
select * from remoteobjectinfo where IDA3A3 IN (5769216)
delete from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))

/*Orgcontainer cleanup */
/*Delete references from wfprocess,wfassignedactivity,axlcontext,wtaclentry,CreatorsLink,SupplierAdministratorLink,FilteredDynamicEnumSet,SubFolder,Cabinet,TypeBasedRule */
select * from wfprocess where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wfprocess where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from wfassignedactivity where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from wfassignedactivity where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from axlcontext where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
delete from axlcontext where classnamekeycontainerreferen like '%OrgContainer' and ida3containerreference not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
select * from wtaclentry where  classnamekeyb3 like '%OrgContainer' and ida3b3 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')
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

/*Delete the orgcontainer*/
select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy'
delete from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

SELECT count(*) FROM WTPRODUCT a0, IterFolderMemberLink a3, SubFolder a4, EPMWorkspace a5 WHERE a3.branchida3b5 = a0.branchiditerationinfo AND a3.ida3a5 = a4.ida2a2 AND a0.latestiterationinfo = 1 AND a5.ida3b5 = a4.ida2a2; 
SELECT a0.* FROM WTPRODUCT a0, IterFolderMemberLink a3, SubFolder a4, EPMWorkspace a5 WHERE a3.branchida3b5 = a0.branchiditerationinfo AND a3.ida3a5 = a4.ida2a2 AND a0.latestiterationinfo = 1 AND a5.ida3b5 = a4.ida2a2; 
select name from wtuser where ida2a2=35405880;
select name from wtproductmaster where ida2a2=39057028;


select name,documentnumber from epmdocumentmaster where name like '%-1610-1-16%';
select cadname,name,documentnumber,ida2a2 from epmdocumentmaster where ida2a2 in ('9083693','29907');
select cadname from  epmcadnamespace where ida3a3=9083693;
update epmcadnamespace set cadname ='ss-1610-1-16_obsolete.sldprt' where ida3a3=9083693;

select * from epmdocumentmaster where documentnumber='CAD-0001153'
update epmdocumentmaster set cadname='Part-Test1', name='Part-Test1' where documentnumber='CAD-0001153'

select * from epmdocumentmaster where documentnumber='CAD-0010499'
update epmdocumentmaster set cadname='SS-1610-1-16-1.sldprt' where documentnumber='CAD-0010499'

select * from wtuser where ida2a2 in (select ida3b5 FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (871626,12292244,12292265,1460813,26251529,26251522))
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA2A2 IN (871626,12292244,12292265,1460813,26251529,26251522)


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

select * from  wtgroup where ida2a2 in (10699396,11625910,7106607)
delete from  wtgroup where ida2a2 in  (10699396,11625910,7106607)

select * from wfassignedActivity where ida3a5 in (13744032)
delete from wfassignedActivity where ida3a5 in (13744032)

D:\vault\vaultFolders
SELECT path, REGEXP_REPLACE(path, '(F:)(.)', 'D:\\vault\2') RESULT
FROM fvmount 
WHERE path LIKE 'F:%'


UPDATE   fvmount SET  Path = REGEXP_REPLACE(path, '(F:)(.)', 'D:\\vault\2') WHERE    path LIKE 'F:%'\

select * from wtpartmasterkey where ida3organizationreference=5769216
select * from manufacturerpartmaster where ida3organizationreference=5769216
update manufacturerpartmaster set ida3organizationreference=5144942 where ida3organizationreference=5769216;

select * from wtpartmaster where name like '%928%'

select * from wtorganization where LOWER(name) like '%bosch%' ;
select * from wtorganization where ida2a2=5769216;
select * from remoteobjectinfo where LOWER(remoteobjectid) like 'o=%bosch%'
select * from Manufacturer  where ida3organizationreference=5144942;
delete from Manufacturer  where ida3organizationreference=4838377;