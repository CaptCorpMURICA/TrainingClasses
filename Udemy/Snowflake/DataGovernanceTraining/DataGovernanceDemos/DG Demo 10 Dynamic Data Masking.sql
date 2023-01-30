-- Demo: Dynamic Data Masking
-- Version: 1.19
-- Last updated: 22AUG2022
 
 -- NOTE: You must first run the script "Setup Taxpayer schema & roles.sql"
 -- in order to create all custom roles and the Taxpayer database, schema, and tables
 -- before running this demo.
 
-- As POLICY_ADMIN, create the masking policies in the TAXPAYER database.

use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Unset data masking policies prior to demo
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


create or replace masking policy ssn_mask as
  (val string) returns string ->
  case
    when current_role() in ('INSTRUCTOR1_TAXDATA_STEWARD','INSTRUCTOR1_TAX_EXECUTIVE','INSTRUCTOR1_TAX_SRANALYST_CORP','INSTRUCTOR1_TAX_SRANALYST_INDIV') then val
    when current_role() in ('INSTRUCTOR1_TAX_JRANALYST_CORP','INSTRUCTOR1_TAX_JRANALYST_INDIV') then repeat('*', length(val)-4) || right(val, 4)
    else '*** MASKED ***'
  end;

create or replace masking policy email_mask as
  (val string) returns string ->
  case
    when current_role() in ('INSTRUCTOR1_TAXDATA_STEWARD','INSTRUCTOR1_TAX_EXECUTIVE','INSTRUCTOR1_TAX_SRANALYST_CORP','INSTRUCTOR1_TAX_SRANALYST_INDIV') then val
    when current_role() in ('INSTRUCTOR1_TAX_JRANALYST_CORP','INSTRUCTOR1_TAX_JRANALYST_INDIV') then regexp_replace(val,'.+\@','*****@')
    else '*** MASKED ***'
  end;

create or replace masking policy name_mask as
(val varchar) returns varchar ->
  case
    when current_role() in ('INSTRUCTOR1_TAXDATA_STEWARD','INSTRUCTOR1_TAX_EXECUTIVE','INSTRUCTOR1_TAX_SRANALYST_CORP','INSTRUCTOR1_TAX_SRANALYST_INDIV') then val
    when current_role() in ('INSTRUCTOR1_TAX_JRANALYST_CORP','INSTRUCTOR1_TAX_JRANALYST_INDIV') then regexp_replace(val,'.','*',2)
    else '*** MASKED ***'
    end;

-- Set masking policies for TAXPAYER columns (Total: 5)
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column email set masking policy email_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column taxpayer_id set masking policy ssn_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column lastname set masking policy name_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column firstname set masking policy name_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify column corp_taxpayer_name set masking policy name_mask;

-- Set masking policies for TAXPAYER_DEPENDENTS columns (Total: 5)
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_email set masking policy email_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column taxpayer_id set masking policy ssn_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dependent_ssn set masking policy ssn_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_lastname set masking policy name_mask;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_firstname set masking policy name_mask;

-- Set masking policies for TAXPAYER_WAGES columns (Total: 1)
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify column taxpayer_id set masking policy ssn_mask;

-- As POLICY_ADMIN, view masking policy metadata (SHOW, DESC commands)

-- Current database only
show masking policies;

-- Match pattern on policy name for current database
show masking policies like '%email%';

-- All databases in account
show masking policies in account;

-- DESCRIBE output of masking policies
desc masking policy ssn_mask;
desc masking policy name_mask;
desc masking policy email_mask;

-- Show DDL for a masking policy
select get_ddl('policy','email_mask'); -- DDL for email_mask policy

-- Show data masking and row access policies currently applied to TAXSCHEMA columns

use role INSTRUCTOR1_policy_admin;

-- TAXPAYER table
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';
   
-- TAXPAYER_DEPENDENTS table
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';
   
-- TAXPAYER_WAGES
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_wages',
    ref_entity_domain=>'TABLE'))
   where policy_kind like'%POLICY';

-- DESCRIBE output of tax tables
-- Expand the output window and note each non-null Policy name for each column that has an assigned masking policy:
desc table taxpayer;
desc table taxpayer_dependents;
desc table taxpayer_wages;

-- View grants on masking policies:
show grants on masking policy email_mask;
show grants on masking policy name_mask;
show grants on masking policy ssn_mask;

-- Test Masking Policies

-- Roles that see Taxpayer data in clear text:
-- INSTRUCTOR1_TAX_EXECUTIVE, INSTRUCTOR1_TAX_SRANALYST_CORP, INSTRUCTOR1_TAX_SRANALYST_INDIV

