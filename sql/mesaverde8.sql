select idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner,count(idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner) from controlbranch having (count9idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner)>1)

select idA3masterReference,versionIdA2versionInfo,iterationIdA2iterationInfo,WipPK.getNormalizedWipState(statecheckoutInfo),idA3view,oneOffVersionIdA2oneOffVersi from wtpart where ida3masterreference=23786565
select * from  wtpart where ida3masterreference=23786565
select * from wtpartmaster where ida2a2=23801079
select * from controlbranch where ida3b5=23786565

CREATE UNIQUE INDEX CONTROLBRANCH$UNIQ01 ON ControlBranch(idA3B5,versionId,oneOffVersionId,viewId,UPPER(adHocStringIdentifier),WipPK.getNormalizedWipState(wipState),sessionOwner)
 TABLESPACE INDX
 STORAGE ( INITIAL 20k NEXT 20k PCTINCREASE 0 )

select * from wfassignedActivity where ida3a5 in (13744032)
delete from wfassignedActivity where ida3a5 in (13744032)

select * from epmcadnamespace where ida3a3=607156
select * from epmdocumentmaster where ida2a2=607156
update epmcadnamespace set cadname ='Part test1' where ida3a3=607156;

select cadname from epmcadnamespace  where ida3a3=9083693;
update epmcadnamespace set cadname ='ss-1610-1-16_obsolete.sldprt' where ida3a3=9083693;
select cadname, count(cadname) from epmcadnamespace group by cadname having ( count(cadname) >1)

SELECT DISTINCT gm.CADName, im.CADName, im.idA2A2 FROM EPMDocument i, EPMDocumentMaster im, EPMDocument g, EPMDocumentMaster gm, EPMContainedIn cii, EPMContainedIn cig, EPMSepFamilyTable ft WHERE (im.authoringApplication = 'CATIAV5' OR im.authoringApplication = 'SOLIDWORKS' OR im.authoringApplication = 'ACAD' OR im.authoringApplication = 'UG') and (i.familyTableStatus = 1 OR i.familyTableStatus = 3) AND im.idA2A2 = i.idA3MasterReference AND i.idA2A2 = cii.idA3A5 AND gm.idA2A2 = g.idA3MasterReference AND g.idA2A2 = cig.idA3A5 AND g.familyTableStatus = 2 AND cig.idA3B5 = ft.idA2A2 AND cii.idA3B5 = ft.idA2A2

select * from epmdocumentmaster where documentnumber='CAD-0001153'
update epmdocumentmaster set cadname='Part-Test1', name='Part-Test1' where documentnumber='CAD-0001153'

select * from epmdocumentmaster where documentnumber='CAD-0010499'
update epmdocumentmaster set cadname='SS-1610-1-16-1.sldprt' where documentnumber='CAD-0010499'

select * from wfassignedActivity where ida3a5 in (13744032,26311649)
delete from wfassignedActivity where ida3a5 in (13744032)
select * from WfVotingEventAudit  where ida3a5=26311649
select * from WfAssignmentEventAudit  where ida3b6=26311649
select * from WfProcess  where ida3b7=26311649
select * from wtuser where LOWER(name) like 'cmshankar%'
DELETE wtuser where LOWER(name) like 'cmshankar%'
select * from wtuser where ida2a2=12731489

SELECT * FROM WTUSER WHERE IDA2A2=26311649

/*Delete principals */ select * from wtuser where name like '%meggers%'
select * from roleprincipalmap where ida3b4 in (26251520,26251527,871623,1460811,12292242,12731489,19726066,26311632,26311649)
delete from roleprincipalmap where ida3b4 in (26251520,26251527,871623,1460811,12292242,12731489,19726066,26311632,26311649)
select * from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar'))
delete from roleprincipalmap where ida3b4 in (select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar'))
select * from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar'))
delete from remoteobjectinfo where ida3a3 in( select ida2a2 from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')); 
select * from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon@bloomenergy.com','cmshankar@bloomenergy.com','nils','makaludave','ebatawi1','meggers','abmenon1','cmshankar')
delete from wtuser where name in ('warehouse','nils@nxrev.com','makaludave@yahoo.com','ebatawi@bloomenergy.com','meggers@bloomenergy.com','abmenon','cmshankar@bloomenergy.com','nils','makaludave','ebatawi','meggers','abmenon','cmshankar')


select name,documentnumber from epmdocumentmaster where name like '%-1610-1-16%';
select cadname,name,documentnumber,ida2a2 from epmdocumentmaster where ida2a2 in ('9083693','29907');
select cadname from  epmcadnamespace where ida3a3=9083693;
update epmcadnamespace set cadname ='ss-1610-1-16_obsolete.sldprt' where ida3a3=9083693;

select * from epmdocumentmaster where documentnumber='CAD-0001153'
update epmdocumentmaster set cadname='Part-Test1', name='Part-Test1' where documentnumber='CAD-0001153'

select * from epmdocumentmaster where documentnumber='CAD-0010499'
update epmdocumentmaster set cadname='SS-1610-1-16-1.sldprt' where documentnumber='CAD-0010499'

Wed 8/20/08 15:04:37: RESULT|LogicalIdentifierMapEntry|wt.iba.definition.StringDefinition|9844878|IDA2A2||
Wed 8/20/08 15:04:37: RESULT|LogicalIdentifierMapEntry|wt.iba.definition.StringDefinition|6525323|IDA2A2||
Wed 8/20/08 15:04:37: RESULT|LogicalIdentifierMapEntry|wt.iba.definition.IntegerDefinition|6525347|IDA2A2||

select pd.name, pi.* from preferencedefinition pd,preferenceinstance pi where name = '/com/ptc/windchill/enterprise/search/latestVersionDefaultSearch' and pd.ida2a2=pi.ida3a4 and pi.instancetype = 200; 
select * from DBPREFENTRY where name like '%/com/ptc/windchill/enterprise/search/latestVersionDefaultSearch%';
select * from wtuser;
select pd.name , count (pd.name)from preferencedefinition pd,preferenceinstance pi where pd.ida2a2=pi.ida3a4 and pi.instancetype = 200 group by pd.name having count (pd.name) > 1;
