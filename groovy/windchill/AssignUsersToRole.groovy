
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.fc.QueryResult;
import wt.fc.PersistenceHelper;
import wt.inf.library.WTLibrary;
import wt.inf.team.ContainerTeam;
import wt.inf.team.ContainerTeamHelper;
import  wt.project.Role;
import wt.session.SessionHelper;
import wt.org.WTUser;

String name="Trash Library";
Class className = wt.inf.library.WTLibrary.class;
int[] index = new int[1];
index[0] = 0;
QuerySpec queryspec = new QuerySpec(className);
queryspec.appendWhere(new SearchCondition(className, "containerInfo.name", "=", name), index);
QueryResult queryresult = PersistenceHelper.manager.find(queryspec);
System.out.println("Result size :"+ queryresult.size());

while (queryresult.hasMoreElements()) {
   Object obj = queryresult.nextElement();
    if (obj instanceof WTLibrary) {
        WTLibrary library = (WTLibrary) obj;
        String displayIdentifier = library.getDisplayIdentifier();
        System.out.println("Library  :"+displayIdentifier);
        System.out.println("Container "+ library.getContainerName());
    
        ContainerTeam team = ContainerTeamHelper.service.getContainerTeam(library);
        Enumeration enumeration = team.getRoles().elements();
        while (enumeration.hasMoreElements()) {
           Object roleobj =enumeration.nextElement();
           Role role = (Role) roleobj;
            System.out.println(role);
            if(role.getDisplay().equalsIgnoreCase("Members")){
                WTUser user = (WTUser)SessionHelper.manager.getPrincipal();
                ContainerTeamHelper.service.addMember(team,role,user);
                System.out.println( "User "+user.getName() +"  added to role "+role.getDisplay()+" in container "+library.getDisplayIdentifier());
                
            }
        }
    }
}
