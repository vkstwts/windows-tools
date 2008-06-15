import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;

String name="AXLE_LATCH";
Class className = wt.part.WTPartMaster.class;
//Class className = wt.part.WTPart.class;
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "name", "=", name), index);
//queryspec.appendWhere(new SearchCondition(className, "master->name", "=", name), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Result size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
   Object obj = queryresult.nextElement();
    if (obj instanceof WTPart) {
        WTPart part = (WTPart) obj;
        String displayIdentifier = part.getDisplayIdentifier();
     //   if(displayIdentifier.indexOf("GC")==0)  
           println("Part  :"+displayIdentifier);
    }    else if (obj instanceof WTPartMaster) {
        WTPartMaster partMaster = (WTPartMaster) obj;
        String displayIdentifier = partMaster.getDisplayIdentifier();
        println("PartMaster :"+displayIdentifier);
    }    
}
