import groovy.sql.Sql

println "---- A working test of writing and then reading a blob into an Oracle DB ---"
instance = Sql.newInstance("jdbc:oracle:thin:@localhost:1521:wind", "wtuser",
                     "wtuser", "oracle.jdbc.OracleDriver")

//rowTest = sql.firstRow("select m.name,m.wtpartnumber,p.VERSIONIDA2VERSIONINFO,p.ITERATIONIDA2ITERATIONINFO from wtpart p, wtpartmaster m where m.ida2a2=p.ida3masterreference and p.latestiterationinfo=1")
sql = "select m.name,m.wtpartnumber,p.VERSIONIDA2VERSIONINFO,p.ITERATIONIDA2ITERATIONINFO "+
      "from wtpart p, wtpartmaster m " +
      " where m.ida2a2=p.ida3masterreference and p.latestiterationinfo=1"
rowTest = instance.rows(sql);
println "No. of parts $rowTest ---"
println " "
println " "
instance.connection.close()




