/* Tested with Windchill 8.0. Use WinDU to find any dangling References */
/*********************************************************/
/* Delete String type soft attribute */
/* Delete references in logicalidentifiermapentry table */
select l.* from  LogicalIdentifierMapEntry l, stringdefinition d where classnamekeya5 like '%StringDefinition' and  l.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL') 
delete from LogicalIdentifierMapEntry   where ida2a2 in (select l.ida2a2 FROM LogicalIdentifierMapEntry l, stringdefinition d where l.classnamekeya5 like '%StringDefinition' and l.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL') )
/* Delete attribute constraints*/
select c.* from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL') 
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, stringdefinition d where c.classnamekeya5 like '%StringDefinition' and c.ida3a5=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL') )

/*Delete attributes SystemNumber, RequesterPhone,Severity, SoftwareChangeType*/
select v.* from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL')
select * from  stringdefinition  where name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL')
select * from wttypedefinition where ida2a2 in (select v.ida3a4 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL'))
delete from stringvalue where ida2a2 in (select v.ida2a2 from stringvalue v, stringdefinition d where v.ida3a6=d.ida2a2 and d.name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL'))
delete from stringdefinition  where name in ('SystemNumber','RequesterPhone','Severity','SoftwareChangeType','MATERIAL')
/*********************************************************/



/*********************************************************/
/*Delete Software Change Request softtype*/
select * from wttypedefinition where  name like '%Software%'
select * from wttypedefinitionmaster where displaynamekey like'Software%'
select t.* from wttypedefinition t, wttypedefinitionmaster m where m.ida2a2=t.ida3masterreference  and m.displaynamekey like'%Software%'
delete from wttypedefinition where ida2a2 in (select t.ida2a2 from wttypedefinition t, wttypedefinitionmaster m where m.ida2a2=t.ida3masterreference  and m.displaynamekey like'%Software%')
delete  from wttypedefinitionmaster where displaynamekey like'%Software%'
/*********************************************************/



/*********************************************************/
/* Delete Integer type soft attribute */
/* Delete attribute constraints for integer types */
select c.* from typesingleattrconstraint c, integerdefinition d where c.classnamekeya5 like '%IntegerDefinition' and c.ida3a5=d.ida2a2 and d.name in ('FindNum','PkgQty') 
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, integerdefinition d where c.classnamekeya5 like '%IntegerDefinition' and c.ida3a5=d.ida2a2 and d.name in ('FindNum','PkgQty') )
/*Delete integer attributes FindNum,PkgQty */
select v.* from integervalue v, integerdefinition d where v.ida3a6=d.ida2a2 and d.name in ('FindNum','PkgQty')
select * from  integerdefinition  where name in ('FindNum','PkgQty')
select * from wttypedefinition where ida2a2 in (select v.ida3a4 from integervalue v, integerdefinition d where v.ida3a6=d.ida2a2 and d.name in ('FindNum','PkgQty'))
delete from integervalue where ida2a2 in (select v.ida2a2 from integervalue v, integerdefinition d where v.ida3a6=d.ida2a2 and  d.name in ('FindNum','PkgQty'))
delete from integerdefinition  where name  in ('FindNum','PkgQty')

/* Delete attribute constraints with ids for float types*/
select l.* from  LogicalIdentifierMapEntry l, floatdefinition d where classnamekeya5 like '%FloatDefinition' and  l.ida3a5=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost')
delete from LogicalIdentifierMapEntry   where ida2a2 in (select l.ida2a2 FROM LogicalIdentifierMapEntry l, floatdefinition d where l.classnamekeya5 like '%FloatDefinition' and l.ida3a5=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost'))
/*********************************************************/



/*********************************************************/
/* Delete Float type soft attribute */
/* Delete attribute constraints with names*/
select c.* from typesingleattrconstraint c, floatdefinition d where c.classnamekeya5 like '%FloatDefinition' and c.ida3a5=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost')
delete from typesingleattrconstraint where ida2a2 in (select c.ida2a2 from typesingleattrconstraint c, floatdefinition d where c.classnamekeya5 like '%FloatDefinition' and c.ida3a5=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost') )
/*Delete attributes Cost,LeadTime,MFGCost,NON_ASSY_QTY,ShippingSize,ShipWT,VendorCost */
select v.* from floatvalue v, floatdefinition d where v.ida3a6=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost')
select * from  floatdefinition  where name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost')
select * from wttypedefinition where ida2a2 in (select v.ida3a4 from floatvalue v, floatdefinition d where v.ida3a6=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost'))
delete from floatvalue where ida2a2 in (select v.ida2a2 from floatvalue v, floatdefinition d where v.ida3a6=d.ida2a2 and d.name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost'))
delete from floatdefinition  where name in ('Cost','LeadTime','MFGCost','NON_ASSY_QTY','ShippingSize','ShipWT','VendorCost')
/*********************************************************/