/*<TOAD_FILE_CHUNK>*/
CREATE OR REPLACE PACKAGE Ggl_Plm_Bom_Interface AS


PROCEDURE iclean_up (p_errbuf OUT VARCHAR2,
    				  p_errcode OUT NUMBER,
    				  p_change_notice IN VARCHAR2 );

PROCEDURE IMPORT_ECO (P1  OUT VARCHAR2,
                      P2  OUT NUMBER,
                      p_test_tag IN VARCHAR2);
					  
PROCEDURE IPOST_UPDATE(p_errbuf  OUT VARCHAR2,
                	   p_errcode OUT NUMBER,
  					   p_change_notice IN VARCHAR2 );
					   
--PROCEDURE CREATE_ROUTING(p_item_number  	  IN VARCHAR2,
--                         p_OrganizationCode IN VARCHAR2,
--                         p_Operation_seq	  IN NUMBER,
--                         p_dept_code		  IN VARCHAR2
--                         );

FUNCTION CREATE_ROUTING(p_item_number  	  IN VARCHAR2,
                         p_OrganizationCode IN VARCHAR2,
                         p_Operation_seq	  IN NUMBER,
                         p_dept_code		  IN VARCHAR2
                         )
    		RETURN BOOLEAN;


END Ggl_Plm_Bom_Interface;
/
/*<TOAD_FILE_CHUNK>*/


create or replace PACKAGE BODY GGL_PLM_BOM_INTERFACE
AS
/********************************************************************
 * Package       : GGL_PLM_BOM_INTERFACE
 * Parameters IN : 
 *                 xxxx
 *                 xxxx
 * Parameters OUT: N/A
 * Purpose       : This Package is to validate and create ECO/BOM records             
 *                 orginated in PLM system.
 *                 
 * Notes:          v. 01 	 	 - Version 1 - Testing code from MFGUAT by Martina.
 * 				   v. 02		 - 091807: Used Routing API for creating routing
 * 				   		 		 - 092107: Used ECO API for creating the BOM for component create and changes. 	
 * 
 *				   v.03 		 - 0921007: Used ECO API for creating the BOM for substitutes...  
 *
 *				   v.03_1 		 - 092507:  Cleanup started!  
 *				   				   	   
 *				   v.04 		 - 100107:  _BY_ECO code modified to make AVL work even with out BOM
 *				   				   			AML_AVL is removed from BOM Request Set and called seperately. 
 *				   v.05_1		 - 102607: 	Started modifying for GIG and CITYBLOCK projects				   	   
 *				   				 - 102807:	Added create_routing from util_pkg; Dicorded util_pkg.
 *				   				   		   
 *				   v.06		 	 - 110407: 	Fixed the ECO API issue by using Create common bom API...	
 *				   				   		   
 *				   v.06_1	 	 - 110507: 	Started working on cleaning up the child org ECO records	
 *				   				   		   
 *				   v.07	 	 	 - 110507: 	Works (except there is a bug in creating common org for child items)
 *				   				   		   
 *				   v.08	 	 	 - 110807: 	Works!!! 
 *
 *				   v.09	 	 	 - 011408: 	Started working on GTW changes with substr(ffv.flex_code,1,3) = org 
 *
 *				   v.10	 	 	 - 011808: 	Mark 'Reman' and 'Watchtower' BOM as RESOLVED; Already addressed in _BY_ECO scripts 
 *				   v.11          	 - 022808 : alkumar : fixed disabling of substitute components .added nvl(acd_type ,1 ) <> 3   
 *
 *				   **Under MFGUAT Testing** 
 *				   
 * Migration Notes and Issues:
 * 			 	   
 * 		 	   
 * 			 	   *****REMOVE ALL COMMENTS AFTER UAT TESTING*****
 * 			 	   
 * 			 	   
 *****************************************************************************/

 
   g_date       					DATE           := SYSDATE;
   v_error      					VARCHAR2 (500) := NULL;
   v_user_id    					NUMBER         := Fnd_Global.user_id;
   v_login_id   					NUMBER         := Fnd_Global.login_id;
   --
   e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
   e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
   e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'GGL_PLM_BOM_INT';
   e_error_desc                     ggl_inv_errors.error%TYPE;
   e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
   e_err_ret_code                   NUMBER;
      
-- ========================================================================================
--
-- This procedure is used to display all the ERROR RECORDS from GGL_INV_ERRPRS table for this eco#  
--
-- ========================================================================================

     PROCEDURE ishow_errors ( p_change_notice IN VARCHAR2 )
     IS
	    l_temp NUMBER;
		--
		CURSOR C_ERRORS IS
           SELECT GBS.CHANGE_NOTICE, GBS.ITEM_NUMBER, GBS.COMPONENT_ITEM_NUMBER
		   		  ,GBS.SUBSTITUTE_COMPONENT_NUMBER, GBS.REVISION ITEM_REVISION
				  ,GBS.COMPONENT_REVISION, GBS.COMPONENT_QTY, GBS.EFFECTIVITY_DATE
				  ,GBS.ERROR_MESSG, GBS.PROCESS_FLAG, GBS.COMP_ACD_TYPE, GBS.SUB_ACD_TYPE
				  ,GBS.DISABLE_DATE, GBS.CONTAINER_NAME, GIE.TRANSACTION_ID, GIE.TRANSACTION_LINE_ID
				  ,GIE.ERROR, GIE.SUGGESTED_ACTION, GIE.TRANSACTION_SOURCE, GBS.CREATION_DATE
				  ,GBS.ECO_STATUS_CODE, GBS.ECO_STATUS_MESSAGE
           FROM GGL_INV_ERRORS GIE, GGL_PLM_BOM_STAGING GBS
           WHERE 1=1 
           AND GIE.TRANSACTION_ID = GBS.GGL_PLM_BOM_INT_ID
           AND NVL(GIE.TRANSACTION_LINE_ID, -999) = NVL(GBS.GGL_PLM_BOM_COMP_INT_ID, -999)
           AND NVL(GIE.TRANSACTION_LINE_ID, -999) = 
           	NVL(NVL(GBS.GGL_PLM_BOM_COMP_SUB_INT_ID,GIE.TRANSACTION_LINE_ID), -999)
           AND GBS.CHANGE_NOTICE = P_CHANGE_NOTICE		   	   		   
	   UNION ALL	   
           SELECT GBS1.CHANGE_NOTICE, GBS1.ITEM_NUMBER, GBS1.COMPONENT_ITEM_NUMBER
		   		  ,GBS1.SUBSTITUTE_COMPONENT_NUMBER, GBS1.REVISION ITEM_REVISION
				  ,GBS1.COMPONENT_REVISION, GBS1.COMPONENT_QTY, GBS1.EFFECTIVITY_DATE
				  ,GBS1.ERROR_MESSG, GBS1.PROCESS_FLAG, GBS1.COMP_ACD_TYPE, GBS1.SUB_ACD_TYPE
				  ,GBS1.DISABLE_DATE, GBS1.CONTAINER_NAME, NULL, NULL,NULL INV_ERROR_MSG
				  ,NULL, NULL , GBS1.CREATION_DATE,GBS1.ECO_STATUS_CODE, GBS1.ECO_STATUS_MESSAGE
           FROM GGL_PLM_BOM_STAGING GBS1
           WHERE 1=1 
           AND GBS1.ERROR_MESSG IS NOT NULL
		   AND GBS1.ERROR_MESSG NOT LIKE 'No Change In Component%'
		   AND GBS1.CHANGE_NOTICE = P_CHANGE_NOTICE;		
	 --	  
	 BEGIN	     
     --
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<ISHOW_ERRORS>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
	 --
       FOR C_ERRORS_REC IN C_ERRORS LOOP
	          Fnd_File.put_line (Fnd_File.LOG, ' ');
			  Fnd_File.put_line (Fnd_File.LOG, '============================================================================ ');
			  Fnd_File.put_line (Fnd_File.LOG, '  ');
	  		  Fnd_File.put_line (Fnd_File.LOG, '   ERRORS:   GGL_TRX_ERRORS RECORDS FOR ECN/BOM# : ' 
			                                  ||c_errors_rec.change_notice );
			  Fnd_File.put_line (Fnd_File.LOG, '   ERRORS:   <<ECO STATUS CODE:>> '||c_errors_rec.ECO_STATUS_CODE);											  
			  Fnd_File.put_line (Fnd_File.LOG, '   ERRORS:   <<ECO STATUS MESSAGE:>> '||c_errors_rec.ECO_STATUS_MESSAGE);											  

			  Fnd_File.put_line (Fnd_File.LOG, '  ');
			  Fnd_File.put_line (Fnd_File.LOG, '=============================================================================');

			  Fnd_File.put_line (Fnd_File.LOG, '  ');
			  Fnd_File.put_line (Fnd_File.LOG, '   GGL_STAGING_ERRORS:   <<INV ITEM:>> '||c_errors_rec.ITEM_NUMBER											  
											  ||' <<COMPONENT:>> '||c_errors_rec.COMPONENT_ITEM_NUMBER
											  ||' <<SUB COMP:>> '||c_errors_rec.SUBSTITUTE_COMPONENT_NUMBER);
			  Fnd_File.put_line (Fnd_File.LOG, '   ERRORS:   <<ERROR MSG:>> '||c_errors_rec.ERROR_MESSG);
			  Fnd_File.put_line (Fnd_File.LOG, '  ');			  											  
			  Fnd_File.put_line (Fnd_File.LOG, '   GGL_INV_ERRORS:   <<ITEM_ID:>> '||c_errors_rec.transaction_id 											  
											  ||' <<COMP_ID/SUBCOMP_ID:>> '||c_errors_rec.transaction_line_id
											  ||' <<SOURCE:>> '||c_errors_rec.transaction_source);
			  Fnd_File.put_line (Fnd_File.LOG, '   ERRORS:   <<ERROR MSG:>> '||c_errors_rec.error
											  ||' <<SUGGESTED ACTION:>> '||c_errors_rec.suggested_action);
			  --
			  Fnd_File.put_line (Fnd_File.LOG, '  ');
			  Fnd_File.put_line (Fnd_File.LOG, '--------------------------------------------------------------------------------- ');
	   --	  		  
	   END LOOP;
	   --
	   NULL;
	  --  
	 END ishow_errors;
	 --
	 --



  --
  -- This procedure will create a routing for a given item number, organization_code, op_seq and dept_code...
  -- If the parameters are null then it uses PNA as Org, 10 as Op Seq, and OSP as Dept.
  --
 FUNCTION CREATE_ROUTING(p_item_number  	  IN VARCHAR2,
                         p_OrganizationCode IN VARCHAR2,
                         p_Operation_seq	  IN NUMBER,
                         p_dept_code		  IN VARCHAR2
                         )
    		RETURN BOOLEAN AS

    v_EntityType               varchar2(30);
    v_ItemName                 varchar2(30);
    v_OrganizationCode         varchar2(30);
    v_Operation_seq            number;
    v_dept_code                varchar2(30);
    v_Resource_seq             number;
    v_Resource_Code            varchar2(30);
    v_Amt_Inverse              number;
    v_Sch_Flag                 number;
    v_commit_flag              varchar2(1);
    
    l_rtg_header_rec           Bom_Rtg_Pub.Rtg_Header_Rec_Type        := Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
    l_rtg_revision_tbl         Bom_Rtg_Pub.Rtg_Revision_Tbl_Type      := Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
    l_operation_tbl            Bom_Rtg_Pub.Operation_Tbl_Type         := Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
    l_op_resource_tbl          Bom_Rtg_Pub.Op_Resource_Tbl_Type       := Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
    l_sub_resource_tbl         Bom_Rtg_Pub.Sub_Resource_Tbl_Type      := Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
    l_op_network_tbl           Bom_Rtg_Pub.Op_Network_Tbl_Type        := Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;
    
    l_error_message_list       Error_handler.error_tbl_type;
  
    l_x_return_status          VARCHAR2(2000);
    l_x_msg_count              NUMBER;
    
    l_x_rtg_header_rec         Bom_Rtg_Pub.Rtg_Header_Rec_Type        := Bom_Rtg_Pub.G_MISS_RTG_HEADER_REC;
    l_x_rtg_revision_tbl       Bom_Rtg_Pub.Rtg_Revision_Tbl_Type      := Bom_Rtg_Pub.G_MISS_RTG_REVISION_TBL;
    l_x_operation_tbl          Bom_Rtg_Pub.Operation_Tbl_Type         := Bom_Rtg_Pub.G_MISS_OPERATION_TBL;
    l_x_op_resource_tbl        Bom_Rtg_Pub.Op_Resource_Tbl_Type       := Bom_Rtg_Pub.G_MISS_OP_RESOURCE_TBL;
    l_x_sub_resource_tbl       Bom_Rtg_Pub.Sub_Resource_Tbl_Type      := Bom_Rtg_Pub.G_MISS_SUB_RESOURCE_TBL;
    l_x_op_network_tbl         Bom_Rtg_Pub.Op_Network_Tbl_Type        := Bom_Rtg_Pub.G_MISS_OP_NETWORK_TBL;
     
    i                          NUMBER									:= 0;
    l_routing_rec_found        NUMBER									:= -1;
    l_routing_exception		 EXCEPTION;
	--
    e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'GGL_PLM_CREATE_ROUTING';
     
  BEGIN
      Fnd_File.put_line (Fnd_File.LOG,'In Create_Routings Function... ');
	  
	  --Assign constant values if not supplied 
	  	  
      v_ItemName         := p_item_number;
	  
	  IF p_OrganizationCode IS NULL OR p_Operation_seq IS NULL OR p_dept_code IS NULL
	  THEN
      	 e_error_desc  := 'OrgCode or OpSeq or DeptCode are null in create_routings; '||'sqlerrm: '||substr(sqlerrm,1,500);
      	 e_sugg_action := 'Please check create_routing records and fix the error...';
	  	 Raise l_routing_exception; 		 
	  ELSE
	  	 v_OrganizationCode  := p_OrganizationCode;	 	  
	  	 v_Operation_seq 	 := p_Operation_seq;
	  	 v_dept_code     	 := p_dept_code;		 		 
	  END IF;	  
	
        
	  --If routing exists with header and op_seq then do not create / exit else create the routing.
	  BEGIN	
        SELECT count(*) INTO l_routing_rec_found
          FROM bom_operational_routings r,
               bom_operation_sequences s,
               bom_departments d,
               mtl_parameters p,
               mtl_system_items_b i
         WHERE i.segment1 		     = v_ItemName
           AND p.organization_code   = v_OrganizationCode
  		   AND s.operation_seq_num   = v_Operation_Seq
  		   AND d.department_code	 = v_dept_code
           AND r.organization_id     = p.organization_id
           AND r.assembly_item_id    = i.inventory_item_id
           AND r.organization_id     = i.organization_id
           AND s.routing_sequence_id = r.routing_sequence_id
           AND s.department_id       = d.department_id;		
	  EXCEPTION
	    WHEN NO_DATA_FOUND THEN 
			 l_routing_rec_found := 0;
		WHEN OTHERS THEN
			 l_routing_rec_found := -1;
	  END;
	  
	  IF l_routing_rec_found > 0 THEN
	  	 Null; --Routing exists, no further processing required.
	  	 Fnd_File.put_line (Fnd_File.LOG,'Routing exists for this assembly item...no routing gets crated for '||v_ItemName);
	  ELSIF l_routing_rec_found = -1 THEN
      	 e_error_desc  := 'Unknown Fatal error in create_routing - l_routing_rec_found query failed; '||'sqlerrm: '||substr(sqlerrm,1,500);
      	 e_sugg_action := 'Please check ggl_plm_util_pkg.create_routing code and fix the error...';
	  	 Raise l_routing_exception;  
	  ELSIF l_routing_rec_found = 0 THEN --Continue creating the routing.
   			 		
         -- Routing Header 
         l_rtg_header_rec.Assembly_Item_Name               := v_ItemName;
         l_rtg_header_rec.Organization_Code                := v_OrganizationCode;
         l_rtg_header_rec.Eng_Routing_Flag                 := 2;                   
   	  
         l_rtg_header_rec.Transaction_Type                 := 'CREATE';
         l_rtg_header_rec.Return_Status                    := NULL;

         i := i + 1;
   
         -- Operation Table
         l_operation_tbl(i).Assembly_Item_Name             := v_ItemName;
         l_operation_tbl(i).Organization_Code              := v_OrganizationCode;
         l_operation_tbl(i).Operation_Sequence_Number      := to_number(v_Operation_seq);
         l_operation_tbl(i).Operation_Type                 := 1;
         l_operation_tbl(i).Start_Effective_Date           := sysdate;
         l_operation_tbl(i).Department_Code                := v_dept_code;
         l_operation_tbl(i).Transaction_Type               := 'CREATE';
   
         Error_Handler.Initialize;                               -- This call can be removed if you set the
                                                                 -- p_init_msg_list          => TRUE 
         --Fnd_File.put_line (Fnd_File.LOG,'Just Before API Call-->1 ');
   	        
         Bom_Rtg_Pub.Process_Rtg
            ( p_bo_identifier          => 'RTG'
            , p_api_version_number     => 1.0                    
            , p_init_msg_list          => FALSE                  
            , p_rtg_header_rec         => l_rtg_header_rec       --  This holds the Routings header information.
            , p_rtg_revision_tbl       => l_rtg_revision_tbl     --  All the p*_tbl parameters are data structure
            , p_operation_tbl          => l_operation_tbl
            , p_op_resource_tbl        => l_op_resource_tbl	  --  Not applicable for Google 
            , p_sub_resource_tbl       => l_sub_resource_tbl	  --  Not applicable for Google 
            , p_op_network_tbl         => l_op_network_tbl		  --  Not applicable for Google 
            , x_rtg_header_rec         => l_x_rtg_header_rec     --  All the x*_tbl parameters are data structure
   
            , x_rtg_revision_tbl       => l_x_rtg_revision_tbl
            , x_operation_tbl          => l_x_operation_tbl
            , x_op_resource_tbl        => l_x_op_resource_tbl
            , x_sub_resource_tbl       => l_x_sub_resource_tbl
            , x_op_network_tbl         => l_x_op_network_tbl
            , x_return_status          => l_x_return_status      --  Flag for business object state after the import.
            , x_msg_count              => l_x_msg_count          --  This holds the number of messages in the API 
                                                                 --  message stack after the import.
            , p_debug                  => 'Y'                    -- To set the Debug Mode on 
            , p_output_dir             => '/usr/tmp'             -- Will create the log file in this directory.
            , p_debug_filename         => 'RTG_BO_debug.log'     -- The Name of the log file
            );
   
         Fnd_File.put_line (Fnd_File.LOG,'Return Status = '||l_x_return_status);
         --Fnd_File.put_line (Fnd_File.LOG,'Message Count = '||l_x_msg_count);
		 
		 --RK: Capture the errors into error table!!! **IMP**           
         
         Error_Handler.Get_message_list(l_error_message_list);
            
         IF l_x_return_status <> 'S'
         THEN
            --  Error Processing
            for i in 1..l_error_message_list.COUNT LOOP
              Fnd_File.put_line (Fnd_File.LOG,'Entity Id    : '||l_error_message_list(i).entity_id);
              Fnd_File.put_line (Fnd_File.LOG,'Index        : '||l_error_message_list(i).entity_index);
              Fnd_File.put_line (Fnd_File.LOG,'Message Type : '||l_error_message_list(i).message_type);
              Fnd_File.put_line (Fnd_File.LOG,'Mesg         : '||SUBSTR(l_error_message_list(i).message_text,1,250));			  
              Fnd_File.put_line (Fnd_File.LOG,'-------------------------------------------------------------------');
			  --
              e_error_desc  := 'Routing Failed...'||'Entity id: '||l_error_message_list(i).entity_id
			  				   					  ||'Error Messg: '||SUBSTR(l_error_message_list(i).message_text,1,250);
              e_sugg_action := 'Please check ggl_plm_util_pkg.create_routing code and fix the error...';
        	  Fnd_File.put_line (Fnd_File.LOG,e_error_desc);
        	  --			   
              Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                     (7771,    --e_transaction_id,
                                                      NULL,	   --e_transaction_line_id,
                                                      e_transaction_source,
                                                      e_error_desc,
                                                      e_sugg_action,
                                                      v_user_id,
                                                      e_err_ret_code
                                                     );			  
            end loop;
            ROLLBACK;
         ELSE
            COMMIT;
         Fnd_File.put_line (Fnd_File.LOG,'Routing created Successfully!!! ');
         END IF;
	  --
	  END IF;	--l_routing_rec_found = 0 THEN  	  	
      
      RETURN TRUE;	   	 
  
  EXCEPTION
    WHEN L_ROUTING_EXCEPTION THEN
	  IF e_error_desc IS NULL THEN
      	 e_error_desc  := 'Unknown Fatal error in create_routing - l_routing_rec_found query failed; '||'sqlerrm: '||substr(sqlerrm,1,500);
      	 e_sugg_action := 'Please check ggl_plm_util_pkg.create_routing code and fix the error...';
	  END IF;
	  Fnd_File.put_line (Fnd_File.LOG,e_error_desc);
	  --			   
      Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                             (7771,    --e_transaction_id,
                                              NULL,	   --e_transaction_line_id,
                                              e_transaction_source,
                                              e_error_desc,
                                              e_sugg_action,
                                              v_user_id,
                                              e_err_ret_code
                                             );		
      RETURN FALSE;
    WHEN OTHERS THEN
      e_error_desc  := 'Unknown Fatal error in create_routing - WHEN OTHERS Exception '||'sqlerrm: '||substr(sqlerrm,1,500);
      e_sugg_action := 'Please check ggl_plm_util_pkg.create_routing code and fix the error...';
	  Fnd_File.put_line (Fnd_File.LOG,e_error_desc);
	  --			   
      Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                             (7771,    --e_transaction_id,
                                              NULL,	   --e_transaction_line_id,
                                              e_transaction_source,
                                              e_error_desc,
                                              e_sugg_action,
                                              v_user_id,
                                              e_err_ret_code
                                             );		   	
      RETURN FALSE;
  END CREATE_ROUTING;

	 


  
-- ========================================================================================
--
-- This procedure will update STAGING and INT tables based on ECO status;
-- If it failed before ECO API then 'INTERFACE_ERROR'; if before Implementation then 'ECO_ERROR'   
-- 'VALIDATION_ERROR' if it failed any where else...
--
-- ========================================================================================
	  
	 PROCEDURE iupdate_eco (p_change_notice VARCHAR2, p_error_status VARCHAR2
	 						,p_error_message VARCHAR2)
	 IS
	   l_temp NUMBER;
	   l_error_message VARCHAR2(2000);
	 BEGIN 
	 	-- 
    	Fnd_File.put_line (Fnd_File.LOG, ' ');
    	Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
        Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<IUPDATE_ECO>> process...');
    	Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
		l_error_message := 'FAILED: At Least One Invalid Record; '||p_error_message;
    	--
		BEGIN
            UPDATE ggl_plm_bom_staging
            SET    
            	   eco_status_code       = p_error_status,  
            	   eco_status_message    = l_error_message--||'; '||eco_status_message
            WHERE  change_notice         = p_change_notice
    		  --AND  process_flag 		<> 'ERROR';
    		  AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
		EXCEPTION
		  WHEN OTHERS THEN NULL; --If it is already marked as 'ERROR' 'INVALID' etc then do not update it.
		END;  	  
            --
		BEGIN	
            UPDATE ggl_plm_bom_int gb
               SET 
            	   eco_status_code       = p_error_status,  
            	   eco_status_message    = l_error_message--||'; '||eco_status_message
            WHERE  change_notice         = p_change_notice
    		  AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
		EXCEPTION
		  WHEN OTHERS THEN NULL;  --If it is already marked as 'ERROR' 'INVALID' etc then do not update it.
		END;  			  
    		--
		BEGIN			
            UPDATE ggl_plm_bom_comp_int gb
               SET 
            	   eco_status_code       = p_error_status,  
            	   eco_status_message    = l_error_message--||'; '||eco_status_message
            WHERE  change_notice         = p_change_notice
    		  AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
		EXCEPTION
		  WHEN OTHERS THEN NULL;
		END;      		  		
    		--
		BEGIN			
            UPDATE ggl_plm_bom_comp_sub_int gb
               SET 
            	   eco_status_code       = p_error_status,  
            	   eco_status_message    = l_error_message--||'; '||eco_status_message
            WHERE  change_notice         = p_change_notice
    		  AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
		EXCEPTION
		  WHEN OTHERS THEN NULL;
		END;  			  		
		--
		--We can also update INTERFACE if needed; but they are not being used and would be deleted periodically
		--
        Fnd_File.put_line (Fnd_File.LOG, l_error_message); 
		--			
   	 EXCEPTION
      WHEN OTHERS
      THEN
	  		
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in iupdate_eco - When others exception; sqlerrm:'
                            ||SUBSTR (SQLERRM, 1, 500)
                           );
               e_transaction_id      := p_change_notice; --c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               e_error_desc  := 'Unknown Fatal error in iUpdate_eco - WHEN OTHERS Exception for ECN# '||p_change_notice
			   					||'sqlerrm: '||substr(sqlerrm,1,500);
               e_sugg_action := 'Please check iupdate_eco code and fix the error...';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );							   
   	 END iupdate_eco;
    


-- ========================================================================================
--
-- This procedure will update STAGING and INT tables based on ECO status;
-- If it failed before ECO API then 'INTERFACE_ERROR'; if before Implementation then 'ECO_ERROR'   
-- 'VALIDATION_ERROR' if it failed any where else...
--
-- ========================================================================================
	  
	 PROCEDURE iupdate_inv_comps (p_change_notice VARCHAR2)
	 IS
	   l_temp  			 NUMBER;
	   l_error_message	 VARCHAR2(2000);
	   l_old_assembly_id NUMBER;
	   l_bill_seq_id	 NUMBER;
	   l_item_num		 NUMBER := 0;
	   --		
	   CURSOR c1 IS
         SELECT assembly_item_id, organization_id
         	   ,ggl_plm_bom_comp_int_id, ggl_plm_bom_int_id
         	   ,transaction_type, change_notice, comp.ROWID row_id
           FROM xxmfg.ggl_plm_bom_comp_int comp
          WHERE transaction_type = 'CREATE' --For Update it uses the right item_num from BOM 
            --AND ggl_plm_bom_int_id is not null	
            AND change_notice = p_change_notice --'04661'    
          ORDER BY comp.ggl_plm_bom_int_id;  
	   --	   
	 BEGIN 
	 	-- 
    	Fnd_File.put_line (Fnd_File.LOG, ' ');
    	Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
        Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<IUPDATE_INV_COMP>> process...');
    	Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');

		FOR R1 in C1 
		LOOP
		  
		  IF R1.assembly_item_id <> NVL(l_old_assembly_id,-9999) THEN
            BEGIN
               SELECT bill_sequence_id
                 INTO l_bill_seq_id
                 FROM bom_bill_of_materials bbm
                WHERE bbm.organization_id  = r1.organization_id
                  AND bbm.assembly_item_id = r1.assembly_item_id
                  AND ROWNUM = 1;
            EXCEPTION
               WHEN OTHERS
               THEN
                  l_bill_seq_id := '';
            END;  
			--  		  
  		    IF l_bill_seq_id IS NULL THEN
  		  	   l_item_num := 10;
			ELSIF l_bill_seq_id IS NOT NULL THEN
			  BEGIN
			    SELECT max(item_num)+10 
			      INTO l_item_num
                  FROM bom_inventory_components bic
                 WHERE bill_sequence_id = l_bill_seq_id
    		  	   AND disable_date IS NULL;
			  EXCEPTION
			  	WHEN NO_DATA_FOUND THEN --This should not happen!!!
					 l_item_num := 10;
              	   Fnd_File.put_line (Fnd_File.LOG,
                                   ' Unknown Fatal error in iupdate_inv_comps - When NDF exception of select max..; sqlerrm:'
                                ||SUBSTR (SQLERRM, 1, 500));		  	   
			  END;	   			   
  		    END IF; --l_bill_seq_id IS NULL THEN
			
			--
		  ELSIF R1.assembly_item_id = NVL(l_old_assembly_id,-9999) THEN
  		  	   l_item_num := l_item_num + 10;  		  
		  END IF; --R1.assembly_item_id <> NVL(l_old_assembly_id,-9999) THEN
		
		  l_old_assembly_id := r1.assembly_item_id;
    	  BEGIN
              UPDATE ggl_plm_bom_comp_int gic
                 SET item_num  = l_item_num
               WHERE gic.ROWID = r1.row_id;
    	  EXCEPTION
    		  WHEN OTHERS THEN
              	   Fnd_File.put_line (Fnd_File.LOG,
                                   ' Unknown Fatal error in iupdate_inv_comps - When others exception of UPDATE ggl_plm_bom_comp_int; sqlerrm:'
                                ||SUBSTR (SQLERRM, 1, 500));		  	   
    	  END;   		
		END LOOP;
		--
   	 EXCEPTION
      WHEN OTHERS
      THEN
	  		
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in iupdate_eco - When others exception; sqlerrm:'
                            ||SUBSTR (SQLERRM, 1, 500)
                           );
               e_transaction_id      := p_change_notice; --c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               e_error_desc  := 'Unknown Fatal error in iUpdate_inv_comps - WHEN OTHERS Exception for ECN# '||p_change_notice
			   					||'sqlerrm: '||substr(sqlerrm,1,500);
               e_sugg_action := 'Please check iupdate_inv_comps code and fix the error...';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );							   
   	 END iupdate_inv_comps;
    
 	 
	  
-- ========================================================================================
--
-- This procedure is used to display all the ERROR RECORDS from GGL_INV_ERRPRS table for this eco#  
-- **IMP NOTE: bbom_interface, bomor_interface, bomos_interface are not being deleted...*** 
--
-- ***REGISTER AS A CONC PROGRAM....
-- ========================================================================================

     PROCEDURE ireprocess_eco (p_change_notice IN VARCHAR2 )
     IS
		l_errbuf 			  VARCHAR2(200);
		l_errcode 			  NUMBER;
		l_corrected_flag	  VARCHAR2(1) := 'N';
		l_bill_sequence_id	  NUMBER;
		--
	 BEGIN	     
     --
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '---------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<IREPROCESS_ECO>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '---------------------------------------------------------------------------- ');
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '    CHECK: 01-CORRECTED ECO#....'||p_change_notice||' Corr_flag: '||l_corrected_flag);	  
  	  --
  	  -- If BOM Exists and process_flag = 'CORRRECTED' then reporcess the corrected/fixed staging records
  	  --
        BEGIN
  	    --
          SELECT 'Y'
		    INTO l_corrected_flag 
            FROM xxmfg.ggl_plm_bom_staging gbs
           WHERE process_flag = 'CORRECTED'
             AND change_notice = p_change_notice
             AND ROWNUM = 1;
            
            IF l_corrected_flag = 0 THEN 
                  SELECT 'Y'
                    INTO l_corrected_flag 
	                FROM xxmfg.ggl_plm_item_upload gpd
                   WHERE gpd.process_flag = 'CORRECTED'  
                     AND change_notice = p_change_notice
                     AND ROWNUM = 1;
            END IF; 	  
		Fnd_File.put_line (Fnd_File.LOG, '    CHECK: 02-CORRECTED ECO#....'||p_change_notice);				  
        --
        EXCEPTION
           WHEN NO_DATA_FOUND THEN
                l_corrected_flag := 'N';
			  Fnd_File.put_line (Fnd_File.LOG, '    CHECK: NDF: Not a CORRECTED ECO....'||p_change_notice||' Corr flag: '||l_corrected_flag);				  
           WHEN OTHERS THEN
              l_corrected_flag := 'N';
			  Fnd_File.put_line (Fnd_File.LOG, '    CHECK: WO: Not a CORRECTED ECO....'||p_change_notice||' Corr flag: '||l_corrected_flag);				  
        END;		  
	 --

		   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: 03-Just before l_corrected_flag<>0....'||l_corrected_flag);	
      	--	 
      	-- If CORRECTED records found then delete them based on either ECO or BOM 
      	--
		IF l_corrected_flag = 'Y' THEN 
		   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: It is a CORRECTED ECO....'||p_change_notice||' corr flag: '||l_corrected_flag);	
			--
			--If it is new BOM then we need to delete the following records
			--
			BEGIN		 
                DELETE FROM xxmfg.ggl_plm_bom_staging 
    			WHERE change_notice = p_change_notice 
    			AND (sub_acd_type = 3 OR comp_acd_type = 3
					 OR disable_date is not null				
					);  --Records created by BOM Disable program...
			EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_STAGING');				   
			END;	 
          	--
			BEGIN
				 DELETE FROM xxmfg.ggl_plm_bom_int WHERE change_notice = p_change_notice; 
			EXCEPTION
			  WHEN OTHERS THEN --Do nothing!! 
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_INT');				   
			END;				 
                
            BEGIN    
                DELETE FROM xxmfg.ggl_plm_bom_comp_int WHERE change_notice = p_change_notice; 
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_COMP_INT');				   
			END;	
			
			BEGIN    
                DELETE FROM xxmfg.ggl_plm_bom_comp_sub_int WHERE change_notice = p_change_notice; 
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_SUB_COMP_INT');				   
			END;	
			
			BEGIN    
                DELETE eng.eng_eng_changes_interface WHERE change_notice = p_change_notice or attribute2 = p_change_notice;
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in ENG_CHANGES_IFACE');				   
			END;	
			
			BEGIN                
                DELETE eng.eng_revised_items_interface WHERE change_notice =  p_change_notice or attribute2 = p_change_notice;
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in ENG_REV_ITEM_IFACE');				   
			END;	
			
			BEGIN                
                DELETE bom.bom_inventory_comps_interface 
				WHERE attribute2 = p_change_notice OR  
					  change_notice = p_change_notice; 
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in INV_COMP_IFACE');				   
			END;	
			
			BEGIN                
                DELETE bom.bom_sub_comps_interface 
				WHERE attribute2 = p_change_notice OR 
					  change_notice = p_change_notice; 
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_SUB_COMP_IFACE');				   
			END;	
			    			
 			--
 			--If it is new BOM then we need to delete the following records
 			--
    		BEGIN	
    			DELETE bom.bom_bill_of_mtls_interface WHERE attribute2 = p_change_notice;
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_BILL_MAT_IFACE');				   
			END;	

    		BEGIN	
    			DELETE bom.bom_op_routings_interface WHERE attribute2 = p_change_notice;
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_OP_ROUTNG_IFACE');				   
			END;	
			
    		BEGIN	
    			DELETE bom.bom_op_sequences_interface WHERE attribute2 = p_change_notice;
            EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to delete in BOM_OP_SEQ_IFACE');				   
			END;							
					
			COMMIT;			
      	  --
      	  --ggl_inv_error tables also
      	  --
      	  --delete inv_errors
      	  --
		  BEGIN
            UPDATE GGL_PLM_BOM_STAGING
               SET process_flag = 'NEW',
            	   error_messg = '',
                   ggl_plm_bom_int_id = '',
                   ggl_plm_bom_comp_int_id = '',
                   ggl_plm_bom_comp_sub_int_id = '',
            	   comp_acd_type=null,
            	   sub_acd_type = null, disable_date = null, 
            	   eco_status_code = NULL, eco_status_message = NULL
             WHERE 1=1  
               AND change_notice = p_change_notice;
			--
            UPDATE xxmfg.ggl_plm_aml_avl_int 
			   SET process_flag = 'NEW', error_messg=null
             WHERE change_notice = p_change_notice;		
			--	  
          EXCEPTION
			  WHEN OTHERS THEN --Do nothing!!
			  	   NULL;
				   Fnd_File.put_line (Fnd_File.LOG, '    CHECK: No records found to update for ECO: '||p_change_notice);				   
		  END;				  
      	  --
      	  COMMIT;
		  -- 
		ELSE
			NULL; --Do nothing as this ECO is not a corrected/fixed ECO...
			Fnd_File.put_line (Fnd_File.LOG, '    CHECK: In Else: Not a CORRECTED ECO....'||p_change_notice||' corr flag: '||l_corrected_flag);			  
		END IF;  	--IF l_corrected_flag = '1' THEN 
		commit;	  
	  --  
	 END ireprocess_eco;
	 
	  
	  
