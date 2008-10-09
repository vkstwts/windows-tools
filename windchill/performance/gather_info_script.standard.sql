--Written and maintained by PTC Technical Support

--Last Modified Feb 7, 2008
	--Add a question to ensure that only customer with the Oracle tuning package and diagnostic packages will run the AWR and ADDM reports.
--Last Modified Feb 4, 2008
	--Added a check for indexes not present on columns which start with the name ID
--Last Modified Feb 1, 2008
	--Added generation of plans for highest rersource consuming SQL stored in the dba_hist_sqlstat table
	--Changed the snaps for which the ADDM and AWR reports were run for.  The 8 highest load intervals now have reports generated against them instead of just the last 10 taken.
--Last Modified Jan 28, 2008
	--Added AWR reports for all of the last 8 snapshots
	--Added the running of the ADDR for each of these intervals too
	--Added a free space check
	--Added a dba_scheduler_jobs report
--Last Modified Jan 25, 2008
	--Replaced the histogram report with a report giving more detailed information about each column 
	--Added AVG_DATA_BLOCKS_PER_KEY to the index report, this will help when trying to understand the data distibution in the index
--Last Modified Jan 18, 2008
	--Added PL/SQL block to output the CBO Plan and SQL for the 20 longest running SQL statements
	--Made a minor change to the rollback section to output rollback space size by tablespace, this will be useful to see the cases where the undo_tablespace parameter doesn't point to a "large" tablespace
	--Fixed the timeup calculation at the top of the script to return a value for 10g
	--Added automatic running of the AWR report covering the previous 8 hours
	--Initiate a snap shot at the beginning of the report, and output the AWR report for the most recent interval only
--Last Modified May 31, 2007
	--Addded SQL hash_value to some of the queries in order to use a new script which will output plans
	--and row source operations when statistics_level= all
--Last Modified April 4, 2007
	--Made some formatting changes to make reports from 10g systems easier to read
--Last Modified Feb 21, 2007
	--Added " select * from V$version;" to try and catch cases when the database has been incompletly upgraded.
	--Added a free space check
--Last Modified Feb 08, 2007
	--Add a check for invalid indexes
--Last Modified Nov 27, 2006
	--Removed Table Row Lengths query
	--Added usernames to the "Worst Total SQL by CPU Time "& "Worst SQL by CPU Time per transaction" queries
	--Modified the "Find Large Blobs" to query dba_ views and not user_ views
--Last Modified June 19, 2006 
	--Added a query to report on average row lengths of each table which can be used to estimate memory footprints
	--Relocated Segement Statistics reports below the index defintions to allow for easier navigation

--Last Modified April 19
	--Added Shared Pool diagnostic information

--Last Modified April 4
	--Added queries from Fino to check cursors and parse counts
	

--Last Modified: Jan 27
	--Added a query to report on the contents of the dba_jobs table

--Last Modified: Jan 23, 2006
	--Added queries to report on rollback usage mostly for migration

--Last Modified: Jan 16, 2006
	--Added a report for histograms
	--Added some leaf blocks and clustering factor to report on indexes
	--Added query to report system statistics
	--Slighly modified formatting so as not output as many ********** lines (used for navigating between report sections)

--Last Modified: Dec 13, 2005
	--Changed Worst SQL By Buffer Gets per Execution to also output explain plans if statistics_level=all
	--Folded the query against dba_indexes into the one with dba_ind_columns and added AVG_LEAF_BLOCKS_PER_KEY to the output
	--Remove frag percent cacluation, proved not to be as useful as once thought
	--Removed one of the table output queries to make the report easier to deal with and added chain_cnt to the output
	--Added a Querys against the V$SEGMENT_STATISTICS to output segment level statistics to aid in idenifing objects that are being being heavily accessed
	--Added a query to output tables with more than 1000 rows (the tables where most tuning activity will be targeted)

--Last Modified: Nov 30, 2005
	--Added a query to report on Temp File I/O to determine if the pga_aggregate_target is under sized

--Last Modified: Aug 17, 2005
	--Added check to "Find SQL WithHigh RowCounts returned per execution or high total number of rows returned"
	--Removed one of the two QueueEntry checks

-- Modified: Aug 15, 2005
	--Added Sclability info query
	--Added rows_processed to the "Worst Total SQL by CPU Time" query

--Gather Info Script 

--This script needs to be run while logged in as either the sys or system user.  i.e.
--        sqlplus "sys/sys as sysdba" @d:\temp\gather_info_script

--A report.txt file will be generated in the directory from which SQL*Plus was started. 
--

--Some SQL in this report is 10g specific because of this, errors running this file against
--9i and 8i databases can be ignored.

spool report_standard_pecan_2008-09-03.txt
set trimspool on

set pagesize 50
select min(to_char(STARTUP_TIME, 'mon-dd-fmday-am-hh-mi-ss')) "Instance Start Time"
from  v$instance;

select to_char(sysdate, 'mon-dd-fmday-am-hh-mi-ss') "Script execution Time"
from  dual;

col days_up for 999.99
Select (sysdate - min(LOGON_TIME)) days_up from v$session;

