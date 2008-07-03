import wt.workflow.definer.WfProcessTemplate;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.Persistable;
import wt.fc.PersistenceHelper;

String name="Approval Process";
Class className =wt.workflow.definer.WfProcessTemplate.class;
QuerySpec queryspec = new QuerySpec();

int classIndex0 = queryspec.appendClassList(wt.workflow.definer.WfProcessTemplate.class, true);

queryspec.appendWhere(new SearchCondition(className, "master>name", "=", name),classIndex0);
queryspec.appendAnd();
queryspec.appendWhere(new SearchCondition(className,wt.vc.Iterated.LATEST_ITERATION,SearchCondition.IS_TRUE));
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Result size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
    print ("Inside while loop");
    //Persistable persistable = (Persistable) queryresult.nextElement();
    Object object =  queryresult.nextElement();
    print object;
    if (object instanceof WfProcessTemplate) {
        print ("Inside if loop");
        WfProcessTemplate template = (WfProcessTemplate) object;
        String displayIdentifier = template.getDisplayIdentifier();
        println("Workflow  :"+displayIdentifier + " "+ ((wt.vc.Iterated)template).isLatestIteration());
    }    
}