use role INSTRUCTOR1_TAXDATA_STEWARD; -- Sees all taxpayer data (Corporate & Individual) in clear text
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

use role INSTRUCTOR1_TAX_EXECUTIVE; -- Sees all taxpayer data (Corporate & Individual) in clear text
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

use role INSTRUCTOR1_TAX_SRANALYST_CORP; -- Sees Corporate taxpayer data in clear text
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state
from taxpayer_dependents; -- No data returned since taxpayer_dependents contains no Corporate tax data
select taxpayer_id,tax_year,w2_total_income,total_federal_tax 
from taxpayer_wages; -- No data returned since taxpayer_wages contains no Corporate tax data

use role INSTRUCTOR1_TAX_SRANALYST_INDIV; -- Sees Individual taxpayer data in clear text
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

-- Roles that see partially-masked Taxpayer data:
-- INSTRUCTOR1_TAX_JRANALYST_CORP, INSTRUCTOR1_TAX_JRANALYST_INDIV

use role INSTRUCTOR1_TAX_JRANALYST_CORP; -- Sees partially-masked Corporate taxpayer data only
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state
from taxpayer_dependents; -- No data returned since taxpayer_dependents contains no Corporate tax data
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

use role INSTRUCTOR1_TAX_JRANALYST_INDIV; -- Sees partially-masked Individual taxpayer data only
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages; -- No data returned since taxpayer_wages contains no Corporate tax data

-- All other roles that are authorized to view taxpayer data will see the PII columns fully masked

use role INSTRUCTOR1_TAX_USER_EAST; -- Sees fully-masked taxpayer data for East US region
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax,state from taxpayer_wages;

use role INSTRUCTOR1_TAX_USER_CENTRAL; -- Sees fully-masked taxpayer data for Central US region
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax,state from taxpayer_wages;

use role INSTRUCTOR1_TAX_USER_WEST; -- Sees fully-masked taxpayer data for West US region
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax,state from taxpayer_wages;

-- Note that SYSADMIN (owner of the tax tables) sees no data at all due to enforcement of row access policy
use role SYSADMIN; -- Sees no tax data (due to enforcement of row access policy on taxpayer and taxpayer_dependents tables
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax,state from taxpayer_wages;

-- Tax table queries by roles such as TRAINING_ROLE and PUBLIC error out since these roles are not authorized

use role TRAINING_ROLE; -- Queries error out due to role not authorized
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

use role PUBLIC; -- Queries error out due to role not authorized
select taxpayer_type,taxpayer_id,corp_taxpayer_name,lastname,firstname,email,city,state from taxpayer;
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;
select taxpayer_id,tax_year,w2_total_income,total_federal_tax from taxpayer_wages;

-- Example of using ENCRYPT in a masking policy

use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Create a masking policy that will encrypt names as full masking
create or replace masking policy name_mask2 as
(val varchar) returns varchar ->
  case
    when current_role() in ('INSTRUCTOR1_TAX_EXECUTIVE','INSTRUCTOR1_TAX_SRANALYST_CORP','INSTRUCTOR1_TAX_SRANALYST_INDIV') then val
    when current_role() in ('INSTRUCTOR1_TAX_JRANALYST_CORP','INSTRUCTOR1_TAX_JRANALYST_INDIV') then regexp_replace(val,'.','*',2)
    else sha2(val,512)
    end;

-- Unset the email masking policy that had been previously applied to the dep_lastname
-- and dep_firstname columns of TAXPAYER_DEPENDENTS
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_lastname unset masking policy;
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_firstname unset masking policy;

-- Apply the new masking policy to the dep_lastname and dep_firstname columns
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_lastname 
set masking policy name_mask2;

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify column dep_firstname 
set masking policy name_mask2;

-- Verify that new masking policy has been applied
SELECT *
   FROM table(INSTRUCTOR1_tax_db.information_schema.policy_references
   (ref_entity_name=>'INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents',
    ref_entity_domain=>'TABLE'))
   where policy_kind='MASKING_POLICY';
   
-- Test the new masking policy (only need to show full masking scenario)

use role INSTRUCTOR1_TAX_USER_EAST; -- Sees fully-masked taxpayer data for Central US region, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

use role INSTRUCTOR1_TAX_USER_WEST; -- Sees fully-masked taxpayer data for Central US region, but spouse emails are in clear text
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;

-- Note that the TAX_JRANALYST_INDIV still sees partially masked last & first dependent names
use role INSTRUCTOR1_TAX_JRANALYST_INDIV; 
select dep_taxpayer_type,dependent_ssn,taxpayer_id,dep_relationship,dep_email,dep_lastname,dep_firstname,dep_city,dep_state from taxpayer_dependents;