Prompt ***********************************************************************
set linesize 200
show parameters
set linesize 1000
select * from V$instance;
 select * from V$version;
Prompt ***********************************************************************


col event  format        a25  heading "Wait Event" trunc
col timew     format    999,999,999.99  heading "Time(secs)|Waited"
select event,time_waited/100 timew
from   v$system_event
order by time_waited ;

Prompt *Current memory sizes**********************************************************************

select * from V$SGAINFO order by bytes;
--Generate a snapshot to be used later, it is placed here so the queries below do not appear in the output
--EXECUTE DBMS_WORKLOAD_REPOSITORY.CREATE_SNAPSHOT();


col name for a30
set linesize 3000
Prompt **V$DB_CACHE_ADVICE*****************************************************
col name format a25
select * from V$DB_CACHE_ADVICE;
Prompt **V$PGA_TARGET_ADVICE*****************************************************
select * from V$PGA_TARGET_ADVICE;
Prompt **V$SHARED_POOL_ADVICE*****************************************************
select * from V$SHARED_POOL_ADVICE;
Prompt *Cursor Check**********************************************************
select name,value from v$sysstat where name like '%cursors current%';
Prompt ** Session Cursor Cache Hits ******************************************
select name,value from v$sysstat where name like '%session cursor cache hits';
Prompt ** Cursor Parse Counts ************************************************
select name,value from v$sysstat where name like '%parse count%';

/* shared pool diagnostic based on: Metalink Note:146599.1
https://metalink.oracle.com/metalink/plsql/f?p=130:14:7683074227855145454::::p14_database_id,p14_docid,p14_show_header,p14_show_help,p14_black_frame,p14_font:NOT,146599.1,1,1,1,helvetica
*/


SELECT SUM(PINS) "EXECUTIONS",
            SUM(RELOADS) "CACHE MISSES WHILE EXECUTING"
            FROM V$LIBRARYCACHE;
            
            SELECT substr(sql_text,1,40) "SQL",
	    count(*) ,
	    sum(executions) "TotExecs"
	    FROM v$sqlarea
	    WHERE executions < 5
	    GROUP BY substr(sql_text,1,40)
	    HAVING count(*) > 30
ORDER BY 2;

SELECT * FROM X$KSMLRU WHERE ksmlrsiz > 0;

select '0 (<140)' BUCKET, KSMCHCLS, KSMCHIDX, 10*trunc(KSMCHSIZ/10) "From",
count(*) "Count" , max(KSMCHSIZ) "Biggest",
trunc(avg(KSMCHSIZ)) "AvgSize", trunc(sum(KSMCHSIZ)) "Total"
from x$ksmsp
where KSMCHSIZ<140
and KSMCHCLS='free'
group by KSMCHCLS, KSMCHIDX, 10*trunc(KSMCHSIZ/10)
UNION ALL
select '1 (140-267)' BUCKET, KSMCHCLS, KSMCHIDX,20*trunc(KSMCHSIZ/20) ,
count(*) , max(KSMCHSIZ) ,
trunc(avg(KSMCHSIZ)) "AvgSize", trunc(sum(KSMCHSIZ)) "Total"
from x$ksmsp
where KSMCHSIZ between 140 and 267
and KSMCHCLS='free'
group by KSMCHCLS, KSMCHIDX, 20*trunc(KSMCHSIZ/20)
UNION ALL
select '2 (268-523)' BUCKET, KSMCHCLS, KSMCHIDX, 50*trunc(KSMCHSIZ/50) ,
count(*) , max(KSMCHSIZ) ,
trunc(avg(KSMCHSIZ)) "AvgSize", trunc(sum(KSMCHSIZ)) "Total"
from x$ksmsp
where KSMCHSIZ between 268 and 523
and KSMCHCLS='free'
group by KSMCHCLS, KSMCHIDX, 50*trunc(KSMCHSIZ/50)
UNION ALL
select '3-5 (524-4107)' BUCKET, KSMCHCLS, KSMCHIDX, 500*trunc(KSMCHSIZ/500) ,
count(*) , max(KSMCHSIZ) ,
trunc(avg(KSMCHSIZ)) "AvgSize", trunc(sum(KSMCHSIZ)) "Total"
from x$ksmsp
where KSMCHSIZ between 524 and 4107
and KSMCHCLS='free'
group by KSMCHCLS, KSMCHIDX, 500*trunc(KSMCHSIZ/500)
UNION ALL
select '6+ (4108+)' BUCKET, KSMCHCLS, KSMCHIDX, 1000*trunc(KSMCHSIZ/1000) ,
count(*) , max(KSMCHSIZ) ,
trunc(avg(KSMCHSIZ)) "AvgSize", trunc(sum(KSMCHSIZ)) "Total"
from x$ksmsp
where KSMCHSIZ >= 4108
and KSMCHCLS='free'
group by KSMCHCLS, KSMCHIDX, 1000*trunc(KSMCHSIZ/1000);


SELECT pool,name,bytes FROM v$sgastat where pool = 'large pool';


Prompt *Scalability info***********************************************

