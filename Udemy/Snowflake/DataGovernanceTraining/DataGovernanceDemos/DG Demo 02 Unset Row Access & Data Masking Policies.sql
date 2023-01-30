-- Demo: Unset Row Access & Data Masking Policies
-- Version: V1.16
-- Last updated: 08AUG2022

-- NOTE: This script should be run prior to re-running any subsequent DG demos, assuming that 
-- you had previously run the DG demos in this same account before.

-- You should *NOT* have to drop/recreate any of the TAX_DB.TAXSCHEMA tables, the custom roles,
-- or the row access and data masking policies in order to rerun the DG demos.

-- You MAY want to truncate the TAX_DB.TAXSCHEMA tables and reload data if you 
-- wish to reset the data content of these tables, since some of the subsequent DML commands 
-- do change tax data.

-- Set context

use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Unset row access policy
-- NOTE: You will get an error if this policy either does not exist or is not currently attached to the associated table

alter table taxpayer drop row access policy taxdata_access_policy; 
alter table taxpayer_dependents drop row access policy taxdata_access_policy;
alter table taxpayer_wages drop row access policy taxdata_access_policy; 

-- Unset data masking policies
-- NOTE: You will get no error regardless of whether the masking policy was or was not set for the column

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column email unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column taxpayer_id unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column lastname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column firstname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column corp_taxpayer_name unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_email unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column taxpayer_id unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dependent_ssn unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_lastname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_firstname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify column taxpayer_id unset masking policy;

-- ***** Verify that all row access and data masking policies are not set for TAXSCHEMA tables or columns *****

use role INSTRUCTOR1_policy_admin;

-- Show row access policies currently applied to TAXSCHEMA tables

-- Each query below should return 0 rows
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer',
    ref_entity_domain=>'TABLE'))
   where policy_kind='ROW_ACCESS_POLICY';

SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents',
    ref_entity_domain=>'TABLE'))
   where policy_kind='ROW_ACCESS_POLICY';

SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_wages',
    ref_entity_domain=>'TABLE'))
   where policy_kind='ROW_ACCESS_POLICY';


-- Show data masking policies currently applied to TAXSCHEMA columns

-- Each query below should return 0 rows
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer',
    ref_entity_domain=>'TABLE'))
   where policy_kind='MASKING_POLICY';
   
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents',
    ref_entity_domain=>'TABLE'))
   where policy_kind='MASKING_POLICY';
   
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_wages',
    ref_entity_domain=>'TABLE'))
   where policy_kind='MASKING_POLICY';
