
-- 4.0.0   ROW ACCESS POLICIES
--         In this lab exercise you will create a row access policy that will
--         filter access to TAXSCHEMA data by TAXANALYST and TAXUSER roles
--         (driven by separation of duty requirements) and also by US geographic
--         region. The row access policy will be applied to the three TAXSCHEMA
--         tables TAXPAYER, TAXPAYER_DEPENDENTS, and TAXPAYER_WAGES.
--         - Generate new row access policies for the TAX_DB database to protect
--         sensitive data stored in the tables.
--         - Demonstrate that row access policies are defined and assigned by
--         reviewing what data can be seen by each role.
--         - Show the access policies that are in place in TAX_DB.

-- 4.1.0   Create the Row Access Policy
--         As POLICY_ADMIN, create a row access policy to limit access to tax
--         data by job role and geographic area.

-- 4.1.1   Set the worksheet context

USE ROLE LEOPARD_policy_admin;
USE WAREHOUSE LEOPARD_wh;
USE SCHEMA LEOPARD_tax_db.taxschema;

--         We are starting with no access policies.
--         No Row Access Policies Assigned

-- 4.1.2   Create a row access policy
--         Create a row access policy to restrict TAXANALYST access by role and
--         also to restrict TAXUSER access to only Taxpayer and Taxpayer
--         Dependents data in Eastern, Central, or Western geographic regions.
--         Create and Assign Row Access Policies
--         POLICY_ADMIN owns the row access policy, not TRAINING_ROLE nor any
--         other role in the account.
--         A mapping table is an associative table that maps two or more tables
--         together. For a row access policy, the mapping table is essentially a
--         permissions table that connects the table with the sensitive data to
--         the table with the roles.

CREATE or REPLACE ROW ACCESS POLICY Taxdata_access_policy
   AS (taxpayertype varchar(30), taxpayerstate varchar(30)) returns Boolean ->
       EXISTS (
            SELECT 1 FROM tax_mapping
              WHERE taxuser_role = current_role()
              AND taxpayer_type=taxpayertype
              )
       OR
       EXISTS (
            SELECT 1 FROM taxuser_mapping
              WHERE taxuser_role = current_role()
              AND taxpayer_state=taxpayerstate
              )
;


-- 4.2.0   Attach the Row Access Policy

-- 4.2.1   Attach the new policy to the taxpayer_type and state columns of the
--         TAXPAYER table.
--         Apply the Row Access Policy

ALTER TABLE TAXPAYER
     ADD ROW ACCESS POLICY Taxdata_access_policy ON (taxpayer_type,state);


-- 4.2.2   Attach the row access policy to the DEP_STATE column of the
--         TAXPAYER_DEPENDENTS table.
--         The row access policy requires two columns to match with the policy
--         signature of two arguments. Additionally, only one row access policy
--         can be assigned to an object at a time.

ALTER TABLE TAXPAYER_DEPENDENTS
     ADD ROW ACCESS POLICY Taxdata_access_policy ON (dep_taxpayer_type,dep_state);


-- 4.2.3   Attach the row access policy to the STATE column of the
--         TAXPAYER_WAGES table.
--         The row access policy requires two columns to match with row access
--         policy signature of two arguments.

ALTER TABLE TAXPAYER_WAGES
     ADD ROW ACCESS POLICY Taxdata_access_policy ON (taxpayer_type,state);


-- 4.3.0   Test the Row Access Policy.
--         Execute the following queries to confirm your row access policy is in
--         place and the custom roles can only view the data permitted by the
--         policy.
--         The Taxdata Steward should have access to all data.

USE SCHEMA LEOPARD_tax_db.taxschema;

USE ROLE LEOPARD_taxdata_steward;
SELECT * FROM TAXPAYER; -- Shows all taxpayer data, both Corporate and Individual
SELECT * FROM TAXPAYER_DEPENDENTS; -- Shows all Individual taxpayer dependents data
SELECT * FROM TAXPAYER_WAGES; -- Shows all Individual taxpayer wages data

--         Now try as the tax executive, who should also have all access!
--         Access to All Data for Tax Executive

USE ROLE LEOPARD_tax_executive;
SELECT * FROM TAXPAYER; -- Shows all taxpayer data, both Corporate and Individual
SELECT * FROM TAXPAYER_DEPENDENTS; -- Shows all Individual taxpayer dependents data
SELECT * FROM TAXPAYER_WAGES; -- Shows all Individual taxpayer wages data

--         Now try as the senior corporate analyst, who should have Corporate
--         access only!
--         Tax Senior Analyst Corp Limited to Only Corporate Data

USE ROLE LEOPARD_tax_sranalyst_corp;
SELECT * FROM TAXPAYER; -- Shows only Corporate taxpayer data
SELECT * FROM TAXPAYER_DEPENDENTS;
  -- In Classic UI you see the column names, but no taxpayer dependent data, since data about dependents is for Individual taxpayers only
  -- If you are using the Snowsight UI you receive the message - Query produced no results
SELECT * FROM TAXPAYER_WAGES;
  -- In Classic UI you see the column names, but no wage data since wages are for Individual taxpayers only
  -- If you are using the Snowsight UI you receive the message - Query produced no results