select sum(CPU_TIME*0.000001) CPU_TIME_secs,
sum(ELAPSED_TIME*0.000001) ELAPSED_TIME_Secs,
sum(FETCHES) FETCHES,
sum(ROWS_PROCESSED) ROWS_PROCESSED,
sum(EXECUTIONS) EXECUTIONS,
sum(LOADS) LOADS,
sum(PARSE_CALLS) PARSE_CALLS,
sum(DISK_READS) DISK_READS,
sum(BUFFER_GETS) BUFFER_GETS
from v$sql;

set linesize 190
Prompt *System Statistics***********************************************

select pname, pval1 from  sys.aux_stats$  where            sname = 'SYSSTATS_MAIN';

Prompt *DBA_jobs and dba_scheduler_jobs report***********************************************
set linesize 350
col INTERVAL for a50
col WHAT  for a50
select JOB, LOG_USER,LAST_DATE,TOTAL_TIME,BROKEN,INTERVAL,FAILURES,WHAT from dba_jobs;

set linesize 550
col JOB_ACTION for a80
col REPEAT_INTERVAL for a50
col OWNER for a20
 select OWNER,JOB_NAME,JOB_ACTION, 
 REPEAT_INTERVAL,RUN_COUNT,FAILURE_COUNT,LAST_START_DATE,LAST_RUN_DURATION,
 NEXT_RUN_DATE,MAX_RUN_DURATION from dba_scheduler_jobs order by LAST_START_DATE;


Prompt *Queue Entry Table Check***********************************************
Select sum(bytes) aSum, segment_name,owner  from dba_segments where Segment_name='QUEUEENTRY' group by segment_name,owner;

Prompt *EndQueue Entry Table Check***********************************************
Prompt ***Check to make sure log mode and archiver don't conflict*************
col name for a10
select NAME, LOG_MODE,OPEN_MODE,PROTECTION_MODE,PROTECTION_LEVEL from v$database;
show parameter log_archive_start

Prompt ***Check the disk I/O occuring in the system***************************

col name for a100
col "Ratio" for 999.999
set linesize 600
set pagesize 75
col TABLESPACE for a10
select v$datafile.name ,V$TABLESPACE.name Tablespace, v$filestat.*
from v$filestat, v$datafile,V$TABLESPACE where
v$datafile.FILE# = v$filestat.FILE#
and PHYBLKRD / (decode(PHYRDS, 0,1,phyrds)) >= 1
and v$datafile.TS#=v$TABLESPACE.TS#
order by 5;

col TempFile for a80
col "Ratio" for 999.999
set linesize 250
set pagesize 75
select name TempFile ,PHYBLKRD "BLKs Read",PHYRDS "Phys Read", READTIM,WRITETIM,AVGIOTIM,LSTIOTIM,MINIOTIM,MAXIORTM,MAXIOWTM
from V$TEMPSTAT,  V$TEMPFILE where
V$TEMPFILE.FILE# = V$TEMPSTAT.FILE#
and PHYBLKRD / (decode(PHYRDS, 0,1,phyrds)) >= 1
order by 4;

Prompt ***Check Free Space in each tablespace ********************************

col  free_space for 999,999,999,999,999
select TABLESPACE_NAME, sum(bytes) free_space from dba_free_space group by tablespace_name order by 2;

Prompt ******Rollback Reports****************
Prompt **The queries relating to rollbacks were not built from scracth*
Prompt **they were pulled from http://www.akadia.com/services/ora_optimize_undo.html**

show parameters undo

SELECT SUM(a.bytes) "UNDO_SIZE", TABLESPACE_NAME
  FROM v$datafile a,
       v$tablespace b,
       dba_tablespaces c
 WHERE c.contents = 'UNDO'
   AND c.status = 'ONLINE'
   AND b.name = c.tablespace_name
   AND a.ts# = b.ts#
   group by TABLESPACE_NAME;
   
   
   SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
         "UNDO_BLOCK_PER_SEC"
  FROM v$undostat;
  
  Prompt**Undo Size = Undo retention*block size*Undo block per Sec *****
col "UNDO RETENTION [Sec]" for 999,999,999
col "NEEDED UNDO SIZE [MByte]" for 999,999,999

SELECT d.undo_size/(1024*1024) "ACTUAL UNDO SIZE [MByte]",
       SUBSTR(e.value,1,25) "UNDO RETENTION [Sec]",
       (TO_NUMBER(e.value) * TO_NUMBER(f.value) *
       g.undo_block_per_sec) / (1024*1024) 
       "NEEDED UNDO SIZE [MByte]"
  FROM (
       SELECT SUM(a.bytes) undo_size
         FROM v$datafile a,
              v$tablespace b,
              dba_tablespaces c
        WHERE c.contents = 'UNDO'
          AND c.status = 'ONLINE'
          AND b.name = c.tablespace_name
          AND a.ts# = b.ts#
       ) d,
       v$parameter e,
       v$parameter f,
       (
       SELECT MAX(undoblks/((end_time-begin_time)*3600*24))
          undo_block_per_sec
         FROM v$undostat
       ) g
 WHERE e.name = 'undo_retention'
  AND f.name = 'db_block_size'
