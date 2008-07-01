import wt.type.TypeDefinitionReference;
import wt.type.TypedUtilityServiceHelper;
import wt.doc.WTDocument;
import wt.fc.PersistenceHelper;
//import com.ptc.core.meta.common.impl.WCTypeIdentifier;
//import com.ptc.core.meta.server.TypeIdentifierUtility;
//import wt.session.SessionHelper;
//import wt.type.Typed;

//println SessionHelper.getPrincipal().getName();
//SessionHelper.manager.setAdministrator();

String objectType ="wt.doc.WTDocument|PRIV.IONAMERICA.General"
TypeDefinitionReference typeDefRef = TypedUtilityServiceHelper.service.getTypeDefinitionReference(objectType);
System.out.println(typeDefRef.toString());        

WTDocument doc = WTDocument.newWTDocument();
doc.setName("test document 101");
doc.setNumber("test document 101");
doc.setTypeDefinitionReference(typeDefRef);
doc = (WTDocument)PersistenceHelper.manager.save(doc);
System.out.println(doc.getDisplayIdentifier());

//Typed typedObj;
//typedObj = doc;
//String type = ((WCTypeIdentifier) TypeIdentifierUtility.getTypeIdentifier(typedObj)).getTypename();                  
//print type
