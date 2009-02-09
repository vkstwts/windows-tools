import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.part.WTPartHelper;
    
class PartWhereUsed {
   def partSearchPatterns = ["190-5%","191-5%"] ;
   def topLevelPartPatterns = ["900","920"];
   def parentParts; //list to keep track of already visited parent parts
   def searchParts; //list to skip the different versions of the same part.
   
   public static void main(String[] args){
        PartWhereUsed partWhereUsed = new PartWhereUsed();
        partWhereUsed.execute();
    }
    
    void execute() {
        Class className = wt.part.WTPart.class;
        partSearchPatterns.each() { number ->
            searchParts=[];
            int[] index = new int[1];
            index[0] = 0;
            QuerySpec queryspec = new QuerySpec(className);
            queryspec.appendWhere(new SearchCondition(className, "master>number", SearchCondition.LIKE, "${number}"), index);
            queryspec.appendAnd();
            queryspec.appendWhere(new SearchCondition(wt.part.WTPart.class,"iterationInfo.latest",SearchCondition.IS_TRUE),index);
            QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
            while (queryresult.hasMoreElements()) {
                Object obj = queryresult.nextElement();
                parentParts=[];
                if (obj instanceof WTPart) {
                    WTPart part = (WTPart) obj;
                    WTPartMaster partMaster = (WTPartMaster) part.getMaster();
                     if(!(searchParts.contains(partMaster.getNumber()))){
                         searchParts.add(partMaster.getNumber());
                         println("Part  :"+partMaster.getNumber());
                         getWhereUsed(partMaster);
                    }
                }    
            }
        }
    }
    
    void getWhereUsed(WTPartMaster partMaster) {
        QueryResult queryResult = WTPartHelper.service.getUsedByWTParts(partMaster);
        if(!queryResult.hasMoreElements()) {
            topLevelPartPatterns.each() { number->
                if(partMaster.getNumber().startsWith("${number}"))
                    println("Top Level Part Number:"+partMaster.getNumber());
            }
        } 
        while (queryResult.hasMoreElements()) {
            Object obj = queryResult.nextElement();
            if (obj instanceof WTPart) {
                WTPart part = (WTPart) obj;
                WTPartMaster parentPartMaster = (WTPartMaster) part.getMaster();
                if(!(parentParts.contains(parentPartMaster.getNumber()))){ 
                    parentParts.add(parentPartMaster.getNumber());
                    getWhereUsed(parentPartMaster);
                }
            }
        }
    }
}