/



Prompt *******Find Large Blobs***************************************************

col COLUMN_NAME for a32
select b.TABLE_NAME,b.COLUMN_NAME,a.TABLESPACE_NAME,sum(bytes) Bytes, sum(blocks)
from dba_segments a, dba_lobs b 
where a.SEGMENT_NAME=b.SEGMENT_NAME
group by b.TABLE_NAME,b.COLUMN_NAME,a.TABLESPACE_NAME
having sum(bytes)> 3000000
order by 4;

set linesize 240
col OWNER for a20
col TABLE_NAME for a30
col NUM_ROWS for 999,999,999
col BLOCKS for 999,999,999
col AVG_ROW_LEN for 999,999
col CHAIN_CNT for 999.99
--select OWNER,TABLE_NAME,NUM_ROWS,BLOCKS,AVG_ROW_LEN,CHAIN_CNT,LAST_ANALYZED,(case when blocks <100 then 0 else (1-((num_rows*avg_row_len )/((case when blocks =0 then 1 else blocks end)*16384)))*100 end) frag_per 
select OWNER,TABLE_NAME,NUM_ROWS,BLOCKS,AVG_ROW_LEN,CHAIN_CNT,LAST_ANALYZED
from dba_tables
where OWNER not in 
 ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
  'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
 'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
 order by 1,2;
Prompt **End Report on Tables*************************************************
--Prompt *Report Tables that have more than 10000 rows**************************

set linesize 240
col OWNER for a20
col TABLE_NAME for a30
col NUM_ROWS for 999,999,999
col BLOCKS for 999,999,999
col AVG_ROW_LEN for 999,999
col CHAIN_CNT for 999.99
--select OWNER,TABLE_NAME,NUM_ROWS,BLOCKS,AVG_ROW_LEN,CHAIN_CNT,LAST_ANALYZED,(case when blocks <100 then 0 else (1-((num_rows*avg_row_len )/((case when blocks =0 then 1 else blocks end)*16384)))*100 end) frag_per 
select OWNER,TABLE_NAME,NUM_ROWS,BLOCKS,AVG_ROW_LEN,CHAIN_CNT,LAST_ANALYZED
from dba_tables
where OWNER not in 
 ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
  'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
 'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
 and NUM_ROWS >=10000
order by NUM_ROWS;


Prompt **End Report Tables that have more than 10000 rows*******************************


--Prompt **Report on Indexes ***************************************************

set linesize 350
set pagesize 100
col index_owner for a20
col table_name for a30
col index_name for a30 
col column_name for a32
col column_position for 99
col CLUSTERING_FACTOR for 999,999,999,999,999
col LEAF_BLOCKS for 999,999,999

select a.index_owner, a.table_name,a.index_name,a.column_name,a.column_position,DISTINCT_KEYS,AVG_DATA_BLOCKS_PER_KEY,AVG_LEAF_BLOCKS_PER_KEY,CLUSTERING_FACTOR,LEAF_BLOCKS
from dba_ind_columns a,dba_indexes b
where a.INDEX_OWNER not in 
 ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
  'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
 'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
 and a.INDEX_NAME=b.INDEX_NAME and a.INDEX_OWNER=b.owner
order by 1,2,3,5;

set linesize 150
Prompt *End Report on Indexes************************************************
--Prompt **Report for Indexes Not VALID ***************************************************

set linesize 350
set pagesize 100
col index_owner for a20
col table_name for a30
col index_name for a30 
col column_name for a32
col column_position for 99
col CLUSTERING_FACTOR for 999,999,999,999,999
col LEAF_BLOCKS for 999,999,999

select b.owner, b.table_name,b.index_name, FUNCIDX_STATUS,STATUS
from dba_indexes b
where b.OWNER not in 
 ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
  'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
 'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
 and (b.FUNCIDX_STATUS ='DISABLED' or STATUS !='VALID')
order by 1,2,3;

set linesize 150
Prompt *End Report for invalid Indexes************************************************
--Prompt *Report On Indexes not present for columns starting with ID************************************************

select * from
(select owner, TABLE_NAME,column_name 
 from dba_tab_columns 
 where  owner not in 
  ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
   'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
  'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
  and column_name like 'ID%' and NUM_DISTINCT >1 
  minus
  select INDEX_OWNER,TABLE_NAME,COLUMN_NAME from dba_ind_columns
 where  index_owner not in 
  ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
   'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
  'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
and column_name like 'ID%' 
) order by 1,2,3;

Prompt *End Report On Indexes not present for columns starting with 'ID'************************************************

--Prompt **Report on table columns************************************************

 set linesize 200
 select utc.owner,utc.TABLE_NAME,utc.COLUMN_NAME,utc.NUM_DISTINCT,utc.DENSITY,utc.NUM_NULLS,utc.NUM_BUCKETS
 from dba_tab_columns utc
 where utc.OWNER not in ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
 'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
 'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS')
 and NUM_DISTINCT >0
 order by 1,2,3;

