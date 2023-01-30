-- Demo: Conditional Data Masking
-- Version: 1.18
-- Last updated: 09AUG2022

-- As POLICY_ADMIN, create a conditional masking policy in the TAXPAYER database.

use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Conditional Masking for dep_email column of TAXPAYER_DEPENDENTS table based on dep_relationship
-- Note: The first argument always specifies the column to be masked (email, in this case), and
-- the second argument is a conditional column (dependent, in this case) used to evaluate whether the first column should be masked. 
create or replace masking policy email_mask_spouse as
  (email string, dependent string) returns string ->
  case
    when current_role() in ('INSTRUCTOR1_TAXDATA_STEWARD','INSTRUCTOR1_TAX_EXECUTIVE','INSTRUCTOR1_TAX_SRANALYST_CORP','INSTRUCTOR1_TAX_SRANALYST_INDIV') then email
    when dependent = 'Spouse' then email
    when current_role() in ('INSTRUCTOR1_TAX_JRANALYST_CORP','INSTRUCTOR1_TAX_JRANALYST_INDIV') then regexp_replace(email,'.+\@','*****@')
	else '*** MASKED ***'
  end;

-- Set masking policies for TAXPAYER_DEPENDENTS columns

-- Unset the email masking policy that had been previously applied to the dep_email column of TAXPAYER_DEPENDENTS
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_email unset masking policy;

-- Apply the conditional masking policy to the dep_email column of TAXPAYER_DEPENDENTS
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_email 
set masking policy email_mask_spouse using (dep_email, dep_relationship);

-- Verify that new masking policy has been applied
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents',
    ref_entity_domain=>'TABLE'))
   where policy_kind='MASKING_POLICY';

-- As POLICY_ADMIN, view masking policy metadata
-- All databases in account
show masking policies in account;

-- Policies in current database only
show masking policies;

-- Test Conditional Masking Policy

-- Roles that see Taxpayer data in clear text:
-- INSTRUCTOR1_TAXDATA_STEWARD, INSTRUCTOR1_TAX_EXECUTIVE, 
-- INSTRUCTOR1_TAX_SRANALYST_CORP, INSTRUCTOR1_TAX_SRANALYST_INDIV

use role INSTRUCTOR1_TAXDATA_STEWARD; -- Sees Individual taxpayer dependent data in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state
from taxpayer_dependents; 

use role INSTRUCTOR1_TAX_SRANALYST_INDIV; -- Sees Individual taxpayer dependent data in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state
from taxpayer_dependents; 

-- Roles that see partially-masked Taxpayer data:
-- INSTRUCTOR1_TAX_JRANALYST_CORP, INSTRUCTOR1_TAX_JRANALYST_INDIV

use role INSTRUCTOR1_TAX_JRANALYST_INDIV; -- Sees partially-masked Individual taxpayer data, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

-- All other roles that are authorized to view taxpayer data will see the PII columns fully masked

use role INSTRUCTOR1_TAX_USER_EAST; -- Sees fully-masked taxpayer data for Central US region, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

use role INSTRUCTOR1_TAX_USER_CENTRAL; -- Sees fully-masked taxpayer data for Central US region, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

use role INSTRUCTOR1_TAX_USER_WEST; -- Sees fully-masked taxpayer data for West US region, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

-- Note that SYSADMIN (owner of the tax tables) sees no data at all
use role SYSADMIN; -- Sees no tax data (due to enforcement of row access policy on taxpayer and taxpayer_dependents tables
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

