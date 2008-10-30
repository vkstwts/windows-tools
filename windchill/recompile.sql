spool recompile.log
set echo on

/*
 * Copyright (c) 2005 PTC Windchill. All Rights Reserved.
 *
 * This software is the confidential and proprietary information of
 * Windchill. You shall not disclose such confidential information
 * and shall use it only in accordance with the terms of the license
 * agreement you entered into with Windchill.
 *
 * This script updates windchill database objects affected by R9.0 M020
 *
 * Output will be written to wnc-wsp.log
 * You can ignore instances of the following errors in the log file:
 *     --ORA-00955: name is already used by an existing object 
 *     --ORA-01408: such column list already indexed
 *     --ORA-01430: column being added already exists in table
 */

set echo off



spool off


REM ALL CHANGES AND UPDATES TO THIS SCRIPT SHOULD GO BEFORE THIS LINE

set echo off
set verify off
set heading off
set feedback off
set pagesize 600

set term off

column object_name format A40
column object_type format A30

spool temp_recomp_pk1.sql


SELECT distinct('alter package '||object_name||' compile '||';' )
FROM user_objects
WHERE object_type in ('PACKAGE', 'PACKAGE BODY')  AND status = 'INVALID';


spool off

set verify on
set heading on
set feedback on
set pagesize 14
set term on
set echo on

@temp_recomp_pk1.sql

set echo off
set verify off
set heading off
set feedback off
set pagesize 600

set term off

column object_name format A40
column object_type format A30

spool temp_recomp_pk2.sql

SELECT distinct('alter package '||object_name||' compile '||';' )
FROM user_objects
WHERE object_type in ('PACKAGE', 'PACKAGE BODY')  AND status = 'INVALID';


spool off

set verify on
set heading on
set feedback on
set pagesize 14
set term on
set echo on

@temp_recomp_pk2.sql


set echo on
/*
 * Output has been written to recompile.log
 * You can ignore instances of the following errors in the log file:
 *     --ORA-00955: name is already used by an existing object 
 *     --ORA-01418: specified index does not exist
 *     --ORA-01430: column being added already exists in table
 *     
 *     
 */