-- ========================================================================================
--
-- This procedure will compare the INT tables againest INTERFACE tables;   
-- If records in INT = INTERFACE then call ECO API; Otherwise mark all ECO records as INTERFACE_ERROR  
--
-- ========================================================================================

     FUNCTION icheck_interface_status (p_change_notice IN VARCHAR2) RETURN NUMBER
     IS
	    --l_return_status NUMBER := -1; 
		l_status		NUMBER := -1;
		l_g_status		NUMBER :=  1;
		--
        CURSOR c_bom
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_int gb
          WHERE process_flag IN ('IN_INTERFACE') 
		    AND organization_code IN 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')			
		    AND change_notice 	= p_change_notice;
		--
        CURSOR c_comp  
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_comp_int gb
          WHERE process_flag IN ('IN_INTERFACE')   
		    AND organization_code IN 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')		  
            AND change_notice = p_change_notice;
		--	
        CURSOR c_scomp 
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_comp_sub_int gb
          WHERE process_flag IN ('IN_INTERFACE')  
		    AND organization_code IN 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')	  
            AND change_notice = p_change_notice;
		--	  
	 BEGIN	     
     --
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<ICHECK_INTERFACE_STATUS>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
	 --
	   l_status := -1;
	 --   
	 -- Check the BOM/ Assembly records matching or not (INT vs. INTERFACE) 
	 --
       FOR C_BOM_REC IN C_BOM LOOP
	   --
       	 Fnd_File.put_line (Fnd_File.LOG, '    CHECK:   Starting the <<IN BOM_REC LOOP>> process...');
		 --
	   	 BEGIN
		   SELECT (	  
		 	  SELECT 1 --INTO l_status  
			    FROM ENG.ENG_REVISED_ITEMS_INTERFACE 
			   WHERE attribute1 = c_bom_rec.ggl_plm_bom_int_id
			     AND rownum = 1
			  UNION
			  SELECT 1 --INTO l_status  
			    FROM BOM.bom_bill_of_mtls_interface 
			   WHERE attribute1 = c_bom_rec.ggl_plm_bom_int_id
			     AND rownum = 1
			      ) INTO l_status FROM DUAL;
		 EXCEPTION
		   WHEN TOO_MANY_ROWS THEN
		   		l_status := 1;
		   WHEN NO_DATA_FOUND THEN 
		   		l_status := -1;
				IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				
       	 		Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...NDF '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id );	
				--
                e_transaction_id      := NVL(c_bom_rec.ggl_plm_bom_int_id,p_change_notice);
                e_transaction_line_id := '';
                e_error_desc  := 'No record found to create change_notice for assembly item: '||c_bom_rec.item_number;
                e_sugg_action := 'Please check this record in BOM_STAGING table';
 			    --			   
                Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE ggl_plm_bom_staging
                     SET process_flag 		 = 'ERROR' , 
				  	   	 error_messg		 = e_error_desc||' <> '||e_sugg_action,
                  	   	 eco_status_code     = 'VALIDATION_ERROR',  
                  	   	 eco_status_message  = e_error_desc||' <> '||e_sugg_action
                   WHERE  change_notice      = p_change_notice
				     AND  item_number 		 = c_bom_rec.item_number
					 AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');		
				EXIT;
		   WHEN OTHERS THEN
		   		-- Report error message in both table and log
				l_status := -1;
				IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				
       	 		Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...OTHERS '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id  
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));					
		 END;
	   --
	   END LOOP;
	   --
	   --
	   -- Check the COMP records matching or not (INT vs. INTERFACE) 
	   --
	   IF l_status <> -1 THEN
	   --
           FOR C_COMP_REC IN C_COMP LOOP
    	   --
       	   Fnd_File.put_line (Fnd_File.LOG, '    CHECK:   Starting the <<IN COMP_REC LOOP>> process...');
		   --
		   EXIT WHEN C_COMP%NOTFOUND;		   
    	   	 BEGIN
    		 	  SELECT 1 INTO l_status  
    			    FROM BOM_INVENTORY_COMPS_INTERFACE BICI
    			   WHERE --change_notice = p_change_notice
				   		 attribute2	  = p_change_notice
    			     AND attribute1	  = c_comp_rec.ggl_plm_bom_comp_int_id;
					 --AND ROWNUM = 1;
    		 EXCEPTION
		       WHEN TOO_MANY_ROWS THEN
		   			l_status := 1;			 
    		   WHEN NO_DATA_FOUND THEN 
    		   		l_status := -1;
					IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status					
       	   			Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN COMP_REC LOOP>> process...NDF '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id );		
				--
                e_transaction_id      := NVL(c_comp_rec.ggl_plm_bom_comp_int_id,p_change_notice);
                e_transaction_line_id := '';
                e_error_desc  := 'No record found to create change_notice for component: '||c_comp_rec.component_item_number;
                e_sugg_action := 'Please check this record in BOM_STAGING table';
 			    --			   
                Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE ggl_plm_bom_staging
                     SET process_flag 		 = 'ERROR' , 
				  	   	 error_messg		 = e_error_desc||' <> '||e_sugg_action,
                  	   	 eco_status_code     = 'VALIDATION_ERROR',  
                  	   	 eco_status_message  = e_error_desc||' <> '||e_sugg_action
                   WHERE change_notice       = p_change_notice
				     AND component_item_number = c_comp_rec.component_item_number
					 AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');	
    			 EXIT;
    		   WHEN OTHERS THEN
    		   		-- Write an error message in both table and log 
    		   		l_status := -1;		
					IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status								
       	   			Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN COMP_REC LOOP>> process...OTHERS '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id 
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));						
    		 END;
    	   --
    	   END LOOP;
	   --
	   END IF;
	   --
	   -- Check the SUB COMP records matching or not (INT vs. INTERFACE) 
	   --
	   IF l_status <> -1 THEN
	   --
           FOR C_SCOMP_REC IN C_SCOMP LOOP
    	   --
       	   Fnd_File.put_line (Fnd_File.LOG, '    CHECK:   Starting the <<IN SCOMP_REC LOOP>> process...');
		   --
		   EXIT WHEN C_SCOMP%NOTFOUND;
    	   	 BEGIN
    		 	  SELECT 1 INTO l_status  
    			    FROM BOM_SUB_COMPS_INTERFACE BICI
    			   WHERE --change_notice = p_change_notice
				   		 attribute2    = p_change_notice
    			     AND attribute1	   = c_scomp_rec.ggl_plm_bom_comp_sub_int_id;
					 --AND rownum = 1;				
    		 EXCEPTION
		       WHEN TOO_MANY_ROWS THEN
		   			l_status := 1;					 
    		   WHEN NO_DATA_FOUND THEN 
    		   		l_status := -1;
					IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status					
       	   			Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...NDF '
		 				   				  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id);		
				--
                e_transaction_id      := NVL(c_scomp_rec.ggl_plm_bom_comp_sub_int_id,p_change_notice);
                e_transaction_line_id := '';
                e_error_desc  := 'No record found to create change_notice for sub component: '||c_scomp_rec.substitute_component_number;
                e_sugg_action := 'Please check this record in BOM_STAGING table';
 			    --			   
                Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE ggl_plm_bom_staging
                  SET  process_flag 		 = 'ERROR' , 
				  	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                  WHERE  change_notice       = p_change_notice
				    AND  substitute_component_number 		 = c_scomp_rec.substitute_component_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');											  				
    				EXIT;
    		   WHEN OTHERS THEN
    		   		-- Write an error message in both table and log
    		   		l_status := -1;	
					IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status									 
       	   			Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...OTHERS '
		 				   				  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id  
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));						
    		 END;
    	   --
    	   END LOOP;
	   --
	   END IF;
	   --
	   COMMIT;
	   --
	   -- Return -1 when either BOM/ASSY, COMP or SUB COMP records does not match to update-
	   -- all eco records to ERROR 
	   --	   
	   RETURN l_g_status;
	  --  
   	 EXCEPTION
      WHEN OTHERS
      THEN
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in icheck_interface_status :'
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500)
                           );
		 IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status						   
         e_transaction_id      := P_CHANGE_NOTICE;
         e_transaction_line_id := '';
         e_error_desc  := 'ICHECK_INTERFACE_STATUS - WHEN OTHERS EXCEPTION; sqlerrm: '
         			   	  ||SUBSTR (SQLERRM, 1, 500);
         e_sugg_action := 'Please check icheck_interface_status procedure';
         --			   
         Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                (e_transaction_id,
                                                 e_transaction_line_id,
                                                 e_transaction_source,
                                                 e_error_desc,
                                                 e_sugg_action,
                                                 v_user_id,
                                                 e_err_ret_code
                                                );
         --			  				
         iupdate_eco (p_change_notice, 'INTERFACE_ERROR', e_error_desc||' ; '||e_sugg_action);
         COMMIT;				  																  
         e_error_desc  := '';
         e_sugg_action := '';
			   						   
	   RETURN l_g_status;						   
	  
	 END icheck_interface_status;
	  --

-- ========================================================================================
--
-- This procedure will compare the INT tables againest ECO main tables;   
-- If records in INT = ECO tables then call IMPL API; Otherwise mark all ECO records as  ECO_ERROR 
--
-- ========================================================================================

     FUNCTION icheck_eco_status (p_change_notice IN VARCHAR2) RETURN NUMBER
     IS
		l_status		NUMBER := -1;
		l_g_status		NUMBER :=  1;
		--
        CURSOR c_bom
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_int gb
          WHERE process_flag IN ('IN_PROCESS', 'IN_INTERFACE') 
		    AND organization_code IN 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')
		    AND change_notice = p_change_notice;
			--AND transaction_type = 'UPDATE';
		--
        CURSOR c_comp  
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_comp_int gb
          WHERE process_flag IN ('IN_PROCESS', 'IN_INTERFACE')  
		    AND organization_code IN 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')		  
            AND change_notice = p_change_notice;
			--AND transaction_type = 'UPDATE';
		--	
        CURSOR c_scomp 
        IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_comp_sub_int gb
          WHERE process_flag IN ('IN_PROCESS', 'IN_INTERFACE') 
		    AND organization_code IN --('PNA','ENU','GNA','GCU')  --RK: 102807 : changed...test it and see!! 
                                 (SELECT distinct attribute1
                                   FROM fnd_flex_values_vl v, fnd_flex_value_sets s
                                  WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
                                    AND v.flex_value_set_id = s.flex_value_set_id
                                    AND v.enabled_flag = 'Y')				 		  
            AND change_notice = p_change_notice;
			--AND transaction_type = 'UPDATE';
		--	  
	 BEGIN	     
     --
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<ICHECK_ECO_STATUS>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
	 --
	   l_status := -1;
	 --
	 -- Check the BOM/ Assembly records matching or not (INT vs. ECO base table records) 
	 --
       FOR C_BOM_REC IN C_BOM LOOP
	   --
       	 Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...Before '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id );
		 --
	   	 BEGIN
		   IF c_bom_rec.transaction_type IN ('UPDATE','CREATE') THEN
		   SELECT (
		 	  SELECT 1 --INTO l_status  
			  FROM ENG_REVISED_ITEMS_V 
			  WHERE 1=1 --and change_notice = p_change_notice 
			    AND attribute1 = c_bom_rec.ggl_plm_bom_int_id
				AND rownum 	   = 1
		      UNION
 		 	  SELECT 1 --INTO l_status  
 			  FROM BOM_BILL_OF_MATERIALS_V 
 			  WHERE 1=1 --and change_notice = p_change_notice 
 			    AND attribute1 = c_bom_rec.ggl_plm_bom_int_id
 				AND rownum 	   = 1
			      ) INTO l_status FROM DUAL;						   
		   END IF;					
		 --		
       	 Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...After '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id );				
		 EXCEPTION
		   WHEN TOO_MANY_ROWS THEN
		   		l_status := 1;				 
		   WHEN NO_DATA_FOUND THEN 
		   		l_status := -1;
				IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status
				
       	 		Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...NDF '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id );	
				--
                e_transaction_id      := NVL(c_bom_rec.ggl_plm_bom_int_id,p_change_notice);
                e_transaction_line_id := '';
                e_error_desc  := 'No record found to implement change_notice for assembly item: '||c_bom_rec.item_number;
                e_sugg_action := 'Please check this record in BOM_STAGING table';
 			    --			   
                Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE ggl_plm_bom_staging
                  SET  process_flag 		 = 'ERROR' , 
				  	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                  WHERE change_notice        = p_change_notice
				    AND item_number 		 = c_bom_rec.item_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');											  				
				EXIT;
		   		--UPDATE STAGING
				--UPDATE INT TABLES (ALL) by change_notice# --do not process any record from this ECO#
				NULL; 
		   WHEN OTHERS THEN
		   		-- Report error message in both table and log
				l_status := -1;
				IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				
       	 		Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN BOM_REC LOOP>> process...OTHERS '
		 				   				  ||' bom_int_id :'||c_bom_rec.ggl_plm_bom_int_id  
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));					
				NULL; 
				EXIT;
		 END;
	   --
	   END LOOP;
	   --
	   --
	   -- Check the COMP records matching or not (INT vs. ECO base table records) 
	   --
	   IF l_status <> -1 THEN
	   --
           FOR C_COMP_REC IN C_COMP LOOP
    	   --
       	   Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN COMP_REC LOOP>> process...Before '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id );	
		   --
    	   	 BEGIN
    		    --IF c_comp_rec.acd_type = 3 THEN  -- For disable look in ENG_REVISED_COMPS_INT
				SELECT ( 
              	  SELECT 1 --INTO l_status
              	    FROM eng_revised_components_v erc 
              	   WHERE 1=1 
              	 	 AND attribute1 = c_comp_rec.ggl_plm_bom_comp_int_id
    		  		 AND ROWNUM = 1 				
    			UNION
              	  SELECT 1 --INTO l_status
              	    FROM bom_inventory_components bic
              	   WHERE 1=1 
              	 	 AND attribute1 = c_comp_rec.ggl_plm_bom_comp_int_id
    		  		 AND ROWNUM = 1  
			      ) INTO l_status FROM DUAL;					 
    			--END IF;	
    	     	--
       	     	Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN COMP_REC LOOP>> process...After '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id||' l_status is:'||l_status);							
    		 EXCEPTION
		       WHEN TOO_MANY_ROWS THEN
		   			l_status := 1;					 
    		   WHEN NO_DATA_FOUND THEN 
    		   	 l_status := -1;
				 IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				 
       	   		 Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN COMP_REC LOOP>> process...NDF '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id );		
				 --
                 e_transaction_id      := NVL(c_comp_rec.ggl_plm_bom_comp_int_id,p_change_notice);
                 e_transaction_line_id := '';
                 e_error_desc  := 'No record found to implement change_notice for component: '||c_comp_rec.component_item_number;
                 e_sugg_action := 'Please check this record in BOM_STAGING table';
 			     --			   
                 Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE ggl_plm_bom_staging
                  SET  process_flag 		 = 'ERROR' , 
				  	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                  WHERE  change_notice       = p_change_notice
				    AND  component_item_number 	= c_comp_rec.component_item_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');											  					
    			  EXIT;
    				--UPDATE INT TABLES (ALL) by change_notice# --do not process any record from this ECO# 
    				NULL; 
    		   WHEN OTHERS THEN
    		   	 -- Write an error message in both table and log 
    		   	 l_status := -1;		
				 IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				 
       	   		 Fnd_File.put_line (Fnd_File.LOG, '    Fatal Error:  <<IN COMP_REC LOOP>> process...OTHERS '
		 				   				  ||' comp_int_id :'||c_comp_rec.ggl_plm_bom_comp_int_id 
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));		
				 --
                 e_transaction_id      := NVL(c_comp_rec.ggl_plm_bom_comp_int_id,p_change_notice);
                 e_transaction_line_id := '';
                 e_error_desc  := 'Fatal Error - When others in icheck_eco_status - for component: '||c_comp_rec.component_item_number;
                 e_sugg_action := 'Please check this record in BOM_STAGING table';
 			     --			   
                 Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                 UPDATE ggl_plm_bom_staging
                    SET process_flag 		 = 'ERROR' , 
				  	   	error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   	eco_status_code      = 'VALIDATION_ERROR',  
                  	   	eco_status_message   = e_error_desc||' <> '||e_sugg_action
                  WHERE  change_notice       = p_change_notice
				    AND  component_item_number 		 = c_comp_rec.component_item_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
															  				
				 EXIT;			
    		 END;
    	   --
    	   END LOOP;
	   --
	   END IF;
	   --
	   -- Check the SUB COMP records matching or not (INT vs. ECO base table records) 
	   --
	   IF l_status <> -1 THEN
	   --
           FOR C_SCOMP_REC IN C_SCOMP LOOP
    	   --
       	   Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...Before '
		 				   		  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id );			   
		   --
		     EXIT WHEN C_SCOMP%NOTFOUND;
			 --
    	   	 BEGIN
    		 	  SELECT 1 INTO l_status  
    			  FROM BOM_SUBSTITUTE_COMPONENTS
    			  WHERE 1=1 --and change_notice = p_change_notice
    			    AND attribute1	  = c_scomp_rec.ggl_plm_bom_comp_sub_int_id;	
    	     --
       	     Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...After '
		 				   				  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id );			   
    		 EXCEPTION
		       WHEN TOO_MANY_ROWS THEN
		   			l_status := 1;					 
    		   WHEN NO_DATA_FOUND THEN 
    		   	 l_status := -1;
				 IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status				 
       	   		 Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...NDF '
		 				   				  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id );	
				 --
                 e_transaction_id      := NVL(c_scomp_rec.ggl_plm_bom_comp_sub_int_id,p_change_notice);
                 e_transaction_line_id := '';
                 e_error_desc  := 'No record found to implement change_notice for sub component: '||c_scomp_rec.substitute_component_number;
                 e_sugg_action := 'Please check this record in BOM_STAGING table';
 			     --			   
                 Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  UPDATE  ggl_plm_bom_staging
                  	 SET  process_flag 		 = 'ERROR' , 
				  	   	  error_messg		 = e_error_desc||' <> '||e_sugg_action,
                  	   	  eco_status_code    = 'VALIDATION_ERROR',  
                  	   	  eco_status_message = e_error_desc||' <> '||e_sugg_action
                   WHERE  change_notice      = p_change_notice
				     AND  substitute_component_number 	 = c_scomp_rec.substitute_component_number
					 AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');
					 
    			  EXIT;
    				--UPDATE INT TABLES (ALL) by change_notice# --do not process any record from this ECO# 
    				NULL; 
    		   WHEN OTHERS THEN
    		   		-- Write an error message in both table and log
    		   		l_status := -1;
					IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status					
       	   			Fnd_File.put_line (Fnd_File.LOG, '    CHECK:  <<IN SUBCOMP_REC LOOP>> process...OTHERS '
		 				   				  ||' sub_comp_int_id :'||c_scomp_rec.ggl_plm_bom_comp_sub_int_id  
										  ||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));	
				    --
                	e_transaction_id      := NVL(c_scomp_rec.ggl_plm_bom_comp_sub_int_id,p_change_notice);
                	e_transaction_line_id := '';
                	e_error_desc  := 'Fatal Error in icheck_eco_status - for sub component: '||c_scomp_rec.substitute_component_number;
                	e_sugg_action := 'Please check this record in BOM_STAGING table';
 			    	--			   
                	Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                       (e_transaction_id,
                                                        e_transaction_line_id,
                                                        e_transaction_source,
                                                        e_error_desc,
                                                        e_sugg_action,
                                                        v_user_id,
                                                        e_err_ret_code
                                                       );
                  	UPDATE ggl_plm_bom_staging
                  	   SET process_flag 		 = 'ERROR' , 
				  	   	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                     WHERE change_notice        = p_change_notice
				       AND substitute_component_number 		 = c_scomp_rec.substitute_component_number
					   AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');										  
				   EXIT;					 
    		 END;
    	   --
    	   END LOOP;
	   --
	   END IF;
	   
	   COMMIT;
	   --
	   -- Return -1 when either BOM/ASSY, COMP or SUB COMP records does not match to update-
	   -- all eco records to ERROR 
	   --	   
	   RETURN l_g_status;
	  --  
   	 EXCEPTION
      WHEN OTHERS
      THEN
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in icheck_eco_status :'
                            ||SUBSTR (SQLERRM, 1, 500)
                           );
						   
 		  IF l_g_status <> -1 THEN l_g_status := -1; END IF; --global status
		  						   
          e_transaction_id      := P_CHANGE_NOTICE;
          e_transaction_line_id := '';
          e_error_desc  := 'Fatal Error - ICHECK_ECO_STATUS - WHEN OTHERS EXCEPTION; sqlerrm: '
          				||SUBSTR (SQLERRM, 1, 500);
          e_sugg_action := 'Please check icheck_eco_status procedure';
          --			   
          Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                 (e_transaction_id,
                                                  e_transaction_line_id,
                                                  e_transaction_source,
                                                  e_error_desc,
                                                  e_sugg_action,
                                                  v_user_id,
                                                  e_err_ret_code
                                                 );
          --			  				
          iupdate_eco (p_change_notice, 'INTERFACE_ERROR', e_error_desc||' ; '||e_sugg_action);
          COMMIT;				  																  
          e_error_desc  := '';
          e_sugg_action := '';
						   
	   RETURN l_g_status;						   
	  
	 END icheck_eco_status;
	  --
	
	
   
