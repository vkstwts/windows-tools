import wt.type.TypeDefinitionReference;
import wt.type.TypedUtilityServiceHelper;
import wt.part.WTPart;
import wt.doc.WTDocument;
import wt.fc.PersistenceHelper;
//import com.ptc.core.meta.common.impl.WCTypeIdentifier;
import com.ptc.core.meta.server.TypeIdentifierUtility;
//import wt.session.SessionHelper;
import wt.type.*;
import com.ptc.core.meta.common.*;
import com.ptc.core.meta.common.impl.*;
import com.ptc.core.meta.type.admin.common.impl.*;
import com.ptc.core.meta.type.mgmt.common.*;

//println SessionHelper.getPrincipal().getName();
//SessionHelper.manager.setAdministrator();

String objectType ="wt.part.WTPart|com.nvidia.Part"
//String objectType ="wt.change2.WTChangeRequest2"

String persistedType = TypedUtilityServiceHelper.service.getExternalTypeIdentifier(objectType);
//String persistedType = TypedUtilityServiceHelper.service.getPersistedType(objectType);
System.out.println(persistedType);        
//TypeIdentifier typeidentifier = (new TypeIdentifierUtility()).getTypeIdentifierFromPersistedType(persistedType);
//System.out.println(typeidentifier);
 //TypedUtilityServiceHelper.service.initTypeDefinitions();

TypeDefinitionReference typeDefRef = TypedUtilityServiceHelper.service.getTypeDefinitionReference("wt.part.WTPart|com.nvidia.Part");
System.out.println(typeDefRef.toString());        
System.out.println(typeDefRef.getKey().toString()); 
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
                  //childNode = TypeAdminHelper.service.checkoutTypeNode((TypeDefinitionNodeView)childNode,java.util.Locale.US);
                   //childNode = TypeAdminHelper.service.undoCheckoutTypeNode((TypeDefinitionNodeView)childNode,true,java.util.Locale.US);
                   defaultView = TypeAdminHelper.service.getTypeDefDefaultView(childNode,java.util.Locale.US);
                   typeIdentifiers =  defaultView.getConstraintContainer().getConstraintTypeIdentifiers();
                   for (identifier in typeIdentifiers) {
                           //if (identifier.getContext() instanceof DiscreteSet )
                               println(identifier);
                    }
                   
             }
        }
    }
 }
//WTPart part = WTPart.newWTPart();
//part.setName("test Part 101");
//part.setNumber("test Part 101");
//part.setTypeDefinitionReference(typeDefRef);
//part = (WTPart)PersistenceHelper.manager.save(part);
//System.out.println(part.getDisplayIdentifier());
