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