Prompt **End Report on table columns*************************************
--Prompt *Report on SegmentStatistics *****************************************************
col STATISTIC_NAME for a30
select OBJECT_TYPE,STATISTIC_NAME,sum(value) from V$SEGMENT_STATISTICS group by OBJECT_TYPE,STATISTIC_NAME order by 3;
select TABLESPACE_NAME,STATISTIC_NAME,sum(value) from V$SEGMENT_STATISTICS group by TABLESPACE_NAME,STATISTIC_NAME order by 1,3;

select OBJECT_NAME,TABLESPACE_NAME,OBJECT_TYPE,STATISTIC_NAME,VALUE from V$SEGMENT_STATISTICS
where value > 100 order by value,STATISTIC_NAME,OBJECT_NAME;

Prompt **End Report on SegmentStatistics*************************************

--Prompt **Find Update Heavy Operations*****************************************

col LAST_LOAD_TIME for a20
col SQL_TEXT for a60
select username, LAST_LOAD_TIME,EXECUTIONS,SQL_TEXT from v$sql, dba_users
where 
(upper(SQL_TEXT) like '%INSERT%'
or upper(SQL_TEXT) like '%DELETE%'  
or upper(SQL_TEXT) like '%UPDATE%'
or upper(SQL_TEXT) like '%DBMS_LOB.WRITE%')
and upper(SQL_TEXT) not like '%SELECT%'
and dba_users.user_id=v$sql.PARSING_USER_ID 
order by EXECUTIONS;

Prompt **End Find Update Heavy Operations*************************************
--Prompt *Worst Total SQL by CPU Time ************************************************
 
set linesize 191
set pagesize 100
col username for a16
col cpu_time_secs for 999,999,999,999
col elapsed_time_secs  for 999,999,999,999,999
col Elap_Exec  for 999,999,999,999
col ROWS_PROCESSED for 999,999,999,999,999
 
col executions for 999,999,999
col sql_text for a65
select a.HASH_VALUE,c.username, CPU_TIME*0.000001 cpu_time_secs,
ELAPSED_TIME*0.000001 elapsed_time_secs,round(ELAPSED_TIME*0.000001/executions) Elap_per_Exec,
executions,ROWS_PROCESSED,b.piece,b.sql_text
from v$sql a, v$sqltext b,dba_users c
where 
a.address=b.address
and
(
ELAPSED_TIME*0.000001>5
or executions  > 1000
)
and executions>0
and c.user_id=a.PARSING_USER_ID 
order by ELAPSED_TIME,CPU_TIME,a.HASH_VALUE, b.piece asc
/
 
Prompt *END Worst Total SQL by CPU Time **************************************
--Prompt *Worst SQL by CPU Time per transaction*********************************
 
set linesize 180
set pagesize 100
col username for a16
col cpu_time_secs for 999,999,999,999
col elapsed_time_secs  for 999,999,999,999,999
col Elap_Exec  for 999,999,999,999
col LAST_LOAD_TIME for a20
 
col executions for 999,999,999
col sql_text for a65
select c.username,CPU_TIME*0.000001 cpu_time_secs,
ELAPSED_TIME*0.000001 elapsed_time_secs,round(ELAPSED_TIME*0.000001/executions) Elap_per_Exec,
executions,LAST_LOAD_TIME,b.piece,b.sql_text
from v$sql a, v$sqltext b, dba_users c
where 
a.address=b.address
and
(
ELAPSED_TIME*0.000001>5
or executions  > 1000
)
and executions>0
and c.user_id=a.PARSING_USER_ID 
order by Elap_per_Exec,ELAPSED_TIME,CPU_TIME,a.HASH_VALUE, b.piece asc;
/

Prompt *END Worst SQL by CPU Time per transaction*****************************
--Prompt *Worst SQL By Factor **************************************************

set linesize 150
set pagesize 100
col  buffer_gets for 999,999,999,999
col disk_reads  for 999,999,999,999
col "% Bad" for 99.999
col sql_text for a64
select a.HASH_VALUE,buffer_gets,disk_reads,executions,b.piece,((disk_reads*1000)+buffer_gets)/tot.sumed*100  "% Bad" ,b.sql_text
from v$sql a, v$sqltext b,
(select sum((disk_reads*1000)+buffer_gets) sumed from v$sql) tot
where 
a.address=b.address
and
(
disk_reads > 1000
or buffer_gets>100000
or executions  > 1000
)
order by  disk_reads*1000 + buffer_gets ,a.HASH_VALUE,b.piece asc
/
Prompt *End Worst SQL By Factor **********************************************

--Prompt *Find SQL ordered by PIOs**********************************************
 
set linesize 250
set pagesize 100
col  buffer_gets for 999,999,999,999
col dr_per_exec for 999,999,999,999
col gets_per_exec 999,999,999,999
col "Percent_disk" for 99.999
col sql_text for a64
select buffer_gets,disk_reads,executions,disk_reads/executions dr_per_exec,round(buffer_gets/executions) gets_per_exec, b.piece,b.sql_text
from v$sql a, v$sqltext b
where 
a.address=b.address
and buffer_gets >1000
and executions >0
order by  disk_reads,a.HASH_VALUE,b.piece asc
/

