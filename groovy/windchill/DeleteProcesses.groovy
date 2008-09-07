import wt.workflow.engine.WfProcess;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.Persistable;
import wt.fc.PersistenceHelper;

String name="Release Process%";
Class className =wt.workflow.engine.WfProcess.class;
QuerySpec queryspec = new QuerySpec();

int classIndex0 = queryspec.appendClassList(wt.workflow.engine.WfProcess.class, true);
queryspec.appendSearchCondition(new SearchCondition(wt.workflow.engine.WfProcess.class, "name",SearchCondition.LIKE, name));
//queryspec.appendWhere(new SearchCondition(className, "name",SearchCondition.LIKE, name),classIndex0);
//queryspec.appendAnd();
//queryspec.appendWhere(new SearchCondition(className,wt.vc.Iterated.LATEST_ITERATION,SearchCondition.IS_TRUE));
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
println("Result size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
    println ("Inside while loop");
 wt.workflow.engine.WfProcess wfprocess = (wt.workflow.engine.WfProcess) queryresult.nextElement(); }
//println "wfprocess    :"+wfprocess+"\n\n\n";
    //Persistable object = (Persistable) queryresult.nextElement();
    Object object[] =  queryresult.nextElement(); 
    println "object    :"+object[0].getClass()+"\n\n\n"; 
//Object object = null;

    if (object instanceof wt.workflow.engine.WfProcess) {
        println ("Inside if loop");
        WfProcess process = (WfProcess) object;
        String displayIdentifier = process.getName();
        println displayIdentifier;
       // println("Workflow  :"+displayIdentifier + " "+ ((wt.vc.Iterated)template).isLatestIteration());
        String state = null;
       /* try {
         PersistenceHelper.manager.delete(process);
        } catch (Exception e) {
            e.printStackTrace();
        }*/
    }    else  println "Not a Process object"
}

