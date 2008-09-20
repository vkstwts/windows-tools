select M.* from epmdocument d, epmdocumentmaster m where m.ida2a2=d.ida3masterreference and m.documentnumber='CAD-0001152'
SELECT * FROM EPMDOCUMENTMASTER WHERE LOWER(CADNAME) LIKE LOWER('%Part-Test.SLDPRT%')
SELECT * FROM EPMDOCUMENTMASTER WHERE DOCUMENTNUMBER LIKE 'CAD-000115%'
SELECT * FROM EPMDOCUMENTMASTER WHERE DOCUMENTNUMBER LIKE 'CAD-0010499%'

select * from wtorganization where LOWER(name) like '%site%'