import wt.query.QuerySpec;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;

def classNameList = [wt.part.WTPartMaster.class,wt.doc.WTDocumentMaster.class,wt.epm.EPMDocumentMaster.class,
                     wt.pdmlink.PDMLinkProduct.class,wt.inf.library.WTLibrary.class,
                    wt.change2.WTChangeIssue.class, wt.change2.WTChangeRequest2.class, wt.change2.WTChangeOrder2.class,
                    wt.lifecycle.LifeCycleTemplateMaster.class,wt.workflow.definer.WfProcessTemplate];

for ( className in classNameList ) {
    QuerySpec queryspec = new QuerySpec(className);
    QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
    println("Objects of  type "+ className.getName()+"  :"+ queryresult.size());
}