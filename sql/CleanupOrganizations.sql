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
select * from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;
delete from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo)  from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;

/* Delete references from remoteobjectinfo */
select * from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))
delete from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))

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

/*Delete the orgcontainer*/
select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy'
delete from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

/*select wtorganizations that have parts. */
select * from manufacturerpartmaster where ida3organizationreference in (select ida2a2 from wtorganization where LOWER(name) in (select LOWER(namecontainerinfo) from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') );

DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4791323
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4791323
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4770633
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4770633
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4770155
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4770155;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4837031;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4837031;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838523;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838523;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838769;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838769;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838981;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838981;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4839527;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4839527;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4839673;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4839673;


DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=40824457;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=40824457;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4791323;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4791323;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4770633;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4770633;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4770155;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4770155;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4837031;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4837031;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838523;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838523;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838769;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838769;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4838981;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4838981;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4839527;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4839527;
DELETE FROM REMOTEOBJECTINFO WHERE IDA3A3=4839673;
DELETE FROM OWNINGREPOSITORYLOCALOBJECT WHERE IDA3B5=4839673;