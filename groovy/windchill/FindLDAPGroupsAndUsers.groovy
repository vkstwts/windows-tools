import java.util.*;
import wt.org.*;

    WTOrganization wtorg = WTOrganization.newWTOrganization("Bloom Energy");
    DirectoryContextProvider directoryContextProvider = (DirectoryContextProvider) wtorg;

    Enumeration windchillGroups = OrganizationServicesHelper.manager.findLikeGroups("*", directoryContextProvider);
    while (windchillGroups.hasMoreElements()) {
        WTGroup wtgroup = (WTGroup) windchillGroups.nextElement();
        System.out.print( wtgroup.getName()+ ":");
        Enumeration usersEnum =wtgroup.members();
        while(usersEnum.hasMoreElements()){
            WTUser user = (WTUser)usersEnum.nextElement();
             System.out.print(user.getName()+"->"+ user.getFullName()+" , ");
        }
         System.out.println("\n");
    }

 