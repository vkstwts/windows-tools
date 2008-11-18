import wt.query.QuerySpec;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.maturity.PromotionNotice;
import wt.maturity.MaturityHelper;


className = wt.maturity.PromotionNotice.class;
QuerySpec queryspec = new QuerySpec(className);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Objects of  type "+ className.getName()+"  :"+ queryresult.size());
while(queryresult.hasMoreElements()){
    PromotionNotice pn = (PromotionNotice)queryresult.nextElement();
    println(pn.getName());
    QueryResult qr = MaturityHelper.service.getBaselineItems(pn);
     while(qr.hasMoreElements()){
          Object baselineItem = qr.nextElement();
          println("--->"+baselineItem);
    }
}


