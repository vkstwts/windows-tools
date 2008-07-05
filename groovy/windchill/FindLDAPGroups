import java.util.*;
import wt.org.*;

    WTOrganization wtorg = WTOrganization.newWTOrganization("BloomEnergy");
    DirectoryContextProvider directoryContextProvider = (DirectoryContextProvider) wtorg;

    Enumeration windchillGroups = OrganizationServicesHelper.manager.findLikeGroups("*", directoryContextProvider);
    while (windchillGroups.hasMoreElements()) {
        Set googleGroupSet = new HashSet();
        Set windchillGroupSet = new HashSet();

        Object nextWindchillGroup = windchillGroups.nextElement();
        System.out.println("Next enumeration object = " + nextWindchillGroup.toString());

        WTGroup wtgroup = (WTGroup) nextWindchillGroup;
        String groupName = wtgroup.getName();
         System.out.println("+++Inside -----------: Group name = " + groupName);
    }

 