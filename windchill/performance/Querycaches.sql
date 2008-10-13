spool C:\General\caches.txt
set heading=TypeCache
select count(*) from TimestampDefinition;
select count(*) from IntegerDefinition;
select count(*) from RatioDefinition;
select count(*) from UnitDefinition;
select count(*) from URLDefinition;
select count(*) from ReferenceDefinition;
select count(*) from FloatDefinition;
select count(*) from StringDefinition;
select count(*) from BooleanDefinition;
set heading=AclCache-200
select count(*) from policyacl;
set heading=MaxAdminDomains-2000
select count(*) from administrativedomain;
set heading=PolicyItemCache-100
select count(*) from fvpolicyitem;
set heading=IndexListCache-200
select count(*) from indexpolicylist;
set heading=NotificationListCache-200
select count(*) from notificationlist;
set heading=teamtemplateCache-200
select count(*) from Teamtemplate;
spool off

