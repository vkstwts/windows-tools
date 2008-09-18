import wt.maturity.MaturityHelper;
import wt.maturity.PromotionNotice;
import wt.part.WTPart;
import wt.doc.WTDocument;
import wt.epm.EPMDocument;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.fc.collections.*;
import wt.part.WTPart;
import wt.part.WTPartMaster;


String number="11322";
Class className = wt.maturity.PromotionNotice.class;

int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "number", "=", number), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Promotion Notices size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
   Object object = queryresult.nextElement();
    if (object instanceof PromotionNotice) {
        PromotionNotice promotion = (PromotionNotice) object;
        String displayIdentifier = promotion.getDisplayIdentifier();
        System.out.println("Promotion  :"+displayIdentifier);
        
        printPromotables(promotion);
        
        WTPart part = getPart("027887");
         WTHashSet wthashset = new WTHashSet();
         wthashset.add(part);
        System.out.println("\nAdding Part 027887 from promotion 11322"); 
        MaturityHelper.service.savePromotionTargets(promotion,wthashset);
         printPromotables(promotion);
        
         System.out.println("\nRemoving Part 027887 from promotion 11322"); 
        MaturityHelper.service.deletePromotionTargets(promotion,wthashset);
        printPromotables(promotion);
    }   
}

public WTPart getPart(String number) {
    WTPart part = null;
    Class className = wt.part.WTPart.class;
    int[] index = new int[1];
    index[0] = 0;
    QuerySpec queryspec = new QuerySpec(className);
    queryspec.appendWhere(new SearchCondition(className, "master>number", "=", number), index);
    QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
   System.out. println("\nPart Result size :"+ queryresult.size());
    while (queryresult.hasMoreElements()) {
       Object obj = queryresult.nextElement();
        if (obj instanceof WTPart) {
            part = (WTPart) obj;
            String displayIdentifier = part.getDisplayIdentifier();
           System.out. println("Found Part  :"+displayIdentifier);
        }   
    }
    return part; 
}

public void printPromotables(PromotionNotice promotion) {
        String displayIdentifier;
        QueryResult promotables = MaturityHelper.service.getBaselineItems(promotion);//MaturityHelper.service.getPromotionTargets(promotion);
        println("Promotables size :"+ promotables.size());
        while (promotables.hasMoreElements()) {
           Object obj = promotables.nextElement();
            if (obj instanceof WTPart) {
                WTPart part = (WTPart) obj;
                displayIdentifier = part.getDisplayIdentifier();
                System.out.println("Part  :"+displayIdentifier);
            }  else if (obj instanceof WTDocument) {
                WTDocument doc = (WTDocument) obj;
                displayIdentifier = doc.getDisplayIdentifier();
                System.out.println("Document  :"+displayIdentifier);
               
                
            }   else if (obj instanceof EPMDocument) {
                EPMDocument doc = (EPMDocument) obj;
                displayIdentifier = doc.getDisplayIdentifier();
               System.out. println("CAD Document  :"+displayIdentifier);
            }    
        }
}
