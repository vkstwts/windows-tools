import wt.part.WTPart;
import wt.part.WTPartMaster;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.project.Role;
import wt.inf.team.ContainerTeamHelper;
import wt.inf.team.ContainerTeam;
import wt.org.WTPrincipal;
import java.util.Vector;

String number="OEMPART1";
Class className = wt.part.WTPart.class;
String usersList="";
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "master>number", "=", number), index);
queryspec.appendAnd();
queryspec.appendWhere(new SearchCondition(className,wt.vc.Iterated.LATEST_ITERATION,SearchCondition.IS_TRUE));

QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
System.out.println("Result size :"+ queryresult.size());
while (queryresult.hasMoreElements()) {
   Object obj = queryresult.nextElement();
    if (obj instanceof WTPart) {
        WTPart part = (WTPart) obj;
        String displayIdentifier = part.getDisplayIdentifier();
        System.out.println("Part  :"+displayIdentifier);
        System.out.println("Container "+ part.getContainer().getName());
        Role designer = Role.toRole("DESIGNER");
        System.out.println("Role "+designer.getDisplay());
        ContainerTeam team =ContainerTeamHelper.service.getContainerTeam(part.getContainer());
        System.out.println("Team  "+team.getDisplayIdentifier());
        System.out.println("Roles "+team.getRoles());
        System.out.println("Members "+team.getPrincipalTarget(designer).toString());
        Enumeration designers = (team.getPrincipalTarget(designer));
        System.out.println("designers  "+designers);
        while (designers!=null && designers.hasMoreElements()) {
            WTPrincipal member = designers.nextElement();
            System.out.println("Member :"+member);
            usersList+=member.getName();
        }
   
    }   
}