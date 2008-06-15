import wt.pdmlink.PDMLinkProduct;
import wt.query.QuerySpec;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.org.WTPrincipal;
import wt.org.WTOrganization;
import wt.session.SessionHelper;
import wt.query.SearchCondition;

PDMLinkProduct product = PDMLinkProduct.newPDMLinkProduct();
product.setName("Test Product");
//product.setNumber("12345");
WTPrincipal admin = SessionHelper.manager.getPrincipal();
product.setOwner(admin);
Class className = wt.org.WTOrganization.class;
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "name", "=", "BLOOMENERGY"), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
if (queryresult.hasMoreElements()) {
   WTOrganization bloom = (WTOrganization) queryresult.nextElement();
   println(bloom.getName());
   product.setOrganization(bloom);
   try {
       bloom = PersistenceHelper.manager.save(bloom);
       bloom = PersistenceHelper.manager.refresh(bloom);
       println("After save");
   } catch (Exception ex) {
        ex.printStacktrace();
   }
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