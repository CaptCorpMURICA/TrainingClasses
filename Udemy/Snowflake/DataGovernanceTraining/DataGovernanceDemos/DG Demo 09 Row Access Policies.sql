-- Demo: Row Access Policies
-- Version: 1.20
-- Last updated: 18SEP2022
 
 -- NOTE: You must first run the script "Setup Taxpayer schema & roles.sql"
 -- in order to create all custom roles and the Taxpayer database, schema, and tables
 -- before running this demo.
 
-- Create row access policy using POLICY_ADMIN role
use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Drop row access policy, if necessary
alter table taxpayer drop row access policy taxdata_access_policy; -- You will get an error if this policy does not exist
alter table taxpayer_dependents drop row access policy taxdata_access_policy; -- You will get an error if this policy does not exist
alter table taxpayer_wages drop row access policy taxdata_access_policy; -- You will get an error if this policy does not exist

drop row access policy if exists taxdata_access_policy;

-- Create row access policy to restrict Taxanalyst access by role, and also to restrict Taxuser access to only
-- Taxpayer and Taxpayer dependents data in Eastern, Central, or Western US states
-- Note: POLICY_ADMIN owns the row access policy, not SYSADMIN

-- Note: Using current_role() context function in this policy, but could also have used invoker_role() instead
--    current_role() returns the session role, regardless of the execution context 
--    invoker_role() returns executing role, based on execution contex

create or replace row access policy taxdata_access_policy as (taxpayertype varchar(30), taxpayerstate varchar(30)) returns boolean ->
       exists (
            select 1 from tax_mapping
              where taxuser_role = current_role()
              and taxpayer_type=taxpayertype
          )
       or
       exists (
            select 1 from taxuser_mapping
              where taxuser_role = current_role()
              and taxpayer_state=taxpayerstate
          )
;

-- Attach row access policy to taxpayer_type and state columns of taxpayer table
alter table taxpayer add row access policy taxdata_access_policy on (taxpayer_type,state);

-- Attach row access policy to dep_state column of taxpayer_dependents table
-- NOTE: Requires two columns to match with row access policy signature of 2 arguments
alter table taxpayer_dependents add row access policy taxdata_access_policy on (dep_taxpayer_type,dep_state); 

-- Attach row access policy to state column of taxpayer_wages table
-- NOTE: Requires two columns to match with row access policy signature of 2 arguments
alter table taxpayer_wages add row access policy taxdata_access_policy on (taxpayer_type,state); 

-- Test the row access policy

-- Note mappings defined in TAX_MAPPING table:
-- insert into tax_mapping
-- values 
-- ('INSTRUCTOR1_TAX_SRANALYST_CORP','Corporate'),
-- ('INSTRUCTOR1_TAX_JRANALYST_CORP','Corporate'),
-- ('INSTRUCTOR1_TAX_SRANALYST_INDIV', 'Individual'),
-- ('INSTRUCTOR1_TAX_JRANALYST_INDIV', 'Individual'),
-- ('INSTRUCTOR1_TAX_EXECUTIVE', 'Corporate'),

use schema INSTRUCTOR1_tax_db.taxschema;

use role INSTRUCTOR1_taxdata_steward;
select * from taxpayer order by filing_status asc; -- Shows all taxpayer data, both Corporate and Individual
select * from taxpayer_dependents; -- Shows all taxpayer dependents data
select * from taxpayer_wages; -- Shows all taxpayer wages data

use role INSTRUCTOR1_tax_executive;
select * from taxpayer order by filing_status asc; -- Shows all taxpayer data, both Corporate and Individual
select * from taxpayer_dependents; -- Shows all taxpayer dependents data
select * from taxpayer_wages; -- Shows all taxpayer wages data

use role INSTRUCTOR1_tax_sranalyst_corp;
select * from taxpayer; -- Shows only Corporate taxpayer data
select * from taxpayer_dependents; -- Shows no taxpayer dependents data, since dependents data is for Individual taxpayers only
select * from taxpayer_wages; -- Shows no taxpayer wages data, since wages data is for Individual taxpayers only

-- JRANALYST_CORP has same row-level access as SRANALYST_CORP
use role INSTRUCTOR1_tax_jranalyst_corp;
select * from taxpayer; -- Shows only Corporate taxpayer data
select * from taxpayer_dependents; -- Shows no taxpayer dependents data, since dependents data is for Individual taxpayers only
select * from taxpayer_wages; -- Shows no taxpayer wages data, since wages data is for Individual taxpayers only

use role INSTRUCTOR1_tax_sranalyst_indiv;
select * from taxpayer; -- Shows only Individual taxpayer data
select * from taxpayer_dependents; -- Shows all taxpayer dependents data
select * from taxpayer_wages; -- Shows all taxpayer wages data

use role INSTRUCTOR1_tax_user_east;
select * from taxpayer; -- Shows Corporate & Individual taxpayer data for only East US States
select * from taxpayer_dependents; -- Shows Individual taxpayer dependents data for only East US States
select * from taxpayer_wages; -- Shows Individual taxpayer wages data for only East US States

use role INSTRUCTOR1_tax_user_central;
select * from taxpayer; -- Shows Corporate & Individual taxpayer data for only Central US States
select * from taxpayer_dependents; -- Shows Individual taxpayer dependents data for only Central US States
select * from taxpayer_wages; -- Shows taxpayer wages data for only Central US States

use role INSTRUCTOR1_tax_user_west;
select * from taxpayer; -- Shows Corporate & Individual taxpayer data for only West US States
select * from taxpayer_dependents; -- Shows Individual taxpayer dependents data for only West US States
select * from taxpayer_wages; -- Shows all taxpayer wages data for only West US States

-- Verify that data owner SYSADMIN cannot read any tax data due to enforcement of the row access policy
-- (SYSADMIN does not get an error, just no rows returned)
use role sysadmin;
select * from taxpayer; -- Shows no taxpayer data, even though sysadmin owns the taxpayer table
select * from taxpayer_dependents; -- Shows no taxpayer dependents data, even though sysadmin owns the taxpayer_dependents table
select * from taxpayer_wages; -- Shows no taxpayer wages data, even though sysadmin owns the taxpayer_wages table

-- Verify that POLICY_ADMIN role has no access to any tax data other than the mapping tables
-- (Gets an error when attempting to access the tax data)
use role INSTRUCTOR1_policy_admin;

select * from taxpayer; --Fails
select * from taxpayer_dependents; --Fails
select * from taxpayer_wages; --Fails
select * from tax_mapping; -- Query succeeds, but mapping table contains no PII
select * from taxuser_mapping; -- Query succeeds, but mapping table contains no PII

-- Show row access policies & DDL
-- Note: get_ddl fails as SYSADMIN, since POLICY_ADMIN is the owning role of the row access policy 
use role sysadmin;
select get_ddl('policy','taxdata_access_policy');

use role INSTRUCTOR1_policy_admin; -- Note: Must use POLICY_ADMIN role to view the currently set row access policies

select get_ddl('policy','taxdata_access_policy'); -- Succeeds, since POLICY_ADMIN is the owner of the row access policy

-- Show the currently set row access policy for TAXSCHEMA tables
-- Note POLICY_STATUS of "ACTIVE", as the policy is currently being enforced for each table
--   (You can only add or drop a row access policy, you CANNOT enable or disable a row access policy)

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

-- Show all row access policies in the account
use role INSTRUCTOR1_policy_admin;
show row access policies in account;

-- Try "disabling" a row access policy (Fails)
alter table taxpayer disable row access policy taxdata_access_policy; -- Errors out, only ADD and DROP are supported


