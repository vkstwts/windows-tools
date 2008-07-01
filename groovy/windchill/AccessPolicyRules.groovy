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


className = AccessPolicyRule.class;
QuerySpec queryspec = new QuerySpec(className);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Objects of  type "+ className.getName()+"  :"+ queryresult.size());

while (queryresult.hasMoreElements()) {
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
        print ("Parent Domain  :"+ parentDomainPath);
        print (" ---  Container  :"+ container.getName()); 
        // println (" ---   Domain  :"+ domain.toString());
        println (" --- Domain  :"+ domain.getDisplayIdentifier());
           println (" Type  :"+apr.getSelector().getTypeId()+" ---  State  :"+apr.getSelector().getStateName());
        while (enumeration.hasMoreElements()) {
            WTAclEntry entry = (WTAclEntry) enumeration.nextElement();
            WTPrincipal principal = entry.getPrincipalReference().getPrincipal();
            print ("\tPrincipal :"+principal.getPrincipalDisplayIdentifier());
           // println (" Entry  : "+ entry);
             print (" ---\t Permissions  :");
            Enumeration enumeratorvector = entry.getPermissions();

                  while(enumeratorvector.hasMoreElements()){
                        
                    AccessPermission accesspermission = (AccessPermission)enumeratorvector.nextElement();
                    print (accesspermission.getDisplay(Locale.US));
                    if(enumeratorvector.hasMoreElements())
                        print (", ");
                }
            println (" ");
        }
          println (" ");
    }   
}

//Reference Sql
//SELECT PDMLINKPRODUCT.NAMECONTAINERINFO PRODUCTNAME, ACCESSPOLICYRULE.CLASSNAMEA5 OBJECTTYPE, ACCESSPOLICYRULE.STATENAMEA5 STATE, WTGROUP.NAME GROUPNAME, WTACLENTRY.PERMISSIONMASK
//FROM
//WTACLENTRY, WTGROUP, ACCESSPOLICYRULE, PDMLINKPRODUCT, ADMINISTRATIVEDOMAIN
//WHERE
//ADMINISTRATIVEDOMAIN.IDA3CONTAINERREFERENCE = PDMLINKPRODUCT.IDA2A2 AND
//ACCESSPOLICYRULE.IDA3DOMAINREF = ADMINISTRATIVEDOMAIN.IDA2A2 AND
//WTACLENTRY.IDA3B3 = ACCESSPOLICYRULE.IDA2A2 AND
//WTGROUP.IDA2A2 = WTACLENTRY.IDA3A3