--         Now try as the senior individual analyst, who should have Individual
--         only access!
--         Tax Senior Analyst Indiv Limited to Only Individual Data

USE ROLE LEOPARD_tax_sranalyst_indiv;
SELECT * FROM TAXPAYER; -- Shows only individual taxpayer data
SELECT * FROM TAXPAYER_DEPENDENTS; -- For individual taxpayer, shows all taxpayer dependents data
SELECT * FROM TAXPAYER_WAGES; -- For individual taxpayer, shows all taxpayer wages data

--         Now try as the east coast user, who should have access to all records
--         in their region!
--         East Coast User Limited to Only Data for States in the Eastern Region

USE ROLE LEOPARD_tax_user_east;
SELECT * FROM TAXPAYER;
   -- Shows Corporate and Individual taxpayer data for only the Eastern region
SELECT * FROM TAXPAYER_DEPENDENTS;
   -- Shows Individual taxpayer dependents data for only the Eastern region
SELECT * FROM TAXPAYER_WAGES;
   -- Shows Individual taxpayer wages data for only the Eastern region

--         Try the remaining combinations to ensure the mapping table and row
--         access policies are working as designated.

USE ROLE LEOPARD_tax_user_central;
SELECT * FROM TAXPAYER;
   -- Shows Corporate and Individual taxpayer data for only the Central region
SELECT * FROM TAXPAYER_DEPENDENTS;
   -- Shows Individual taxpayer dependents data for only the Central region
SELECT * FROM TAXPAYER_WAGES;
   -- Shows taxpayer wages data for only the Central region

USE ROLE LEOPARD_tax_user_west;
SELECT * FROM TAXPAYER;
   -- Shows Corporate and Individual taxpayer data for only the Western region
SELECT * FROM TAXPAYER_DEPENDENTS;
   -- Shows Individual taxpayer dependents data for only the Western region
SELECT * FROM TAXPAYER_WAGES;
   -- Shows all taxpayer wages data for only the Western region


-- 4.3.1   Verify that the TAX_DB database owner TRAINING_ROLE cannot read any
--         tax data due to the enforcement of the row access policy.

USE ROLE training_role;
SELECT * FROM TAXPAYER;
   -- In Classic UI you see the column names, but no taxpayer data even though TRAINING_ROLE owns the TAXPAYER table
   -- If you are using the Snowsight UI you receive the message - Query produced no results
SELECT * FROM TAXPAYER_DEPENDENTS;
   -- In Classic UI you see the column names, but no taxpayer dependent data even though TRAINING_ROLE owns the TAXPAYER_DEPENDENTS table
   -- If you are using the Snowsight UI you receive the message - Query produced no results
SELECT * FROM TAXPAYER_WAGES;
   -- In Classic UI you see the column names, but no taxpayer wage data even though TRAINING_ROLE owns the TAXPAYER_WAGES table
   -- If you are using the Snowsight UI you receive the message - Query produced no results


-- 4.3.2   Verify that the POLICY_ADMIN role has no access to any tax data other
--         than the data in the two mapping tables.

USE ROLE LEOPARD_policy_admin;
SELECT * FROM TAXPAYER; -- Fails
SELECT * FROM TAXPAYER_DEPENDENTS; -- Fails
SELECT * FROM TAXPAYER_WAGES; -- Fails
SELECT * FROM TAX_MAPPING; -- Query succeeds, but mapping table contains no sensitive data
SELECT * FROM TAXUSER_MAPPING; -- Query succeeds, but mapping table contains no sensitive data


-- 4.3.3   Show the row access policy metadata and DDL.
--         GET_DDL fails when called by TRAINING_ROLE, since POLICY_ADMIN is the
--         owning role of the row access policy.

USE ROLE TRAINING_ROLE;
SELECT get_ddl('policy','taxdata_access_policy');
   -- Fails, since TRAINING_ROLE is not the policy owner

USE ROLE LEOPARD_policy_admin;

SHOW ROW ACCESS POLICIES in account;

SELECT get_ddl('policy','taxdata_access_policy');
   -- Succeeds, since POLICY_ADMIN is the policy owner

--         The SNOWFLAKE.ACCOUNT_USAGE view POLICY_REFERENCES can be used to
--         identify the tables and views for which a row access policy is set.
--         However, this view has up to a 2-hour data latency.
--         The database-level table function POLICY_REFERENCES returns a row for
--         each object that has the specified policy assigned to that object or
--         returns a row for each policy assigned to the specified object. This
--         table function experiences no latency when executed.

-- 4.3.4   Execute the POLICY_REFERENCES table function to see all policies
--         currently assigned to the TAXPAYER, TAXPAYER_DEPENDENTS, and
--         TAXPAYER_WAGES tables.

USE ROLE LEOPARD_policy_admin;
USE DATABASE LEOPARD_tax_db;

SELECT *
     FROM TABLE(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.taxpayer', ref_entity_domain => 'TABLE'));

SELECT *
     FROM TABLE(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.TAXPAYER_DEPENDENTS', ref_entity_domain => 'TABLE'));

SELECT *
     FROM TABLE(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.TAXPAYER_WAGES', ref_entity_domain => 'TABLE'));

