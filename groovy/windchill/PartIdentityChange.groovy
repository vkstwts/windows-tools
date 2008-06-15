import java.lang.reflect.Method;
import java.util.*;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;


import com.ptc.windchill.suma.axl.AXLEntry;
import com.ptc.windchill.suma.axl.AXLHelper;
import com.ptc.windchill.suma.part.*;
import com.ptc.windchill.suma.supplier.AbstractSupplier;
import com.ptc.windchill.suma.supplier.Manufacturer;
import com.ptc.windchill.suma.supplier.Supplier;
import com.ptc.windchill.suma.supplier.SupplierHelper;
import com.ptc.windchill.suma.supplier.Vendor;
import com.ptc.windchill.cadx.common.util.GenericUtilities;
import com.ptc.core.meta.container.common.impl.BasicAttributeContainer;

import wt.change2.AffectedActivityData;
import wt.change2.ChangeHelper2;
import wt.change2.ChangeRecord2;
import wt.change2.InventoryDisposition;
import wt.change2.WTChangeActivity2;
import wt.change2.WTChangeOrder2;
import wt.change2.WTChangeRequest2;
import wt.eff.EffGroup;
import wt.eff.EffGroupAssistant;
import wt.effectivity.WTDatedEffectivity;
import wt.epm.upload.Cache.Iterated;
import wt.fc.*;
import wt.inf.container.WTContained;
import wt.inf.container.WTContainer;
import wt.inf.container.WTContainerRef;
import wt.inf.container.WTContainerHelper;
import wt.lifecycle.LifeCycleManaged;
import wt.method.RemoteMethodServer;
import wt.org.WTOrganization;
import wt.org.WTPrincipalReference;
import wt.org.WTUser;
import wt.org.electronicIdentity.SignatureLink;
import wt.org.electronicIdentity.ElectronicallySignable;
import wt.org.electronicIdentity.UserElectronicIDLink;
import wt.part.*;
import wt.project.Role;
import wt.query.QuerySpec;
import wt.query.SearchCondition;
import wt.team.Team;
import wt.team.TeamHelper;
import wt.vc.VersionControlHelper;
import wt.vc.config.LatestConfigSpec;
import wt.vc.config.OwnershipIndependentLatestConfigSpec;
import wt.vc.config.ConfigSpec;
import wt.vc.struct.StructHelper;
import wt.workflow.engine.WfEngineHelper;
import wt.workflow.engine.WfProcess;
import wt.enterprise.RevisionControlled;
import wt.iba.value.AttributeContainer;
import wt.iba.value.IBAHolder;


public static WTObject getObject(Class className, String number , String version) throws Exception {
        OwnershipIndependentLatestConfigSpec lcSpec = new OwnershipIndependentLatestConfigSpec();
        QuerySpec querySpec = new QuerySpec(className);
        querySpec.appendSearchCondition(new SearchCondition(className, "master>number", "=", number , false));
        querySpec.appendAnd();
        querySpec.appendSearchCondition(new SearchCondition(className, "iterationInfo.latest", "TRUE"));

        if(version != null){
            querySpec.appendAnd();
            querySpec.appendSearchCondition(new SearchCondition(className, "versionInfo.identifier.versionId", "=", version , false));
        }
        QueryResult queryResult = PersistenceHelper.manager.find(querySpec);
        if(version == null){ queryResult = lcSpec.process(queryResult); }
        while(queryResult.hasMoreElements()){
            WTObject part = (WTObject) queryResult.nextElement();
            String className2 = part.getClass().getName();

            // DEBUG
            //System.out.println("    ---> Class Name1 ; Class Name2 = " + className + " : " + className2);
            //

            if (className.getName().equals("wt.part.WTPart") &&
                className2.equals("wt.part.WTPart")) {

                // DEBUG
                //System.out.println("    ---> Inside = WTPart");
                //

                return part;
            } else if (className.getName().equals("com.ptc.windchill.suma.part.ManufacturerPart") &&
                       className2.equals("com.ptc.windchill.suma.part.ManufacturerPart")) {

                // DEBUG
                //System.out.println("    ---> Inside = ManufacturerPart");
                //

                return part;
            } else if (className.getName().equals("com.ptc.windchill.suma.part.VendorPart") &&
                       className2.equals("com.ptc.windchill.suma.part.VendorPart")) {

                // DEBUG
                //System.out.println("    ---> Inside = VendorPart");
                //

                return part;
            } else if (className.getName().equals("com.ptc.windchill.suma.part.SupplierPart") &&
                       className2.equals("com.ptc.windchill.suma.part.SupplierPart")) {

                // DEBUG
                //System.out.println("    ---> Inside = SupplierPart");
                //

                return part;
            } else if (className.getName().equals("wt.part.WTProduct") &&
                       className2.equals("wt.part.WTProduct")) {

                // DEBUG
                //System.out.println("    ---> Inside = WTProduct");
                //
                return part;
            }
        }
        return null;
    }