-- ===========================================================================================
--
-- This procedure is used to validate records in the staging table with process_flag = 'CLEAN  
--
-- ==========================================================================================


   PROCEDURE import_eco (
      p1           OUT      VARCHAR2,
      p2           OUT      NUMBER,
      p_test_tag   IN       VARCHAR2
   )
   IS
      l_eco_rec                Eng_Eco_Pub.eco_rec_type;
      l_eco_revision_tbl       Eng_Eco_Pub.eco_revision_tbl_type;
      l_revised_item_tbl       Eng_Eco_Pub.revised_item_tbl_type;
      l_rev_component_tbl      Bom_Bo_Pub.rev_component_tbl_type;
      l_sub_component_tbl      Bom_Bo_Pub.sub_component_tbl_type;
      l_ref_designator_tbl     Bom_Bo_Pub.ref_designator_tbl_type;
      l_rev_operation_tbl      Bom_Rtg_Pub.rev_operation_tbl_type;
      l_rev_op_resource_tbl    Bom_Rtg_Pub.rev_op_resource_tbl_type;
      l_rev_sub_resource_tbl   Bom_Rtg_Pub.rev_sub_resource_tbl_type;
      l_return_status          VARCHAR2 (1);
      l_msg_count              NUMBER;
      l_msg_data               VARCHAR2 (2000);
      l_error_table            Error_Handler.error_tbl_type;
      l_message_text           VARCHAR2 (2000);

      CURSOR c_eco_rec
      IS
         SELECT *
           FROM eng_eng_changes_interface
          WHERE eng_changes_ifce_key LIKE p_test_tag;

      CURSOR c_eco_rev
      IS
         SELECT *
           FROM eng_eco_revisions_interface
          WHERE eng_eco_revisions_ifce_key LIKE p_test_tag;

      CURSOR c_rev_items
      IS
         SELECT *
           FROM eng_revised_items_interface
          WHERE eng_revised_items_ifce_key LIKE p_test_tag;

      CURSOR c_rev_comps
      IS
         SELECT *
           FROM bom_inventory_comps_interface
          WHERE bom_inventory_comps_ifce_key LIKE p_test_tag;

      CURSOR c_sub_comps
      IS
         SELECT *
           FROM bom_sub_comps_interface
          WHERE bom_sub_comps_ifce_key LIKE p_test_tag;

      CURSOR c_ref_desgs
      IS
         SELECT *
           FROM bom_ref_desgs_interface
          WHERE bom_ref_desgs_ifce_key LIKE p_test_tag;

      i                        NUMBER;
   BEGIN
      -- Query all the records and call the Private API.
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<IMPORT_ECO>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');


      FOR eco_rec IN c_eco_rec
      LOOP
         l_eco_rec.eco_name := eco_rec.change_notice;
         l_eco_rec.organization_code := eco_rec.organization_code;
         l_eco_rec.change_type_code := eco_rec.change_order_type;
         l_eco_rec.approval_status_name := 'Approved';
         --l_eco_rec.status_type          := 6 ;--eco_rec.status_type;
         l_eco_rec.eco_department_name := NULL;
                                              --eco_rec.responsible_org_code;
         l_eco_rec.priority_code := NULL;            --eco_rec.priority_code;
         l_eco_rec.approval_list_name := NULL;  --eco_rec.approval_list_name;
         --l_eco_rec.approval_status_type    := 5; --eco_rec.approval_status_type;
         l_eco_rec.reason_code := NULL;                --eco_rec.reason_code;
         l_eco_rec.eng_implementation_cost := NULL;
                                                --eco_rec.estimated_eng_cost;
         l_eco_rec.mfg_implementation_cost := NULL;
                                                --eco_rec.estimated_mfg_cost;
         l_eco_rec.cancellation_comments := NULL;
                                             --eco_rec.cancellation_comments;
         l_eco_rec.requestor := NULL;                 --eco_rec.requestor_id;
         l_eco_rec.description := NULL;                --eco_rec.description;
         l_eco_rec.transaction_type := eco_rec.transaction_type;
 --        l_eco_rec.attribute_category := eco_rec.attribute_category;			 
         l_eco_rec.attribute1 := eco_rec.attribute1;	--ggl_plm_bom_int_id	
         l_eco_rec.attribute2 := eco_rec.attribute2;	--ECO Number...		  
      END LOOP;

      /*
      -- Fetch ECO Revisions
      i := 1;
      FOR rev IN c_eco_rev
      LOOP
         l_eco_revision_tbl(i).eco_name         := rev.change_notice;
         l_eco_revision_tbl(i).revision         := rev.revision;
         l_eco_revision_tbl(i).new_revision     := rev.new_revision;
         l_eco_revision_tbl(i).transaction_type    := rev.transaction_type;
         i := i + 1;
      END LOOP;   */
      Fnd_File.put_line (Fnd_File.LOG, 'Comes before rev_items loop');
      -- Fetch revised items
      i := 1;

      FOR ri IN c_rev_items
      LOOP
         l_revised_item_tbl (i).eco_name := ri.change_notice;
         l_revised_item_tbl (i).revised_item_name := ri.revised_item_number;
         l_revised_item_tbl (i).organization_code := ri.organization_code;
         --IF ri.new_item_revision = FND_API.G_MISS_CHAR THEN
         l_revised_item_tbl (i).new_revised_item_revision := NULL;
         --ELSE
            --l_revised_item_tbl(i).new_revised_item_revision := ri.new_item_revision;
         --END IF;		 
		 l_revised_item_tbl (i).start_effective_date := TRUNC(SYSDATE);
                                                         --ri.scheduled_date;
         l_revised_item_tbl (i).alternate_bom_code := NULL;
                                               --ri.alternate_bom_designator;
         l_revised_item_tbl (i).status_type := NULL;        --ri.status_type;
         l_revised_item_tbl (i).mrp_active := NULL;          --ri.mrp_active;
         l_revised_item_tbl (i).earliest_effective_date := TRUNC (SYSDATE);
                                                   --ri.early_.schedule_date;
         l_revised_item_tbl (i).use_up_item_name := NULL;
                                                     --ri.use_up_item_number;
         l_revised_item_tbl (i).use_up_plan_name := NULL;
                                                       --ri.use_up_plan_name;
         l_revised_item_tbl (i).disposition_type := NULL;
                                                       --ri.disposition_type;
         l_revised_item_tbl (i).update_wip := NULL;          --ri.update_wip;
         l_revised_item_tbl (i).cancel_comments := NULL;
                                                        --ri.cancel_comments;
         l_revised_item_tbl (i).change_description := NULL;
                                                       --ri.descriptive_text;
         l_revised_item_tbl (i).transaction_type := ri.transaction_type;
         --l_revised_item_tbl (i).attribute_category := ri.attribute_category;	
         l_revised_item_tbl (i).attribute1 := ri.attribute1;	 --ggl_plm_bom_int_id	
         l_revised_item_tbl (i).attribute2 := ri.attribute2;	--ECO Number...				 
		  
         i := i + 1;
      END LOOP;

      Fnd_File.put_line (Fnd_File.LOG, 'Comes before rev_comps loop');
      -- Fetch revised components
      i := 1;

      FOR rc IN c_rev_comps
      LOOP
         IF rc.acd_type IN (2, 3)
         THEN
            BEGIN	--RK: This might create problem going forward (Should get latest rev's op_seq_num not rownum=1 ??
               SELECT   a.effectivity_date,
                        a.operation_seq_num
                   INTO l_rev_component_tbl (i).old_effectivity_date,
                        l_rev_component_tbl (i).old_operation_sequence_number
                   FROM bom_inventory_components a
                  WHERE a.component_item_id = rc.component_item_id
                    AND a.bill_sequence_id = rc.bill_sequence_id
                    AND implementation_date IS NOT NULL
                    AND TRUNC (SYSDATE) BETWEEN TRUNC (a.effectivity_date)
                                            AND NVL (TRUNC (a.disable_date),
                                                     TRUNC (SYSDATE) + 1
                                                    )
                    AND ROWNUM = 1
               ORDER BY implementation_date ASC;

               Fnd_File.put_line
                         (Fnd_File.LOG,
                             'Update bill_sequence_id '
                          || rc.bill_sequence_id
                          || ' component_item_id '
                          || rc.component_item_id
                          || ' old_effectivity_date '
                          || l_rev_component_tbl (i).old_effectivity_date
                          || ' old_operation_sequence_number '
                          || l_rev_component_tbl (i).old_operation_sequence_number
                         );
            EXCEPTION
               WHEN OTHERS
               THEN
                  v_error := SUBSTR (SQLERRM, 1, 500);
                  Fnd_File.put_line
                     (Fnd_File.LOG,
                         'Exception Can not find old bom comp data bill_sequence_id '
                      || rc.bill_sequence_id
                      || ' component_item_id '
                      || rc.component_item_id
                      || ' '
                      || v_error
                     );
            END;
--where a.component_item_id = 7132
--and a.bill_sequence_id = 4753;
         END IF;

         l_rev_component_tbl (i).eco_name := rc.change_notice;           --666
         l_rev_component_tbl (i).revised_item_name := rc.assembly_item_number;
                                                                 --'06100302';
         l_rev_component_tbl (i).organization_code := rc.organization_code;
         l_rev_component_tbl (i).new_revised_item_revision := NULL;
		 -- changed start effective date to avoid old start date errors

   		 IF rc.acd_type = 1 THEN
         	l_rev_component_tbl (i).start_effective_date := TRUNC(SYSDATE); --RK: Required for creating comp
			l_rev_component_tbl (i).disable_date := NULL;       
			 							  	 		---rc.disable_date;			
		 ELSE
--         	l_rev_component_tbl (i).start_effective_date := SYSDATE; --RK: Required for changing the comp
         	l_rev_component_tbl (i).start_effective_date := TRUNC(SYSDATE); --RK: ONLY FOR TESTING REMOVE THIS LINE

			l_rev_component_tbl (i).disable_date := --NULL;      --RK: Changed on 052507 
			 							  	 		rc.disable_date;					  
		 END IF;
		 
         l_rev_component_tbl (i).operation_sequence_number :=
                                                          rc.operation_seq_num;
                                                                  --1 ;--1; --
         l_rev_component_tbl (i).alternate_bom_code := NULL;
                                                --rc.alternate_bom_designator;
         l_rev_component_tbl (i).acd_type := rc.acd_type;              --1; --
         
		 IF rc.acd_type = 1 THEN
		 	l_rev_component_tbl(i).old_effectivity_date := NULL;
		 ELSE
		 	 l_rev_component_tbl(i).old_effectivity_date := rc.old_effectivity_date;
		 END IF;		 
         --l_rev_component_tbl(i).old_operation_sequence_number := 10; --rc.old_operation_seq_num;
         
		 l_rev_component_tbl (i).item_sequence_number := rc.item_num; --10; --
         l_rev_component_tbl (i).quantity_per_assembly :=
                                                         rc.component_quantity;
                                                                          --3;
         l_rev_component_tbl (i).component_item_name :=
                                                      rc.component_item_number;
                                                     --'900831'; --'00603315';
         l_rev_component_tbl (i).planning_percent := NULL;
                                                        -- rc.planning_factor;
--    l_rev_component_tbl(i).projected_yield :=
         l_rev_component_tbl (i).include_in_cost_rollup := NULL;
                                                  --rc.include_in_cost_rollup;
         l_rev_component_tbl (i).wip_supply_type := NULL;
                                                         --rc.wip_supply_type;
         l_rev_component_tbl (i).so_basis := NULL;              --rc.so_basis;
         l_rev_component_tbl (i).optional := NULL;              --rc.optional;
         l_rev_component_tbl (i).mutually_exclusive := NULL;
                                              --rc.mutually_exclusive_options;
         l_rev_component_tbl (i).check_atp := NULL;            --rc.check_atp;
         l_rev_component_tbl (i).shipping_allowed := NULL;
                                                        --rc.shipping_allowed;
         l_rev_component_tbl (i).required_to_ship := NULL;
                                                        --rc.required_to_ship;
         l_rev_component_tbl (i).required_for_revenue := NULL;
                                                    --rc.required_for_revenue;
         l_rev_component_tbl (i).include_on_ship_docs := NULL;
                                                    --rc.include_on_ship_docs;
         l_rev_component_tbl (i).quantity_related := NULL;
                                                        --rc.quantity_related;
         l_rev_component_tbl (i).supply_subinventory := NULL;
                                                     --rc.supply_subinventory;
         --l_rev_component_tbl(i).component_sequence_id := null; --rc.supply_subinventory;
         l_rev_component_tbl (i).location_name := NULL;    --rc.location_name;
         l_rev_component_tbl (i).minimum_allowed_quantity := NULL;
                                                            --rc.low_quantity;
         l_rev_component_tbl (i).maximum_allowed_quantity := NULL;
                                                           --rc.high_quantity;
         l_rev_component_tbl (i).transaction_type := rc.transaction_type; -- 'CREATE'
        -- l_revised_item_tbl (i).attribute_category := rc.attribute_category;			 
         l_rev_component_tbl (i).attribute1 := rc.attribute1;  --ggl_plm_bom_comp_int_id		
         l_rev_component_tbl (i).attribute2 := rc.attribute2;  --ECO# 
		 		 														   
         i := i + 1;
      END LOOP;

      Fnd_File.put_line (Fnd_File.LOG, 'Comes before sub_comps loop');
      -- Fetch substitute component records
      i := 1;

      FOR sc IN c_sub_comps
      LOOP
         l_sub_component_tbl (i).eco_name := sc.change_notice;
         l_sub_component_tbl (i).revised_item_name := sc.assembly_item_number;
         l_sub_component_tbl (i).start_effective_date := sc.effectivity_date;
         l_sub_component_tbl (i).new_revised_item_revision := NULL;
         l_sub_component_tbl (i).alternate_bom_code := NULL;
                                               --sc.alternate_bom_designator;
         l_sub_component_tbl (i).substitute_component_name :=
                                                    sc.substitute_comp_number;
         l_sub_component_tbl (i).acd_type := sc.acd_type;
         l_sub_component_tbl (i).operation_sequence_number :=
                                                         sc.operation_seq_num;
         l_sub_component_tbl (i).substitute_item_quantity :=
                                                  sc.substitute_item_quantity;
         l_sub_component_tbl (i).transaction_type := sc.transaction_type;
         l_sub_component_tbl (i).organization_code := sc.organization_code;
         l_sub_component_tbl (i).component_item_name := sc.component_item_number;
                                                    --'900831'; --'00603315';
        -- l_revised_item_tbl (i).attribute_category := sc.attribute_category;														
         l_sub_component_tbl (i).attribute1 := sc.attribute1; --ggl_plm_bom_comp_sub_int_id 	
         l_sub_component_tbl (i).attribute2 := sc.attribute2; --ECO# 
		 		 												
         i := i + 1;
      END LOOP;

/*
   -- Fetch reference designators
   i := 1;
   FOR rd IN c_ref_desgs
   LOOP
      l_ref_designator_tbl(i).eco_name := rd.change_notice;
      l_ref_designator_tbl(i).revised_item_name := rd.assembly_item_number;
      l_ref_designator_tbl(i).start_effective_date := rd.effectivity_date;
      l_ref_designator_tbl(i).new_revised_item_revision := null;
      l_ref_designator_tbl(i).operation_sequence_number := rd.operation_seq_num;
      l_ref_designator_tbl(i).alternate_bom_code := rd.alternate_bom_designator;
--    l_ref_designator_tbl(i).reference_designator_name :=
      l_ref_designator_tbl(i).acd_type := rd.acd_type;
      l_ref_designator_tbl(i).ref_designator_comment := rd.ref_designator_comment;
      l_ref_designator_tbl(i).new_reference_designator := rd.new_designator;
      l_ref_designator_tbl(i).transaction_type := rd.transaction_type;
   END LOOP;  */
      Eng_Globals.g_who_rec.user_id := Fnd_Global.user_id;
      Eng_Globals.g_who_rec.prog_appid := Fnd_Global.prog_appl_id;
      Eng_Globals.g_who_rec.prog_id := Fnd_Global.conc_program_id;
-- Eng_Globals.G_WHO_REC.prog_id:= NULL; --FND_GLOBAL.conc_program_id
-- Eng_Globals.G_WHO_REC.req_id := NULL; --FND_GLOBAL.conc_request_id
      Eng_Globals.g_who_rec.req_id := Fnd_Global.conc_request_id;
      Fnd_Global.apps_initialize
                             (user_id           => Eng_Globals.g_who_rec.user_id,
                              resp_id           => Fnd_Global.resp_id,
                              resp_appl_id      => Eng_Globals.g_who_rec.prog_appid
                             );
      -- Call the private API
      Fnd_File.put_line (Fnd_File.LOG, 'Comes before process_eco call');
      Eng_Eco_Pub.process_eco
                            (p_api_version_number        => 1.0,
                             p_init_msg_list             => FALSE,
                             x_return_status             => l_return_status,
                             x_msg_count                 => l_msg_count,
                             p_bo_identifier             => 'ECO',
                             p_eco_rec                   => l_eco_rec,
                             p_eco_revision_tbl          => l_eco_revision_tbl,
                             p_revised_item_tbl          => l_revised_item_tbl,
                             p_rev_component_tbl         => l_rev_component_tbl,
                             p_sub_component_tbl         => l_sub_component_tbl,
                             p_ref_designator_tbl        => l_ref_designator_tbl,
                             p_rev_operation_tbl         => l_rev_operation_tbl,
                             p_rev_op_resource_tbl       => l_rev_op_resource_tbl,
                             p_rev_sub_resource_tbl      => l_rev_sub_resource_tbl,
                             x_eco_rec                   => l_eco_rec,
                             x_eco_revision_tbl          => l_eco_revision_tbl,
                             x_revised_item_tbl          => l_revised_item_tbl,
                             x_rev_component_tbl         => l_rev_component_tbl,
                             x_sub_component_tbl         => l_sub_component_tbl,
                             x_ref_designator_tbl        => l_ref_designator_tbl,
                             x_rev_operation_tbl         => l_rev_operation_tbl,
                             x_rev_op_resource_tbl       => l_rev_op_resource_tbl,
                             x_rev_sub_resource_tbl      => l_rev_sub_resource_tbl,
                             p_debug                     => 'Y',
                             p_output_dir                => '/sqlcom/log/v115dlyp',
                             p_debug_filename            => 'ECO_BO_debug.log'
                            );
      --
      -- On return from the PUB API
      -- Perform all the error handler operations to verify that the
      -- error or warning are displayed and all the error table interface
      -- function provided to the user work correctly;
      --
      Error_Handler.get_message_list (x_message_list => l_error_table);

      FOR i IN 1 .. l_error_table.COUNT
      LOOP
         Fnd_File.put_line (Fnd_File.LOG,
                            'Entity Id: ' || l_error_table (i).entity_id
                           );
         Fnd_File.put_line (Fnd_File.LOG,
                            'Index: ' || l_error_table (i).entity_index
                           );
         Fnd_File.put_line (Fnd_File.LOG,
                            'Mesg: ' || l_error_table (i).MESSAGE_TEXT
                           );
         Fnd_File.put_line (Fnd_File.LOG,
                               'Total Messages: '
                            || TO_CHAR (i)
                            || l_error_table (i).MESSAGE_TEXT
                           );
      END LOOP;

      --Fnd_File.put_line ( Fnd_File.LOG,'Total Messages: ' || to_char(i)||l_error_table(i).message_text);
      l_msg_count := Error_Handler.get_message_count;
      Fnd_File.put_line (Fnd_File.LOG,
                         'Message Count Function: ' || TO_CHAR (l_msg_count)
                        );
      Error_Handler.dump_message_list;
      Error_Handler.get_entity_message (p_entity_id         => 'ECO',
                                        x_message_list      => l_error_table
                                       );
      Error_Handler.get_entity_message (p_entity_id         => 'REV',
                                        x_message_list      => l_error_table
                                       );
      Error_Handler.get_entity_message (p_entity_id         => 'RI',
                                        x_message_list      => l_error_table
                                       );
      Error_Handler.get_entity_message (p_entity_id         => 'RC',
                                        x_message_list      => l_error_table
                                       );
      Error_Handler.get_entity_message (p_entity_id         => 'SC',
                                        x_message_list      => l_error_table
                                       );
      Error_Handler.get_entity_message (p_entity_id         => 'RD',
                                        x_message_list      => l_error_table
                                       );
   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line (Fnd_File.LOG,
                            'Unknown Fatal error clean :' || v_error
                           );
   END import_eco;
   

   
--
--  This procedure updates the staging tables once the ECO/BOM gets created using attribute1 
--	of main tables 
-- 
   PROCEDURE ipost_update 
   			 (p_errbuf OUT VARCHAR2, 
			  p_errcode OUT NUMBER, 
      		  p_change_notice IN VARCHAR2)
   IS
      --
	  
 --     p_errcode number := 0;
	   
   	  v_bomi_id NUMBER;
   	  v_bom_id  NUMBER;
	  l_rec_found NUMBER;

      CURSOR c_bom_ecn_success 
      IS
        SELECT gbs.ROWID row_id,
        gbs.*
        FROM ggl_plm_bom_staging gbs
        WHERE gbs.process_flag IN ('IN_PROCESS','IN_INTERFACE') 
        AND gbs.change_notice = NVL(p_change_notice , gbs.change_notice)
        AND gbs.comp_acd_type is not null  --RK:012408 - Making sure that it post updates only real records!
        ORDER BY ggl_plm_bom_staging_id
        FOR UPDATE OF process_flag;

   BEGIN
   
      Fnd_File.put_line (Fnd_File.LOG, '');
	  Fnd_File.put_line (Fnd_File.LOG, '======================================================================');
	  Fnd_File.put_line (Fnd_File.LOG, '');
      Fnd_File.put_line (Fnd_File.LOG, '1) POST UPDATE:   Starting the <<IPOST_UPDATE>> process........');
	  Fnd_File.put_line (Fnd_File.LOG, '======================================================================');
 
	  --   
      FOR c_bcs_rec IN c_bom_ecn_success
      LOOP
	    --
	    Fnd_File.put_line (Fnd_File.LOG, ' ');
	    Fnd_File.put_line (Fnd_File.LOG, '   LOOP:      Processing Change Notice = ' ||c_bcs_rec.change_notice);
        --
		  l_rec_found := 0;
        --
        --
        IF (c_bcs_rec.substitute_component_number IS NOT NULL AND c_bcs_rec.sub_acd_type <> 3)
		-- IF c_bcs_rec.substitute_component_number IS NOT NULL THEN
		-- Do not check for substitutes that needs to be deleted along with comp disable as api disables only comps
		-- Fixed on 080107 so that it does not check bom_substitute_components for disable records 
		THEN
        --
    	 Fnd_File.put_line (Fnd_File.LOG, ' ');
    	 Fnd_File.put_line (Fnd_File.LOG, ' In IF Substitute is NOT null: '||c_bcs_rec.substitute_component_number|| 
						  ' l_rec_found: '||l_rec_found|| ' for comp_sub_id: '||c_bcs_rec.ggl_plm_bom_comp_sub_int_id);
    	  
          BEGIN
		  	 UPDATE xxmfg.ggl_plm_bom_staging 
                SET process_flag   = 'ERROR', --'RESOLVED', can be marked as RESOLVED!!
            	   	error_messg    = 'Component and Substitute Change together is not supported by ECO API...'||
								   	 'Implement the ECO Manually after verification'
              WHERE change_notice  = P_CHANGE_NOTICE --'RAVI004'
                AND comp_acd_type  = 2 
                AND sub_acd_type   = 2; 		  
		  EXCEPTION
		    WHEN OTHERS THEN NULL; -- Per PLM comp qty changes should not occur!! 
		  END;
		  	
    	  --
		  BEGIN
          	  SELECT 1 INTO l_rec_found
                FROM bom_substitute_components bic
               WHERE 1=1 
                 AND TRUNC(creation_date) = TRUNC(SYSDATE)
                 AND attribute1 = c_bcs_rec.ggl_plm_bom_comp_sub_int_id  
    		   	 AND ROWNUM = 1; 
		  EXCEPTION
		  	WHEN OTHERS THEN 
				 l_rec_found := 0;
				 NULL;
		  END;		
          --
		  IF l_rec_found = 1 THEN  --Sub comp found  
		  --
            BEGIN
            --
             UPDATE ggl_plm_bom_staging
                SET process_flag = 'PROCESSED',   
                    error_messg  = ''
              WHERE CURRENT OF c_bom_ecn_success;
			--  
              Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Updating status to PROCESSED from previous status = ' ||
					c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );       
            EXCEPTION
              WHEN OTHERS
              THEN
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update staging table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );  
				NULL;     
            END;			
        --
            BEGIN
               UPDATE ggl_plm_bom_int gb
                  SET process_flag = 'PROCESSED',
                      error_messg  = ''
                WHERE gb.ggl_plm_bom_int_id = c_bcs_rec.ggl_plm_bom_int_id
		          AND process_flag = 'IN_INTERFACE';
				  
   			   Fnd_File.put_line (Fnd_File.LOG, 'Updated Bom  Int to Processed');
            END;
		--			
            BEGIN
               UPDATE ggl_plm_bom_comp_int gc
                  SET process_flag = 'PROCESSED',
                      error_messg  = ''
                WHERE gc.ggl_plm_bom_comp_int_id = c_bcs_rec.ggl_plm_bom_comp_int_id
				  AND process_flag = 'IN_INTERFACE';
   			 
   			          Fnd_File.put_line (Fnd_File.LOG, 'Updated Bom Comp Int to Processed');
            END;
   		--
            BEGIN
               UPDATE ggl_plm_bom_comp_sub_int gb
                  SET process_flag = 'PROCESSED',
                      error_messg  = ''				  
                WHERE gb.ggl_plm_bom_comp_sub_int_id =  c_bcs_rec.ggl_plm_bom_comp_sub_int_id
                  AND process_flag = 'IN_INTERFACE';
   			   Fnd_File.put_line (Fnd_File.LOG, 'Updated Bom Comp Sub Int to Processed');
            END;
		  ELSE  -- IF l_rec_found = 1 THEN  --Sub comp found
		   		--if sub comp not found write error record and mark the staging record as ERROR 
			--			  				
            BEGIN
            --
	           e_transaction_id      := c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := c_bcs_rec.ggl_plm_bom_comp_sub_int_id;
               e_error_desc  := 'Post Update Could not find Sub component '||c_bcs_rec.substitute_component_number
			   				 	||' to update the record as ERROR';
               e_sugg_action := 'Please check the attribute value in bom_substitute_components for this sub_comp_id';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );		

            	UPDATE ggl_plm_bom_staging
                   SET process_flag = 'ERROR',   
                   	   error_messg  = e_error_desc||'; '||error_messg
              	 WHERE CURRENT OF c_bom_ecn_success;
			    --  
              		Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Updating status to ERROR from previous status = ' ||
					c_bcs_rec.change_notice||' ggl_plm_bom_comp_sub_int_id: '||c_bcs_rec.ggl_plm_bom_comp_sub_int_id );       
            EXCEPTION
                  WHEN OTHERS THEN
                	Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update staging table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_sub_int_id: '||c_bcs_rec.ggl_plm_bom_comp_sub_int_id );  
				  NULL;     
            END;													     
		    --
		  END IF; -- IF l_rec_found = 1 THEN  --Sub comp found
		  
        --
		ELSIF c_bcs_rec.component_item_number IS NOT NULL THEN
        --
    	 Fnd_File.put_line (Fnd_File.LOG, ' ');
    	 Fnd_File.put_line (Fnd_File.LOG, '   In IF Component is NOT null: '||c_bcs_rec.component_item_number|| 
							  ' l_rec_found: '||l_rec_found|| ' for comp_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id);
          --
		  BEGIN
		    --IF c_bcs_rec.comp_acd_type = 3 THEN  -- For disable look in ENG_REVISED_COMPS_INT 
          	SELECT 
			 (SELECT 1 --INTO l_rec_found
          	  FROM   eng_revised_components_v erc 
          	  WHERE  1=1 
          	 	 AND attribute1 = c_bcs_rec.ggl_plm_bom_comp_int_id
		  		 AND ROWNUM = 1 				
			  UNION
          	  SELECT 1 --INTO l_rec_found
          	  FROM   bom_inventory_components bic
          	  WHERE  1=1 
          	 	 AND attribute1 = c_bcs_rec.ggl_plm_bom_comp_int_id
		  		 AND ROWNUM = 1
				 ) INTO l_rec_found
			FROM DUAL;  
			--END IF;				
		  EXCEPTION
		    WHEN OTHERS THEN --Do Nothing..
   			   Fnd_File.put_line (Fnd_File.LOG, 'Error: Could not find comp record in <<Post Update>> for comp_id: '
			   					 				||c_bcs_rec.ggl_plm_bom_comp_int_id);		
			   l_rec_found := 0;																					
		  END;
		  
		  
	      IF l_rec_found = 1 THEN  --Comp found 
		  --
            BEGIN
            --
             UPDATE ggl_plm_bom_staging
                SET process_flag = 'PROCESSED',   
                    error_messg  = ''
              WHERE CURRENT OF c_bom_ecn_success;
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Updating status to PROCESSED from previous status = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_sub_int_id );       
            EXCEPTION
              WHEN OTHERS
              THEN
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update staging table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );
				NULL;       
            END;

        --
	    --Updating the _int for all org related records 
   	    --(only common has comp, so we find only comm bom_id, not the other orgs to update)
            BEGIN
               UPDATE ggl_plm_bom_int gb
                  SET process_flag = 'PROCESSED',
                      error_messg  = ''
                WHERE --gb.ggl_plm_bom_int_id = c_bcs_rec.ggl_plm_bom_int_id
					  gb.ITEM_NUMBER   = c_bcs_rec.item_number
		  		  AND gb.change_notice = c_bcs_rec.change_notice
		  		  AND process_flag = 'IN_INTERFACE';
   		   			Fnd_File.put_line (Fnd_File.LOG, 'Updated Bom  Int to Processed');
            EXCEPTION
              WHEN OTHERS
              THEN
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update BOM_INT table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_int_id: '||c_bcs_rec.ggl_plm_bom_int_id );
				NULL;       
            END;

	--			
            BEGIN
               UPDATE ggl_plm_bom_comp_int gc
                  SET process_flag = 'PROCESSED',
                      error_messg  = ''
                WHERE gc.ggl_plm_bom_comp_int_id = c_bcs_rec.ggl_plm_bom_comp_int_id
				  AND process_flag = 'IN_INTERFACE';
   			          Fnd_File.put_line (Fnd_File.LOG, 'Updated Bom Comp Int to Processed');
            EXCEPTION
              WHEN OTHERS
              THEN
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update BOM_INT table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );
				NULL;       
            END;
			--
		  ELSE --IF l_rec_found = 1 THEN  --Comp found 
		   		--if comp not found write error record and mark the staging record as ERROR 
			--			  				
            BEGIN
            --
               e_transaction_id      := c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := c_bcs_rec.ggl_plm_bom_comp_int_id;
               e_error_desc  := 'Post Update Could not find component '||c_bcs_rec.component_item_number
			   				 	||' to update the record as ERROR';
               e_sugg_action := 'Please check the attribute value in bom_inventory_component for this comp_id';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );	

            	UPDATE ggl_plm_bom_staging
                   SET process_flag = 'ERROR',   
                   	   error_messg  = e_error_desc||'; '||error_messg
              	 WHERE CURRENT OF c_bom_ecn_success;
			    --  
              		Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Updating status to ERROR from previous status = ' ||
					c_bcs_rec.change_notice||' ggl_plm_bom_comp_sub_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );       
            EXCEPTION
                  WHEN OTHERS THEN
                	Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Unable to update staging table = ' ||
						c_bcs_rec.change_notice||' ggl_plm_bom_comp_sub_int_id: '||c_bcs_rec.ggl_plm_bom_comp_int_id );  
				  NULL;     
            END;													     
   		  --
		  END IF; --IF l_rec_found = 1 THEN  --Comp found
		--   
		--
        ELSE --This should never be the case! 
        Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     In Else...Both Comp or sub comp values are null for = '|| 
                            c_bcs_rec.change_notice||' ggl_plm_bom_comp_int_id: '||c_bcs_rec.ggl_plm_bom_comp_sub_int_id);
			NULL; 
        END IF; -- comp or sub comp record
		
      END LOOP;  
	  
      COMMIT;
      Fnd_File.put_line (Fnd_File.LOG, 'End GGL_PLM_BOM_INTERFACE.IPOST_UPDATE');
				
   EXCEPTION
      WHEN OTHERS
      THEN
         Fnd_File.put_line
                   (Fnd_File.LOG,
                       'GGL_PLM_BOM_INTERFACE.IPOST_UPDATE - WHEN OTHERS EXCEPTION '
                    || SQLERRM
                   );
               e_transaction_id      := p_change_notice; --c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               e_error_desc  := 'Post Update WHEN OTHERS Exception for ECN# '||p_change_notice
			   					||'sqlerrm: '||substr(sqlerrm,1,500);
               e_sugg_action := 'Please check ipost_update code and fix the error...';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );				   
   END ipost_update;

   

   
   PROCEDURE check_revision (
      p_item              IN       VARCHAR2,
      p_organization_id   IN       NUMBER,
      p_revision          OUT      VARCHAR2
   )
   AS
   BEGIN
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS: <<CHECK_REVISION>> Started...');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
   	  --
      p_revision := '-1';

      BEGIN
         SELECT mir.revision
           INTO p_revision
           FROM mtl_system_items_b msi, mtl_item_revisions_b mir
          WHERE msi.segment1 = p_item
            AND msi.organization_id = p_organization_id
            AND mir.inventory_item_id = msi.inventory_item_id
            AND mir.organization_id = msi.organization_id
            AND msi.bom_enabled_flag = 'Y'
            AND mir.effectivity_date =
                   (SELECT MAX (mir.effectivity_date)
                      FROM mtl_system_items_b msi, mtl_item_revisions_b mir
                     WHERE msi.segment1 = p_item
                       AND msi.organization_id = p_organization_id
                       AND mir.inventory_item_id = msi.inventory_item_id
                       AND mir.organization_id = msi.organization_id
                       AND msi.bom_enabled_flag = 'Y'                             /*
                                                     and mir.effectivity_date < sysdate*/
						);
			--			
			Fnd_File.put_line (Fnd_File.LOG, 'SUCCESS: <<CHECK_REVISION>> Revision Found :'||p_revision);
      EXCEPTION
         WHEN OTHERS
         THEN
            p_revision := '-1';
            v_error := SUBSTR (SQLERRM, 1, 500);
            Fnd_File.put_line
               (Fnd_File.LOG,
                   'ERROR: <<CHECK_REVISION>> Unable to Find Effectivity Date For Revision error in check_revision :'
                || v_error
               );
      END;

   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line (Fnd_File.LOG,
                               'ERROR: <<CHECK_REVISION>> - In Others - Unknown Fatal error in check_revision :'
                            || v_error
                           );
   END check_revision;
   
   
-- ========================================================================================
--
-- This procedure is used to validate records
--
--RK: If BOM exists for the Assembly record then it marks for UPDATE else CREATE --
--	  in _INT table for further processing
-- ========================================================================================
      
  
   PROCEDURE ivalidate_bom_recs (
      p_org_code              VARCHAR2,
      p_common_org_sequence   NUMBER,
	  p_change_notice		  VARCHAR2
   )
   AS
   
      --
	  -- Selects all the records from the interface table ggl_plm_bom_int 
	  -- with process_flag in NEW, ERROR 
	  --
      CURSOR c_bom
      IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_int gb
          WHERE organization_code = p_org_code
            AND process_flag IN ('NEW', 'ERROR')
		    AND change_notice 	  = p_change_notice			
			--AND change_notice = 00586
		  ORDER BY Change_notice;

      --
      process_next_bom                 EXCEPTION;
      c_bom_rec                        c_bom%ROWTYPE;
      --
      v_org_id                         mtl_parameters.master_organization_id%TYPE;
      v_total_rec                      NUMBER                             := 0;
      v_proc_rec                       NUMBER                             := 0;
      v_err_rec                        NUMBER                             := 0;
      dummy                            VARCHAR2 (1);
      v_dummy                          NUMBER;
      v_alternate_count                NUMBER;
      v_revision                       VARCHAR2 (3);
      zero_rows                        EXCEPTION;
	  --
      v_bom_enabled_flag               mtl_system_items_b.bom_enabled_flag%TYPE;
      v_bill_sequence_id               NUMBER;
      v_transaction_type               VARCHAR2 (50);
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'GGL_PLM_BOM_INT';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
      e_err_ret_code                   NUMBER;
	  --
      error_on_insert_in_error_table   EXCEPTION;
      error_on_delete_in_error_table   EXCEPTION;
	  --
	  
   BEGIN
      --
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '  ------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, '  PROCESS:   Start Validating Records in <<IVALIDATE_BOM_RECS>> process...');
	  Fnd_File.put_line (Fnd_File.LOG, '  ------------------------------------------------------------------------- ');
 	  Fnd_File.put_line (Fnd_File.LOG, ' ');
      Fnd_File.put_line (Fnd_File.LOG, '  PROCESS:   Parameters are p_org_code:'||p_org_code
	  								   ||' p_common_org_seq:'||p_common_org_sequence);
      FOR c_bom_rec IN c_bom 
      LOOP
         BEGIN                                                  --loop  
            
	             Fnd_File.put_line (Fnd_File.LOG,
                                    'ivalidate_bom_rec: For item :'||c_bom_rec.item_number
									||' with org : '||c_bom_rec.organization_code||' org id :'||c_bom_rec.organization_id
									||' with BOM Revision: '||c_bom_rec.revision
                                    );				
			
            IF c_bom_rec.item_number IS NULL
            THEN                                                --item_number   
               e_error_desc  := 'Assembly Item # is null.';
               e_sugg_action := 'Please enter Assembly Item #.';
			   Fnd_File.put_line (Fnd_File.LOG, '   ERROR:   Assembly Item Num is Null '
			                                 ||c_bom_rec.item_number
											 ||' Change Notice = '
											 ||c_bom_rec.change_notice);
            --             raise process_next_bom;  
            ELSE
			   --
               v_transaction_type := 'CREATE'; -- In case bill sequence Id is null 
               v_bom_enabled_flag := '';

			   
			   -- We are doing this for particular org?  
               BEGIN
                  SELECT inventory_item_id, 
				         bom_enabled_flag
                    INTO c_bom_rec.assembly_item_id, 
					     v_bom_enabled_flag
                    FROM mtl_system_items msi
                   WHERE organization_id = c_bom_rec.organization_id
                     AND msi.segment1    = c_bom_rec.item_number;
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     c_bom_rec.assembly_item_id := '';
                     v_bom_enabled_flag         := '';
               END;

			   
			   
			   
               IF c_bom_rec.assembly_item_id IS NULL
               THEN
                  e_error_desc :=
                        e_error_desc
                     || ' Invalid Assembly Item For Organization '
                     || p_org_code; 
                  e_sugg_action := e_sugg_action || ' Enter Valid Component.';
               ELSIF v_bom_enabled_flag IS NULL
               THEN
                  e_error_desc :=
                        e_error_desc
                     || ' BOM Allowed Not Enabled For Assembly Item in Organization '
                     || p_org_code;   
                  e_sugg_action :=
                          e_sugg_action || ' Enable BOM Allowed For Assembly.';
               END IF;
			   
			   

			   --
			   --RK: If BOM exists for the Assembly record then it marks for UPDATE
			   --			   

               IF c_bom_rec.assembly_item_id IS NOT NULL
               THEN
                  v_dummy := '';

                  BEGIN
				     --
                     SELECT bill_sequence_id
                       INTO v_bill_sequence_id
                       FROM bom_bill_of_materials bbm
                      WHERE bbm.organization_id  = c_bom_rec.organization_id
                        AND bbm.assembly_item_id = c_bom_rec.assembly_item_id
                        AND ROWNUM = 1;
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_bill_sequence_id := '';
                  END;
				   
                  IF v_bill_sequence_id IS NOT NULL
                  THEN
                     v_transaction_type := 'UPDATE';
                     --      e_error_desc := e_error_desc || ' BOM already exists For Organization '||p_org_code;
                     --      e_sugg_action := e_sugg_action || ' Update BOM.';
        	  		 Fnd_File.put_line (Fnd_File.LOG, ' ');
              		 Fnd_File.put_line (Fnd_File.LOG, '  PROCESS:   Marked for Update; BOM exists with bill_seq_id:'||v_bill_sequence_id);
                  END IF;
               END IF;

            
			
			   -- Why are we doing this ?  
               IF     c_bom_rec.assembly_type IS NOT NULL
                  AND c_bom_rec.assembly_type NOT IN (1, 2)
               THEN
                  e_error_desc := e_error_desc || ' Invalid Assembly Type Value';
               END IF;

			   
		   
			   --
			   -- This is where it is faling mostly 
			   --
               IF c_bom_rec.revision IS NULL
               THEN
                  e_error_desc := e_error_desc || ' BOM Revision Number is null';
               ELSE
			      --
        	  	  Fnd_File.put_line (Fnd_File.LOG, ' ');
                  Fnd_File.put_line (Fnd_File.LOG,
                                     'Before validate_bom_recs check_revision- item_number: '||c_bom_rec.item_number
									 ||' organization_id: '||c_bom_rec.organization_id
                                    );
                  v_revision := '-1';
				  --
                  check_revision (c_bom_rec.item_number,
                                  c_bom_rec.organization_id,
                                  v_revision
                                 );

	             Fnd_File.put_line (Fnd_File.LOG,
                                    'After validate_bom_recs check_revision- item_number: '||c_bom_rec.item_number
									 ||' organization_id: '||c_bom_rec.organization_id|| ' result revision: '||v_revision
                                     );
							
	             Fnd_File.put_line (Fnd_File.LOG,
                                    'After validate_bom_recs check_revision- BOM Revision: '||c_bom_rec.revision
                                    );
       	  		 Fnd_File.put_line (Fnd_File.LOG, ' ');
																		 
								 
                  IF c_bom_rec.revision != v_revision
                  THEN
                     e_error_desc :=
                           e_error_desc
                        || ' Invalid Revision BOM '
                        || c_bom_rec.revision
                        || '. Effective Revision is '
                        || v_revision;
              		 Fnd_File.put_line (Fnd_File.LOG, '  PROCESS: Item Rev: '||v_revision||' does not match with BOM Rev:'||c_bom_rec.revision);
        	  		 Fnd_File.put_line (Fnd_File.LOG, '  --------------------------------------------------------------------------------------- ');
        	  		 Fnd_File.put_line (Fnd_File.LOG, ' ');
                  END IF;
               END IF;
			   

			   -- In case of any error then 
               IF e_error_desc IS NOT NULL
               THEN
                  RAISE process_next_bom;
               END IF;
            END IF;                                              --item_number  

           
		    --RK:08072007 - Validate and get rid of this logic in the future 
            IF c_bom_rec.process_flag = 'ERROR'
            THEN
               e_transaction_id      := c_bom_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               Ggl_Inv_Txn_Interface.ggl_inv_error_delete
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_err_ret_code
                                                      );

               IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_delete_in_error_table;
               END IF;
            END IF;
	
			
            IF v_transaction_type = 'UPDATE' AND p_common_org_sequence = 2
            THEN                                                      --DELETE   
               Fnd_File.put_line (Fnd_File.LOG,
                                  'Delete Common Org record as NO ECO needed'
                                 );

               BEGIN
                  DELETE  ggl_plm_bom_int gb
                   WHERE  gb.ROWID = c_bom_rec.row_id;
               END;
			   
			   
            ELSE                                                      --DELETE 
               Fnd_File.put_line (Fnd_File.LOG, 'Update Process Flag to In_process');
               --
               BEGIN
			      --
                  UPDATE ggl_plm_bom_int gb
                     SET error_messg      = NULL,
                         process_flag     = 'IN_PROCESS',
                         assembly_item_id = c_bom_rec.assembly_item_id,
                         transaction_type = v_transaction_type,
                         bill_sequence_id = v_bill_sequence_id,
                         created_by       = v_user_id,
                         creation_date    = SYSDATE,
                         last_updated_by  = v_user_id,
                         last_update_date = SYSDATE
                   WHERE gb.ROWID = c_bom_rec.row_id;
				   
				   
                  Fnd_File.put_line (Fnd_File.LOG, 'Update Process Flag to NEW?');
                  --Change Process Flag for Common BOMs also   why ?? 
                  UPDATE ggl_plm_bom_int gb
                     SET error_messg      = NULL,
                         process_flag     = 'NEW',
                         assembly_item_id = c_bom_rec.assembly_item_id,
                         created_by       = v_user_id,
                         creation_date    = SYSDATE,
                         last_updated_by  = v_user_id,
                         last_update_date = SYSDATE
                   WHERE c_bom_rec.item_number       IN (item_number, common_item_number_bom)
                     AND c_bom_rec.organization_code IN (organization_code, common_org)
                     AND process_flag = 'ERROR';
					 
               END;
            END IF;
         EXCEPTION
		    --
            WHEN process_next_bom
            THEN
               e_transaction_id      := c_bom_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );
               e_error_desc  := '';
               e_sugg_action := '';

               IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
               END IF;

			   
               BEGIN                                               --exception  
                  Fnd_File.put_line (Fnd_File.LOG, 'Update Process Flag to NEW?');
                  UPDATE ggl_plm_bom_int sb
                     SET process_flag     = 'ERROR',
                         error_messg      = e_error_desc,
                         created_by       = v_user_id,
                         creation_date    = SYSDATE,
                         last_updated_by  = v_user_id,
                         last_update_date = SYSDATE  --RS , actual_error = 'T'    
                   WHERE sb.ROWID = c_bom_rec.row_id;

				   
                  --Error out Common BOMs      
                  UPDATE ggl_plm_bom_int
                     SET process_flag = 'ERROR',
                         error_messg = 'Error In Other BOM '||c_bom_rec.item_number||' Org '||c_bom_rec.organization_code||' Validation',
                         created_by = v_user_id,
                         creation_date = SYSDATE,
                         last_updated_by = v_user_id,
                         last_update_date = SYSDATE
                   WHERE c_bom_rec.item_number       IN (item_number, common_item_number_bom)
                     AND c_bom_rec.organization_code IN (organization_code, common_org)
                     AND process_flag                IN ('NEW', 'IN_PROCESS')
                     AND ROWID != c_bom_rec.row_id;

                 END;   --exception                                                
         END;                                                                            
      END LOOP;     --loop 
	  
   EXCEPTION
      WHEN error_on_insert_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATE_BOM_RECS UNABLE TO INSERT RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN error_on_delete_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATE_BOM_RECS UNABLE TO DELETE RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN OTHERS
      THEN
         Fnd_File.put_line
             (Fnd_File.LOG,
                 'GGL_PLM_BOM_INTERFACE.IVALIDATE_BOM_RECS OTHERS EXCEPTION '
              || SQLERRM
             );

   END ivalidate_bom_recs;

   
