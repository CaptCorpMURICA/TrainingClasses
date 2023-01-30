-- Demo: Cloning & Row Access and Data Masking Policies
-- Version: V1.9
-- Last updated: 22AUG2022

-- Set context
use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Note that POLICY_ADMIN owns all row access & masking policies for INSTRUCTOR1_TAX_DB tables
show masking policies;
show row access policies;

-- Show the currently set policies for TAXPAYER table

SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';

-- As SYSADMIN, clone the TAXPAYER table

use role sysadmin;
drop table if exists INSTRUCTOR1_tax_db.taxschema.taxpayer_clone;

create or replace table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone
clone INSTRUCTOR1_tax_db.taxschema.taxpayer;

-- Note that the row access and masking policies are carried over to the clone
use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_clone',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';
   
-- Note that POLICY_ADMIN is able to unset/set policies on the cloned table,
-- since POLICY_ADMIN has been granted these account-level privileges:
--   APPLY ROW ACCESS POLICY 
--   APPLY MASKING POLICY

-- If we were using a decentralized policy administration model,
-- where some other role may need to have the ability to set and unset
-- policies on the clone, then the owner of the row access and masking policies 
-- will need to be granted APPLY privileges on the cloned table
--
-- For example: 
--   use role INSTRUCTOR1_policy_admin;
--   grant apply on row access policy taxdata_access_policy to role training_role;
--   grant apply on masking policy email_mask to role training_role;
--   grant apply on masking policy ssn_mask to role training_role;
--   grant apply on masking policy name_mask to role training_role;
--   grant apply on masking policy email_mask_spouse to role training_role;

-- Unset policies on cloned table
alter table taxpayer_clone drop row access policy taxdata_access_policy; 
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column email unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column taxpayer_id unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column lastname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column firstname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column corp_taxpayer_name unset masking policy;

-- Note that no policies are now set on the cloned table
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_clone',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';

-- Resetting policies on cloned table
alter table taxpayer_clone add row access policy taxdata_access_policy on (taxpayer_type,state);
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column email set masking policy email_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column taxpayer_id set masking policy ssn_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column lastname set masking policy name_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column firstname set masking policy name_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_clone modify column corp_taxpayer_name set masking policy name_mask;

-- Note that the row access and masking policies are now re-enabled on the cloned table
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_clone',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';

-- (Optional part of demo)
-- Grants to apply ONLY if you wanted to use a more decentralized policy management approach,
-- and provide TRAINING_ROLE with the ability to apply row access & masking policies.

use role INSTRUCTOR1_policy_admin;
grant apply on row access policy taxdata_access_policy to role training_role;
grant apply on masking policy email_mask to role training_role;
grant apply on masking policy ssn_mask to role training_role;
grant apply on masking policy name_mask to role training_role;
grant apply on masking policy email_mask_spouse to role training_role;
