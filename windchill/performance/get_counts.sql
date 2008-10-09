
spool get_counts.sql.out.txt
select to_char(sysdate, 'mon-dd-fmday-am-hh-mi-ss') "Script execution Time"
from  dual;

Prompt ***********************************************************************
show parameters
Prompt ***********************************************************************


select '## ' as tag,  count(*) as cnt,  'policyacl'             as tbl from policyacl;
select '## ' as tag,  count(*) as cnt,  'notificationlist'      as tbl from notificationlist;
select '## ' as tag,  count(*) as cnt,  'wtuser'                as tbl from wtuser;
select '## ' as tag,  count(*) as cnt,  'wtgroup'               as tbl from wtgroup;
select '## ' as tag,  count(*) as cnt,  'indexpolicylist'       as tbl from indexpolicylist;
select '## ' as tag,  count(*) as cnt,  'teamtemplate'          as tbl from teamtemplate;
select '## ' as tag,  count(*) as cnt,  'team'                  as tbl from team;
select '## ' as tag,  count(*) as cnt,  'calendarcomponent'     as tbl from calendarcomponent;
select '## ' as tag,  count(*) as cnt,  'dbprefentry'           as tbl from dbprefentry;
select '## ' as tag,  count(*) as cnt,  'administrativedomain'  as tbl from administrativedomain;
select '## ' as tag,  count(*) as cnt,  'project2'              as tbl from project2;

select '## ' as tag,  count(*) as cnt,  'fvpolicyitem'          as tbl from fvpolicyitem;
select '## ' as tag,  count(*) as cnt,  'TimestampDefinition'   as tbl from TimestampDefinition;
select '## ' as tag,  count(*) as cnt,  'IntegerDefinition'     as tbl from IntegerDefinition ;
select '## ' as tag,  count(*) as cnt,  'RatioDefinition'       as tbl from RatioDefinition;

select '## ' as tag,  count(*) as cnt,  'UnitDefinition'        as tbl from UnitDefinition;
select '## ' as tag,  count(*) as cnt,  'URLDefinition'         as tbl from URLDefinition;
select '## ' as tag,  count(*) as cnt,  'ReferenceDefinition'   as tbl from ReferenceDefinition;

select '## ' as tag,  count(*) as cnt,  'FloatDefinition'       as tbl from FloatDefinition;
select '## ' as tag,  count(*) as cnt,  'StringDefinition'      as tbl from StringDefinition;
select '## ' as tag,  count(*) as cnt,  'BooleanDefinition'     as tbl from BooleanDefinition;

select '## ' as tag,  count(*) as cnt,  'FVITEM'                as tbl from FVITEM; 
select '## ' as tag,  count(*) as cnt,  'EPMDOCUMENT'           as tbl from EPMDOCUMENT;
select '## ' as tag,  count(*) as cnt,  'EPMDOCUMENTMASTER'     as tbl from EPMDOCUMENTMASTER;
select '## ' as tag,  count(*) as cnt,  'APPLICATIONDATA'       as tbl from APPLICATIONDATA;
select '## ' as tag,  count(*) as cnt,  'WTACLENTRY'            as tbl from WTACLENTRY;
select '## ' as tag,  count(*) as cnt,  'BASELINEMEMBER'        as tbl from BASELINEMEMBER; 

spool off



