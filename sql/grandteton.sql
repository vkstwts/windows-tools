select D.* from EPMDocument D, EPMDocumentMaster M where M.ida2a2=D.ida3masterreference and D.branchida2typedefinitionrefe=892;

select D.* from EPMDocument D, EPMDocumentMaster M where M.ida2a2=D.ida3masterreference and M.documentnumber='CAD-0034979';

select M.* from EPMDocument D, EPMDocumentMaster M where M.ida2a2=D.ida3masterreference and M.documentnumber='CAD-0034979';

select D.versionida2versioninfo,D.versionlevela2versioninfo from EPMDocument D, EPMDocumentMaster M where M.ida2a2=D.ida3masterreference and M.documentnumber='CAD-0034979';

update EPMDocument set versionida2versioninfo='A',versionlevela2versioninfo=1 where ida2a2 in (select D.ida2a2 from EPMDocument D, EPMDocumentMaster M where M.ida2a2=D.ida3masterreference and M.documentnumber='CAD-0034979');