Prompt *END Find SQL ordered by PIOs*****************************************

--Prompt *Find SQL where LIOs are close to PIOs*********************************

--Find SQL where LIOs are close to PIOs


set linesize 250
set pagesize 100
col  buffer_gets for 999,999,999,999
col dr_per_exec for 999,999,999,999
col "Percent_disk" for 999.99
col sql_text for a64
select buffer_gets,disk_reads,executions,disk_reads/executions dr_per_exec,b.piece,disk_reads/buffer_gets*100 Percent_disk  ,b.sql_text
from v$sql a, v$sqltext b
where 
a.address=b.address
and disk_reads >1000
and executions >0
order by (buffer_gets/disk_reads)desc,disk_reads/executions ,a.HASH_VALUE,b.piece asc
/
Prompt *END Find SQL where LIOs are close to PIOs*****************************
--Prompt *Find SQL ordered by Execution Counts**********************************



set linesize 250
set pagesize 100
col  buffer_gets for 999,999,999,999
col dr_per_exec for 999,999,999,999
col gets_per_exec for 999,999,999,999
col "Percent_disk" for 99.999
col sql_text for a64
select buffer_gets,disk_reads,executions,disk_reads/executions dr_per_exec,round(buffer_gets/executions) gets_per_exec, b.piece,b.sql_text
from v$sql a, v$sqltext b
where 
a.address=b.address
and buffer_gets >0
and executions >1000
order by  executions,a.HASH_VALUE,b.piece asc
/

Prompt *END Find SQL ordered by Execution Counts************************************
--Prompt *Find SQL WithHigh RowCounts returned per execution or high total number of rows returned**********************************


set linesize 126
set pagesize 100
col  buffer_gets for 999,999,999,999
col rows_per_exec for 999,999,999,999
col gets_per_exec for 999,999,999,999
col ROWS_PROCESSED for 999,999,999,999
col "Percent_disk" for 99.999
col sql_text for a64


select  a.executions,a.ROWS_PROCESSED,a.ROWS_PROCESSED/a.executions Rows_per_exec, b.piece,b.sql_text
from (select address, HASH_VALUE,executions,ROWS_PROCESSED from v$sql where executions != 0) a, v$sqltext b
where 
a.address=b.address
and a.executions != 0
order by  a.ROWS_PROCESSED,Rows_per_exec,a.HASH_VALUE,b.piece asc
/

Prompt *END Find SQL With High RowCounts returned per execution or high total number of rows returned**********************************



Prompt *Output SQL and Plans for long running SQL statements; 10g and higher**********************************

set linesize 200
set serveroutput on size 20000000
DECLARE

	SQLID V$SQL.SQL_ID%TYPE;
	CHILD  V$SQL.CHILD_NUMBER%TYPE;
	v_sqlplan VARCHAR2(200); 
	
	v_sqltext v$sqltext.sql_text%type;

/* Get the identifiers for the slow SQL, limit output to the slowest 20, this should catch 95% of the  */

	cursor ids_for_plans is
		select distinct sql_id,CHILD_NUMBER from (
		select a.sql_id,a.CHILD_NUMBER 
		from v$sql a, v$sqltext b
		where 
		a.address=b.address
		and
		(
		ELAPSED_TIME*0.000001>5
		or executions  > 1000
		) order by ELAPSED_TIME desc
		) where rownum <=20;


/*Get the SQL based on the slow SQL identifiers */

	cursor cur_sqltext (v_sqlid V$SQL.SQL_ID%TYPE, v_child V$SQL.CHILD_NUMBER%TYPE) is
	select b.sql_text
	from v$sql a, v$sqltext b
	where 
	a.address=b.address and 
	a.sql_id=v_sqlid 
	and a.child_number=v_child
	order by b.piece;

/*Get the Plan based on the slow SQL identifiers */

cursor cur_output (v_sqlid V$SQL.SQL_ID%TYPE, v_child V$SQL.CHILD_NUMBER%TYPE) is
	select * from table(dbms_xplan.display_cursor(v_SQLID,v_CHILD));

BEGIN

open ids_for_plans;

	loop
		/* Get the SQLID and cursor Child number */
		fetch ids_for_plans into SQLID,CHILD;
			--dbms_output.put_line(SQLID);
			--dbms_output.put_line(CHILD);
			
		
		/*Display the SQL */
			open cur_sqltext (SQLID,CHILD);
			loop
			fetch cur_sqltext into v_sqltext;
			--dbms_output.put_line('The SQL is: ');
				dbms_output.put_line(v_sqltext );
			exit when cur_sqltext%NOTFOUND;
			end loop;
			close cur_sqltext;
		
		/* Display the Plan */
			open cur_output(SQLID,CHILD);
			loop
			fetch cur_output into v_sqlplan;
			--dbms_output.put_line('The Plan is: ');
			dbms_output.put_line(v_sqlplan );
			exit when cur_output%NOTFOUND;
			end loop;
			close cur_output;
			
	dbms_output.put_line('--------------------------------------------------');
	dbms_output.put_line('--------------------------------------------------');		

	exit when ids_for_plans%NOTFOUND;
	
	END LOOP;

