import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.part.WTPartHelper;
    
class PartWhereUsed {
   def static partSearchPatterns = ["190-5%","191-5%"] ;
   def static topLevelPartPatterns = ["900","920"];
   def static parentParts;
   
   public static void main(String[] args){
        Class className = wt.part.WTPart.class;
        partSearchPatterns.each() { number ->
            parentParts=[];
            int[] index = new int[1];
            index[0] = 0;
            QuerySpec queryspec = new QuerySpec(className);
            queryspec.appendWhere(new SearchCondition(className, "master>number", SearchCondition.LIKE, "${number}"), index);
            queryspec.appendAnd();
            queryspec.appendWhere(new SearchCondition(wt.part.WTPart.class,"iterationInfo.latest",SearchCondition.IS_TRUE),index);
            QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
            while (queryresult.hasMoreElements()) {
               Object obj = queryresult.nextElement();
                if (obj instanceof WTPart) {
                    WTPart part = (WTPart) obj;
                    String displayIdentifier = part.getDisplayIdentifier();
                    WTPartMaster partMaster = (WTPartMaster) part.getMaster();
                     if(!(parentParts.contains(partMaster.getNumber()))){
                         parentParts.add(partMaster.getNumber());
                         println("Part  :"+partMaster.getNumber());
                         getWhereUsed(partMaster);
                    }
                     println "";
                }    
            }
        }
    }

    static  getWhereUsed(WTPartMaster partMaster) {
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
                String displayIdentifier = part.getDisplayIdentifier();
                WTPartMaster parentPartMaster = (WTPartMaster) part.getMaster();
                if(!(parentParts.contains(parentPartMaster.getNumber()))){ 
                    parentParts.add(parentPartMaster.getNumber());
                    getWhereUsed(parentPartMaster);
                }
            }
        }
    }

}
