import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.method.RemoteMethodServer;
import wt.pdmlink.PDMLinkProduct;
import wt.inf.library.WTLibrary;	
import wt.inf.container.WTContainer;

RemoteMethodServer methodServer = RemoteMethodServer.getDefault();
methodServer.setUserName("wcadmin");
methodServer.setPassword("wcadmin");

classname = PDMLinkProduct.class;
QuerySpec queryspec = new QuerySpec(classname);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Objects of  type "+ classname.getName()+"  :"+ queryresult.size());
while(queryresult.hasMoreElements()){
	PDMLinkProduct product = (PDMLinkProduct) queryresult.nextElement();
	findParts(product);
}

classname = WTLibrary.class;
queryspec = new QuerySpec(classname);
queryresult = PersistenceHelper.manager.find(queryspec)
println("Objects of  type "+ classname.getName()+"  :"+ queryresult.size());
while(queryresult.hasMoreElements()){
	library = (WTLibrary) queryresult.nextElement();
	findParts(library);
}

void findParts(WTContainer container) {
	 println "Inside findParts  :"+container.getName();
	 
	 classname = WTPartMaster.class;
	 queryspec = new QuerySpec(classname);
	 if (container.getName().equals("Tucson") || container.getName().equals("Kailash") ) {
	 	//queryspec.appendSearchCondition(new SearchCondition(classname, WTPart.NUMBER, SearchCondition.LIKE,"%123%"))
		//queryspec.appendAnd();
	 }
	 queryspec.appendSearchCondition(new SearchCondition(classname, "containerReference.key.id", "=",PersistenceHelper.getObjectIdentifier(container).getId()))

	 queryresult = PersistenceHelper.manager.find(queryspec);
	 println("Objects of  type "+ classname.getName()+"  :"+ queryresult.size());
	 while(queryresult.hasMoreElements()){
		partMaster = (WTPartMaster) queryresult.nextElement();
		println  partMaster.getDisplayIdentifier();
	 }
	/*while(queryresult.hasMoreElements()){
		part = (WTPart) queryresult.nextElement();
		println  part.getDisplayIdentifier();
	 }*/
	
}

//classname = WTPart.class;
//QuerySpec queryspec = new QuerySpec(classname);
//queryspec.appendSearchCondition(new SearchCondition(classname, WTPart.NUMBER, SearchCondition.LIKE,"%12345%"))
//QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
//println("Objects of  type   :"+ queryresult.size());
//println(((WTPart)queryresult.nextElement()).getDisplayIdentifier())
