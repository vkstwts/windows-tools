import wt.type.TypeDefinitionReference;
import wt.type.TypedUtilityServiceHelper;
import wt.part.WTPart;
import wt.doc.WTDocument;
import wt.fc.PersistenceHelper;
import com.ptc.core.meta.server.TypeIdentifierUtility;
import wt.type.*;
import wt.util.*;
import com.ptc.core.meta.container.common.*;
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


String objectType ="wt.part.WTPart|com.nvidia.Part"

TypeDefinitionReference typeDefRef = TypedUtilityServiceHelper.service.getTypeDefinitionReference("wt.part.WTPart");
System.out.println("*********"+typeDefRef.toString());        
System.out.println("*********"+typeDefRef.getKey().toString()); 


TypeDefinitionNodeView[] nodes = TypeAdminHelper.service.getTypeNodeRoots();
for(node in nodes){
    String nodeName = node.getName();
    System.out.println(nodeName);
    if(nodeName.equals("wt.part.WTPart")){
        TypeDefinitionNodeView[] childNodes= TypeAdminHelper.service.getTypeNodeChildren((TypeDefinitionNodeView)node,java.util.Locale.US);
        for(childNode in childNodes){
            String childNodeName = childNode.getName();
            System.out.println("--->"+childNodeName);
            if(childNodeName.equals("com.nvidia.Part")){
                System.out.println("checking out "+childNodeName);
                      childNode = TypeAdminHelper.service.checkoutTypeNode((TypeDefinitionNodeView)childNode,java.util.Locale.US);
                    
                defaultView = TypeAdminHelper.service.getTypeDefDefaultView(childNode,java.util.Locale.US);
                identifiers =  defaultView.getConstraintContainer().getConstraintIdentifiers(1);
                for (identifier in identifiers) {
                     if (identifier.toString().indexOf("Part_ProductLine")>0
                       && identifier.getEnforcementRuleClassname().equalsIgnoreCase("com.ptc.core.meta.container.common.impl.DiscreteSetConstraint") ){
                        println("----------->"+identifier);
                    ConstraintData constraintData = defaultView.getConstraintContainer().get(identifier);
                    println constraintData.getBindingRuleData();
                    DiscreteSet enforcementRuleData = constraintData.getEnforcementRuleData();
                    println enforcementRuleData;
                    DiscreteSet newData = new DiscreteSet("Test3");
                    constraintData.setEnforcementRuleData(enforcementRuleData.getUnion(newData))
                     println constraintData.getEnforcementRuleData();
                    defaultView.getConstraintContainer().put(identifier,constraintData);
                    try {
                     defaultView = TypeAdminHelper.service.updateTypeDefDefaultView(defaultView,java.util.Locale.US);
                     println defaultView;
                    childNode = TypeAdminHelper.service.checkinTypeNode(null,(TypeDefinitionNodeView)childNode,java.util.Locale.US);
                    System.out.println("checking in "+childNodeName);
                 
                    } catch (WTException exception) {
                    System.out.println("undoing checking out "+childNodeName);
                 
                   childNode = TypeAdminHelper.service.undoCheckoutTypeNode((TypeDefinitionNodeView)childNode,true,java.util.Locale.US);
                    println exception;
                      }
                   }
                 }
                break;           
            }
            
        }
    }
}