-- ========================================================================================
--
-- This procedure is used to validate records
--
--RK: If BOM exists for the component record then it marks for UPDATE else CREATE --
--	  in _INT table for further processing 
--
-- ========================================================================================
      

   PROCEDURE ivalidate_inv_comp_recs (p_org_code VARCHAR2, p_change_notice VARCHAR2)
   IS
      --
	  --
	  --
      CURSOR c_inv_comp
      IS
         SELECT gic.*, gic.ROWID row_id
           FROM ggl_plm_bom_comp_int gic
          WHERE organization_code = p_org_code
            AND process_flag IN ('NEW', 'ERROR')
			AND change_notice 	  = p_change_notice
		  ORDER BY Change_notice;

    
      process_next_bom                 EXCEPTION;
      c_inv_comp_rec                   c_inv_comp%ROWTYPE;
      v_org_id                         mtl_parameters.master_organization_id%TYPE;
      v_bom_enabled_flag               mtl_system_items.bom_enabled_flag%TYPE;
      v_total_rec                      NUMBER                             := 0;
      v_proc_rec                       NUMBER                             := 0;
      v_err_rec                        NUMBER                             := 0;
	  --
      v_component_sequence_id          NUMBER;
      v_transaction_type               VARCHAR2 (50);
      v_revision                       VARCHAR2 (3);
      v_item_num                       NUMBER;
      v_operation_seq_num              NUMBER;
	  --
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'PLM_BOM_GGL_PLM_BOM_COMP_INT';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
      e_err_ret_code                   NUMBER;
	  --
      error_on_insert_in_error_table   EXCEPTION;
      error_on_delete_in_error_table   EXCEPTION;
	  --
	  
   BEGIN
  		 Fnd_File.put_line (Fnd_File.LOG, ' ');
   		 Fnd_File.put_line (Fnd_File.LOG, '  --------------------------------------------------------------------------------------- ');
   		 Fnd_File.put_line (Fnd_File.LOG, '  PROCESS: Starting the <<IVALIDATE_INV_COMP_RECS>> process...');
   		 Fnd_File.put_line (Fnd_File.LOG, '  --------------------------------------------------------------------------------------- ');
  
      OPEN c_inv_comp;
       LOOP

         BEGIN
            FETCH c_inv_comp
             INTO c_inv_comp_rec;

            Fnd_File.put_line (Fnd_File.LOG,
                                  c_inv_comp_rec.item_number
                               || '-'
                               || c_inv_comp_rec.component_item_number
                               || '-'
                               || c_inv_comp_rec.organization_code
                              );
            EXIT WHEN c_inv_comp%NOTFOUND;

			
            IF c_inv_comp_rec.item_number IS NULL
            THEN
               e_error_desc  := e_error_desc  || ' Assembly is null.';
               e_sugg_action := e_sugg_action || ' Enter Assembly.';
            END IF;

			
            IF c_inv_comp_rec.component_item_number IS NULL
            THEN
               e_error_desc  := e_error_desc  || ' Component is null.';
               e_sugg_action := e_sugg_action || ' Enter Component.';
            END IF;

			--
            v_transaction_type := 'CREATE';
            v_bom_enabled_flag := '';
            v_item_num 		   := 10;
                    --For Add it should be 1 and Change Delete anthing is fine   
            v_operation_seq_num := c_inv_comp_rec.operation_seq_num;
            v_component_sequence_id := '';

			
            BEGIN
               SELECT inventory_item_id, 
			          bom_enabled_flag
                 INTO c_inv_comp_rec.component_item_id, 
				      v_bom_enabled_flag
                 FROM mtl_system_items msi
                WHERE organization_id = c_inv_comp_rec.organization_id
                  AND msi.segment1 = c_inv_comp_rec.component_item_number;
            EXCEPTION
               WHEN OTHERS
               THEN
                  c_inv_comp_rec.component_item_id := '';
                  v_bom_enabled_flag               := '';
            END;

			
            BEGIN
			   --
               SELECT inventory_item_id
                 INTO c_inv_comp_rec.assembly_item_id
                 FROM mtl_system_items msi
                WHERE organization_id = c_inv_comp_rec.organization_id
                  AND msi.segment1 = c_inv_comp_rec.item_number;
            EXCEPTION
               WHEN OTHERS
               THEN
                  c_inv_comp_rec.assembly_item_id := '';
            END;


            IF c_inv_comp_rec.component_item_id IS NULL
            THEN
               e_error_desc :=
                     e_error_desc
                  || ' Invalid Component For Organization '
                  || p_org_code;     
               e_sugg_action := e_sugg_action || ' Enter Valid Component.';
            ELSIF v_bom_enabled_flag IS NULL
            THEN
               e_error_desc :=
                     e_error_desc
                  || ' BOM Allowed Disabled For Component in Organization '
                  || p_org_code;     
               e_sugg_action :=
                         e_sugg_action || ' Enable BOM Allowed For Component.';
            END IF;
 
  
            IF c_inv_comp_rec.component_revision IS NULL  -- why are we checking revision 
            THEN
               e_error_desc := e_error_desc || ' Component Revision Number is null';
            ELSE

	             Fnd_File.put_line (Fnd_File.LOG,
                                    'Before validate_inv_comp_recs check_revision- comp_number: '||c_inv_comp_rec.component_item_number
									 ||' organization_id: '||c_inv_comp_rec.organization_id
									 || ' Comp revision is : '||c_inv_comp_rec.component_revision
                                    );
									
               v_revision := '-1';
			   --
               check_revision (c_inv_comp_rec.component_item_number,
                               c_inv_comp_rec.organization_id,
                               v_revision
                              );
							  
	             Fnd_File.put_line (Fnd_File.LOG,
                                    'After validate_bom_recs check_revision- item_number: '||c_inv_comp_rec.component_item_number
									 ||' organization_id: '||c_inv_comp_rec.organization_id
									 || ' result revision: '||v_revision
                                    );
							  
				-- ramesh what is the rule to check revision 			  
               IF c_inv_comp_rec.component_revision != v_revision
               THEN
                  e_error_desc :=
                        e_error_desc
                     || ' Invalid Revision for Component: '||c_inv_comp_rec.component_item_number|| ' : '
                     || c_inv_comp_rec.component_revision
                     || '. Effective Revision is: '
                     || v_revision;
               END IF;
            END IF;
 
			--
			--RK: If assembly and comp exists then check for BOM in that ORG; 
			--	  If BOM found then mark the record for UPDATE instead of CREATE for new ECO/BOM 
			--		  
            IF     c_inv_comp_rec.component_item_id IS NOT NULL
               AND c_inv_comp_rec.assembly_item_id  IS NOT NULL
            THEN
               BEGIN
                  SELECT component_sequence_id, 
				         item_num,
                         bic.operation_seq_num, 
						 'UPDATE'
                    INTO v_component_sequence_id, 
					     v_item_num,
                         v_operation_seq_num, 
						 v_transaction_type
                    FROM bom_inventory_components bic,
                         bom_bill_of_materials bbm
                   WHERE bbm.organization_id   = c_inv_comp_rec.organization_id
                     AND bbm.assembly_item_id  = c_inv_comp_rec.assembly_item_id
                     AND bic.bill_sequence_id  = bbm.bill_sequence_id
                     AND bic.component_item_id = c_inv_comp_rec.component_item_id
                     AND c_inv_comp_rec.effectivity_date
                            BETWEEN bic.effectivity_date AND NVL (bic.disable_date,
                                         TRUNC (SYSDATE) + 1 );                     
                     --  and     bic.operation_seq_num = NVL(c_inv_comp_rec.operation_seq_num,10)
--                     AND TRUNC (c_inv_comp_rec.effectivity_date)  --RK:01232008 -
--                            BETWEEN TRUNC (bic.effectivity_date)
--                                AND NVL (TRUNC (bic.disable_date),
--                                         TRUNC (SYSDATE) + 1
--										 );
					--					
            		Fnd_File.put_line (Fnd_File.LOG,
                                  'COMP UPDATE '
                               || c_inv_comp_rec.organization_id
                               || ' * '
                               || c_inv_comp_rec.assembly_item_id
                               || ' * '
                               || c_inv_comp_rec.component_item_id
                               || ' * '
                               || c_inv_comp_rec.operation_seq_num
                               || ' * '
                               || c_inv_comp_rec.effectivity_date
                              );
										
					--					
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     Fnd_File.put_line (Fnd_File.LOG,
                                           'COMP UPDATE exception '
                                        || c_inv_comp_rec.organization_id
                                        || ' * '
                                        || c_inv_comp_rec.assembly_item_id
                                        || ' * '
                                        || c_inv_comp_rec.component_item_id
                                        || ' * '
                                        || c_inv_comp_rec.operation_seq_num
                                        || ' * '
                                        || c_inv_comp_rec.effectivity_date
                                       );
               END;

            END IF;


            IF e_error_desc IS NOT NULL
            THEN
               RAISE process_next_bom; --???Why process next BOM??? why not error out whole ECO????
			   
            ELSE
               IF c_inv_comp_rec.process_flag = 'ERROR'
               THEN
                  e_transaction_id := c_inv_comp_rec.ggl_plm_bom_int_id;
                  e_transaction_line_id :=
                                       c_inv_comp_rec.ggl_plm_bom_comp_int_id;
                  Ggl_Inv_Txn_Interface.ggl_inv_error_delete
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_err_ret_code
                                                      );

                  IF e_err_ret_code <> 0
                  THEN
                     RAISE error_on_delete_in_error_table;
                  END IF;
               END IF;

			--   
			--RK: If BOM found in above step then mark the record for UPDATE --
			-- 	  instead of CREATE (for new ECO/BOM) 
			--		  
			   
               BEGIN
			      --
                  UPDATE ggl_plm_bom_comp_int gic
                     SET error_messg       = NULL,
                         process_flag      = 'IN_PROCESS',
                         transaction_type  = v_transaction_type,
                         item_num          = v_item_num,
                         component_sequence_id = v_component_sequence_id,
                         --  organization_id = c_inv_comp_rec.organization_id,
                         assembly_item_id  = c_inv_comp_rec.assembly_item_id,
                         component_item_id = c_inv_comp_rec.component_item_id,
                         operation_seq_num = v_operation_seq_num,--c_inv_comp_rec.operation_seq_num,
                         created_by        = v_user_id,
                         creation_date     = SYSDATE,
                         last_updated_by   = v_user_id,
                         last_update_date  = SYSDATE
                   WHERE gic.ROWID = c_inv_comp_rec.row_id;

                  v_proc_rec := v_proc_rec + 1;
               END;
            END IF;

            v_total_rec := v_total_rec + 1.0;
			--
         EXCEPTION
            WHEN process_next_bom
            THEN
			   --
               e_transaction_id := c_inv_comp_rec.ggl_plm_bom_int_id;
               e_transaction_line_id :=
                                       c_inv_comp_rec.ggl_plm_bom_comp_int_id;
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );

				--
				-- RK: Update all ECO records with the status as 'ERROR'  
				-- 
				  
            	   Fnd_File.put_line (Fnd_File.LOG, '<<iValidate Inv Comp>> At least one Invalid record in ECO#:... '
                               || p_change_notice||'; Updated the ECO as VALIDATION_ERROR...'
                              );
				--			  				
				  iupdate_eco (p_change_notice, 'VALIDATION_ERROR', e_error_desc||' ; '||e_sugg_action);
				  COMMIT;														  
				--									  
               e_error_desc := '';
               e_sugg_action := '';

               IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
               END IF;

               BEGIN
			      --
				  --RK: 06282007 - Added to fix the IN_PROCESS status issue; should be shown as ERROR 
				  --
				  e_error_desc := ' At least one Invalid record in ECO#:... '
                               || p_change_notice||'; Please check the GGL_INV_ERROR table or log for iCLEANUP...';
				  e_sugg_action := 'Fix the Issue and reprocess the change notice';
				  
                  UPDATE ggl_plm_bom_staging
                  SET  process_flag 		 = 'ERROR' , 
				  	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                  WHERE  change_notice       = p_change_notice
				    AND  item_number 		 = item_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');				  
				  
                  UPDATE ggl_plm_bom_comp_int
                     SET error_messg = e_error_desc,
                         process_flag = 'ERROR',
                         created_by = v_user_id,
                         creation_date = SYSDATE,
                         last_updated_by = v_user_id,
                         last_update_date = SYSDATE
                   WHERE ROWID = c_inv_comp_rec.row_id;

				  --
                  UPDATE ggl_plm_bom_comp_int
                     SET error_messg =
                               'Validation Error In Other Component <<'
                            || c_inv_comp_rec.component_item_number
                            || '>> for Org <<'
                            || c_inv_comp_rec.organization_code
                            || '>>',
                         process_flag     = 'ERROR',
                         created_by       = v_user_id,
                         creation_date    = SYSDATE,
                         last_updated_by  = v_user_id,
                         last_update_date = SYSDATE
                   WHERE ROWID != c_inv_comp_rec.row_id
                     AND c_inv_comp_rec.item_number = item_number
                     AND c_inv_comp_rec.organization_code = organization_code
                     AND process_flag IN ('NEW', 'IN_PROCESS');

               END;
         END;
      END LOOP; --     CLOSE c_inv_comp;
	  --
      v_err_rec := v_total_rec - v_proc_rec;
	  --
   EXCEPTION
      WHEN error_on_insert_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATE_INV_COMP_RECS UNABLE TO INSERT RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN error_on_delete_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATE_INV_COMP_RECS UNABLE TO DELETE RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN OTHERS
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATE_INV_COMP_RECS OTHERS EXCEPTION '
             || SQLERRM
            );
 
   END ivalidate_inv_comp_recs;




-- ===========================================================================================
--
-- This procedure is used to validate records in the staging table with process_flag = 'CLEAN 
--
--RK: If BOM exists for the component record then it marks for UPDATE else CREATE --
--	  in _INT table for further processing
--
--
-- ==========================================================================================

   
   
   
   PROCEDURE ivalidate_sub_comp (p_org_code VARCHAR2, p_change_notice VARCHAR2)
   AS
      CURSOR c_sub_inv_comp
      IS
         --(p_item_number in varchar2, p_component_item_number in varchar2, p_organization_id in number) IS
         SELECT s.*, s.ROWID row_id
           FROM ggl_plm_bom_comp_sub_int s
          WHERE organization_code = p_org_code
		    AND change_notice 	  = p_change_notice
		    AND process_flag IN ('NEW', 'ERROR');


      process_next_bom                 EXCEPTION;
      c_sub_inv_comp_rec               c_sub_inv_comp%ROWTYPE;
      --
      v_org_id                         mtl_parameters.master_organization_id%TYPE;
      v_total_rec                      NUMBER                             := 0;
      v_proc_rec                       NUMBER                             := 0;
      v_err_rec                        NUMBER                             := 0;
      dummy                            VARCHAR2 (1);
      v_dummy                          NUMBER;
      v_alternate_count                NUMBER;
      v_revision                       VARCHAR2 (3);
      zero_rows                        EXCEPTION;
	  --
      v_bom_enabled_flag               mtl_system_items_b.bom_enabled_flag%TYPE;
      v_substitute_component_id        NUMBER;
      v_transaction_type               VARCHAR2 (50);
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE
                                         := 'PLM_BOM_GGL_PLM_BOM_COMP_SUB_INT';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
      e_err_ret_code                   NUMBER;
      error_on_insert_in_error_table   EXCEPTION;
      error_on_delete_in_error_table   EXCEPTION;
	  --
   BEGIN
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<IVALIDATE_SUB_COMP>> process......');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');

      FOR c_sub_inv_comp_rec IN c_sub_inv_comp
      LOOP
         BEGIN                                                         --loop

            IF c_sub_inv_comp_rec.substitute_component_number IS NULL
            THEN                                                --item_number
               e_error_desc := 'Substitute Component Item # is null.';
               e_sugg_action := 'Please enter Substitute Component Item #.';
               --             raise process_next_bom;
            ELSE
               v_transaction_type := 'CREATE';
               v_bom_enabled_flag := '';

               BEGIN
                  SELECT inventory_item_id,
                         bom_enabled_flag
                    INTO c_sub_inv_comp_rec.substitute_component_id,
                         v_bom_enabled_flag
                    FROM mtl_system_items msi
                   WHERE organization_id = c_sub_inv_comp_rec.organization_id
                     AND msi.segment1    = c_sub_inv_comp_rec.substitute_component_number;
					 --
               EXCEPTION
                  WHEN OTHERS
                  THEN
                     c_sub_inv_comp_rec.substitute_component_id := '';
                     v_bom_enabled_flag := '';
               END;

			   
			   
               IF c_sub_inv_comp_rec.substitute_component_id IS NULL
               THEN
                  e_error_desc :=
                        e_error_desc
                     || ' Invalid Substitute Component Item For Organization '
                     || p_org_code;  
                  e_sugg_action :=
                         e_sugg_action || ' Enter Valid Substitute Component.';
               ELSIF v_bom_enabled_flag IS NULL
               THEN
                  e_error_desc :=
                        e_error_desc
                     || ' BOM Allowed Not Enabled For Substitute Component Item in Organization '
                     || p_org_code;   
                  e_sugg_action :=
                        e_sugg_action
                     || ' Enable BOM Allowed For Substitute Component.';
               END IF;

			   
			--
			--RK: If assembly, comp, and sub comp exists then check for BOM in that ORG; 
			--	  If BOM found then mark the record for UPDATE instead of CREATE for new ECO/BOM 
			--		 			   
               IF c_sub_inv_comp_rec.substitute_component_id IS NOT NULL
               THEN
                  BEGIN
                     SELECT substitute_component_id
                       INTO v_substitute_component_id
                       FROM bom_substitute_components bsc,
                            bom_inventory_components bic,
                            bom_bill_of_materials bbm
                      WHERE bsc.component_sequence_id   = bic.component_sequence_id
                        AND bsc.substitute_component_id = c_sub_inv_comp_rec.substitute_component_id
                        AND bbm.organization_id   =   c_sub_inv_comp_rec.organization_id
                        AND bbm.assembly_item_id  =  c_sub_inv_comp_rec.assembly_item_id
                        AND bic.bill_sequence_id  = bbm.bill_sequence_id
                        AND bic.component_item_id = c_sub_inv_comp_rec.component_item_id
                        AND bic.operation_seq_num = c_sub_inv_comp_rec.operation_seq_num
                        AND SYSDATE BETWEEN bic.effectivity_date
                                        AND NVL (bic.disable_date, SYSDATE+1)
                        AND ROWNUM = 1;
						--
                  EXCEPTION
                     WHEN OTHERS
                     THEN
                        v_substitute_component_id := '';
                  END;

                 --
				 -- Mark the record for UPDATE for updating existing BOM / ECO 
				 --
                  IF v_substitute_component_id IS NOT NULL
                  THEN
                     v_transaction_type := 'UPDATE';
                  END IF;
				  --
               END IF;

              
               IF e_error_desc IS NOT NULL
               THEN
                  --  
                  RAISE process_next_bom;
               END IF;
            END IF;                                              --item_number

			
			
            BEGIN
               SELECT inventory_item_id
                 INTO c_sub_inv_comp_rec.component_item_id
                 FROM mtl_system_items msi
                WHERE organization_id = c_sub_inv_comp_rec.organization_id
                  AND msi.segment1   = c_sub_inv_comp_rec.component_item_number;
            EXCEPTION
               WHEN OTHERS
               THEN
                  c_sub_inv_comp_rec.component_item_id := '';
            END;

			
			
            BEGIN
               SELECT inventory_item_id
                 INTO c_sub_inv_comp_rec.assembly_item_id
                 FROM mtl_system_items msi
                WHERE organization_id = c_sub_inv_comp_rec.organization_id
                  AND msi.segment1 = c_sub_inv_comp_rec.item_number;
            EXCEPTION
               WHEN OTHERS
               THEN
                  c_sub_inv_comp_rec.assembly_item_id := '';
            END;

			
             
            IF c_sub_inv_comp_rec.process_flag = 'ERROR'
            THEN
               e_transaction_id      := c_sub_inv_comp_rec.ggl_plm_bom_comp_int_id;
               e_transaction_line_id := c_sub_inv_comp_rec.ggl_plm_bom_comp_sub_int_id;
               Ggl_Inv_Txn_Interface.ggl_inv_error_delete
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_err_ret_code
                                                      );

               IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_delete_in_error_table;
               END IF;
            END IF;

            BEGIN
               UPDATE ggl_plm_bom_comp_sub_int gb
                  SET error_messg = NULL,
                      process_flag = 'IN_PROCESS',
                      substitute_component_id = c_sub_inv_comp_rec.substitute_component_id,
                      component_item_id       = c_sub_inv_comp_rec.component_item_id,
                      assembly_item_id        = c_sub_inv_comp_rec.assembly_item_id,
                      transaction_type        = v_transaction_type,
                      operation_seq_num       = 10, --c_sub_inv_comp_rec.operation_seq_num,
                      created_by              = v_user_id,
                      creation_date           = SYSDATE,
                      last_updated_by         = v_user_id,
                      last_update_date        = SYSDATE
                WHERE gb.ROWID                = c_sub_inv_comp_rec.row_id;
            END;
			--
         EXCEPTION
            WHEN process_next_bom
            THEN
			   --
               e_transaction_id := c_sub_inv_comp_rec.ggl_plm_bom_comp_int_id;
               e_transaction_line_id :=
                               c_sub_inv_comp_rec.ggl_plm_bom_comp_sub_int_id;
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );
               e_error_desc  := '';
               e_sugg_action := '';

               IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
               END IF;

				  --RK: 06282007 - Added to fix the IN_PROCESS status issue; should be shown as ERROR
				  --
				  e_error_desc := ' At least one Invalid record in ECO#:... '
                               || p_change_notice||'; Please check the ERROR table or log for iCLEANUP...';
				  e_sugg_action := 'Fix the Issue and reprocess the change notice';
				  
                  UPDATE ggl_plm_bom_staging
                  SET  process_flag 		 = 'ERROR' , 
				  	   error_messg			 = e_error_desc||' <> '||e_sugg_action,
                  	   eco_status_code       = 'VALIDATION_ERROR',  
                  	   eco_status_message    = e_error_desc||' <> '||e_sugg_action
                  WHERE  change_notice       = p_change_notice
				    AND  item_number 		 = c_sub_inv_comp_rec.item_number
					AND process_flag in ('NEW','CLEAN','IN_PROCESS','IN_INTERFACE');		  
			   
			   
               BEGIN                                               --exception  
                  UPDATE ggl_plm_bom_comp_sub_int sb
                     SET process_flag     = 'ERROR',
                         created_by       = v_user_id,
                         creation_date    = SYSDATE,
                         last_updated_by  = v_user_id,
                         last_update_date = SYSDATE
                   WHERE sb.ROWID = c_sub_inv_comp_rec.row_id
                     AND process_flag = 'NEW';
               END;                                                --exception
         END;                                                           --loop   
      END LOOP;
   EXCEPTION
      WHEN error_on_insert_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.validate_sub_comp UNABLE TO INSERT RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN error_on_delete_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.validate_sub_comp UNABLE TO DELETE RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN OTHERS
      THEN
         Fnd_File.put_line
              (Fnd_File.LOG,
                  'GGL_PLM_BOM_INTERFACE.validate_sub_comp OTHERS EXCEPTION '
               || SQLERRM
              );
   END ivalidate_sub_comp;

   
   
-- ========================================================================================
--
-- This procedure is used to validate records
-- 
--RK: Based on TRANSACTION_TYPE passed this procedure will populate ECO or BOM records -
--	  into INTERFACE tables for sub component level 
--
-- ========================================================================================
   
   
   PROCEDURE insert_sub_comp_interface (
      p_org_code                  VARCHAR2,
      p_ggl_plm_bom_comp_int_id   NUMBER,
      p_transaction_type          VARCHAR2,
      p_operation_seq_num         NUMBER,
	  p_bill_sequence_id     	  NUMBER
   )
   IS
      CURSOR c_sub_comp
      IS
         SELECT gic.*, gic.ROWID row_id
           FROM ggl_plm_bom_comp_sub_int gic
          WHERE process_flag = 'IN_PROCESS'
            AND organization_code = p_org_code
            AND ggl_plm_bom_comp_int_id = p_ggl_plm_bom_comp_int_id;

      c_sub_comp_rec   c_sub_comp%ROWTYPE;
  	  l_acd_type			 	  NUMBER;
	  
   BEGIN
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<INSERT_SUB_COMP_INTERFACE>> process......');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');

      FOR c_sub_comp_rec IN c_sub_comp
      LOOP
--    FND_FILE.put_line(FND_FILE.log,'Start insert_sub_comp_interface 1');
         IF UPPER (p_transaction_type) IN ('UPDATE','CREATE')  --For ECO Records 
         THEN                                                    --ECO or BOM
            Fnd_File.put_line (Fnd_File.LOG, 'FOR ECO Record;  acd_type is: '||c_sub_comp_rec.acd_type
							  				||' Transaction Type: '||p_transaction_type);

            BEGIN
               INSERT INTO bom_sub_comps_interface
                           (substitute_component_id, --RK: Do not pass for create
						    last_update_date,
                            last_updated_by, creation_date,
                            created_by,
                            last_update_login,
                            substitute_item_quantity,
                            component_sequence_id,
                            original_system_reference,
                            --assembly_item_id, --RK: Might need to revert back - 05292007 
                            --organization_id,	--RK: Might need to revert back - 05292007 
                            component_item_id,
                            operation_seq_num,
                            effectivity_date, 
							process_flag,
                            organization_code,
                            substitute_comp_number,
                            component_item_number,
                            assembly_item_number, transaction_type,
                            bom_sub_comps_ifce_key,
                            change_notice, acd_type, interface_entity_type,
							bill_sequence_id, --RK: Added on 052507 to fix the sub comp 
							--attribute_category,
							attribute1,
							attribute2									
                           )
                    VALUES (DECODE(c_sub_comp_rec.acd_type, 1,'',c_sub_comp_rec.substitute_component_id), 
						    SYSDATE,
                            c_sub_comp_rec.last_updated_by, SYSDATE, --creation_date,
                            c_sub_comp_rec.created_by,
                            c_sub_comp_rec.last_update_login,
                            c_sub_comp_rec.component_qty, --substitute_item_quantity,
							-- decode(c_sub_comp_rec.acd_type, 2, c_sub_comp_rec.component_qty,3, ''),
                            c_sub_comp_rec.component_sequence_id,
                            c_sub_comp_rec.ggl_plm_bom_comp_sub_int_id, --original_system_reference,
                            --DECODE(c_sub_comp_rec.acd_type, 1,'',c_sub_comp_rec.assembly_item_id), --RK: Might need to revert back - 05292007 
                            --DECODE(c_sub_comp_rec.acd_type, 1,'',c_sub_comp_rec.organization_id),  --RK: Might need to revert back - 05292007 
                            c_sub_comp_rec.component_item_id,
                            c_sub_comp_rec.operation_seq_num,
							--c_sub_comp_rec.effectivity_date, --TRUNC(SYSDATE) --RK: Changed on 052707 
                            TRUNC(c_sub_comp_rec.effectivity_date), --TRUNC(SYSDATE) --RK: Changed on 052407 
                            1,                 				 --process_flag,
                            c_sub_comp_rec.organization_code,
                            c_sub_comp_rec.substitute_component_number,--substitute_comp_number,
                            c_sub_comp_rec.component_item_number,
                            c_sub_comp_rec.item_number,   --assembly_item_number,
                            'CREATE',					  --c_sub_comp_rec.transaction_type,
                            c_sub_comp_rec.change_notice, --bom_sub_comps_ifce_key,
                            c_sub_comp_rec.change_notice, 
							c_sub_comp_rec.acd_type,	  --RK: Changed on 052407 
                            'ECO',						   --interface_entity_type,
							p_bill_sequence_id,    
							--'ECO_INT',			   		   --attribute_category
							c_sub_comp_rec.ggl_plm_bom_comp_sub_int_id		--attribute1 
							,c_sub_comp_rec.change_notice					--attribute2  							
                           );                       
            END;
         END IF;                                                  --ECO or BOM

         BEGIN
            UPDATE ggl_plm_bom_comp_sub_int gic
               SET error_messg = NULL,
                   process_flag = 'IN_INTERFACE',
                   created_by = v_user_id,
                   creation_date = SYSDATE,
                   last_updated_by = v_user_id,
                   last_update_date = SYSDATE
             WHERE gic.ROWID = c_sub_comp_rec.row_id;
			 
         END;
      END LOOP;
   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line
                        (Fnd_File.LOG,
                            'Unknown Fatal error insert_sub_comp_interface :'
                         || v_error
                        );
   END insert_sub_comp_interface;

   
