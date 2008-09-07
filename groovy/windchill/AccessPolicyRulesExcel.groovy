import wt.access.AccessPolicyRule;
import wt.access.AclEntrySet;
import wt.access.AccessControlHelper;
import wt.access.WTAclEntry;

import wt.query.QuerySpec;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import java.util.Enumeration;
import wt.org.WTPrincipal;
import wt.admin.DomainAdministeredHelper;
import wt.admin.AdministrativeDomainHelper;
import wt.admin.AdministrativeDomain;
import wt.admin.AdminDomainRef;
import wt.inf.container.WTContainer;
import wt.inf.container.WTContainerHelper;
import wt.access.AccessPermission;
import wt.type.TypedUtility;
import org.apache.poi.poifs.filesystem.POIFSFileSystem;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFCell;

public static boolean VERBOSE=true;

try{
    className = AccessPolicyRule.class;
    QuerySpec queryspec = new QuerySpec(className);
    QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
    if(VERBOSE) println("Objects of  type "+ className.getName()+"  :"+ queryresult.size());

    String outFilename="AccessPolicyRules.xls";
    File lFile = new File(outFilename);
    // create a new file 
    FileInputStream lFin=null;
    POIFSFileSystem fs=null;
    HSSFWorkbook wb = null;
    HSSFSheet s=null;
    HSSFSheet s2=null; 

        if (lFile.exists()) {   
            System.out.println("file exists");    
                   
        }//if (outF.exists()) 
        else{    
         System.out.println("no file");    
        // create a new workbook    
         wb = new HSSFWorkbook();   
         }
        // create a new sheet
        s = wb.createSheet("ACLs");
         // declare a row object reference
        HSSFRow r = null; 
        // declare a cell object reference
        HSSFCell c = null;
        short rownum; 
       /* for (rownum = (short) 0; rownum < 30; rownum++){  
          // create a row    
            r = s.createRow(rownum);     
             for (short cellnum = (short) 0; cellnum < 10; cellnum += 1)    { 
               // create a numeric cell     
                System.out.println("creating cell :"+cellnum );  
                 c = r.createCell((short)cellnum);   
                 System.out.println("created cell :"+cellnum ); 
                 // do some goofy math to demonstrate decimals       
                 c.setCellValue(rownum * 10000 + cellnum);    
                 System.out.println("Printing cell value :"+(rownum * 10000 + cellnum));   
            }
             System.out.println("Done with row:"+rownum );  
        }
       */
        
        short cellnum = (short) 0;
        
        rownum = (short) 0;  

        r = s.createRow(rownum);   
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue("Parent Domain");   
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue("Container");   
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue( "Domain"); 
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue( "Object Type");  
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue("State");  
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue("Principal");  
        cellnum = (short)(cellnum+1); c = r.createCell((short)cellnum); c.setCellValue("Permissions");  
        rownum = (short)(rownum+1);  
        cellnum = (short) 0;

        while (queryresult.hasMoreElements()) {
           if(VERBOSE) println ("test");
           Object obj = queryresult.nextElement();
             if (obj instanceof AccessPolicyRule) {
                AccessPolicyRule apr = (AccessPolicyRule) obj;
                String displayIdentifier = apr.getDisplayIdentifier();
               // println("Rule  :"+displayIdentifier);
               // AclEntrySet entrySet = apr.getEntrySet();
               Enumeration enumeration = AccessControlHelper.manager.getEntries(apr);
               AdministrativeDomain domain = DomainAdministeredHelper.getAdminDomain(apr);
              // WTContainer container = WTContainerHelper.getContainer(domain);
               WTContainer container = domain.getContainerReference().getObject();//.getReferencedContainerReadOnly();// WTContainerHelper.getContainer(domain);
               //println ("  domain.getContainerReference() :" +  domain.getContainerReference());//((WTContainer)domain.getContainerReference().getObject()).getName())
                AdminDomainRef parentDomainRef = domain.getDomainRef();
                String parentDomainPath =AdministrativeDomainHelper.manager.getDisplayDomainPath(parentDomainRef);
                if(VERBOSE) print ("Parent Domain  :"+ parentDomainPath);
                //cellnum = (short)(cellnum+1);if(VERBOSE) println ("test1"); c = r.createCell((short)cellnum); if(VERBOSE) println ("test2"); c.setCellValue(parentDomainPath);   
                if(VERBOSE) print (" ---  Container  :"+ container.getName()); 
                //cellnum = (short)(cellnum+1);if(VERBOSE) println ("test3"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test4"); c.setCellValue(container.getName());   
                // println (" ---   Domain  :"+ domain.toString());
                if(VERBOSE) println (" --- Domain  :"+ domain.getDisplayIdentifier());
               // cellnum = (short)(cellnum+1);if(VERBOSE) println ("test5"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test6"); c.setCellValue( (String)domain.getDisplayIdentifier());  if(VERBOSE) println ("test6.5");
                if(VERBOSE) println (" Type  :"+apr.getSelector().getTypeId()+" ---  State  :"+apr.getSelector().getStateName());
                //cellnum = (short)(cellnum+1);if(VERBOSE) println ("test7"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test8"); c.setCellValue( apr.getSelector().getStateName());  
               
                while (enumeration.hasMoreElements()) {
                    WTAclEntry entry = (WTAclEntry) enumeration.nextElement();
                    WTPrincipal principal = entry.getPrincipalReference().getPrincipal();
                    if(VERBOSE) print ("\tPrincipal :"+principal.getPrincipalDisplayIdentifier());
                   // println (" Entry  : "+ entry);
                     if(VERBOSE) print (" ---\t Permissions  :");
                        Enumeration enumeratorvector = entry.getPermissions();
                          String permissions ="";
                          while(enumeratorvector.hasMoreElements()){
                                
                            AccessPermission accesspermission = (AccessPermission)enumeratorvector.nextElement();
                            if(VERBOSE) print (accesspermission.getDisplay(Locale.US));
                            permissions +=accesspermission.getDisplay(Locale.US);
                            if(enumeratorvector.hasMoreElements()){
                                if(VERBOSE) print (", ");
                                 permissions +=","
                            }

                        }
                        r = s.createRow(rownum);   
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test1"); c = r.createCell((short)cellnum); if(VERBOSE) println ("test2"); c.setCellValue(parentDomainPath);   
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test3"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test4"); c.setCellValue(container.getName());   
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test5"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test6"); c.setCellValue( (String)domain.getDisplayIdentifier()); 
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test7"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test8"); c.setCellValue( apr.getSelector().getTypeId());  
                       // print("Object Type :"+wt.type.ClientTypedUtility.getTypeDefinitionReference( apr.getSelector().getTypeId()));
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test7"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test8"); c.setCellValue( apr.getSelector().getStateName());  
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test9"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test10"); c.setCellValue( principal.getPrincipalDisplayIdentifier());  
                        cellnum = (short)(cellnum+1);if(VERBOSE) println ("test11"); c = r.createCell((short)cellnum);if(VERBOSE) println ("test12"); c.setCellValue(permissions);  
                        rownum = (short)(rownum+1);  
                        cellnum = (short) 0;
                            
                    if(VERBOSE) println (" ");
                }
                  if(VERBOSE) println (" ");
            }   
          //break;
        }

        FileOutputStream out = new FileOutputStream(outFilename,true);
        wb.write(out);
        out.close();
        //lFin.close();
}catch (Exception e){
    print("Exception Occured :"+e);
    e.printStackTrace ();
}   

// print("Object Type :"+wt.type.ClientTypedUtility.getTypeDefinitionReference( "wt.doc.WTDocument"));



//Reference Sql
//SELECT PDMLINKPRODUCT.NAMECONTAINERINFO PRODUCTNAME, ACCESSPOLICYRULE.CLASSNAMEA5 OBJECTTYPE, ACCESSPOLICYRULE.STATENAMEA5 STATE, WTGROUP.NAME GROUPNAME, WTACLENTRY.PERMISSIONMASK
//FROM
//WTACLENTRY, WTGROUP, ACCESSPOLICYRULE, PDMLINKPRODUCT, ADMINISTRATIVEDOMAIN
//WHERE
//ADMINISTRATIVEDOMAIN.IDA3CONTAINERREFERENCE = PDMLINKPRODUCT.IDA2A2 AND
//ACCESSPOLICYRULE.IDA3DOMAINREF = ADMINISTRATIVEDOMAIN.IDA2A2 AND
//WTACLENTRY.IDA3B3 = ACCESSPOLICYRULE.IDA2A2 AND
//WTGROUP.IDA2A2 = WTACLENTRY.IDA3A3