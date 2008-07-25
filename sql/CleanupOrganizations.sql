/* Tested in Windchill 8.0 */
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


/* Delete wtorganizations */
select * from wtorganization where name in (select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;
delete from wtorganization where name in (select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy') ;

/* Delete references from remoteobjectinfo */
select * from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))
delete from remoteobjectinfo where remoteobjectid in (select CONCAT(CONCAT('o=',LOWER(namecontainerinfo)),',ou=people,cn=windchill8,cn=application services,o=ionamerica') from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy'))

/*Delete the orgcontainer*/
select namecontainerinfo from orgcontainer where LOWER(namecontainerinfo) not like 'bloom energy'
delete from orgcontainer where ida2a2 not in (select ida2a2 from orgcontainer where LOWER(namecontainerinfo) like 'bloom energy')