-- ========================================================================================
--
-- This procedure is used to validate records
-- 
--RK: Based on TRANSACTION_TYPE passed this procedure will populate ECO or BOM records -
--	  into INTERFACE tables for component level and then calls -
--	  insert_sub_comp_interface for populating rest of the records.
--
-- ========================================================================================
   
   
   PROCEDURE insert_inv_comp_interface (
      p_org_code             VARCHAR2,
      p_ggl_plm_bom_int_id   NUMBER,
      p_transaction_type     VARCHAR2,
      p_operation_seq_num    NUMBER,
      p_bill_sequence_id     NUMBER
   )
   IS
      --
	  l_old_effectivity_date DATE;
	  --l_item_num			 NUMBER := -10; --Used for item_seq  
	  --
      CURSOR c_inv_comp
      IS
         SELECT gic.*, gic.ROWID row_id
           FROM ggl_plm_bom_comp_int gic
          WHERE process_flag = 'IN_PROCESS'
            AND organization_code = p_org_code
            AND ggl_plm_bom_int_id = p_ggl_plm_bom_int_id;

      c_inv_comp_rec   c_inv_comp%ROWTYPE;
	  l_acd_type	   NUMBER;
	  v_chk_int_rec	   NUMBER;			
	  --
   BEGIN
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
          Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<INSERT_INV_COMP_INTERFACE>> process......');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');

      Fnd_File.put_line (Fnd_File.LOG, 'Before Comp Loop;  p_org_code: '||p_org_code
					||' p_ggl_plm_bom_int_id: '||p_ggl_plm_bom_int_id
					||' Transaction Type: '||p_transaction_type);
					

      FOR c_inv_comp_rec IN c_inv_comp
      LOOP
         Fnd_File.put_line (Fnd_File.LOG, 'In Comp Loop;  acd_type is: '||c_inv_comp_rec.acd_type
							  				||' Transaction Type: '||p_transaction_type);
		 --									
         IF UPPER (p_transaction_type) IN ('UPDATE','CREATE')  --For ECO Records 
         THEN                                                    --ECO or BOM  
            Fnd_File.put_line (Fnd_File.LOG, 'FOR ECO Record;  acd_type is: '||c_inv_comp_rec.acd_type
							  				||' Transaction Type: '||p_transaction_type);
			
			--IF update get the old_eff_date else use null...
			BEGIN
    		   SELECT bic.effectivity_date--, item_num 
				 INTO l_old_effectivity_date--, l_item_num
    			 FROM BOM_INVENTORY_COMPONENTS bic
    			WHERE 1=1
    			  AND bic.component_item_id = c_inv_comp_rec.component_item_id
    			  AND bic.bill_sequence_id  = p_bill_sequence_id
    			  AND bic.disable_date IS NULL
    			  AND ROWNUM = 1;
			EXCEPTION
			  WHEN NO_DATA_FOUND THEN
			  	   l_old_effectivity_date := null;
		          Fnd_File.put_line (Fnd_File.LOG, 'In effectivity date select - No Data Found'
				  					||' Comp id:'||c_inv_comp_rec.component_item_id||' comp # '||c_inv_comp_rec.component_item_number);
			  WHEN OTHERS THEN
		          Fnd_File.put_line (Fnd_File.LOG, 'In effectivity date select - When Others');
				  NULL;			  
			END;	  

			
            BEGIN
               --
               INSERT INTO bom_inventory_comps_interface
                           (operation_seq_num,
                            component_item_id,
                            component_quantity,
                            effectivity_date,
                            disable_date,
                            item_num,
							 bill_sequence_id,
                            --   assembly_item_id,
                            --   organization_id,
                            organization_code,
                            component_item_number,
                            assembly_item_number, 
							transaction_type,
                            process_flag, 
							original_system_reference,
                            bom_inventory_comps_ifce_key,
                            --  eng_revised_items_ifce_key,
                            --  eng_changes_ifce_key,
							--attribute_category,
							attribute1,		
							attribute2,					
                            created_by, 
							creation_date,
                            last_updated_by, 
							last_update_date,
                            change_notice,
                            acd_type,
							old_effectivity_date,
                            interface_entity_type
                           )
                    VALUES (p_operation_seq_num, --10, --RK: For update we should use old value
                            --c_inv_comp_rec.operation_seq_num,
                            DECODE(c_inv_comp_rec.acd_type,1,'',c_inv_comp_rec.component_item_id),
                            DECODE(c_inv_comp_rec.acd_type, 3, '',c_inv_comp_rec.component_qty),
							--TRUNC(SYSDATE), --RK: checking to fix the eco update issue 
							c_inv_comp_rec.effectivity_date, --RK: Changed on 052707; when adding a subcomp you need to use time portion also 
                            --TRUNC(c_inv_comp_rec.effectivity_date), --RK: ***For update get effectivity date from prior record?? doubt full
                            c_inv_comp_rec.disable_date,--decode(c_inv_comp_rec.acd_type, 3,c_inv_comp_rec.disable_date, null), --c_inv_comp_rec.disable_date --RK: 
                            c_inv_comp_rec.item_num, 
							p_bill_sequence_id, --DECODE(c_inv_comp_rec.acd_type,1, '',p_bill_sequence_id),
                            --   c_inv_comp_rec.assembly_item_id,
                            --   c_inv_comp_rec.organization_id,
                            c_inv_comp_rec.organization_code,
                            c_inv_comp_rec.component_item_number,
                            c_inv_comp_rec.item_number, 
							'CREATE',
                            --c_inv_comp_rec.transaction_type,
                            1,                  --c_inv_comp_rec.process_flag,
                            c_inv_comp_rec.ggl_plm_bom_comp_int_id,
                             --original_system_reference,
                            c_inv_comp_rec.change_notice,
                            --bom_inventory_comps_ifce_key,
                            --     c_inv_comp_rec.change_notice,--eng_revised_items_ifce_key,
                             --    c_inv_comp_rec.change_notice,--eng_changes_ifce_key,
							--'ECO_INT', --att_category 
							c_inv_comp_rec.ggl_plm_bom_comp_int_id, --attribute1	
							c_inv_comp_rec.change_notice,			--attribute2								 
                            c_inv_comp_rec.created_by, 
							SYSDATE,
                            c_inv_comp_rec.last_updated_by,
                            SYSDATE,
                            c_inv_comp_rec.change_notice,
                            --   DECODE (UPPER (c_inv_comp_rec.transaction_type),
                            --           'CREATE',  1,
                            --           'UPDATE',  2,
                            --           'DISABLE', 3,
                            --           ''
                            --          ),               --c_inv_comp_rec.acd_type,
							c_inv_comp_rec.acd_type,
							l_old_effectivity_date,
                            'ECO'
                           );                        --interface_entity_type);

				IF SQL%NOTFOUND THEN
					Fnd_File.put_line (Fnd_File.LOG, 'Error in inserting component ECO record comp_id '||c_inv_comp_rec.ggl_plm_bom_comp_int_id);
				END IF;    
	      EXCEPTION
			WHEN OTHERS THEN
		   	   Fnd_File.put_line (Fnd_File.LOG, 'When Others: Error in inserting component ECO record comp_id '||c_inv_comp_rec.ggl_plm_bom_comp_int_id
							||'sqlerrm: '||SUBSTR (SQLERRM, 1, 500));                       
            END;
		  --	
         END IF;  --ECO or BOM  
	
	 	 v_chk_int_rec := 0;

         SELECT COUNT(*)
         INTO v_chk_int_rec
         FROM bom_inventory_comps_interface
         WHERE original_system_reference = c_inv_comp_rec.ggl_plm_bom_comp_int_id;
         
         IF v_chk_int_rec <> 0 THEN
		Fnd_File.put_line (Fnd_File.LOG,'In v_chk_int_rec <> :'|| v_chk_int_rec);
	         BEGIN
	            UPDATE ggl_plm_bom_comp_int gic
	               SET error_messg = NULL,
	                   process_flag = 'IN_INTERFACE',
	                   created_by = v_user_id,
	                   creation_date = SYSDATE,
	                   last_updated_by = v_user_id,
	                   last_update_date = SYSDATE
	             WHERE gic.ROWID = c_inv_comp_rec.row_id;
			 EXCEPTION
				  WHEN NO_DATA_FOUND THEN
			          Fnd_File.put_line (Fnd_File.LOG, 'In Update ggl_plm_bom_comp_int - No Data Found');
					  NULL;			  
				  WHEN OTHERS THEN
			          Fnd_File.put_line (Fnd_File.LOG, 'In Update ggl_plm_bom_comp_int - When Others');
					  NULL;			  
    	     END;

	         Fnd_File.put_line
    	              (Fnd_File.LOG,
        	              'Start substitutue comp insert GGL_PLM_BOM_COMP_INT_ID '
            	       || c_inv_comp_rec.ggl_plm_bom_comp_int_id
                	  );
			--	  
			BEGIN
    		     		insert_sub_comp_interface (p_org_code,
        		                            c_inv_comp_rec.ggl_plm_bom_comp_int_id,
            		                        p_transaction_type,
                	      	              	p_operation_seq_num,
										  	p_bill_sequence_id
                        	           		);
           		EXCEPTION
		  	WHEN OTHERS THEN 
	         		Fnd_File.put_line
    	              	(Fnd_File.LOG,
        	            	  'When others: Substitutue comp insert failed; GGL_PLM_BOM_COMP_INT_ID '
            	       	|| c_inv_comp_rec.ggl_plm_bom_comp_int_id
                	  		);
			END;
		 ELSE
			 Fnd_File.put_line (Fnd_File.LOG, 'Interface record not found for comp_id '||c_inv_comp_rec.ggl_plm_bom_comp_int_id);
         END IF;                          
      END LOOP;
      
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Completed the <<INSERT_INV_COMP_INTERFACE>> process......');
   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line
                        (Fnd_File.LOG,
                            'Unknown Fatal error insert_inv_comp_interface :'
                         || v_error
                        );
   END insert_inv_comp_interface;



-- ========================================================================================
--
-- This procedure is used to validate records
-- 
--RK: For each distinct ECO record process all assembly/comp/sub comp records based on-
--	  TRANSACTION_TYPE of that record and populate ECO or BOM records into INTERFACE tables.
--	  This procedure populates records until assembly level and then calls -
--	  insert_inv_comp_interface for populating rest of the records.
--
-- ========================================================================================
 
   
   PROCEDURE insert_bom_interface (p_org_code              VARCHAR2,
                                   p_common_org_sequence   NUMBER,
				   					p_change_notice	   VARCHAR2
                                  )
   IS
      --
	  -- Why are we not checking for records in the 1st interface 
	  -- for ERROR 
      CURSOR c_eco
      IS
         SELECT DISTINCT gb.change_notice, gb.organization_id, gb.assembly_item_id, mp.organization_id common_org_id
                    FROM ggl_plm_bom_int gb, mtl_parameters mp
                   WHERE process_flag = 'IN_PROCESS'
				     AND mp.organization_code(+) = gb.common_org  --RK:110507 Add for common bom creation 
                     AND gb.organization_code = p_org_code
		     		 AND gb.change_notice 	   = p_change_notice	
                     AND gb.change_notice IS NOT NULL
                     AND (   ( p_common_org_sequence = 1
					          --
                              AND NOT EXISTS (
                                     SELECT 1
                                       FROM ggl_plm_bom_comp_int gc
                                      WHERE gc.change_notice =  gb.change_notice
                                        AND gc.process_flag = 'ERROR')
										--
                              AND NOT EXISTS (
                                     SELECT 1
                                       FROM ggl_plm_bom_comp_sub_int gs
                                      WHERE gs.change_notice = gb.change_notice
                                        AND gs.process_flag  = 'ERROR')
                              )
							  --
                          OR  ( p_common_org_sequence = 2
                              AND NOT EXISTS (
                                     SELECT 1
                                       FROM ggl_plm_bom_int gc
                                      WHERE gc.assembly_item_id = gb.assembly_item_id
                                        AND gc.revision = gb.revision
                                        AND gc.common_item_number_bom IS NULL
                                        AND gc.process_flag IN
                                               ('NEW', 'IN_PROCESS', 'ERROR'))
                             )
                         );

      CURSOR c_bom_main (p_change_notice IN VARCHAR2)
      IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_int gb
          WHERE process_flag = 'IN_PROCESS'
		    --AND common_org	 IS NULL
            AND organization_code = p_org_code
            AND change_notice = p_change_notice;
			
      CURSOR c_bom (p_change_notice IN VARCHAR2)
      IS
         SELECT gb.*, gb.ROWID row_id
           FROM ggl_plm_bom_int gb
          WHERE process_flag = 'IN_PROCESS'
		    --AND common_org	 IS NULL
            AND organization_code = p_org_code
            AND change_notice = p_change_notice;			

      c_bom_rec            c_bom%ROWTYPE;
      v_transaction_type   VARCHAR2 (10);
      v_iurequestid        NUMBER          := 0;
      v_iurphase           VARCHAR2 (40)   := NULL;
      v_iurstatus          VARCHAR2 (40)   := NULL;
      v_iudphase           VARCHAR2 (40)   := NULL;
      v_iudstatus          VARCHAR2 (40)   := NULL;
      v_iumessage          VARCHAR2 (40)   := NULL;
      v_iustatus           BOOLEAN         := FALSE;
      v_iutext             VARCHAR2 (40)   := NULL;
      v_iuretcode          NUMBER          := 0;
      v_iuwaitstatus       BOOLEAN         := FALSE;
      v_iuerrbuf           VARCHAR2 (100)  := NULL;
      v_req_id             NUMBER;
      v_dummy              NUMBER;
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'GGL_PLM_BOM_INT';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
	  e_err_ret_code	   NUMBER;		   
	  v_implement_flag	   NUMBER 		   := 0;	
	  l_bom_count		   NUMBER		   := 0;
	  --
   BEGIN
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, 'PROCESS:   Starting the <<INSERT_BOM_INTERFACE>> process....');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
Fnd_File.put_line (Fnd_File.LOG, '=======> Parameters are  p_common_org_sequence:'||p_common_org_sequence|| ' org code: '||p_common_org_sequence);	
	  	  
      FOR c_eco_rec IN c_eco
      LOOP                                    --ECO 
         v_transaction_type := 'CREATE';

         FOR c_bom_rec IN c_bom (c_eco_rec.change_notice)
         LOOP
	        --
			--RK: If BOM already exists then create ECO records else create BOM records 
			--	 
            IF c_bom_rec.transaction_type = 'UPDATE'
            THEN                                           --transaction_type
               v_transaction_type := 'UPDATE';
            ELSIF c_bom_rec.transaction_type = 'CREATE'
            THEN                                            --transaction_type
               v_transaction_type := 'CREATE';
            END IF; --IF c_bom_rec.transaction_type = 'UPDATE'   --transaction_type
			
			
		    BEGIN -- bom 1 
		      SELECT count(*)
                INTO l_bom_count
                FROM bom_bill_of_materials bbm
               WHERE bbm.organization_id  = c_bom_rec.organization_id 
                 AND bbm.assembly_item_id = c_bom_rec.assembly_item_id;			
			END;			
			
Fnd_File.put_line (Fnd_File.LOG, 'Before l_bom_count :'||l_bom_count);			
			
			IF l_bom_count = 0 THEN
               --
               -- Create Routings by using Routing API...
               --
               	IF NOT 
                CREATE_ROUTING
               	(c_bom_rec.item_number, 		   		 --p_item_number  	  IN VARCHAR2,
                 c_bom_rec.organization_code,	  		 --p_OrganizationCode IN VARCHAR2,
                 c_bom_rec.routing_operation_seq_num, 	 --p_Operation_seq	  IN NUMBER,
                 c_bom_rec.routing_department_code		 --p_dept_code		  IN VARCHAR2 
                ) THEN
		            Fnd_File.put_line (Fnd_File.LOG,'Routing Creation Issue; item# '||c_bom_rec.item_number||'; Org Cd: '||c_bom_rec.organization_code);
                      iupdate_eco (P_change_notice, 'INTERFACE_ERROR'
                      , '<<CREATE_ROUTING>> failed for Assembly Item :'|| c_bom_rec.item_number||'; Org Cd: '||c_bom_rec.organization_code);
	            ELSE
                     Fnd_File.put_line (Fnd_File.LOG,'Routing created successfully; item# '||c_bom_rec.item_number||'; Org Cd: '||c_bom_rec.organization_code);
                END IF;
               		
                Fnd_File.put_line (Fnd_File.LOG, 'After create_routing---l_bom_count :'||l_bom_count);			
			END IF;
			
			Fnd_File.put_line (Fnd_File.LOG, 'Common_org_seq '||p_common_org_sequence||'  Org: '||p_org_code );
			--
			-- Create ECO for only Primary Org (ex: PNA / GNA / ENU etc)
			--
			IF p_common_org_sequence = 1 and (l_bom_count = 0 or c_bom_rec.transaction_type = 'UPDATE') 
			THEN			
               BEGIN
                  SELECT 1
                    INTO v_dummy
                    FROM eng_eng_changes_interface
                   WHERE change_notice      = c_bom_rec.change_notice
                     AND organization_code  = c_bom_rec.organization_code;
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     BEGIN
Fnd_File.put_line (Fnd_File.LOG, 'in insert in to eng_eng_changes; l_bom_count :'||l_bom_count);						 
                        INSERT INTO eng_eng_changes_interface
                                    (change_notice, 
									 change_order_type,
                                     process_flag, 
									 transaction_type,
                                     organization_code,
                                     eng_changes_ifce_key, 
                                     --     status_type,
                                     --     approval_status_type,
                                     --     approval_date,
									 -- 	attribute_category,
									 attribute1,
									 attribute2,	--eco# 								 
                                     created_by, 
									 creation_date,
                                     last_updated_by, 
									 last_update_date
                                    )
                             VALUES (c_bom_rec.change_notice, 
							         'PLM',
                                     --c_bom_rec.change_order_type,
                                     -- '',--c_bom_rec.change_order_type,
                                     1, --c_bom_rec.process_flag,
                                     'CREATE',           --transaction_type,
                                     c_bom_rec.organization_code,
                                     c_bom_rec.change_notice,
                                                       --eng_changes_ifce_key,
                                     --                    '1',--c_bom_rec.status_type,
                                     --                    '5',--c_bom_rec.approval_status_type,
                                     --                    c_bom_rec.approval_date,
									 -- 'ECO_INT',
									 c_bom_rec.ggl_plm_bom_int_id,
									 c_bom_rec.change_notice,
                                     c_bom_rec.created_by, 
									 SYSDATE,
                                     --creation_date,
                                     c_bom_rec.last_updated_by, 
									 SYSDATE
                                    );
									
					           Fnd_File.put_line
                                    (Fnd_File.LOG,
                                        ' SUCCESS:    Inserted record Into Interface table:  ENG_ENG_CHANGES_INTERFACE '
                                    );
                     END;
               END;

               BEGIN
                  INSERT INTO eng_revised_items_interface
                              (change_notice,
                               revised_item_number,
                               --  status_type,
                               scheduled_date,
                               --  bill_sequence_id,
                               transaction_type, 
							  -- process_flag,
                               organization_code,
                               eng_revised_items_ifce_key,
                               --  eng_changes_ifce_key,
                               --  update_wip,
							  -- attribute_category,
							   attribute1,	
							   attribute2,								   						   
                               created_by, 
							   creation_date,
                               last_updated_by, 
							   last_update_date
                              )
                       VALUES (c_bom_rec.change_notice,
                               c_bom_rec.item_number,   --revised_item_number,
                               --  '1', --status_type 6 You cannot implement revised items through this import process.
                               SYSDATE,
                               --scheduled_date,
                               -- c_bom_rec.bill_sequence_id,
                               'CREATE',              --transaction_type,
                               --'1',                   --process_flag,
                               c_bom_rec.organization_code,
                               c_bom_rec.change_notice,
                               --  eng_revised_items_ifce_key
                               --  c_bom_rec.change_notice,--eng_changes_ifce_key
                               --  '2', -- Update Job Disable
							   --'ECO_INT',
							   c_bom_rec.ggl_plm_bom_int_id,
							   c_bom_rec.change_notice,						   
                               c_bom_rec.created_by, 
							   SYSDATE, --creation_date,
                               c_bom_rec.last_updated_by, 
							   SYSDATE
                              );
							--
					        Fnd_File.put_line
                                 (Fnd_File.LOG,
                                   ' SUCCESS:    Inserted record Into Interface table:  ENG_REVISED_ITEMS_INTERFACE '
                                 );
                END;

            BEGIN
			   --
               UPDATE ggl_plm_bom_int gb
                  SET error_messg      = NULL,
                      process_flag     = 'IN_INTERFACE',
                      created_by       = v_user_id,
                      creation_date    = SYSDATE,
                      last_updated_by  = v_user_id,
                      last_update_date = SYSDATE
                WHERE gb.ROWID = c_bom_rec.row_id;
				--

				Fnd_File.put_line
                                 (Fnd_File.LOG,
                                   '  UPDATE:    Updated Record in table ggl_plm_bom_int to IN_INTERFACE '
								   ||c_bom_rec.ggl_plm_bom_int_id
                                 ); 	
								 
            END;

            Fnd_File.put_line (Fnd_File.LOG,
                                  'Start comp insert GGL_PLM_BOM_INT_ID '
                               || c_bom_rec.ggl_plm_bom_int_id
                              );
	    --
	    --RK: Create inventory component records for the above BOM / ECO 
	    --
            Fnd_File.put_line (Fnd_File.LOG, 'Before insert_inv_comp_interface: ggl_plm_bom_int_id '||c_bom_rec.ggl_plm_bom_int_id
				||' transaction_type '||c_bom_rec.transaction_type
				||' routing_operation_seq_num '||c_bom_rec.routing_operation_seq_num
				||' bill_sequence_id '||c_bom_rec.bill_sequence_id
                              );

            insert_inv_comp_interface (p_org_code,
                                       c_bom_rec.ggl_plm_bom_int_id,
                                       c_bom_rec.transaction_type,
                                       c_bom_rec.routing_operation_seq_num,
                                       c_bom_rec.bill_sequence_id
                                      );
									  
            	Fnd_File.put_line (Fnd_File.LOG, 'After insert_inv_comp_interface: ggl_plm_bom_int_id '
							  ||c_bom_rec.ggl_plm_bom_int_id
							  ||' transaction_type '||c_bom_rec.transaction_type
							  ||' routing_operation_seq_num '||c_bom_rec.routing_operation_seq_num
							  ||' bill_sequence_id '||c_bom_rec.bill_sequence_id
                              );
			--				
			END IF; 		--IF p_common_org_sequence = 1 and l_bom_count = 0 THEN	
			--  
			--
         END LOOP; 		--BOM 			  
		 --
		 	 
Fnd_File.put_line (Fnd_File.LOG, 'Before c_bom_rec second loop for eco processing :');				  
			  
--         FOR c_bom_rec IN c_bom (c_eco_rec.change_notice)
--         LOOP
-- 	        --
-- 			--RK: If BOM already exists then create ECO records else create BOM records 
-- 			--	 
--             IF c_bom_rec.transaction_type = 'UPDATE'
--             THEN                                           --transaction_type
--                v_transaction_type := 'UPDATE';
--             ELSIF c_bom_rec.transaction_type = 'CREATE'
--             THEN                                            --transaction_type
--                v_transaction_type := 'CREATE';
--             END IF; --IF c_bom_rec.transaction_type = 'UPDATE'   --transaction_type
-- 			
			
		    BEGIN -- bom 1 
		      SELECT count(*)
                INTO l_bom_count
                FROM bom_bill_of_materials bbm
               WHERE bbm.organization_id  = c_eco_rec.organization_id 
                 AND bbm.assembly_item_id = c_eco_rec.assembly_item_id;			
			END;			
			
Fnd_File.put_line (Fnd_File.LOG, 'After l_bom_count in eco processing :'||l_bom_count
				  ||' for org :'||c_bom_rec.organization_id||' and item :'||c_bom_rec.assembly_item_id);			

			  
			  
-- 		 --
--          IF v_transaction_type IN ('UPDATE', 'CREATE')  	 
--          THEN 
    	-- 							   
    	-- Call "Google BOM Interface - Import ECO" only when the _INT records matches with INTERFACE;   
    	-- Even a single subcomp or comp or bom/assembly records does not match mark all ECO records 
    	-- as ERROR and DO NOT call the ECO_API to process the records.
    	-- 
    	  IF icheck_interface_status(c_eco_rec.change_notice) <> -1 THEN
    	  --
                	Fnd_File.put_line (Fnd_File.LOG, '<<ECO API>> is being called for ECO#:... '
                                 || c_eco_rec.change_notice||'   and p_common_org_seq is :'||p_common_org_sequence);
    	  --			
			IF p_common_org_sequence = 1 THEN	--Only for the primary bom org... 
			   						 --RK: May be add extra check for looking for records in eng_tables... 
                  Fnd_File.put_line (Fnd_File.LOG,'****Just before ECO import******');
				  									 
               v_IURequestId := 
                  Fnd_Request.SUBMIT_REQUEST('XXMFG','GGL_PLM_BOM_INT_IMPORT_ECO','','',NULL,
                  			          c_eco_rec.change_notice,Fnd_Global.local_chr(0),'','', '',
                  				      '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  					  '','','','','','','','','','',
                  			   	      '','','','','','','','','','',
                  			          '','','','','','','','');
    		--
                  Fnd_File.put_line (Fnd_File.LOG,'****After ECO import - Successful******');
    	    COMMIT;
    		--  
              BEGIN
                IF v_iurequestid != 0
                THEN
                  BEGIN
                     LOOP
                        v_iuwaitstatus :=
                           Fnd_Concurrent.wait_for_request (v_iurequestid,
                                                            10,
                                                            0,
                                                            v_iurphase,
                                                            v_iurstatus,
                                                            v_iudphase,
                                                            v_iudstatus,
                                                            v_iumessage
                                                           );
                        EXIT WHEN UPPER (v_iurphase) = 'COMPELETED'
                              OR UPPER (v_iudphase) = 'COMPLETE'
                              OR UPPER (v_iurstatus) = 'ERROR'
                              OR UPPER (v_iudstatus) = 'ERROR';
                     END LOOP;
                  END;
                END IF;
              END;
			
              --
              Fnd_File.put_line (Fnd_File.LOG, 'v_IUrphase    :	' || v_iurphase);
              Fnd_File.put_line (Fnd_File.LOG, 'v_IUrstatus	:	' || v_iurstatus);
              Fnd_File.put_line (Fnd_File.LOG, 'v_IUdphase	:	' || v_iudphase);
              Fnd_File.put_line (Fnd_File.LOG, 'v_IUdstatus	:	' || v_iudstatus);
              Fnd_File.put_line (Fnd_File.LOG, 'v_IUmessage	:	' || v_iumessage);
              --
              BEGIN
                IF    (v_iurequestid = 0)
                  OR (UPPER (v_iurstatus) = 'ERROR')
                  OR (UPPER (v_iudstatus) = 'ERROR')
                THEN
                  v_iuretcode := 2;
                  v_iuerrbuf := 'Call unsuccessful ' || v_iumessage;
				  
                ELSIF    (UPPER (v_iurstatus) = 'WARNING')
                     OR (UPPER (v_iudstatus) = 'WARNING')
                THEN
                  v_iuretcode := 1;
                END IF;
              END;

              BEGIN
                SELECT DECODE (v_iuretcode,
                              0, 'NORMAL',
                              1, 'WARNING',
                              2, 'ERROR'
                             )
                 INTO v_iutext
                 FROM DUAL;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  Fnd_File.put_line (Fnd_File.LOG, '****Aborting******');
                  Fnd_File.put_line (Fnd_File.LOG,
                                     'ERR(100):No Process for ECO'
                                    );
              END;				  
			--	  
			END IF; 	--IF p_common_org_sequence = 1 THEN	--Only for the primary bom org...
			--					 
    	  ELSE	--IF icheck_interface_status(c_eco_rec.change_notice) <> -1 THEN
    		--
    		-- Update all ECO records with the status as 'ERROR'  
    		-- 
              	   Fnd_File.put_line (Fnd_File.LOG, '<<ECO API>> is not being called for ECO#:... '
                                 || c_eco_rec.change_notice||'; Update the ECO as INTERFACE_ERROR...'
                                );
    		--
                  e_transaction_id      := P_CHANGE_NOTICE;
                  e_transaction_line_id := '';
                  e_error_desc  := 'IMPORT_ECO API is not being called as at least one record not processed';
                  e_sugg_action := 'Please check ERROR_MESSG colum in BOM_STAGING table';
    		    --			   
                  Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                         (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                         );
    		    --			  				
    		  iupdate_eco (P_change_notice, 'INTERFACE_ERROR'
    		  , '<<IMPORT_ECO API>> is not being called for Assembly Item :... '
                      || c_eco_rec.assembly_item_id||'; icheck_interface_status failed...');
                  e_error_desc  := '';
                  e_sugg_action := '';
    	  END IF;  --IF icheck_interface_status(c_eco_rec.change_notice) <> -1 THEN									  
    	  --
    	    COMMIT;
    		--  

              Fnd_File.put_line (Fnd_File.LOG, 'Just before IMPLEMENT_ECO_API Call-- v_iutext: ' || v_iutext);

			  -- 							   
			  -- Call "ECO Implementation API" only when the _INT records matches with ECO CREATED;   
			  -- Even a single subcomp or comp or bom/assembly records does not match mark all ECO records 
			  -- as ERROR and DO NOT call the ECO_IMPL_API to Implement the ECO created in prior step.
			  -- 
			  IF icheck_eco_status(c_eco_rec.change_notice) <> -1 THEN
			  --
              	Fnd_File.put_line (Fnd_File.LOG, '<<IMPLEMENT_ECO API>> is being called for ECO#:... '
                               || c_eco_rec.change_notice);
			  --			
			    IF p_common_org_sequence = 1 THEN	--Only for the primary bom org...
                  BEGIN
                    IF v_iutext = 'NORMAL'  				  
                    THEN
                     Fnd_File.put_line (Fnd_File.LOG,
                                           '****Start ECO Implementation****** '
                                        || c_eco_rec.organization_id
                                       );
		
             	     v_req_id := Fnd_Request.SUBMIT_REQUEST('ENG','ENCACN','','',NULL, c_eco_rec.organization_id, '2', '',
         												                 c_eco_rec.change_notice,'',Fnd_Global.local_chr(0),
         													             '','','','','','','','','',
         													             '','','','','','','','','','',
         																 '','','','','','','','','','',
         												                 '','','','','','','','','','',
         												                 '','','','','','','','','','',
         												                 '','','','','','','','','','',
         												                 '','','','','','','','','','',
         										   	                     '','','','','','','','','','',
         										                         '','','','','','','','');
   				      --														 
                      COMMIT;
Fnd_File.put_line (Fnd_File.LOG, 'After ENCACN... : common_org_sequence: '||p_common_org_sequence);						  
                    END IF; --v_iutext = 'NORMAL' 
                  END;
      	  		  --			
                  BEGIN
                    IF v_req_id != 0
                    THEN
                       BEGIN
                          LOOP
                             v_iuwaitstatus :=
                                Fnd_Concurrent.wait_for_request (v_req_id,
                                                                 10,
                                                                 0,
                                                                 v_iurphase,
                                                                 v_iurstatus,
                                                                 v_iudphase,
                                                                 v_iudstatus,
                                                                 v_iumessage
                                                                );
                             EXIT WHEN UPPER (v_iurphase) = 'COMPELETED'
                                   OR UPPER (v_iudphase) = 'COMPLETE'
                                   OR UPPER (v_iurstatus) = 'ERROR'
                                   OR UPPER (v_iudstatus) = 'ERROR';
                          END LOOP;
                       END;
                    END IF;
                  END;				 
  
                  --
                  BEGIN
                    IF    (v_req_id = 0)
                       OR (UPPER (v_iurstatus) = 'ERROR')
                       OR (UPPER (v_iudstatus) = 'ERROR')
                    THEN
                       v_iuretcode := 2;
                       v_iuerrbuf := 'Call unsuccessful ' || v_iumessage;
                    ELSIF    (UPPER (v_iurstatus) = 'WARNING')
                          OR (UPPER (v_iudstatus) = 'WARNING')
                    THEN
                       v_iuretcode := 1;
                    END IF;
                  END;
     
                  BEGIN
                    SELECT DECODE (v_iuretcode,
                                   0, 'NORMAL',
                                   1, 'WARNING',
                                   2, 'ERROR'
                                  )
                      INTO v_iutext
                      FROM DUAL;
                  EXCEPTION
                    WHEN NO_DATA_FOUND
                    THEN
                       Fnd_File.put_line (Fnd_File.LOG, '****Aborting******');
                       Fnd_File.put_line (Fnd_File.LOG,
                                          'ERR(100):No Process for ECO'
                                         );
                  END;
  			    --
			    END IF;  --IF p_common_org_sequence = 1 THEN			
			--

Fnd_File.put_line (Fnd_File.LOG, 'Before BOMPCMBM... : common_org_sequence: '||p_common_org_sequence);		            
Fnd_File.put_line (Fnd_File.LOG, 'Before BOMPCMBM... : common_org_id: '||c_eco_rec.common_org_id);	
Fnd_File.put_line (Fnd_File.LOG, 'Before BOMPCMBM... : assembly_item_id: '||c_eco_rec.assembly_item_id);	
Fnd_File.put_line (Fnd_File.LOG, 'Before BOMPCMBM... : org_id: '||c_eco_rec.organization_id);				
                --
                -- Create the common bom for all child orgs (like PIE, PTW for PNA)...not for main orgs like PNA, ENU etc
                --
                IF p_common_org_sequence = 2 and l_bom_count = 0 THEN -- Only for child orgs like PIE, PTW etc
                   Fnd_File.put_line (Fnd_File.LOG,
                                             '****Start Common BOM creation****** '|| c_eco_rec.organization_id);
