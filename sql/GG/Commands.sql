create table TestWTPartMaster as select * from WTPartMaster where wtpartnumber between '900881' and '900890' ;
select * from WTPartMaster where wtpartnumber between '900881' and '900890' ;
select * from TestWTPartMaster;
drop table TestWTPartMaster;
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+9) where A.wtpartnumber='900881';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+7) where A.wtpartnumber='900882';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+5) where A.wtpartnumber='900883';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+3) where A.wtpartnumber='900884';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+1) where A.wtpartnumber='900885';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber-1) where A.wtpartnumber='900886';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber-3) where A.wtpartnumber='900887';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber-5) where A.wtpartnumber='900888';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber-7) where A.wtpartnumber='900889';
update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber-9) where A.wtpartnumber='900890';
commit;

DECLARE

    i NUMBER := 900881;
    j NUMBER := 9;

BEGIN

    LOOP

        update WTPartMaster A set name=(select name from TestWTPartMaster where wtpartnumber= A.wtpartnumber+j) where A.wtpartnumber=i;

        i := i+1;
        j := j-2;

        EXIT WHEN i>900890;

    END LOOP;

END;

@UpdatePartDescription.sql;