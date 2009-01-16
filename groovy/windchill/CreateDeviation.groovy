import wt.type.TypeDefinitionReference;
import wt.type.TypedUtilityServiceHelper;
import wt.change2.WTVariance;
import wt.fc.PersistenceHelper;
import wt.session.SessionHelper;
import wt.org.WTPrincipalReference;
import wt.change2.VarianceCategory;

String objectType ="wt.change2.WTVariance|com.ptc.Deviation"
TypeDefinitionReference typeDefRef = TypedUtilityServiceHelper.service.getTypeDefinitionReference(objectType);
     
WTVariance variance = WTVariance.newWTVariance();
variance.setName("test deviation 101");
variance.setNumber("test deviation 101");
variance.setTypeDefinitionReference(typeDefRef);
variance.setVarianceOwner(WTPrincipalReference.newWTPrincipalReference(SessionHelper.getPrincipal()))
variance.setRecurring(false)
variance.setReason("test deviation")
variance.setVarianceCategory(VarianceCategory.toVarianceCategory("MINOR"))
variance = (WTVariance)PersistenceHelper.manager.save(variance);
System.out.println(variance.getDisplayIdentifier());