close ids_for_plans;

    END;
.
run;


Prompt *End Output SQL and Plans for long running SQL statements**********************************

--------------
--------------

Prompt -->The rest of this diagnostic script depends on the database being licensed to run the 
Prompt -->Oracle tuning and Diagnostic package which are purchased from Oracle at an additional cost of @$3000.00 each
Prompt -->There is no record in the database of whether they have been purchased or not, 
Prompt -->A receipt of their purchase from Oracle is the proof they have been licensed.
Prompt
accept additional_packages_installed default no prompt 'Is this database licensed to run these packages? [yes/no; default = no]'

set linesize 200
set serveroutput on size 20000000


/*
WHENEVER SQLERROR EXIT SQL.SQLCODE
begin
  SELECT COLUMN_DOES_NOT_EXIST FROM DUAL;
END;
/
*/
WHENEVER SQLERROR EXIT SQL.SQLCODE

DECLARE

	var1 number:=0;
	var2 number;
	cursor cursor_error  is
	SELECT 1/dummy FROM DUAL;
	
begin

        if to_char('&additional_packages_installed') = to_char('no')
        then var1:=2;
        dbms_output.put_line(var1);
        		if var1>1 then
			  open cursor_error;
			  dbms_output.put_line('The gather info script has been intentionally abort');
			  dbms_output.put_line('because needed Oracle licensing is not present');

			  fetch cursor_error into var2;
			end if;

        end if;
    END;
.
run;



variable task_name  varchar2(40);




Prompt *Start Output SQL and Plans for long running SQL statements from the AWR respository*********************************

set linesize 500
set serveroutput on size 20000000

 
DECLARE

	SQLID DBA_HIST_SQLSTAT.SQL_ID%TYPE;

	v_elapsed	DBA_HIST_SQLSTAT.ELAPSED_TIME_DELTA%TYPE;
	v_cpu_tot DBA_HIST_SQLSTAT.CPU_TIME_DELTA%TYPE;
	v_Disk_reads_tot DBA_HIST_SQLSTAT.DISK_READS_DELTA%TYPE;
	v_buffer_gets_tot DBA_HIST_SQLSTAT.BUFFER_GETS_DELTA%TYPE;
	v_executions_tot DBA_HIST_SQLSTAT.EXECUTIONS_DELTA%TYPE;
	
	
	v_sqlplan VARCHAR2(200); 
	
	v_sqltext v$sqltext.sql_text%type;

/* Get the identifiers for the slow SQL, limit output to the slowest 20, this should catch 95% of the  */

	cursor ids_for_plans is
	select distinct sql_id from (
			select b.SQL_ID
			from dba_hist_sql_plan a, dba_hist_sqlstat b where
			a.sql_id=b.sql_id and
			a.object_owner is not null and
			a.object_owner not in  ('SYS','SYSTEM','WMSYS','WKSYS','XDB','QS','QS_CBADM','QS_CS','QS_ES','QS_OS','QS_WS','ODM','ODM_MTR','OLAPSYS','ORDSYS','OUTLN',
			'DBSNMP','SYSMAN','MGMT_VIEW','SYS','SYSTEM','MDSYS','ORDSYS','EXFSYS','DMSYS','SCOTT','WMSYS','TSMSYS','BI','PM','MDDATA','IX','CTXSYS','ANONYMOUS',
			'SH','OUTLN','DIP','OE','HR','XDB','ORDPLUGINS','SI_INFORMTN_SCHEMA','OLAPSYS','DBMS_XPLAN','DBMS_SPACE')
			order by b.ELAPSED_TIME_TOTAL
		) where rownum <=20;


/*Get the SQL based on the slow SQL identifiers */

	cursor cur_sqlresources (v_sqlid V$SQL.SQL_ID%TYPE) is
	select distinct ELAPSED_TIME_DELTA,CPU_TIME_DELTA,DISK_READS_DELTA,BUFFER_GETS_DELTA,EXECUTIONS_DELTA from (
			select b.SQL_ID,b.ELAPSED_TIME_DELTA,b.CPU_TIME_DELTA,b.DISK_READS_DELTA,b.BUFFER_GETS_DELTA,b.EXECUTIONS_DELTA
			from  dba_hist_sqlstat b where
			b.sql_id =v_sqlid );

/*Get the Plan based on the slow SQL identifiers */

cursor cur_output (v_sqlid V$SQL.SQL_ID%TYPE) is
	select * from table(dbms_xplan.display_awr(v_SQLID));

BEGIN