Fnd_File.put_line (Fnd_File.LOG, 'In BOMPCMBM... : common_org_sequence: '||p_common_org_sequence);
                    BEGIN
                    	  v_req_id := Fnd_Request.SUBMIT_REQUEST('BOM','BOMPCMBM','','',NULL,1,''
            					                    , c_eco_rec.common_org_id, c_eco_rec.assembly_item_id ,'',
            			 							c_eco_rec.organization_id, c_eco_rec.assembly_item_id,
            			 							Fnd_Global.local_chr(0),
                                                	'','','','','','','','','',
                                                	'','','','','','','','','','',
                                   			 		'','','','','','','','','','',
                                                    '','','','','','','','','','',
                                                    '','','','','','','','','','',
                                                    '','','','','','','','','','',
                                                    '','','','','','','','','','',
                                   	                '','','','','','','','','','',
                                                    '','','','','','','','');
                	  --														 
                      COMMIT;
					  --
                      UPDATE ggl_plm_bom_int gb
                         SET error_messg      = NULL,
                             process_flag     = 'IN_INTERFACE',						 
                             --process_flag     = 'IN_PROCESS',
                             created_by       = v_user_id,
                             creation_date    = SYSDATE,
                             last_updated_by  = v_user_id,
                             last_update_date = SYSDATE
                       WHERE gb.ROWID = c_bom_rec.row_id;
											  
					EXCEPTION
					   WHEN OTHERS THEN
					   	Fnd_File.put_line (Fnd_File.LOG, 'Exception BOMPCMBM... : v_req_id: '||v_req_id);
						--			  				
				   		iupdate_eco (p_change_notice, 'COMMON_BOM_API_ERROR'
				   					,'<<COMMON BOM CREATION API>> failed for ECO#:... '
                      			|| c_eco_rec.change_notice||'; as icheck_eco_status failed...');							
                    END;      			
                END IF; 	  --p_common_org_sequence = 2 THEN 
Fnd_File.put_line (Fnd_File.LOG, 'After BOMPCMBM... : v_req_id: '||v_req_id);		            
			  --
			  ELSE
				--
				-- Update all ECO records with the status as 'ERROR'  
				-- 
            	   Fnd_File.put_line (Fnd_File.LOG, '<<ECO IMPL API>> is not being called for ECO#:... '
                               || c_eco_rec.change_notice||'; Update the ECO as ECO_ERROR...'
                              );
				--			  				
				   iupdate_eco (p_change_notice, 'IMPL_ECO_ERROR'
				   		,'<<ECO IMPL API>> is not being called for ECO#:... '
                      || c_eco_rec.change_notice||'; as icheck_eco_status failed...');
				--
                   e_transaction_id      := nvl(c_bom_rec.ggl_plm_bom_int_id,p_change_notice);
                   e_transaction_line_id := '';
    			   e_error_desc			 := '<<IMPLEMENT_ECO API ERR: >> At least one comp or Sub-comp did not get created in this ECO';
    			   e_sugg_action		 := 'Check ECO for missing components and/or sub components...'; 
                   Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                          (e_transaction_id,
                                                           e_transaction_line_id,
                                                           e_transaction_source,
                                                           e_error_desc,
                                                           e_sugg_action,
                                                           v_user_id,
                                                           e_err_ret_code
                                                          );
                   e_error_desc  := '';
                   e_sugg_action := '';				   
				   COMMIT;
				--  
			END IF;		--IF icheck_eco_status(c_eco_rec.change_notice) <> -1 THEN				  
			--
--         END LOOP; 		--BOM 
		 --   
      END LOOP;         --ECO	  
	  COMMIT;		     
   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := 'Unknown Fatal error insert_bom_interface :'||SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line (Fnd_File.LOG, v_error);
			--
                   e_transaction_id      := p_change_notice;
                   e_transaction_line_id := '';
    			   e_error_desc			 := v_error;
    			   e_sugg_action		 := 'Check insert_bom_interface code...'; 
                   Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                          (e_transaction_id,
                                                           e_transaction_line_id,
                                                           e_transaction_source,
                                                           e_error_desc,
                                                           e_sugg_action,
                                                           v_user_id,
                                                           e_err_ret_code
                                                          );
                   e_error_desc  := '';
                   e_sugg_action := '';				   
				   COMMIT;
						   
   END insert_bom_interface;



-- ===========================================================================================
--
-- This procedure is used to validate records in the staging table with process_flag = 'CLEAN 
-- RK: After validation it writes bom, comp, and sub comp records into _INT tables for further processing.
--
-- ==========================================================================================



   PROCEDURE ivalidation (p_errbuf OUT VARCHAR2, p_errcode OUT NUMBER, p_change_notice VARCHAR2)
   IS
   
   
     -- 
	 -- This cursor will pick up all the records in the staging table 
	 -- with process flag = clean 
	 -- And also there should not be nay ERROR records for that change notice 
	 --
      CURSOR c_bom_comp
      IS
           SELECT   c.*, c.container_name container_map, c.ROWID row_id
             FROM   ggl_plm_bom_staging c
            WHERE   c.container_name IN ('PLATFORM', 'ENTERPRISE','GIG','CITYBLOCK')
              AND   c.process_flag = 'CLEAN'
		      AND 	c.change_notice = p_change_notice			  
              AND   ((c.item_number, c.revision) 
			         NOT IN (
                                  SELECT e.item_number,
                                         e.revision
                                    FROM ggl_plm_bom_staging e
                                   WHERE e.process_flag = 'ERROR'
								   	 AND e.change_notice = p_change_notice	
								   ) -- only error or should we include other statuses 
                    )
              AND  ((NOT EXISTS (
                                  SELECT 1
                                    FROM ggl_plm_bom_staging e
                                   WHERE e.change_notice =  c.change_notice
								    -- AND e.revision 	 = c.revision --RK: Added to process records with same ecn but different revision???
									 AND e.change_notice = p_change_notice	
                                     AND e.process_flag  = 'ERROR')
                    )
                   )
         ORDER BY  item_number,
                   component_item_number,
                   substitute_component_number;
  
    
	  
	  --
	  -- Comments  Why do we need this cursor Please explain  
	  --
      CURSOR c_org (p_container_name VARCHAR2)
      IS	  
         SELECT   DECODE (substr(v.flex_value,1,3),
                          v.attribute1, 1,
                          2
                         ) common_org_sequence,
                  v.attribute1 common_org, p.organization_code,
                  p.organization_id
             FROM fnd_flex_values_vl v,
                  fnd_flex_value_sets s,
                  mtl_parameters p
            WHERE s.flex_value_set_name  = 'GGL_MAP_BOM_CONTAINER_ORG'
              AND v.flex_value_set_id    = s.flex_value_set_id
              AND v.description          = p_container_name
              AND substr(v.flex_value,1,3) = p.organization_code
              AND v.enabled_flag         = 'Y'
         ORDER BY 1;

		 
	  --
	  -- Why are we doing this EIR /ENU 2  
	  -- ENU/ENU = 1 
	  -- PNA/PNA = 1 PTW/PNA 2   
	  --
      CURSOR c_organization
      IS
         SELECT   DECODE (v.flex_value,
                          v.attribute1, 1,
                          2
                         ) common_org_sequence,
                  v.flex_value organization_code
             FROM fnd_flex_values_vl v, fnd_flex_value_sets s
            WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
              AND v.flex_value_set_id = s.flex_value_set_id
              AND v.description IN ('PLATFORM', 'ENTERPRISE','GIG','CITYBLOCK')
              AND v.enabled_flag = 'Y'
         ORDER BY 1;


      v_organization_code              VARCHAR2 (3)                      := '';
      v_ggl_plm_bom_int_id             ggl_plm_bom_int.ggl_plm_bom_int_id%TYPE;
      v_ggl_plm_bom_comp_int_id        ggl_plm_bom_comp_int.ggl_plm_bom_comp_int_id%TYPE;
      v_ggl_plm_bom_comp_sub_int_id    ggl_plm_bom_comp_sub_int.ggl_plm_bom_comp_sub_int_id%TYPE;
	  --
      v_common_assembly_item_id        ggl_plm_bom_int.common_assembly_item_id%TYPE;
      v_routing_operation_seq_num      NUMBER;
      v_routing_department_code        VARCHAR2 (10);
	  v_error_code                     NUMBER := 0;
	  --
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE
                                              := 'PLM_BOM_GGL_PLM_BOM_STAGING';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
      e_err_ret_code                   NUMBER;
	  
      error_on_insert_in_error_table   EXCEPTION;
      error_on_delete_in_error_table   EXCEPTION;
	  --
   BEGIN
      --
	  p_errcode := 0;
	  
	  Fnd_File.put_line (Fnd_File.LOG, ' ');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');
      Fnd_File.put_line (Fnd_File.LOG, '1) PROCESS:   Starting the Validation Process <<In iValidation>> process....');
	  Fnd_File.put_line (Fnd_File.LOG, '------------------------------------------------------------------------------------- ');

      BEGIN
	     -- Why do we need this  K
         SELECT substr(v.flex_value,1,3)
           INTO v_organization_code
           FROM fnd_flex_values_vl v, fnd_flex_value_sets s
          WHERE s.flex_value_set_name = 'GGL_MAP_BOM_CONTAINER_ORG'
            AND v.flex_value_set_id = s.flex_value_set_id
            AND v.enabled_flag = 'Y'
            AND ROWNUM = 1
            AND NOT EXISTS (SELECT 1
                              FROM mtl_parameters p
                             WHERE substr(v.flex_value,1,3) = p.organization_code);
      EXCEPTION
         WHEN OTHERS
         THEN
            v_organization_code := ''; 
      END;

	  
	  
	  -- This should be null  
      IF v_organization_code IS NOT NULL
      THEN                                                --Organization setup  
         Fnd_File.put_line
            (Fnd_File.LOG,
                v_organization_code
             || '2) ERROR:   Organization or Value Set GGL_MAP_BOM_CONTAINER_ORGANIZATION_CODE is not Setup Correctly.'
            );
         p_errcode := -1;
		 --
      ELSE                                                --Organization setup  
	     
		   Fnd_File.put_line
            (Fnd_File.LOG,
                v_organization_code
             || '2) SUCCESS:   Organization and Value Set GGL_MAP_BOM_CONTAINER_ORGANIZATION_CODE Setup Correctly.'
            );
		 --
		 -- Get the operation sequence Number for each organization code 
		 -- 
		                                               
         FOR c_organization_rec IN c_organization
         LOOP 					   				  --COMMON ITEM SETUP   
		    IF c_organization%NOTFOUND THEN
			   Fnd_File.put_line (Fnd_File.LOG, ' GGL_MAP_BOM_CONTAINER_ORG ValueSet is not setup right');
				 --
				 -- Update all ECO records with the status as 'VALIDATION_ERROR'  
				 -- 
            	 Fnd_File.put_line (Fnd_File.LOG, '<<iVALIDATION ERROR>> No further processing for ECO#:... '
                               || p_change_notice||'; Update the ECO status as VALIDATION_ERROR...'
                              );
				 --			  				
				 iupdate_eco (p_change_notice, 'iVALIDATION_ERROR', 
				 	'<<iVALIDATION ERROR>> ECO#: '|| p_change_notice
					||'failed; GGL_MAP_BOM_CONTAINER_ORG ValueSet is not setup right');		
			END IF;
		                                       
		    --
            -- Find Common BOM and Routing for Item name COMMON ITEM 
			-- to be used for orgs other then PGA and ENU 
			--
            Fnd_File.put_line (Fnd_File.LOG, '              -------------------------------------------------------------');
		    Fnd_File.put_line (Fnd_File.LOG, '   LOOP1:     Organization Code  = ' ||c_organization_rec.organization_code);
			--
            BEGIN   
				p_errcode :=0;                                 --COMMON ITEM 
			   -- 
               SELECT s.operation_seq_num
                 INTO v_routing_operation_seq_num
                 FROM bom_operational_routings r,
                      bom_operation_sequences s,
                      bom_departments d,
                      mtl_parameters p,
                      mtl_system_items_b i
                WHERE i.segment1 		  	= 'COMMON ITEM'
                  AND p.organization_code   = c_organization_rec.organization_code
                  AND r.organization_id     = p.organization_id
                  AND r.assembly_item_id    = i.inventory_item_id
                  AND r.organization_id     = i.organization_id
                  AND s.routing_sequence_id = r.routing_sequence_id
                  AND s.department_id       = d.department_id
                  AND ROWNUM = 1;
				  --
                  Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   SUCCESS:   Common Item is Setup for Organization : '
                              || c_organization_rec.organization_code||' errcode: '||p_errcode
                             );
             EXCEPTION
               WHEN OTHERS
               THEN
                  Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   ERROR:     Common Item is not Setup for Organization : '
                              || c_organization_rec.organization_code||' errcode: '||p_errcode
                             );
                  p_errcode := -1;
             END;                                           --COMMON ITEM 
          END LOOP;                                         --COMMON ITEM SETUP 
		 
		 

         IF NVL (p_errcode, 0) != -1                   --p_errcode 
         THEN                                                      
            FOR c_bom_comp_rec IN c_bom_comp
            LOOP
			--
		     IF c_bom_comp%NOTFOUND THEN
		   	 	Fnd_File.put_line (Fnd_File.LOG, 'GGL_PLM_BOM_STAGING has atleast one record with status as ERROR...');
				--
				-- Update all ECO records with the status as 'VALIDATION_ERROR'  
				-- 
           	   	Fnd_File.put_line (Fnd_File.LOG, '<<VALIDATION ERROR>> No further processing for ECO#:... '
                              || p_change_notice||'; Update the ECO status as VALIDATION_ERROR...'
                             );
				--			  				
			   	iupdate_eco (p_change_notice, 'VALIDATION_ERROR',
				'GGL_PLM_BOM_STAGING has atleast one error record' );	
				--		
   				--  
   			    e_transaction_id      := c_bom_comp_rec.ggl_plm_bom_staging_id;
   			    e_transaction_line_id := '';
   			    e_error_desc          := 'GGL_PLM_BOM_STAGING has atleast one record with status as ERROR';
   			    e_sugg_action         := 'Please correct the issue before processing further';
   			    Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                             e_transaction_line_id,
                                                             e_transaction_source,
                                                             e_error_desc,
                                                             e_sugg_action,
                                                             v_user_id,
                                                             e_err_ret_code
                                                             );
   														  
       		    IF e_err_ret_code <> 0 THEN
       			   RAISE error_on_insert_in_error_table;
       		    END IF;   		   			   
									
		     END IF;  --c_bom_comp%NOTFOUND THEN 		
			
			   
			   v_error_code := 0;
			   Fnd_File.put_line (Fnd_File.LOG, '              -------------------------------------------------------------');
		       Fnd_File.put_line (Fnd_File.LOG,  '   LOOP2:    Processing');
               Fnd_File.put_line (Fnd_File.LOG, '   PROCESS:   '
			                      || ' CHANGE NOTICE= '
                                  ||   c_bom_comp_rec.change_notice
                                  || ' STAGING_ID= '
                                  || c_bom_comp_rec.ggl_plm_bom_staging_id
                                  || ' BOM Item= '
                                  || c_bom_comp_rec.item_number
                                  || ' REVISION= '
                                  || c_bom_comp_rec.revision
                                  || ' COMPONENT= '
                                  || c_bom_comp_rec.component_item_number
                                  || ' SUBSTITUTE= '
                                  || c_bom_comp_rec.substitute_component_number
                                  || ' PROCESS_FLAG= '
                                  || c_bom_comp_rec.process_flag                                  
                                 );
								 
          
               v_ggl_plm_bom_int_id          := '';
               v_ggl_plm_bom_comp_int_id     := '';
               v_ggl_plm_bom_comp_sub_int_id := '';

			   
               FOR c_org_rec IN c_org (c_bom_comp_rec.container_map)
               LOOP
			   --
               Fnd_File.put_line (Fnd_File.LOG, '              -------------------------------------------------------------');
		       Fnd_File.put_line (Fnd_File.LOG, '   LOOP3:     Processing = ' ||c_org_rec.organization_code);

                  --Check if records exist in custom interface table   
				  --
                  BEGIN
                     SELECT b.ggl_plm_bom_int_id
                       INTO v_ggl_plm_bom_int_id
                       FROM ggl_plm_bom_int b
                      WHERE b.item_number = c_bom_comp_rec.item_number
					    AND b.change_notice = p_change_notice	
                        AND b.revision = c_bom_comp_rec.revision
                        AND b.organization_id = c_org_rec.organization_id
                        AND b.process_flag IN ('NEW', 'IN_PROCESS');
				        --
                  Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   CHECK:     Data Found in the Interface table:   GGL_PLM_BOM_INT'
                              || c_org_rec.organization_code
                             );
				  --
                  EXCEPTION
                     WHEN NO_DATA_FOUND
                     THEN
                        BEGIN

                           Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '     CHECK:   No Data found in Interface table:  GGL_PLM_BOM_INT with Org: '
                              || c_org_rec.organization_code
                             );
							 
						   
                          --Records do not exist in custom interface table so insert record
                          --Create Sequence  
						  --
                           SELECT ggl_plm_bom_int_s.NEXTVAL
                             INTO v_ggl_plm_bom_int_id
                             FROM DUAL;

                           -- Find Common BOM and Routing for Item name COMMON ITEM 
						   -- to be used for orgs other then PNA and ENU  
						   --
                           BEGIN   
						      --                              --COMMON ITEM  
                              SELECT s.operation_seq_num,
                                     d.department_code,
                                     r.assembly_item_id
                                     --DECODE(C_BOM_COMP_REC.CONTAINER_NAME, 'PLATFORM', R.ASSEMBLY_ITEM_ID,'')
                                INTO v_routing_operation_seq_num,
                                     v_routing_department_code,
                                     v_common_assembly_item_id
                                FROM bom_operational_routings r,
                                     bom_operation_sequences s,
                                     bom_departments d,
                                     mtl_parameters p,
                                     mtl_system_items_b i
                               WHERE i.segment1 = 'COMMON ITEM'
                                 AND p.organization_id     = c_org_rec.organization_id
                                 AND r.organization_id     = p.organization_id
                                 AND r.assembly_item_id    = i.inventory_item_id
                                 AND r.organization_id     = i.organization_id
                                 AND s.routing_sequence_id = r.routing_sequence_id
                                 AND s.department_id       = d.department_id
                                 AND ROWNUM = 1;
								 --
                           EXCEPTION
                              WHEN OTHERS
                              THEN
                                 v_routing_operation_seq_num := '';
                                 v_routing_department_code   := '';
                                 v_common_assembly_item_id   := '';
								 --
                           		 Fnd_File.put_line (Fnd_File.LOG,
                                 		'     CHECK:   Common BOM and Routing not found :  GGL_PLM_BOM_INT for Org: '
                              				  || c_org_rec.organization_code											  
                             				  	 );								 
                   				--  
                   			    e_transaction_id      := c_bom_comp_rec.ggl_plm_bom_staging_id;
                   			    e_transaction_line_id := '';
                   			    e_error_desc          := 'Common BOM and Routing not found :  GGL_PLM_BOM_INT for Org: '
                              				  || c_org_rec.organization_code;
                   			    e_sugg_action         := 'Please create routing for COMMON ITEM in this ORG before processing further';
                   			    Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                                             e_transaction_line_id,
                                                                             e_transaction_source,
                                                                             e_error_desc,
                                                                             e_sugg_action,
                                                                             v_user_id,
                                                                             e_err_ret_code
                                                                             );
                			   	iupdate_eco (p_change_notice, 'VALIDATION_ERROR', e_error_desc );																				 							 
                           END;                                  --COMMON ITEM  
						   
                           BEGIN
						       --
                               INSERT INTO ggl_plm_bom_int (
										   ggl_plm_bom_int_id,
                                           item_number,
                                           organization_code,
                                           organization_id, process_flag,
                                           last_update_date,
                                           last_updated_by,
                                           creation_date,
                                           created_by,
                                           last_update_login,
                                           revision,
                                           container_name,
                                           common_item_number_bom,
                                           common_org,
                                           --   COMMON_ITEM_NUMBER_ROUTING,
                                           --   COMMON_ROUTING_SEQUENCE_ID,
                                           routing_operation_seq_num,
                                           routing_department_code,
                                           common_assembly_item_id,
                                           change_notice
                                          )
                                   VALUES (v_ggl_plm_bom_int_id,
                                           c_bom_comp_rec.item_number,
                                           c_org_rec.organization_code,
                                           c_org_rec.organization_id, 
										   'NEW',  
                                           c_bom_comp_rec.last_update_date,
                                           c_bom_comp_rec.last_updated_by,
                                           c_bom_comp_rec.creation_date,
                                           c_bom_comp_rec.created_by,
                                           c_bom_comp_rec.last_update_login,
                                           c_bom_comp_rec.revision,
                                           c_bom_comp_rec.container_name,
                                           DECODE
                                               (c_org_rec.common_org_sequence,
                                                2, c_bom_comp_rec.item_number
                                               ),
                                           DECODE
                                               (c_org_rec.common_org_sequence,
                                                2, c_org_rec.common_org
                                               ),
                                           --    V_COMMON_ITEM_NUMBER_ROUTING,
                                           --    V_COMMON_ROUTING_SEQUENCE_ID,
                                           v_routing_operation_seq_num,
                                           v_routing_department_code,
                                           v_common_assembly_item_id,
                                           c_bom_comp_rec.change_notice
                                          );
                            Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '    INSERT:   Inserted Data Into Interface table:   GGL_PLM_BOM_INT with Org : '
                              || c_org_rec.organization_code
                             );
							
                           EXCEPTION
                              WHEN OTHERS
                              THEN
							     v_error_code := 1;
                                 v_error := SUBSTR (SQLERRM, 1, 500);
								 --
                                 Fnd_File.put_line
                                    (Fnd_File.LOG,
                                        '   ERROR:    Unable to Insert Into Interface table:  GGL_PLM_BOM_INT '
                                     || v_error
                                    );
                           END;
                        END;
                  END;

				  
				     
                  IF c_org_rec.common_org_sequence = 1
                  THEN
				       --
				       Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   CHECK:     Common Org Sequence for this = '  
                              || c_org_rec.common_org_sequence
                             );
							 
                     BEGIN
					    -- We dont need revisions?      
                        SELECT b.ggl_plm_bom_comp_int_id, effectivity_date
                          INTO v_ggl_plm_bom_comp_int_id, c_bom_comp_rec.effectivity_date
                          FROM ggl_plm_bom_comp_int b
                         WHERE b.item_number = c_bom_comp_rec.item_number
                           AND b.component_item_number =  c_bom_comp_rec.component_item_number
                           --     AND B.REVISION = C_BOM_COMP_REC.REVISION 
                           AND b.organization_id = c_org_rec.organization_id
						   AND b.change_notice = p_change_notice	
                           AND b.process_flag IN ('NEW', 'IN_PROCESS');
						   --
					  
                     Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   CHECK:     Data Found in the Interface table:  GGL_PLM_BOM_COMP_INT'
                              || c_org_rec.organization_code
                             );
					 --
                     EXCEPTION
                        WHEN NO_DATA_FOUND
                        THEN
                           BEGIN
                           Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '     CHECK:   No Data found in Interface table: GGL_PLM_BOM_COMP_INT'
                              || c_org_rec.organization_code
                             );
							 
						      --
                              --Records do not exist in custom interface table so insert record  
                              --Create Sequence
							  --
							  
                              SELECT ggl_plm_bom_comp_int_s.NEXTVAL
                                INTO v_ggl_plm_bom_comp_int_id
                                FROM DUAL;

							  --
							  --
                              IF NVL (c_bom_comp_rec.effectivity_date, SYSDATE) <= SYSDATE
                              THEN
                                 c_bom_comp_rec.effectivity_date :=  SYSDATE;
                              END IF;

							  --
							  --RK: ACD_TYPE, and DISABLE_DATE added 
							  --
                              BEGIN
                                 INSERT INTO ggl_plm_bom_comp_int
                                             (ggl_plm_bom_comp_int_id,
                                              ggl_plm_bom_int_id,
                                              --            GGL_PLM_BOM_STAGING_ID,
                                              item_number,
                                              organization_code,
                                              component_item_number,
                                              component_revision,
                                              component_qty,
                                              organization_id,
                                              process_flag,
                                              created_by,
                                              creation_date,
                                              last_updated_by,
                                              last_update_date,
                                              container_name,
                                              effectivity_date,
                                              disable_date,
                                              change_notice,
											  acd_type
                                             )
                                      VALUES (v_ggl_plm_bom_comp_int_id,
                                              v_ggl_plm_bom_int_id,
                                              --   C_BOM_COMP_REC.GGL_PLM_BOM_STAGING_ID,
                                              c_bom_comp_rec.item_number,
                                              c_org_rec.organization_code,
                                              c_bom_comp_rec.component_item_number,
                                              c_bom_comp_rec.component_revision,
                                              DECODE
                                                 (c_bom_comp_rec.component_qty,
                                                  NULL, 0.01,
                                                  0, 0.01,
                                                  c_bom_comp_rec.component_qty
                                                 ),
                                              c_org_rec.organization_id,
                                              'NEW',             
                                              c_bom_comp_rec.created_by,
                                              c_bom_comp_rec.creation_date,
                                              c_bom_comp_rec.last_updated_by,
                                              c_bom_comp_rec.last_update_date,
                                              c_bom_comp_rec.container_name,
                                              NVL(trunc(C_BOM_COMP_REC.EFFECTIVITY_DATE),trunc(SYSDATE)),
											  --c_bom_comp_rec.effectivity_date, --RK: Commented on 072707; for adding a subcomp we need time portion
                                              --TRUNC(c_bom_comp_rec.effectivity_date),
											 DECODE(c_bom_comp_rec.comp_acd_type,3,c_bom_comp_rec.disable_date,NULL),   
                                              --c_bom_comp_rec.disable_date,
                                              c_bom_comp_rec.change_notice,
											  c_bom_comp_rec.comp_acd_type
                                             );
                            
                            Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '    INSERT:   Inserted Data Into Interface table:   GGL_PLM_BOM_COMP_INT'
                              || c_org_rec.organization_code
                             );
                              EXCEPTION
                                 WHEN OTHERS
                                 THEN
								    --
								    v_error_code := 1;
                                    v_error := SUBSTR (SQLERRM, 1, 500);
                                    Fnd_File.put_line
                                       (Fnd_File.LOG,
                                         '   ERROR:    Unable to Insert Into Interface table:  GGL_PLM_BOM_COMP_INT '
                                        || v_error
                                       );
                              END;
                           END;
                     END;

					 
					 
                     IF c_bom_comp_rec.substitute_component_number IS NOT NULL
                     THEN
					 --
                     Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   CHECK:     Substitute Component is Not Null. Will Insert into Table'
                              || c_org_rec.organization_code || 'Effective Date '|| c_bom_comp_rec.effectivity_date
                             );
							 
					    --
					    -- why are we not chacking if the substitute is not in the interface ? 
                        -- Create Sequence
						--
                        SELECT ggl_plm_bom_comp_sub_int_s.NEXTVAL
                          INTO v_ggl_plm_bom_comp_sub_int_id
                          FROM DUAL;

						--
						--RK: ACD_TYPE, and DISABLE_DATE added
						--Assumption: DISABLE_DATE is common for both comp and sub comp
						--
                        BEGIN
						   --
                           INSERT INTO ggl_plm_bom_comp_sub_int
                                       (ggl_plm_bom_comp_sub_int_id,
                                        ggl_plm_bom_comp_int_id,
                                        ggl_plm_bom_int_id,
                                        --    GGL_PLM_BOM_STAGING_ID,
                                        substitute_component_number,
                                        item_number,
                                        organization_code,
                                        component_item_number,
                                        component_qty,
                                        organization_id, process_flag,
                                        created_by,
                                        creation_date,
                                        last_updated_by,
                                        last_update_date,
                                        container_name,
                                        effectivity_date,
                                        change_notice,
										acd_type,
										disable_date
                                       )
                                VALUES (v_ggl_plm_bom_comp_sub_int_id,
                                        v_ggl_plm_bom_comp_int_id,
                                        v_ggl_plm_bom_int_id,
                                        --  C_BOM_COMP_REC.GGL_PLM_BOM_STAGING_ID,
                                        c_bom_comp_rec.substitute_component_number,
                                        c_bom_comp_rec.item_number,
                                        c_org_rec.organization_code,
                                        c_bom_comp_rec.component_item_number,
                                        DECODE (c_bom_comp_rec.component_qty,
                                                NULL, 0.01,
                                                0, 0.01,
                                                c_bom_comp_rec.component_qty
                                               ),
                                        c_org_rec.organization_id, 
										'NEW',
                                        c_bom_comp_rec.created_by,
                                        c_bom_comp_rec.creation_date,
                                        c_bom_comp_rec.last_updated_by,
                                        c_bom_comp_rec.last_update_date,
                                        c_bom_comp_rec.container_name,
										NVL(trunc(C_BOM_COMP_REC.EFFECTIVITY_DATE),trunc(SYSDATE)),	
                                        --c_bom_comp_rec.effectivity_date, --RK: Commented on 072707; for adding a subcomp we need time portion										
                                        --TRUNC(c_bom_comp_rec.effectivity_date),
--                                        NVL (c_bom_comp_rec.effectivity_date,SYSDATE),
                                        c_bom_comp_rec.change_notice,
										c_bom_comp_rec.sub_acd_type,
										c_bom_comp_rec.disable_date
                                       );
                            Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '    INSERT:   Inserted Data Into Interface table:   GGL_PLM_BOM_COMP_SUB_INT '
                              || c_org_rec.organization_code
                             );
							 
                        EXCEPTION
                           WHEN OTHERS
                           THEN
						      v_error_code := 0;
                              v_error := SUBSTR (SQLERRM, 1, 500);
                              Fnd_File.put_line
                                 (Fnd_File.LOG,
                                  '   ERROR:    Unable to Insert Into Interface table:  GGL_PLM_BOM_COMP_SUB_INT '
                                  || v_error
                                 );
                        END;
					 ELSE --IF c_bom_comp_rec.substitute_component_number IS NOT NULL
					 --
                     Fnd_File.put_line
                             (Fnd_File.LOG,
                                 '   CHECK:     Substitute Component is Null. Will not Insert into Table'
                              || c_org_rec.organization_code
                             );
					 
                     END IF; --IF c_bom_comp_rec.substitute_component_number IS NOT NULL
					 
                     IF v_error_code = 0 THEN
					 --
                      BEGIN
					  
                        UPDATE ggl_plm_bom_staging
                           SET process_flag = 'IN_PROCESS',
                               ggl_plm_bom_int_id           = v_ggl_plm_bom_int_id,
                               ggl_plm_bom_comp_int_id      = v_ggl_plm_bom_comp_int_id,
                               ggl_plm_bom_comp_sub_int_id  = v_ggl_plm_bom_comp_sub_int_id
                         WHERE ROWID = c_bom_comp_rec.row_id;
						 --
                         Fnd_File.put_line
                                       (Fnd_File.LOG,
                                           '   UPDATE:    Updated GGL_PLM_BOM_STAGING to IN_PROCESS '
                                        || c_bom_comp_rec.ggl_plm_bom_staging_id
                                       );
						 --
                      EXCEPTION
                        WHEN OTHERS 
                        THEN
                           v_error := SUBSTR (SQLERRM, 1, 500);
                           Fnd_File.put_line
                              (Fnd_File.LOG,
                                  '   ERROR:  Unable to update GGL_PLM_BOM_STAGING with process_flag IN_PROCESS: '
                               || v_error
                              );

                      END;
					 ELSE  --IF v_error_code = 0 THEN
					   NULL; -- need some coding here 
					 END IF;  -- IF v_error_code = 0 THEN
					 --
                  END IF;  -- IF c_org_rec.common_org_sequence = 1
               END LOOP;
            END LOOP;
            --

		    --
		    --
            FOR c_organization_rec IN c_organization
            LOOP
			      --
				  Fnd_File.put_line (Fnd_File.LOG,'');
                  Fnd_File.put_line (Fnd_File.LOG,
                                     '   PROCESS:     Start bom validation for Organization = '
                                  || c_organization_rec.organization_code
                                 );
				  --		 
                  ivalidate_bom_recs (c_organization_rec.organization_code,
                                    c_organization_rec.common_org_sequence,
									p_change_notice	
                               );
					
								  
                --
                -- Create Component for PGA and ENU for all other 
				-- org create Common BOM so need to validate only PGA and ENU  
				--
				
				
               IF c_organization_rec.common_org_sequence = 1
               THEN
			      --
                  Fnd_File.put_line (Fnd_File.LOG,
                                        'Start comp Organization '
                                     || c_organization_rec.organization_code
                                    );
				  --			
                  ivalidate_inv_comp_recs (c_organization_rec.organization_code, p_change_notice);
				  --
				  -- To update the item_num with the right value; Increment it by 10 if it is a new inventory component record (BOM or ECO) 
				  --
				  iupdate_inv_comps(p_change_notice);
				  --
                  Fnd_File.put_line (Fnd_File.LOG,
                                        'Start substitute comp Organization '
                                     || c_organization_rec.organization_code
                                    );
				  --
                  ivalidate_sub_comp (c_organization_rec.organization_code, p_change_notice);
				  --
               END IF;
			   --
            END LOOP;
			--
            COMMIT;
			
            --
			--
			--
            FOR c_organization_rec IN c_organization
            LOOP
			   --
               Fnd_File.put_line (Fnd_File.LOG,
                                     'Start bom insert Organization '
                                  || c_organization_rec.organization_code
                                 );
			    --
			    --
                 insert_bom_interface (c_organization_rec.organization_code,
                                     c_organization_rec.common_org_sequence,
				     				 p_change_notice
                                     );
            END LOOP;
        
			 
              COMMIT;
         --ELSIF NVL (p_errcode, 0) = -1 THEN
		 END IF;        --IF NVL (p_errcode, 0) != -1                   --p_errcode
      END IF;                                             --Organization setup  

      Fnd_File.put_line (Fnd_File.LOG, '   END: End Of IVALIDATION Process: ');
	  --
   EXCEPTION
      WHEN error_on_insert_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATION UNABLE TO INSERT RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN error_on_delete_in_error_table
      THEN
         Fnd_File.put_line
            (Fnd_File.LOG,
                'GGL_PLM_BOM_INTERFACE.IVALIDATION UNABLE TO DELETE RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN NO_DATA_FOUND
      THEN
         Fnd_File.put_line
                    (Fnd_File.LOG,
                        'GGL_PLM_BOM_INTERFACE.IVALIDATION WHEN NO DATA FOUND EXCEPTION '
                     || SQLERRM
                    );			
      WHEN OTHERS
      THEN
         Fnd_File.put_line
                    (Fnd_File.LOG,
                        'GGL_PLM_BOM_INTERFACE.IVALIDATION OTHERS EXCEPTION '
                     || SQLERRM
                    );
   END ivalidation;


   
  
-- ========================================================================================
--
--  Created - Ramesh Kamineni 
-- This procedure is used to validate the records in the staging table
-- and derive the acd_type. If the record is new acd_type will be 1. 
-- If there is a change in the existing record then acd_type = 2 
-- if the records is not available  the new record is assumed as disabled 
-- and will be inserted into the staging tables 
--
-- ========================================================================================
   
   
    
   PROCEDURE check_bom_update (p_change_notice IN VARCHAR2)
   AS
   
   
   CURSOR c_check_bom
	  IS
         SELECT DISTINCT 
		        change_notice, 
				item_number, 
				inventory_item_id,
                gbst.process_flag, 
				mp.organization_id
           FROM ggl_plm_bom_staging gbst, 
		        mtl_system_items_b msi,
		        mtl_parameters     mp
          WHERE gbst.process_flag  = 'CLEAN'
		    AND gbst.item_number   = msi.segment1
		    AND gbst.change_notice = p_change_notice
			AND msi.organization_id    = mp.organization_id
			AND mp.organization_code = DECODE(gbst.container_name, 'ENTERPRISE', 'ENU', 'PLATFORM' 
									   				,'PNA', 'GIG','ZGA','CITYBLOCK','GCU', 'PNA')
			AND gbst.disable_date IS NULL;
			

						 			
			
     CURSOR c_check_comp (p_item_number   IN VARCHAR2, 
	                          p_change_notice IN VARCHAR2)
	  IS
         SELECT DISTINCT 
		        g.item_number,
				g.component_item_number,
   				DECODE(g.component_qty, 
                           NULL, 0.01,
                           0, 0.01,
                           g.component_qty) component_qty,				
				--g.component_qty, 
				g.effectivity_date,
				g.disable_date,
                g.process_flag,
                g.comp_acd_type,
				g.change_notice --, g.rowid row_id
           FROM ggl_plm_bom_staging g
          WHERE g.process_flag ='CLEAN'
		    AND g.change_notice = p_change_notice
			AND g.item_number = p_item_number
			AND disable_date IS NULL;
			

			
     CURSOR c_check_sub (p_item_number IN VARCHAR2, p_component_item IN VARCHAR2, p_change_notice IN VARCHAR2)
	  IS
         SELECT DISTINCT 
		        g.item_number,
				g.component_item_number,
				g.substitute_component_number,
   				DECODE(g.substitute_item_quantity,  
                           NULL, 0.01,
                           0, 0.01,
                           g.substitute_item_quantity) substitute_item_quantity				
				--g.substitute_item_quantity 
           FROM ggl_plm_bom_staging g
          WHERE g.process_flag ='CLEAN'
		    AND g.change_notice = p_change_notice
			AND g.item_number   = p_item_number
			AND g.component_item_number = p_component_item
			AND g.substitute_component_number IS NOT NULL
			AND disable_date IS NULL;
			
	
	--	
	v_bill_sequence_id 		NUMBER;
	v_component_quantity	NUMBER  := -999;
	v_component_seq_id      NUMBER;
	v_sub_component_id      NUMBER;
	v_sub_quantity			NUMBER  := -999;
			
	
   BEGIN

      BEGIN
	  
	  Fnd_File.put_line (Fnd_File.LOG, 'Starting update loop...'); 
      FOR c_check_bom_rec IN c_check_bom  -- bom  
	   LOOP
	   
	   Fnd_File.put_line (Fnd_File.LOG, 'Inside update loop...'); 
	   
		  BEGIN -- bom 1 
		    SELECT bill_sequence_id
              INTO v_bill_sequence_id
              FROM bom_bill_of_materials bbm
             WHERE bbm.organization_id  = c_check_bom_rec.organization_id 
               AND bbm.assembly_item_id = c_check_bom_rec.inventory_item_id
               AND ROWNUM = 1;
			   
			Fnd_File.put_line (Fnd_File.LOG, 'Bill Exists for this Item...'||
                    c_check_bom_rec.item_number||' ECN#: '||c_check_bom_rec.change_notice); 
			   
                Fnd_File.put_line (Fnd_File.LOG, 'Just before Comp loop...');
                
	      		FOR c_check_comp_rec IN c_check_comp(c_check_bom_rec.item_number, 
				                                     c_check_bom_rec.change_notice)
		   		LOOP
                     Fnd_File.put_line (Fnd_File.LOG, 'Just after Comp loop...');
                     Fnd_File.put_line (Fnd_File.LOG, '01-Bill Exists for this component - item#:'||c_check_bom_rec.item_number
                                                        ||';  Comp#: '||c_check_comp_rec.component_item_number
                                                        ||'; Process_flag: '||c_check_comp_rec.process_flag
                                                        --||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );
                            --v_component_quantity := -999;    
							--v_component_seq_id := -999;
		        BEGIN
                     Fnd_File.put_line (Fnd_File.LOG, 'Just After BEGIN..In Comp loop...');    
                     Fnd_File.put_line (Fnd_File.LOG, '11-Bill Exists for this component - item#:'||c_check_bom_rec.item_number
                                                        ||'comp#: '||c_check_comp_rec.component_item_number
                                                        ||'process_flag: '||c_check_comp_rec.process_flag
                                                        --||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );  
                                                                                     
--                     Fnd_File.put_line (Fnd_File.LOG, '11-Bill Exists for this component - item#:'||c_check_bom_rec.item_number
--                                                        ||'comp#: '||c_check_comp_rec.component_item_number
--                                                        ||'process_flag: '||c_check_comp_rec.process_flag
--                                                        ||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
--                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
--                                                        ||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
--                                                        );  
--                  BEGIN
			 		SELECT  DISTINCT
		        		    b.component_quantity,
							b.component_sequence_id
		        	  INTO  
		        		    v_component_quantity,
							v_component_seq_id
		   			 FROM   bom_inventory_components b , mtl_system_items_b m
		  			 WHERE  b.bill_sequence_id = v_bill_sequence_id
					 AND    b.disable_date IS NULL 
					 AND    b.component_item_id = m.inventory_item_id
					 AND    m.organization_id = c_check_bom_rec.organization_id
					 AND    m.segment1 = c_check_comp_rec.component_item_number
					 AND 	b.implementation_date is not null    --RK: Added to fix multiple rows exception because of non implemented comps
                     AND    rownum = 1; 
					 
                     Fnd_File.put_line (Fnd_File.LOG, '2-Bill Exists for this component - item#:'||c_check_bom_rec.item_number
                                                        ||'; comp#: '||c_check_comp_rec.component_item_number
                                                        ||'; process_flag: '||c_check_comp_rec.process_flag
                                                        --||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );  

			         Fnd_File.put_line (Fnd_File.LOG, '2.1-Bill Exists for this component: '|| c_check_comp_rec.component_item_number);
                                                    
                     Fnd_File.put_line (Fnd_File.LOG, '3-Bill Exists for this component - item#:'||c_check_bom_rec.item_number
                                                        ||'; comp#: '||c_check_comp_rec.component_item_number
                                                        ||'; process_flag: '||c_check_comp_rec.process_flag
                                                        --||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );                                                    
--                  EXCEPTION
--                        WHEN OTHERS THEN NULL;       
--                            Fnd_File.put_line (Fnd_File.LOG, 'Bill Exists for this component - EXCEPTION = ' 
--					                                || c_check_comp_rec.component_item_number);                                                     
--				  END;	 
    				 --
    				 FOR c_check_sub_rec IN c_check_sub(c_check_comp_rec.item_number
                                        , c_check_comp_rec.component_item_number, c_check_comp_rec.change_notice)
    				  LOOP
                        Fnd_File.put_line (Fnd_File.LOG, 'Inside update substitute loop ...BEFORE IF'); 	
                       IF c_check_sub%NOTFOUND THEN
                            Fnd_File.put_line (Fnd_File.LOG, 'Inside substitute loop: No Substitutes for comp#: '
                                                   ||c_check_comp_rec.component_item_number); 	
                       ELSE
                            Fnd_File.put_line (Fnd_File.LOG, 'Inside substitute loop: Substitutes found for comp#: '
                                                   ||c_check_comp_rec.component_item_number);                             
    				    BEGIN
    					   Fnd_File.put_line (Fnd_File.LOG, 'Inside update substitute loop ...IN ELASE..BEFORE SELECT SUB'); 					       
    				 		SELECT 
    						       substitute_component_id,
    						       substitute_item_quantity
    						  INTO v_sub_component_id,
    						       v_sub_quantity
    						  FROM bom_substitute_components a, 
    						       mtl_system_items_b b
    						 WHERE a.component_sequence_id  = v_component_seq_id
    						   AND a.substitute_component_id = b.inventory_item_id
    						   AND b.organization_id =  c_check_bom_rec.organization_id
    						   AND b.segment1 = c_check_sub_rec.substitute_component_number
							   AND a.acd_type <> 3; --RK:07312007- Added to fix 'No Change in Component' Issue...
                               
    					   Fnd_File.put_line (Fnd_File.LOG, 'Inside update substitute loop ...IN ELASE..AFTER SELECT SUB');
                                						   
    					 IF  ((v_sub_quantity <> c_check_comp_rec.component_qty)
							  --(v_sub_quantity <> c_check_sub_rec.substitute_item_quantity)
							  --RK:080107 - This scenario might not occur in PLM at this point of time.
							) THEN
    						 Fnd_File.put_line (Fnd_File.LOG, 'Component is changed..substitute loop-001...'); 
    					    --
    			       		UPDATE ggl_plm_bom_staging
    			   	   		SET    sub_acd_type          = 2
								   ,comp_acd_type 		 = 2 --RK:000000 - Added to make sure substitute additions are taken care for existing comps
    		     	   		 WHERE change_notice         = c_check_bom_rec.change_notice
    			   	   		 AND   item_number           = c_check_bom_rec.item_number
    						 AND   component_item_number = c_check_comp_rec.component_item_number
							 --RK:07312007 - We should update only that substitute not other subs of same comp
							 AND   substitute_component_number = c_check_sub_rec.substitute_component_number  
    			   	   		 AND   process_flag          = 'CLEAN'
    						 AND   disable_date IS NULL;
    						 
    						 Fnd_File.put_line (Fnd_File.LOG, 'Component is changed..substitute loop-002...'); 
    					    --
    					 ELSE
    						 Fnd_File.put_line (Fnd_File.LOG, 'Component NOT changed..substitute loop-003...'); 
                             
    			       		UPDATE ggl_plm_bom_staging
    			   	   		SET    
    			       	     	   sub_acd_type          = '',
    							   process_flag          = 'PROCESSED',
    							   error_messg           = 'No Change In Component/Substitute'
    		     	   		 WHERE change_notice         = c_check_bom_rec.change_notice
    			   	   		 AND   item_number           = c_check_bom_rec.item_number
    						 AND   component_item_number = c_check_comp_rec.component_item_number
							 --RK:07312007 - We should update only that substitute not other subs of same comp
							 AND   substitute_component_number = c_check_sub_rec.substitute_component_number  
    			   	   		 AND   process_flag          = 'CLEAN'
    						 AND   disable_date         IS NULL;

    						 Fnd_File.put_line (Fnd_File.LOG, 'Component is not changed..substitute loop...'); 
    			         END IF;
        	            EXCEPTION
        	              WHEN OTHERS THEN
    					   Fnd_File.put_line (Fnd_File.LOG, 'Inside update substitute loop - exception...sqlerrm: '||sqlerrm); 		    				  
             				UPDATE ggl_plm_bom_staging
             	   	        SET    comp_acd_type = 2,  --RK:073107 --comp found, sub not found
             	       	           sub_acd_type  = 1
                  	        WHERE  change_notice = c_check_bom_rec.change_notice
             	   	          AND  item_number   = c_check_bom_rec.item_number
    						  AND   component_item_number = c_check_comp_rec.component_item_number
							  --RK:07312007 - We should update only that substitute not other subs of same comp
							  AND   substitute_component_number = c_check_sub_rec.substitute_component_number  
             	   	          AND    process_flag  = 'CLEAN'
             		          AND    disable_date IS NULL;
    						   
    				    END;  
                       END IF; --c_check_sub%NOTFOUND THEN
    						 
    				  END LOOP; --end of substitute loop
					  
					--
					-- RK:073107 - Moved after substitute update to make sure other subs does not get updated-
					--             for the same component    
					--
                    Fnd_File.put_line (Fnd_File.LOG,'Just before Comp qty check: '
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );                    
                    
					IF    ( v_component_quantity <> c_check_comp_rec.component_qty) THEN
					   --OR (TRUNC(c_check_comp_rec.effectivity_date)) > TRUNC(SYSDATE) THEN
					    --
			       		UPDATE ggl_plm_bom_staging
			   	   		SET    comp_acd_type         = 2 
		     	   		 WHERE change_notice         = c_check_bom_rec.change_notice
			   	   		 AND   item_number           = c_check_bom_rec.item_number
						 AND   component_item_number = c_check_comp_rec.component_item_number
			   	   		 AND   process_flag          = 'CLEAN'
						 AND   disable_date          IS NULL;
                         --AND   ROWID                 = c_check_comp_rec.ROW_ID;
						 
						 Fnd_File.put_line (Fnd_File.LOG, 'Component is changed..component loop...'||c_check_comp_rec.component_item_number); 
					    --
					ELSE
					  BEGIN
                        Fnd_File.put_line (Fnd_File.LOG, 'COMPONENT NOT CHANGED - item#:'||c_check_bom_rec.item_number
                                                        ||'comp#: '||c_check_comp_rec.component_item_number
                                                        ||'process_flag: '||c_check_comp_rec.process_flag
                                                        --||'comp_acd_type: '||NVL(c_check_comp_rec.comp_acd_type,'NULL')
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );

			       		UPDATE ggl_plm_bom_staging
			   	   		SET    comp_acd_type         = '',
							   process_flag          = 'PROCESSED',
							   error_messg           = 'No Change In Component',
                               eco_status_message    = 'No Change In Component - Marked as PROCESSED'
		     	   		 WHERE change_notice         = c_check_bom_rec.change_notice
			   	   		 AND   item_number           = c_check_bom_rec.item_number
						 AND   component_item_number = c_check_comp_rec.component_item_number
			   	   		 AND   process_flag          = 'CLEAN'
						 AND   substitute_component_number is null 
						 --AND   comp_acd_type IS NULL --RK:073107 - It should not update if substitute changes are there from above loop 
						 AND   disable_date         IS NULL;
                         --AND   ROWID                 = c_check_comp_rec.ROW_ID;
                         commit;
						 Fnd_File.put_line (Fnd_File.LOG, 'Component not changed..updated to PROCESSED for '||c_check_comp_rec.component_item_number); 
					  EXCEPTION
                         WHEN NO_DATA_FOUND THEN
						    Fnd_File.put_line (Fnd_File.LOG, 'WNF:Component not changed..Could not update to PROCESSED for '
                                                ||c_check_comp_rec.component_item_number||sqlerrm);                          
					  	 WHEN OTHERS THEN 
						    Fnd_File.put_line (Fnd_File.LOG, 'WO: Component is not changed..Could not update to PROCESSED for '
                                                ||c_check_comp_rec.component_item_number||sqlerrm); 
					  END;	 
						 Fnd_File.put_line (Fnd_File.LOG, 'Component is not changed..component loop '||c_check_comp_rec.component_item_number); 
			        END IF;
                    
                    COMMIT;
                    Fnd_File.put_line (Fnd_File.LOG,'Just after Comp qty check: '
                                                        --||'v_comp_qty: '||NVL(v_component_quantity,'NULL')
                                                        --||'comp_qty: '||NVL(c_check_comp_rec.component_qty,'NULL')
                                                        );                     
				  --	 
	            EXCEPTION		  --comp loop exception
			     WHEN NO_DATA_FOUND THEN
				 
				  --NULL;
				 
			       UPDATE ggl_plm_bom_staging
			   	   SET    comp_acd_type = 1,
			       	      sub_acd_type  = 1
		     	   WHERE  change_notice = c_check_bom_rec.change_notice
			   	   AND    item_number   = c_check_bom_rec.item_number
				   AND   component_item_number = c_check_comp_rec.component_item_number   --RK: Added to fix the update with comp_acd_type=1 issue
			   	   AND    process_flag  = 'CLEAN'
				   AND    disable_date IS NULL;
				   
        			UPDATE ggl_plm_bom_staging
        			   SET sub_acd_type  = ''
        		     WHERE change_notice = c_check_bom_rec.change_notice
        			   AND item_number   = c_check_bom_rec.item_number
					   AND component_item_number = c_check_comp_rec.component_item_number  --RK: Added to fix the update with comp_acd_type=1 issue
        			   AND process_flag  = 'CLEAN'
        			   AND comp_acd_type = 1
        			   AND substitute_component_number IS NULL
        			   AND disable_date IS NULL;
					   Fnd_File.put_line (Fnd_File.LOG, 'Inside update comp loop - exception for new comp '||c_check_comp_rec.component_item_number
					   					 				||' with acd_type=1...sqlerrm: '||sqlerrm); 					 			 
			     WHEN OTHERS THEN
                     e_transaction_id      := p_change_notice;
                     e_transaction_line_id := '';
                     e_error_desc  := 'Unknown Fatal error in check_bom_update - WHEN OTHERS Exception for COMP# '||c_check_comp_rec.component_item_number
      			   					||'sqlerrm: '||substr(sqlerrm,1,500);
                     e_sugg_action := 'Please check iupdate_eco code and fix the error...';
      			   --			   
                     Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                            (e_transaction_id,
                                                             e_transaction_line_id,
                                                             e_transaction_source,
                                                             e_error_desc,
                                                             e_sugg_action,
                                                             v_user_id,
                                                             e_err_ret_code
                                                            );				 	  
			    END;
			 
		  	  	END LOOP; --comp loop
		        --
			--
	        EXCEPTION	  		 --bom loop exception
			 WHEN OTHERS THEN	

			Fnd_File.put_line (Fnd_File.LOG, 'Inside update loop11-exception...'); 
			
			UPDATE ggl_plm_bom_staging
			   SET comp_acd_type = 1,
			       sub_acd_type  = 1
		     WHERE change_notice = c_check_bom_rec.change_notice
			   AND item_number   = c_check_bom_rec.item_number
			   AND process_flag  = 'CLEAN'
			   AND   disable_date IS NULL;
			   
			UPDATE ggl_plm_bom_staging
			   SET 
			       sub_acd_type  = ''
		     WHERE change_notice = c_check_bom_rec.change_notice
			   AND item_number   = c_check_bom_rec.item_number
			   AND process_flag  = 'CLEAN'
			   AND comp_acd_type = 1
			   AND substitute_component_number IS NULL
			   AND disable_date IS NULL;
		        
	            
			END;  -- bom 1 
	   
	     END LOOP;   -- bom loop
      EXCEPTION		 --extra begin exception 
         WHEN OTHERS
         THEN
		
		 Fnd_File.put_line (Fnd_File.LOG, 'Inside begin (not proc begin)...'); 
            
            v_error := SUBSTR (SQLERRM, 1, 500);
            Fnd_File.put_line
               (Fnd_File.LOG,
                   'Verify :'
                || v_error
               );
      END;

      COMMIT;  

   EXCEPTION   --main exception 
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in check_bom_update - When others exception; sqlerrm:'
                            || v_error
                           );
               e_transaction_id      := -9991; --p_change_notice; --c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               e_error_desc  := 'Unknown Fatal error in check_bom_update - WHEN OTHERS Exception for ECN# '||p_change_notice
			   					||'sqlerrm: '||substr(sqlerrm,1,500);
               e_sugg_action := 'Please check check_bom_update code and fix the error...';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );							   
   END check_bom_update;
   
   
