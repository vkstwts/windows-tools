import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;

String name="AXLE_LATCH";
//Class className = wt.part.WTPartMaster.class;
Class className = wt.part.WTPart.class;
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
//queryspec.appendWhere(new SearchCondition(className, "name", "=", name), index);
queryspec.appendWhere(new SearchCondition(className, "master>name", "=", name), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Result size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
   Object obj = queryresult.nextElement();
    if (obj instanceof WTPart) {
        WTPart part = (WTPart) obj;
        String displayIdentifier = part.getDisplayIdentifier();
        println("Part  :"+displayIdentifier);
        println("Container "+ part.getContainerName());
        println("Folder :"+wt.folder.FolderHelper.service.getFolder(part).getName());  
        println("Folder Path:"+wt.folder.FolderHelper.getLocation(part));  
        println("Folder Path:"+wt.folder.FolderHelper.getFolderPath(part));  
    }    else if (obj instanceof WTPartMaster) {
        WTPartMaster partMaster = (WTPartMaster) obj;
        String displayIdentifier = partMaster.getDisplayIdentifier();
        println("PartMaster :"+displayIdentifier);
        println("Container "+ partMaster.getContainerName());
    }    
}