open ids_for_plans;

	loop
		/* Get the SQLID and cursor Child number */
		fetch ids_for_plans into SQLID;
			--dbms_output.put_line('The SQL ID is: ' ||SQLID);

		/* Get the Resource consumption of the statement */
		open cur_sqlresources (SQLID);
		for i in 1..1 loop
		fetch cur_sqlresources into v_elapsed,v_cpu_tot,v_Disk_reads_tot,v_buffer_gets_tot,v_executions_tot;
		dbms_output.put_line('*AWR high resource SQL****************************************************');
			dbms_output.put_line('Total Elapsed Time: ' || v_elapsed );
			dbms_output.put_line('Total CPU Time: ' || v_elapsed );
			dbms_output.put_line('Total Executions: ' || v_executions_tot );
			dbms_output.put_line('Total Disk Reads: ' || v_Disk_reads_tot );
			dbms_output.put_line('Total Buffer Gets: ' || v_buffer_gets_tot );

		exit when cur_sqlresources%NOTFOUND;
			end loop;
			close cur_sqlresources;
		
		/* Display the Plan */
			dbms_output.put_line('----Plan------------');

			open cur_output(SQLID);
			loop
			fetch cur_output into v_sqlplan;
			--dbms_output.put_line('The Plan is: ');
			dbms_output.put_line(v_sqlplan );
			exit when cur_output%NOTFOUND;
			end loop;
			close cur_output;
			
	--dbms_output.put_line('--------------------------------------------------');		

	exit when ids_for_plans%NOTFOUND;
	
	END LOOP;

close ids_for_plans;

    END;
.
run;



Prompt *End Output SQL and Plans for long running SQL statements from the AWR respository*********************************

Prompt *Start Output AWR and ADDM reports for the 8 highest resource consuming snap intervals in the last 7 days*********************************



set long 1000000 pagesize 0 longchunksize 1000
variable task_name  varchar2(40);
set linesize 200
set serveroutput on size 20000000
column get_clob format a80

 
DECLARE

	v_dbid number;
	v_iid number;
	v_snap_id_start number;
	v_snap_id_end number;
	v_output_awr varchar2(32767);
	v_output_addm varchar2(32767);
	v_name  varchar2(100);

	cursor database_id is
	select dbid from v$database;

	cursor instance_id is
	select INSTANCE_NUMBER iid from  v$instance;

--Find the snap ids for the 8 intervals where the load appeared to be highest as measured by dba_hist_sqlstat
--Not all SQL is stored in this table, but enough should be to be usable for identifying the high load periods
--adjust the 'row_num <= 8' up to include more intervals or down to see fewer

	cursor snap_id is
	select snap_id snap_start, (snap_id +1) snap_end from 
	(select snap_ID,rownum row_num from 
		(select snap_id, sum(ELAPSED_TIME_DELTA) tot_time from 
		dba_hist_sqlstat group by snap_id order by tot_time desc)
	) where row_num <= 8;
	
/*Get the AWR report on the SNAP IDs identifiers */

cursor awr_output
	(v1_dbid number,v1_iid number,v1_snap_id_start number,v1_snap_id_end number)
	is select * from table(
	dbms_workload_repository.awr_report_text(v1_dbid, v1_iid, v1_snap_id_start, v1_snap_id_end,8));


cursor addm_output (v_name varchar2 )
	is select dbms_advisor.get_task_report(v_name, 'TEXT', 'TYPICAL') from   sys.dual;
	

    id number;
 name varchar2(100) ;

  BEGIN

open database_id;
fetch database_id into v_dbid;
close database_id;

open instance_id;
fetch instance_id into v_iid;
close instance_id;

		/*get the snap ids reports */
open snap_id ;
loop

fetch snap_id into v_snap_id_start,v_snap_id_end;
dbms_output.put_line('The begining and end snap ids are: ' || v_snap_id_start ||' & '||v_snap_id_end);
dbms_output.put_line('AWR Snap************************************************************************');

		/*get the AWR reports*/

				open awr_output(v_dbid,v_iid,v_snap_id_start,v_snap_id_end);
				loop
					fetch awr_output into v_output_awr;
					dbms_output.put_line(v_output_awr);
				exit when awr_output%NOTFOUND;
				end loop;
				close awr_output;
			
		/*get the ADDM reports */

			name :='';
		     dbms_advisor.create_task('ADDM',id,name,'',null);
		     :task_name := name;

		     -- set time window
		     dbms_advisor.set_task_parameter(name, 'START_SNAPSHOT', v_snap_id_start);
		     dbms_advisor.set_task_parameter(name, 'END_SNAPSHOT', v_snap_id_end);

		     -- set instance number
		     dbms_advisor.set_task_parameter(name, 'INSTANCE', v_iid);

		     -- set dbid
		     dbms_advisor.set_task_parameter(name, 'DB_ID', v_dbid);

		     -- execute task
		     dbms_advisor.execute_task(name);


			open addm_output(name);
			for i in 1..1 loop
--dbms_output.put_line('OUTPUTTING THE ADDM REPORT');
dbms_output.put_line('The begining and end snap ids are: ' || v_snap_id_start ||' & '||v_snap_id_end);
dbms_output.put_line('ADDM Snap************************************************************************');
			
				fetch addm_output into v_output_addm;
				dbms_output.put_line(v_output_addm);
--dbms_output.put_line('DONE OUTPUTTING THE ADDM REPORT');

			exit when addm_output%NOTFOUND;
			end loop;
			close addm_output;
			
			
exit when snap_id%NOTFOUND;
end loop;
close snap_id;






--  end;
end;
/




Prompt *End Output AWR and ADDM reports for the 8 highest resource consuming snaps*********************************





spool off