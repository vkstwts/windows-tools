import wt.pdmlink.PDMLinkProduct;
import wt.query.QuerySpec;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.org.WTPrincipal;
import wt.org.WTOrganization;
import wt.session.SessionHelper;
import wt.query.SearchCondition;
import wt.inf.container.WTContainerHelper;
import wt.inf.container.WTContainerRef;
import wt.inf.template.DefaultWTContainerTemplate;
import wt.inf.container.OrgContainer;

PDMLinkProduct product = PDMLinkProduct.newPDMLinkProduct();
product.setName("Test Product 1");
product.setDescription("Test Product 1");
product.setInvitationMsg("Test Product 1");
product.setSharingEnabled(false);
//product.setNumber("12345");
println("Product  2  :"+product);
className = DefaultWTContainerTemplate.class;
DefaultWTContainerTemplate productTemplate;
queryspec = new QuerySpec(className);
//queryspec.appendWhere(new SearchCondition(className, "name", "=", "General Product"), index);
queryresult = PersistenceHelper.manager.find(queryspec);
while (queryresult.hasMoreElements()) {
    productTemplate = (DefaultWTContainerTemplate) queryresult.nextElement();
    println("DefaultWTContainerTemplate  :"+ productTemplate.getName());
    if(productTemplate.getName().equals("General Product")) {
        product.setContainerTemplate(productTemplate);
        break;
    }
}  

WTPrincipal admin = SessionHelper.manager.getAdministrator();
println("Current user  :"+ admin.getFullName());
product.setOwner(admin);
product.setCreator(admin);
println("Product  1 :"+product);
className = wt.inf.container.OrgContainer.class;
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "containerInfo.name", "=", "BLOOMENERGY"), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
// WTOrganization bloom ;
OrgContainer orgContainer;
if (queryresult.hasMoreElements()) {
   orgContainer = (OrgContainer) queryresult.nextElement();
   println("orgContainer  :"+orgContainer.getName());
   //product.setOrganization(bloom);
}
//orgContainer  = WTContainerHelper.getContainer(bloom);
//print(orgContainer);
orgContainerRef = WTContainerRef.newWTContainerRef(orgContainer);
println(" orgContainerRef  :"+orgContainerRef);
println("Product   3:"+product);
 WTContainerHelper.setContainer(product,orgContainerRef);
println("Product   :"+product);
//Create Product
try {
    WTContainerHelper.service.create(product);
   //product = PersistenceHelper.manager.save(product);
   //product = PersistenceHelper.manager.refresh(product);
   println("After save");
} catch (wt.inf.container.WTContainerException ex) {
    println("Exception raised");
    ex.getStandardMessage();
    ex.printStackTrace();
}


className = wt.pdmlink.PDMLinkProduct.class;
queryspec = new QuerySpec(className);
//queryspec.appendWhere(new SearchCondition(className, "productName", "=", "Test Product"), index);
queryresult = PersistenceHelper.manager.find(queryspec);
while (queryresult.hasMoreElements()) {
     PDMLinkProduct product1 = (PDMLinkProduct) queryresult.nextElement();
   println("Product  :"+ product1.getName());
   //print("Found Product :");
}



 