-- ========================================================================================
--
-- This procedure is used to cleanup records in the staging table ggl_plm_bom_staging 
-- All the records have to be cleaned up to remove duplicates 
--
-- ========================================================================================
   
     PROCEDURE bom_disable ( 
             p_change_notice     IN       VARCHAR2
   )
   AS
 
   
   CURSOR c_bom_disable
	  IS
         SELECT DISTINCT change_notice, item_number, inventory_item_id, mp.organization_id, container_name
           FROM ggl_plm_bom_staging gbst, mtl_system_items_b msi, mtl_parameters mp
          WHERE gbst.process_flag = 'CLEAN'
		    AND gbst.item_number = msi.segment1
		    AND gbst.change_notice = p_change_notice
			AND msi.organization_id = mp.organization_id
			AND mp.organization_code = DECODE(gbst.container_name,  'ENTERPRISE', 'ENU', 'PLATFORM' 
									   						,'PNA', 'GIG','ZGA','CITYBLOCK','GCU')
			AND comp_acd_type IS NULL
		  ORDER	BY item_number;
			
   
   CURSOR c_comp_disable (l_bill_sequence IN NUMBER,
                          p_org_id IN NUMBER)
   IS						 
	      SELECT  b.component_sequence_id , 
		          a.segment1, 
				  b.component_item_id,
				  b.component_quantity, 
				  a.organization_id,
				  b.inventory_item_status_code
			FROM  bom_inventory_components_v b, 
			      mtl_system_items_b a 
		    WHERE a.inventory_item_id = b.component_item_id
			  AND b.bill_sequence_id = l_bill_sequence
			  AND a.organization_id =  p_org_id
			  AND b.disable_date IS NULL
		 ORDER BY A.segment1;
			  
			  
   CURSOR c_sub_disable (p_comp_sequence_id IN NUMBER,
                         p_org_id IN NUMBER)
   IS						 
		   SELECT a.substitute_component_id,
				  b.segment1,
				  b.inventory_item_status_code --RK:07312007-Sub_item_status code should be used 
			FROM  bom_substitute_components a,
				  mtl_system_items_b b 
			WHERE a.component_sequence_id   = p_comp_sequence_id
			  AND a.substitute_component_id = b.inventory_item_id
		      AND a.acd_type 	    <> 3 --RK:07312007- Added to eliminate disabled records as we can not disable them again 
			  AND b.organization_id	= p_org_id;
			  
			  
   --
   l_bill_sequence_id     NUMBER;
   --
   v_staging_comp_item    VARCHAR2(60);
   v_staging_sub_item    VARCHAR2(60);
   v_comp_revision		  VARCHAR2(20);
   v_item_revision		  VARCHAR2(20); 
   v_bom_status_code      VARCHAR2(60);
   v_comp_status_code      VARCHAR2(60);
   v_count                NUMBER := 0;
   --
   
   BEGIN   
     --
     BEGIN
        Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     0 - BOM-DISABLE-STARTED; ITEM: '||c_bom_disable_rec.item_number);     
	  --
	  FOR  c_bom_disable_rec IN c_bom_disable 
	  LOOP
	  --
	  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     1; ITEM: '||c_bom_disable_rec.item_number);
	     BEGIN
	        SELECT bill_sequence_id
              INTO l_bill_sequence_id
              FROM bom_bill_of_materials bbm
             WHERE bbm.organization_id  = c_bom_disable_rec.organization_id 
               AND bbm.assembly_item_id = c_bom_disable_rec.inventory_item_id
               AND ROWNUM = 1;
			   
			   Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     2; bill_seq_id '||l_bill_sequence_id||
			   					 				' item: '||c_bom_disable_rec.item_number);
				   SELECT mir.revision, msi.inventory_item_status_code
                     INTO v_item_revision, v_bom_status_code
                     FROM mtl_item_revisions     mir
                       , mtl_system_items_b     msi
                   WHERE msi.segment1          = c_bom_disable_rec.item_number
                     AND msi.inventory_item_id = c_bom_disable_rec.inventory_item_id
                     AND msi.organization_id   = c_bom_disable_rec.organization_id
                     AND msi.inventory_item_id = mir.inventory_item_id
                     AND msi.organization_id = mir.organization_id
                     AND mir.effectivity_date = (SELECT MAX(b.effectivity_date)
                                                   FROM mtl_item_revisions b 
                                                  WHERE b.inventory_item_id = mir.inventory_item_id        
                                                    AND b.organization_id = mir.organization_id);
	   		 --
       	 	 FOR c_comp_disable_rec IN c_comp_disable(l_bill_sequence_id, c_bom_disable_rec.organization_id)
	    	 LOOP
			     --
		   	 	 BEGIN
		     	   SELECT DISTINCT 
				          component_item_number
			   	   INTO   v_staging_comp_item
				   FROM   ggl_plm_bom_staging
			       WHERE  component_item_number = c_comp_disable_rec.segment1
				   AND    item_number = c_bom_disable_rec.item_number
			       AND    change_notice = p_change_notice
			       AND    process_flag = 'CLEAN';
				   
				   SELECT mir.revision
                     INTO v_comp_revision
                     FROM mtl_item_revisions     mir
                       , mtl_system_items_b      msi
                   WHERE msi.segment1 = c_comp_disable_rec.segment1
                     AND msi.inventory_item_id = c_comp_disable_rec.component_item_id
                     AND msi.organization_id   = c_comp_disable_rec.organization_id
                     AND msi.inventory_item_id = mir.inventory_item_id
                     AND msi.organization_id = mir.organization_id
                     AND mir.effectivity_date = (SELECT MAX(b.effectivity_date)
                                                   FROM mtl_item_revisions b 
                                                  WHERE b.inventory_item_id = mir.inventory_item_id        
                                                    AND b.organization_id = mir.organization_id);				   
				   
				    Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     4; Comp_item: '||c_comp_disable_rec.segment1);
				 
 				   	FOR c_sub_disable_rec IN c_sub_disable(c_comp_disable_rec.component_sequence_id, c_bom_disable_rec.organization_id)
	    	 		LOOP --comp found and sub found
					Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     5; comp_seq_id: '||c_comp_disable_rec.component_sequence_id);
			     		--
		   	 	 		BEGIN
		     	   		SELECT   DISTINCT 
				          	     substitute_component_number
			   	   	      INTO   v_staging_sub_item
				   		  FROM   ggl_plm_bom_staging
			       		  WHERE  component_item_number = c_comp_disable_rec.segment1
						  AND    substitute_component_number = c_sub_disable_rec.segment1
						  AND    item_number = c_bom_disable_rec.item_number
			       		  AND    change_notice = p_change_notice
			       		  AND    process_flag = 'CLEAN';
						  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     6; Found sub_comp: '||c_sub_disable_rec.segment1);
						EXCEPTION 
		                 WHEN OTHERS THEN --comp found, sub not found 
												
                           Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     7; Not Found sub_comp: '||c_sub_disable_rec.segment1);
      					 
      			           INSERT INTO GGL_PLM_BOM_STAGING 
      					      (
      					       ggl_plm_bom_staging_id       ,
        					   item_number                  ,
        					   revision                     ,
        					   iteration                    ,
        					   container_name               ,
        					   bom_status_code              ,
        					   component_item_number        ,
        					   component_status_code        ,
        					   component_qty                ,
        					   effectivity_date             ,
        					   disable_date                 ,
        					   uom                          ,
        					   process_flag                 ,
        					   error_messg                  ,
        					   change_notice                ,
        					   transaction_date             ,
        					   substitute_component_number  ,
        					   substitute_status_code       ,
        					   substitute_item_quantity     ,
        					   plm_creator                  ,
        					   ggl_plm_bom_int_id           ,
        					   ggl_plm_bom_comp_int_id      ,
        					   ggl_plm_bom_comp_sub_int_id  ,
        					   created_by                   ,
        					   creation_date                ,
        					   last_updated_by              ,
        					   last_update_date             ,
        					   last_update_login            ,
        					   component_revision           ,
        					   comp_acd_type                ,
        					   sub_acd_type                 ,
        					   ext_attrib1                  ,
        					   ext_attrib2                  ,
        					   ext_attrib3                  ,
        					   ext_attrib4                  ,
        					   ext_attrib5                  )
      		 	   		    VALUES  (
      					       ggl_plm_bom_staging_s.NEXTVAL ,
        					   c_bom_disable_rec.item_number ,
        					   v_item_revision  ,
        					   1        ,
        					   c_bom_disable_rec.container_name, --'PLATFORM'           ,
        					   v_bom_status_code          ,
        					   c_comp_disable_rec.segment1 ,--component_item_number        ,
							   --v_bom_status_code     , RK: 071407 we should be using comp status from bom 
        					   c_comp_disable_rec.inventory_item_status_code,
        					   c_comp_disable_rec.component_quantity, --component_qty                ,
        					   SYSDATE             ,
        					   SYSDATE             ,
        					   'each'     ,
        					   'CLEAN'       ,
        					   ''            ,
        					   p_change_notice        ,
        					   SYSDATE ,
        					   c_sub_disable_rec.segment1 ,
							   c_sub_disable_rec.inventory_item_status_code, 
        					   --v_bom_status_code,		  --RK: 073107 We should be using sub status code, 
        					   '', --substitute_item_quantity     ,
        					   'Disabled Record'                  ,
        					   ''           ,
        					   ''      ,
        					   ''  ,
        					   v_user_id                   ,
        					   SYSDATE                ,
        					   v_user_id              ,
        					   SYSDATE             ,
        					   ''            ,
        					   v_comp_revision, --RK: 071307 use rev from comp found 
        					   2                ,
        					   3                 ,
        					   ''                  ,
        					   ''                 ,
        					   ''                  ,
        					   ''                  ,
        					   ''     );
						END;
				   
				    END LOOP; --comp found and sub found
				   
				 EXCEPTION 
		           WHEN OTHERS THEN  --comp NOT found 
				     --
				  v_count := 0;
							 
 				   	FOR c_sub_disable_rec IN c_sub_disable(c_comp_disable_rec.component_sequence_id, c_bom_disable_rec.organization_id)
	    	 		LOOP  --comp NOT found look for sub
			     		--
		   	 	 		BEGIN
		     	   		SELECT   DISTINCT 
				          	     substitute_component_number
			   	   	      INTO   v_staging_sub_item
				   		  FROM   ggl_plm_bom_staging
			       		  WHERE  component_item_number = c_comp_disable_rec.segment1
						  AND    NVL(substitute_component_number,'ZZZ') = NVL(c_sub_disable_rec.segment1,'ZZZ')
						  AND    item_number = c_bom_disable_rec.item_number
			       		  AND    change_notice = p_change_notice
			       		  AND    process_flag = 'CLEAN';
						  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     8; Found sub_item: '||v_staging_sub_item);
						  
						  
						EXCEPTION 
		                 WHEN OTHERS THEN	 --comp NOT found and Sub NOT found
					 
					 v_count := 1;
				   SELECT mir.revision, msi.inventory_item_status_code
                     INTO v_comp_revision, v_comp_status_code
                     FROM mtl_item_revisions     mir
                       , mtl_system_items_b      msi
                   WHERE msi.segment1 = c_comp_disable_rec.segment1
                     AND msi.inventory_item_id = c_comp_disable_rec.component_item_id
                     AND msi.organization_id   = c_comp_disable_rec.organization_id
                     AND msi.inventory_item_id = mir.inventory_item_id
                     AND msi.organization_id = mir.organization_id
                     AND mir.effectivity_date = (SELECT MAX(b.effectivity_date)
                                                   FROM mtl_item_revisions b 
                                                  WHERE b.inventory_item_id = mir.inventory_item_id        
                                                    AND b.organization_id = mir.organization_id);
													
              		Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     9; Not Found sub_item '||v_staging_sub_item);

			         INSERT INTO GGL_PLM_BOM_STAGING 
					   (
					   ggl_plm_bom_staging_id       ,
  					   item_number                  ,
  					   revision                     ,
  					   iteration                    ,
  					   container_name               ,
  					   bom_status_code              ,
  					   component_item_number        ,
  					   component_status_code        ,
  					   component_qty                ,
  					   effectivity_date             ,
  					   disable_date                 ,
  					   uom                          ,
  					   process_flag                 ,
  					   error_messg                  ,
  					   change_notice                ,
  					   transaction_date             ,
  					   substitute_component_number  ,
  					   substitute_status_code       ,
  					   substitute_item_quantity     ,
  					   plm_creator                  ,
  					   ggl_plm_bom_int_id           ,
  					   ggl_plm_bom_comp_int_id      ,
  					   ggl_plm_bom_comp_sub_int_id  ,
  					   created_by                   ,
  					   creation_date                ,
  					   last_updated_by              ,
  					   last_update_date             ,
  					   last_update_login            ,
  					   component_revision           ,
  					   comp_acd_type                ,
  					   sub_acd_type                 ,
  					   ext_attrib1                  ,
  					   ext_attrib2                  ,
  					   ext_attrib3                  ,
  					   ext_attrib4                  ,
  					   ext_attrib5                  )
		 	   VALUES  (
					   ggl_plm_bom_staging_s.NEXTVAL ,
  					   c_bom_disable_rec.item_number ,
  					   v_item_revision  ,
  					   1        ,
  					   c_bom_disable_rec.container_name, --'PLATFORM'           ,
  					   v_bom_status_code          ,
  					   c_comp_disable_rec.segment1 ,--component_item_number        ,
  					   v_comp_status_code     ,
  					   c_comp_disable_rec.component_quantity, --component_qty                ,
  					   SYSDATE   ,
  					   SYSDATE   ,
  					   'each'     ,
  					   'CLEAN'       ,
  					   ''            ,
  					   p_change_notice        ,
  					   SYSDATE ,
  					   c_sub_disable_rec.segment1, 
  					   --v_comp_status_code, --RK: 071407 we should be using comp status from bom 
					    c_sub_disable_rec.inventory_item_status_code, --RK: 073107 We should be using sub status code
    					--c_comp_disable_rec.inventory_item_status_code,
						--v_bom_status_code     , 
					   
  					   '', --substitute_item_quantity     ,
  					   'Disabled Record'                  ,
  					   ''           ,
  					   ''      ,
  					   ''  ,
  					   v_user_id                   ,
  					   SYSDATE                ,
  					   v_user_id              ,
  					   SYSDATE             ,
  					   ''            ,
  					   v_comp_revision, --c_comp_disable_rec.revision,--component_revision           ,
  					   3                ,
  					   3                 ,
  					   ''                  ,
  					   ''                 ,
  					   ''                  ,
  					   ''                  ,
  					   ''     );
					
                   END;
				  END LOOP;  --comp found and sub NOT found
				 
				 BEGIN	 --comp NOT found --Insert for comp
				 IF v_count = 0 THEN
				 Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     10');
				 SELECT mir.revision, msi.inventory_item_status_code
                     INTO v_comp_revision , v_comp_status_code	
                     FROM mtl_item_revisions     mir
                       , mtl_system_items_b      msi
                   WHERE msi.segment1 = c_comp_disable_rec.segment1
                     AND msi.inventory_item_id = c_comp_disable_rec.component_item_id
                     AND msi.organization_id   = c_comp_disable_rec.organization_id
                     AND msi.inventory_item_id = mir.inventory_item_id
                     AND msi.organization_id = mir.organization_id
                     AND mir.effectivity_date = (SELECT MAX(b.effectivity_date)
                                                   FROM mtl_item_revisions b 
                                                  WHERE b.inventory_item_id = mir.inventory_item_id        
                                                    AND b.organization_id = mir.organization_id);
													
                     Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     11; Not Found Comp : '||c_comp_disable_rec.segment1
					 				   				  	  			 	 ||' Revision: '||v_comp_revision);
					 
			         INSERT INTO GGL_PLM_BOM_STAGING 
					   (
					   ggl_plm_bom_staging_id       ,
  					   item_number                  ,
  					   revision                     ,
  					   iteration                    ,
  					   container_name               ,
  					   bom_status_code              ,
  					   component_item_number        ,
  					   component_status_code        ,
  					   component_qty                ,
  					   effectivity_date             ,
  					   disable_date                 ,
  					   uom                          ,
  					   process_flag                 ,
  					   error_messg                  ,
  					   change_notice                ,
  					   transaction_date             ,
  					   substitute_component_number  ,
  					   substitute_status_code       ,
  					   substitute_item_quantity     ,
  					   plm_creator                  ,
  					   ggl_plm_bom_int_id           ,
  					   ggl_plm_bom_comp_int_id      ,
  					   ggl_plm_bom_comp_sub_int_id  ,
  					   created_by                   ,
  					   creation_date                ,
  					   last_updated_by              ,
  					   last_update_date             ,
  					   last_update_login            ,
  					   component_revision           ,
  					   comp_acd_type                ,
  					   sub_acd_type                 ,
  					   ext_attrib1                  ,
  					   ext_attrib2                  ,
  					   ext_attrib3                  ,
  					   ext_attrib4                  ,
  					   ext_attrib5                  )
		 	   VALUES  (
					   ggl_plm_bom_staging_s.NEXTVAL ,
  					   c_bom_disable_rec.item_number ,
  					   v_item_revision  ,
  					   1        ,
  					   c_bom_disable_rec.container_name, --'PLATFORM'           ,
  					   v_bom_status_code          ,
  					   c_comp_disable_rec.segment1 ,--component_item_number        ,
  					   --v_comp_status_code     , --RK: 071407 we should be using comp status from bom
					   c_comp_disable_rec.inventory_item_status_code, 
  					   c_comp_disable_rec.component_quantity, --component_qty                ,
  					   SYSDATE ,
  					   SYSDATE ,
  					   'each'     ,
  					   'CLEAN'       ,
  					   ''            ,
  					   p_change_notice        ,
  					   SYSDATE ,
  					   '', 
  					   '',
  					   '', --substitute_item_quantity     ,
  					   'Disabled Record'                  ,
  					   ''           ,
  					   ''      ,
  					   ''  ,
  					   v_user_id                   ,
  					   SYSDATE                ,
  					   v_user_id              ,
  					   SYSDATE             ,
  					   ''            ,
  					   v_comp_revision, --c_comp_disable_rec.revision,--component_revision           ,
  					   3                ,
  					   ''                 ,
  					   ''                  ,
  					   ''                 ,
  					   ''                  ,
  					   ''                  ,
  					   ''     );
					   
					 END IF;
					END;
					--v_comp_revision := '';
				 END;
				 --
			 END LOOP;
			 --
			 -- ECO API fails if we are trying to disable a substribute along with Component, so just disable-
			 -- the component record not the substritute; Disabling the comp will remove the sub as well in the ECO/BOM  
			 --	Below stmt will remove any such records from staging 
			 --
             BEGIN
			 	  UPDATE ggl_plm_bom_staging
				     SET sub_acd_type = null
					 	 ,substitute_component_number = null
						 ,substitute_status_code = null
             	   WHERE comp_acd_type = 3 
				     AND sub_acd_type = 3
               	     AND change_notice = p_change_notice;				  
				  
				  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     Update subcomp-disable when comp-disable exists');				  
			 EXCEPTION
			   WHEN OTHERS THEN --do nothing as there might not be such record in staging table...
			   		NULL;
			 END;			  			 
			 --	   
			 
		  EXCEPTION 
		    WHEN OTHERS THEN
			NULL;
			Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     12');
		
		 END;  
			   v_item_revision := '';  
		END LOOP;
		--

      EXCEPTION
         WHEN OTHERS
         THEN

            v_error := SUBSTR (SQLERRM, 1, 500);
            Fnd_File.put_line
               (Fnd_File.LOG,
                   'When others error in bom_disable.... :'
                || v_error
               );
      END;

   EXCEPTION
      WHEN OTHERS
      THEN
         v_error := SUBSTR (SQLERRM, 1, 500);
         Fnd_File.put_line (Fnd_File.LOG,
                               ' Unknown Fatal error in bom_disable - When others exception; sqlerrm:'
                            || v_error
                           );
               e_transaction_id      := p_change_notice; --c_bcs_rec.ggl_plm_bom_int_id;
               e_transaction_line_id := '';
               e_error_desc  := 'Unknown Fatal error in bom_disable - WHEN OTHERS Exception for ECN# '||p_change_notice
			   					||'sqlerrm: '||substr(sqlerrm,1,500);
               e_sugg_action := 'Please check bom_disable code and fix the error...';
			   --			   
               Ggl_Inv_Txn_Interface.ggl_inv_error_insert
                                                      (e_transaction_id,
                                                       e_transaction_line_id,
                                                       e_transaction_source,
                                                       e_error_desc,
                                                       e_sugg_action,
                                                       v_user_id,
                                                       e_err_ret_code
                                                      );	
						   
   END bom_disable;
   

  
