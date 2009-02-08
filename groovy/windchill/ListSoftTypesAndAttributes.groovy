import wt.type.TypeDefinitionReference;
import wt.type.TypedUtilityServiceHelper;
import wt.part.WTPart;
import wt.doc.WTDocument;
import wt.fc.PersistenceHelper;
//import com.ptc.core.meta.common.impl.WCTypeIdentifier;
import com.ptc.core.meta.server.TypeIdentifierUtility;
//import wt.session.SessionHelper;
import wt.type.*;
import wt.util.*;
import com.ptc.core.meta.common.*;
import com.ptc.core.meta.common.impl.*;
import com.ptc.core.meta.type.admin.common.impl.*;
import com.ptc.core.meta.type.mgmt.common.*;
import com.ptc.core.meta.type.mgmt.server.*;
import com.ptc.core.meta.type.mgmt.server.impl.*;
import com.ptc.core.meta.type.mgmt.server.impl.service.*;

import com.ptc.core.meta.type.mgmt.common.*;
import com.ptc.core.meta.type.mgmt.server.*;
import com.ptc.core.meta.type.mgmt.server.impl.*;
import com.ptc.core.meta.type.mgmt.server.impl.service.*;
import wt.method.RemoteMethodServer;

RemoteMethodServer methodServer = RemoteMethodServer.getDefault();
methodServer.setUserName("wcadmin");
methodServer.setPassword("wcadmin");



def printAttributes(TypeDefinitionNodeView nodeView) {
            
            defaultView = TypeAdminHelper.service.getTypeDefDefaultView(nodeView,java.util.Locale.US);
            typeIdentifiers =  defaultView.getConstraintContainer().getConstraintTypeIdentifiers();
           
            identifiers =  defaultView.getConstraintContainer().getConstraintIdentifiers(1);
            for (identifier in identifiers) {
                attribute=defaultView.getConstraintContainer().get(identifier).getBindingRuleData().toString();
                index=attribute.indexOf("IBA");
                if(index!=-1) {
                    println ("    Attribute --->"+ attribute.substring(index+4))
                }
            }
            TypeDefinitionNodeView[] childNodes= TypeAdminHelper.service.getTypeNodeChildren((TypeDefinitionNodeView)nodeView,java.util.Locale.US);
            for(childNode in childNodes){
                String childNodeName = childNode.getName();
                System.out.println("  Nvidia Object--->"+childNodeName);
                 printAttributes(childNode)
              }
}

TypeDefinitionNodeView[] nodes = TypeAdminHelper.service.getTypeNodeRoots();
for(node in nodes){
    String nodeName = node.getName();
    System.out.println("OOTB Object--->"+nodeName);
    printAttributes(node)
    }
;