-- ========================================================================================
--
-- This procedure is used to cleanup records in the staging table ggl_plm_bom_staging 
-- All the records have to be cleaned up to remove duplicates 
--
-- ========================================================================================


    PROCEDURE iclean_up ( p_errbuf OUT VARCHAR2,
                             p_errcode OUT NUMBER,
                             p_change_notice IN VARCHAR2 )
     IS
     
     --
     -- Cursor to select all the distinct change notice numbers
     -- in the staging table with status of NEW, ERROR 
     --
     CURSOR c_bom_ecn
     IS
     SELECT DISTINCT gbst.change_notice
       FROM ggl_plm_bom_staging gbst
      WHERE gbst.process_flag IN ('NEW','ERROR','HOLD')
        AND gbst.change_notice = NVL(p_change_notice , gbst.change_notice)
      ORDER BY change_notice;		  
      --
	  -- Cursor to select all the records in the staging table with 
	  -- Status of NEW, ERROR for the required change notice 
	  --
      CURSOR c_bom_staging(p_change_notice IN VARCHAR2) 
	  IS
         SELECT gbs.ROWID row_id,
				gbs.*
           FROM ggl_plm_bom_staging gbs
          WHERE gbs.process_flag IN ('NEW','ERROR','HOLD')
		    AND gbs.change_notice = p_change_notice
		  ORDER BY ggl_plm_bom_staging_id
		  FOR UPDATE OF process_flag;
		  
		  
      CURSOR c_bom_remove_dup(p_change_notice IN VARCHAR2) 
	  IS
         SELECT gbs.ROWID row_id,
				gbs.*
           FROM ggl_plm_bom_staging gbs
          WHERE gbs.process_flag IN ('CLEAN')
		    AND substitute_component_number IS NULL
		    AND gbs.change_notice = p_change_notice;
		  
		  
		  
	  --
      v_item_number                    ggl_plm_bom_staging.item_number%TYPE     := '';
      v_bom_status_code                ggl_plm_bom_staging.bom_status_code%TYPE := '';
      v_revision                       ggl_plm_bom_staging.revision%TYPE        := '';
      v_process_flag                   ggl_plm_bom_staging.process_flag%TYPE    := '';
      e_transaction_id                 ggl_inv_errors.transaction_id%TYPE;
      e_transaction_line_id            ggl_inv_errors.transaction_line_id%TYPE;
      e_transaction_source             ggl_inv_errors.transaction_source%TYPE := 'PLM_BOM_GGL_PLM_BOM_STAGING';
      e_error_desc                     ggl_inv_errors.error%TYPE;
      e_sugg_action                    ggl_inv_errors.suggested_action%TYPE;
      e_err_ret_code                   NUMBER;
	  --
	  v_check_item                     VARCHAR2(50);
	  v_check_component                VARCHAR2(50);
	  v_check_substitute               VARCHAR2(50);
	  v_clean                          NUMBER := 0;
	  v_no_ecn                         NUMBER := 0;
	  v_no_containers                  NUMBER := 0;
	  v_record_count                   NUMBER := 0;
	  v_duplicate                      NUMBER := 0;
	  v_comp_item_num                  VARCHAR2(60);
	  --
      error_on_insert_in_error_table   EXCEPTION;
      error_on_delete_in_error_table   EXCEPTION;
	  --
  BEGIN
      --
      Fnd_File.put_line (Fnd_File.LOG, '');
	  Fnd_File.put_line (Fnd_File.LOG, '======================================================================');
      Fnd_File.put_line (Fnd_File.LOG, '1) CLEANUP:   Starting the cleanup process........for '||p_change_notice);
	  Fnd_File.put_line (Fnd_File.LOG, '======================================================================');
	  Fnd_File.put_line (Fnd_File.LOG, '');

      p_errcode := 0;
	  --
	  -- Reprocess the ECO if it is corrected using the custom errors form.
	  -- It will do nothing if there are no records found with process_flag = 'CORRECTED' 
	  --
	  ireprocess_eco (p_change_notice);	   
	  --
	  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     After ireprocess_eco call'); 	  
	  --
	  -- Open the cursor to get the distinct change notice 
	  --PROCESS
      FOR c_bom_ecn_rec IN c_bom_ecn
      LOOP
	    --
	    Fnd_File.put_line (Fnd_File.LOG, ' ');
	    Fnd_File.put_line (Fnd_File.LOG, '   LOOP:      Processing Change Notice = ' ||c_bom_ecn_rec.change_notice);
        --
	
        FOR c_bom_staging_rec IN c_bom_staging(c_bom_ecn_rec.change_notice)
        LOOP
		 --
		    v_clean := 0 ;
            Fnd_File.put_line (Fnd_File.LOG, '              -------------------------------------------------------------');
		    Fnd_File.put_line (Fnd_File.LOG, '   LOOP:      Processing Staging ID = ' 
			                                  ||c_bom_staging_rec.ggl_plm_bom_staging_id
											  ||' Item# = '
											  ||c_bom_staging_rec.item_number );
											  
			--
            IF c_bom_staging_rec.process_flag IN ('ERROR','CORRECTED')  THEN
			  --
		      BEGIN
			  --
               UPDATE ggl_plm_bom_staging
                  SET process_flag = 'NEW', -- why are we making ERROR to new ??  
                      error_messg  = ''
                WHERE CURRENT OF c_bom_staging;
              EXCEPTION
                WHEN OTHERS
                THEN
                Fnd_File.put_line (Fnd_File.LOG,'   UPDATE :   Updating status to New from Error = ' ||c_bom_ecn_rec.change_notice);        --NULL;
              END;
		      --
              e_transaction_id := c_bom_staging_rec.ggl_plm_bom_staging_id;
              Ggl_Inv_Txn_Interface.ggl_inv_error_delete (e_transaction_id,
                                                         e_transaction_line_id,
                                                         e_transaction_source,
                                                         e_err_ret_code
                                                         );
              --
              IF e_err_ret_code <> 0
               THEN
                RAISE error_on_delete_in_error_table;
              END IF;
		      --
			ELSE
				 Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     Process Flag = ' 
			                                  ||c_bom_staging_rec.process_flag );
											  
		    END IF; -- End  10 
		    --
			
			
			 
            BEGIN
		       SELECT  COUNT(*)
                 INTO  v_duplicate
				 FROM  ggl_plm_bom_staging 
                WHERE  process_flag IN ( 'NEW')
				  AND  item_number = c_bom_staging_rec.item_number
    		      AND  revision = c_bom_staging_rec.revision
				  AND  bom_status_code = c_bom_staging_rec.bom_status_code --Added new
    		      AND  component_item_number = c_bom_staging_rec.component_item_number
    		      AND  component_revision = c_bom_staging_rec.component_revision --Added new
				  AND  component_status_code = c_bom_staging_rec.component_status_code --Added new				  
			      AND  NVL(substitute_component_number,'ZZZZZ') =
				  		NVL(c_bom_staging_rec.substitute_component_number,'ZZZZZ')
				  AND  NVL(substitute_status_code,'ZZZZZ') = 
				  		NVL(c_bom_staging_rec.substitute_status_code,'ZZZZZ') --Added new
			      AND  change_notice = c_bom_staging_rec.change_notice
		        GROUP BY item_number, 
				  		 revision,
						 bom_status_code,
				  		 component_item_number,
						 component_revision,
						 component_status_code,						 
						 substitute_component_number,
						 substitute_status_code,
						 change_notice
				  HAVING COUNT(*) > 1;
			   --
			     
               IF v_duplicate = 1 THEN
			      NULL;
				  Fnd_File.put_line (Fnd_File.LOG, '     CHECK:    Not a Duplicate Record');
			   ELSE
			     UPDATE ggl_plm_bom_staging
    		        SET process_flag = 'INVALID',
			   	        error_messg = 'Duplicate Component or Substitute'
    		      WHERE process_flag = 'NEW'
 				    AND item_number = c_bom_staging_rec.item_number
    		      	AND revision = c_bom_staging_rec.revision
				  	AND bom_status_code = c_bom_staging_rec.bom_status_code --Added new
    		      	AND component_item_number = c_bom_staging_rec.component_item_number
    		      	AND component_revision = c_bom_staging_rec.component_revision --Added new
				  	AND component_status_code = c_bom_staging_rec.component_status_code --Added new				  
			      	AND NVL(substitute_component_number,'ZZZZZ') =
				  		NVL(c_bom_staging_rec.substitute_component_number,'ZZZZZ')
				  	AND NVL(substitute_status_code,'ZZZZZ') = 
				  		NVL(c_bom_staging_rec.substitute_status_code,'ZZZZZ') --Added new 
			        AND change_notice = c_bom_staging_rec.change_notice
			        AND ROWID = c_bom_staging_rec.row_id;

			        v_clean := 1 ;
			        Fnd_File.put_line (Fnd_File.LOG, '   UPDATE:    Updating Duplicate record Process Flag = INVALID ');
				  
				END IF;
											  
               EXCEPTION
			      --
                  WHEN OTHERS THEN 
				  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     Not a Duplicate Record');
		     END; 
			

			
            IF UPPER(c_bom_staging_rec.bom_status_code) 
			   NOT IN ('IN WORK','PROTOTYPE','PRODUCTION CHANGE','PRODUCTION') THEN 
			  --
		      BEGIN
			  --
			   
               UPDATE ggl_plm_bom_staging
                  SET process_flag = 'ERROR',  
                      error_messg  = 'Invalid Status'
                WHERE CURRENT OF c_bom_staging;
				
				v_clean := 1;
				
				Fnd_File.put_line (Fnd_File.LOG, '   ERROR:  BOM Status Code not in In-Work/Prototype/Production Change/Production = ' 
			                                  ||c_bom_staging_rec.bom_status_code );
											  
              EXCEPTION
                WHEN OTHERS
                THEN
                  NULL;
			   END;

		      --
              e_transaction_id := c_bom_staging_rec.ggl_plm_bom_staging_id;
              e_transaction_line_id := '';
              e_error_desc := 'Invalid BOM_STATUS_CODE Status: '||c_bom_staging_rec.bom_status_code;
              e_sugg_action := 'Please correct Status';
              Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );

              IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
              END IF;
		    ELSE
						  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   BOM Status Code in In-Work/Prototype/Production Change/Production = ' 
			                                  ||c_bom_staging_rec.bom_status_code );
		      --
		    END IF; -- End  10 
		    --
		
		    
			 
            IF ((UPPER(c_bom_staging_rec.bom_status_code) 
			      IN ('PRODUCTION', 'PRODUCTION CHANGE')
			     AND c_bom_staging_rec.revision BETWEEN '-999999999999999.99' AND '999999999999999.99')
			                   OR 
			   (UPPER(c_bom_staging_rec.bom_status_code) 
			      IN ('IN WORK', 'PROTOTYPE')
			     AND c_bom_staging_rec.revision NOT BETWEEN '-999999999999999.99' AND '999999999999999.99')) THEN
			  --
		      BEGIN
			  --
               UPDATE ggl_plm_bom_staging
                  SET process_flag = 'ERROR',  
                      error_messg  = 'Invalid BOM Revision'
                WHERE CURRENT OF c_bom_staging;
				--
				v_clean := 1;
				--
              EXCEPTION
                WHEN OTHERS
                THEN
                 NULL;
              END;
		      --
              e_transaction_id := c_bom_staging_rec.ggl_plm_bom_staging_id;
              e_transaction_line_id := '';
              e_error_desc  := 'Invalid BOM Revision';
              e_sugg_action := 'Please correct BOM Revision';
              Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );

              IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
              END IF;
		    ELSE
									  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   BOM Revision is Correct Bom Status Code = ' 
			                                  ||c_bom_staging_rec.bom_status_code 
											  ||' Revison = '
											  ||c_bom_staging_rec.revision 
											  );
		    END IF; -- End  10 
		    --	
			
		    			 
            IF ((UPPER(c_bom_staging_rec.component_status_code) 
			      IN ('PRODUCTION', 'PRODUCTION CHANGE')
			     AND c_bom_staging_rec.component_revision     
				 	 BETWEEN '-999999999999999.99' AND '999999999999999.99')
			                   OR 
			   (UPPER(c_bom_staging_rec.component_status_code) 
			      IN ('IN WORK', 'PROTOTYPE')
			     AND c_bom_staging_rec.component_revision 
				 	 NOT BETWEEN '-999999999999999.99' AND '999999999999999.99')) THEN
			  --
		      BEGIN
			  --
               UPDATE ggl_plm_bom_staging
                  SET process_flag = 'ERROR', -- why are we making ERROR to new ??  
                      error_messg  = 'Invalid Component Revision'
                WHERE CURRENT OF c_bom_staging;
				v_clean := 1;
				--
              EXCEPTION
                WHEN OTHERS
                THEN
                 NULL;
              END;
		      --
              e_transaction_id := c_bom_staging_rec.ggl_plm_bom_staging_id;
              e_transaction_line_id := '';
              e_error_desc  := 'Invalid Component Revision';
              e_sugg_action := 'Please correct Component Revision';
              Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );

              IF e_err_ret_code <> 0
               THEN
                  RAISE error_on_insert_in_error_table;
              END IF;
		    ELSE
									  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   Component Revision is Correct. Component Status Code = ' 
			                                  ||c_bom_staging_rec.component_status_code 
											  ||' Revison = '
											  ||c_bom_staging_rec.component_revision 
											  );
		    END IF; -- End  10 

		    --		
					
		    
            IF  c_bom_staging_rec.item_number IS NOT NULL THEN
			  --
		      BEGIN
			  
			    SELECT  segment1
				  INTO  v_check_item
    			  FROM  mtl_system_items msi, mtl_parameters mp
    			 WHERE  msi.organization_id = mp.organization_id
    			   AND  mp.organization_code = 'GGM'
    			   AND  msi.segment1 = c_bom_staging_rec.item_number
				   AND	msi.bom_enabled_flag = 'Y';
				   
									  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   BOM exist and BOM Enabled for GGM Organization. Item = ' 
			                                  ||c_bom_staging_rec.item_number 
											  );
			  --
              EXCEPTION
                WHEN OTHERS
                THEN
				--
				UPDATE ggl_plm_bom_staging
                   SET process_flag = 'ERROR',  
                       error_messg  = 'BOM / Assembly Item does not exist or not BOM Enabled for GGM Organization'
                 WHERE CURRENT OF c_bom_staging;
				 v_clean := 1; 
				 
			   e_transaction_id      := c_bom_staging_rec.ggl_plm_bom_staging_id;
			   e_transaction_line_id := '';
			   e_error_desc          := 'BOM does not exist or not BOM Enabled for GGM Organization';
			   e_sugg_action         := 'Please correct BOM in GGM Organization';
			   Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );
    		   IF e_err_ret_code <> 0 THEN
    			   RAISE error_on_insert_in_error_table;
    		   END IF;       
              END;
		      --
		    END IF; -- End  10 
		 
			
			
			 
            IF  c_bom_staging_rec.component_item_number IS NOT NULL THEN
			  --
		      BEGIN
			  
			    SELECT  segment1
				  INTO  v_check_component
    			  FROM  mtl_system_items msi, mtl_parameters mp
    			 WHERE  msi.organization_id = mp.organization_id
    			   AND  mp.organization_code = 'GGM'
    			   AND  msi.segment1 = c_bom_staging_rec.component_item_number
				   AND	msi.bom_enabled_flag = 'Y';
				   
									  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   Component exist and BOM Enabled for GGM Organization. Item = ' 
			                                  ||c_bom_staging_rec.component_item_number 
											  );
			  --
              EXCEPTION
                WHEN OTHERS
                THEN
				--
				UPDATE ggl_plm_bom_staging
                   SET process_flag = 'ERROR',  
                       error_messg  = 'Component does not exist or not BOM Enabled for GGM Organization'
                 WHERE CURRENT OF c_bom_staging; 
				 --
				--
				-- Update all ECO records with the status as 'VALIDATION_ERROR'  
				-- 
            	   Fnd_File.put_line (Fnd_File.LOG, '<<VALIDATION ERROR>> No further processing for ECO#:... '
                               || p_change_notice||'; Update the ECO status as VALIDATION_ERROR...'
                              );
				--			  				
				   iupdate_eco (p_change_notice, 'VALIDATION_ERROR',
				   	'Component does not exist or not BOM Enabled for GGM Organization');				 

				 --
				 v_clean := 1;

			     e_transaction_id      := c_bom_staging_rec.ggl_plm_bom_staging_id;
			     e_transaction_line_id := '';
			     e_error_desc          := 'Component does not exist or not BOM Enabled for GGM Organization';
			     e_sugg_action         := 'Please correct Component in GGM Organization';
			     Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );
														  
    		   IF e_err_ret_code <> 0 THEN
    			   RAISE error_on_insert_in_error_table;
    		   END IF;       
              END;
		      --
		    END IF; -- End  10 
		    --		
			
			
		 
            IF  c_bom_staging_rec.substitute_component_number IS NOT NULL THEN
			  --
		      BEGIN
			  
			    SELECT  segment1
				  INTO  v_check_substitute
    			  FROM  mtl_system_items msi, mtl_parameters mp
    			 WHERE  msi.organization_id = mp.organization_id
    			   AND  mp.organization_code = 'GGM'
    			   AND  msi.segment1 = c_bom_staging_rec.substitute_component_number
				   AND	msi.bom_enabled_flag = 'Y';
				   
									  
				Fnd_File.put_line (Fnd_File.LOG, '   SUCCESS:   Sunbtitute exist and BOM Enabled for GGM Organization. Item = ' 
			                                  ||c_bom_staging_rec.substitute_component_number 
											  );
			  --
              EXCEPTION
                WHEN OTHERS
                THEN
				--
				UPDATE ggl_plm_bom_staging
                   SET process_flag = 'ERROR',  
                       error_messg  = 'Substitute does not exist or not BOM Enabled for GGM Organization'
                 WHERE CURRENT OF c_bom_staging; 
				 v_clean := 1;
				 
			   e_transaction_id      := c_bom_staging_rec.ggl_plm_bom_staging_id;
			   e_transaction_line_id := '';
			   e_error_desc          := 'Substitute does not exist or not BOM Enabled for GGM Organization';
			   e_sugg_action         := 'Please correct Substitute in GGM Organization';
			   Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                          e_transaction_line_id,
                                                          e_transaction_source,
                                                          e_error_desc,
                                                          e_sugg_action,
                                                          v_user_id,
                                                          e_err_ret_code
                                                          );
    		   IF e_err_ret_code <> 0 THEN
    			   RAISE error_on_insert_in_error_table;
    		   END IF;       
              END;
		      --
		    END IF; -- End  10 		


			
			   IF v_clean = 0 THEN
			   BEGIN
    	  	    SELECT 'HOLD'
			      INTO v_process_flag
			      FROM ggl_plm_bom_staging
    		     WHERE item_number           = c_bom_staging_rec.item_number
    		       AND component_item_number = c_bom_staging_rec.component_item_number
    		       AND component_revision    < c_bom_staging_rec.component_revision
				   AND change_notice 		 <> p_change_notice		
				   AND transaction_date 	 < c_bom_staging_rec.transaction_date		   
			       AND process_flag 		 IN ('NEW','CLEAN','ERROR','IN_PROCESS')
			       AND ROWNUM = 1;
				--
				v_clean := 1 ;
			    UPDATE ggl_plm_bom_staging 
    		       SET process_flag = 'HOLD',
				       error_messg  = 'Component Item with lower revison found in NEW/CLEAN/ERROR/IN_PROCESS Status for another ECN'
    		     WHERE CURRENT OF c_bom_staging; 
				 --
                 EXCEPTION
                  WHEN OTHERS THEN 
				--
			    UPDATE ggl_plm_bom_staging 
    		       SET process_flag = 'CLEAN'
    		     WHERE CURRENT OF c_bom_staging; 
    	       END;
			   END IF;

			   
			  IF v_clean = 0 THEN 
		      BEGIN
    	  	   SELECT 'HOLD'
			     INTO v_process_flag
			     FROM ggl_plm_bom_staging
    		    WHERE item_number = c_bom_staging_rec.item_number
    		      AND revision    < c_bom_staging_rec.revision
  				  AND change_notice <> p_change_notice
				  AND transaction_date < c_bom_staging_rec.transaction_date					  
			      AND process_flag IN ('NEW','CLEAN','ERROR','IN_PROCESS')
			      AND ROWNUM = 1;
				--
				v_clean := 1;
				--
			    UPDATE ggl_plm_bom_staging 
    		       SET process_flag = 'HOLD',
				       error_messg  = 'Item with lower revison found in NEW/CLEAN/ERROR/IN_PROCESS Status for another ECN'
    		     WHERE CURRENT OF c_bom_staging; 
                 EXCEPTION
                  WHEN OTHERS THEN 
				--
			    UPDATE ggl_plm_bom_staging 
    		       SET process_flag = 'CLEAN'
    		     WHERE CURRENT OF c_bom_staging;  
    	      END;
			  END IF;
	   
		      v_record_count := v_record_count + 1;
      END LOOP;
	  
	  COMMIT;
	          Fnd_File.put_line (Fnd_File.LOG, ' ');
	  		  Fnd_File.put_line (Fnd_File.LOG, '   PROCESS:   Total records processed for Change Notice ' 
			                                  ||c_bom_ecn_rec.change_notice 
											  ||'='
											  ||v_record_count);
			  Fnd_File.put_line (Fnd_File.LOG, '--------------------------------------------------------------------------------- ');
			  Fnd_File.put_line (Fnd_File.LOG, '  ');
			  
	BEGIN
	
	   FOR c_bom_remove_dup_rec IN c_bom_remove_dup(c_bom_ecn_rec.change_notice)
        LOOP
		    BEGIN
				 SELECT component_item_number
				   INTO v_comp_item_num
				   FROM ggl_plm_bom_staging
    		      WHERE process_flag IN ( 'CLEAN')
				    AND item_number = c_bom_remove_dup_rec.item_number
    		       	AND revision = c_bom_remove_dup_rec.revision
				  	AND bom_status_code = c_bom_remove_dup_rec.bom_status_code --Added new
    		      	AND component_item_number = c_bom_remove_dup_rec.component_item_number
    		      	AND component_revision = c_bom_remove_dup_rec.component_revision --Added new
				  	AND component_status_code = c_bom_remove_dup_rec.component_status_code --Added new				  
				  	AND substitute_component_number IS NOT NULL
					AND ROWNUM = 1;
					
			     UPDATE ggl_plm_bom_staging
    		        SET process_flag = 'INVALID',
			   	        error_messg = 'Duplicate Component or Substitute'
    		      WHERE process_flag IN ('CLEAN')
				    AND item_number = c_bom_remove_dup_rec.item_number
    		        AND revision = c_bom_remove_dup_rec.revision
				  	AND bom_status_code = c_bom_remove_dup_rec.bom_status_code --Added new 
    		      	AND component_item_number = c_bom_remove_dup_rec.component_item_number
    		      	AND component_revision = c_bom_remove_dup_rec.component_revision --Added new 
				  	AND component_status_code = c_bom_remove_dup_rec.component_status_code --Added new				  
			        AND change_notice =  c_bom_remove_dup_rec.change_notice
			        AND ROWID =  c_bom_remove_dup_rec.row_id;
								
				 EXCEPTION
			      --
                  WHEN OTHERS THEN 
				  Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     Not a Duplicate Record');
			  END;
		END LOOP;
	END;
    --
	END LOOP;
	--
	COMMIT;
	
	Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     Before bom_disable call');
	
	
	IF 	v_clean = 0 THEN
    
    	--
    	bom_disable(p_change_notice);
    	--	
    	COMMIT;	
    	--
    	
    	Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     After bom_disable call');	
    	
        check_bom_update(p_change_notice);
    	--	
    	COMMIT;
        
    	Fnd_File.put_line (Fnd_File.LOG, '   CHECK:     After check_bom_update call');	        
    	
    	Ggl_Plm_Bom_Interface.ivalidation (p_errbuf, p_errcode, p_change_notice);
    
    	BEGIN
    	  DELETE FROM xxmfg.ggl_plm_bom_staging 
     	   WHERE process_flag 	= 'INVALID'
       	  	 AND error_messg	= 'Duplicate Component or Substitute'
       		 AND change_notice 	= p_change_notice;
    	EXCEPTION
    	  WHEN OTHERS THEN NULL; --May not have INVALID records!
    	END;
    --
        Fnd_File.put_line (Fnd_File.LOG, ' ');
        Fnd_File.put_line (Fnd_File.LOG, '   CALL ishow_errors for ECO# : '||p_change_notice);
        Fnd_File.put_line (Fnd_File.LOG, ' ');	
    	--
      	ishow_errors (p_change_notice);
    	--
	ELSE
       	Fnd_File.put_line (Fnd_File.LOG, '<<VALIDATION ERROR>> No further processing for ECO#:... '
                      || p_change_notice||'; Update the ECO status as CLEANUP_ERROR...'
                     );
       --			  				
       iupdate_eco (p_change_notice, 'CLEANUP_ERROR', 'GGL_PLM_BOM_STAGING has atleast one error record' );	
       --		
       --  
       e_transaction_id      := p_change_notice;
       e_transaction_line_id := '';
       e_error_desc          := 'GGL_PLM_BOM_STAGING has atleast one ERROR record';
       e_sugg_action         := 'Please correct the issue before processing further';
       Ggl_Inv_Txn_Interface.ggl_inv_error_insert (e_transaction_id,
                                                     e_transaction_line_id,
                                                     e_transaction_source,
                                                     e_error_desc,
                                                     e_sugg_action,
                                                     v_user_id,
                                                     e_err_ret_code
                                                     );
       		  
       IF e_err_ret_code <> 0 THEN
       RAISE error_on_insert_in_error_table;
       END IF;  			
	END IF;
		
--	
	EXCEPTION
      WHEN error_on_insert_in_error_table
      THEN
	     --
         Fnd_File.put_line
            (Fnd_File.LOG,
                'Ggl_Plm_Bom_Interface_dev1.ICLEAN_UP UNABLE TO INSERT RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN error_on_delete_in_error_table
      THEN
	     --
         Fnd_File.put_line
            (Fnd_File.LOG,
                'Ggl_Plm_Bom_Interface_dev1.ICLEAN_UP UNABLE TO DELETE RECORD INTO ERROR TABLE. '
             || SQLERRM
            );
      WHEN OTHERS
      THEN
	     --
         Fnd_File.put_line
                      (Fnd_File.LOG,
                          'Ggl_Plm_Bom_Interface_dev1.ICLEAN_UP OTHERS EXCEPTION '
                       || SQLERRM
                      );
  END iclean_up;  
  --
	  
END GGL_PLM_BOM_INTERFACE;
