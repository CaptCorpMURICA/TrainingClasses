
-- 1.0.0   SET UP TAXPAYER OBJECTS AND CUSTOM ROLES
--         The purpose of this lab exercise is to set up all objects and custom
--         roles to be used for all data governance labs (object tagging, row
--         access policies, data masking, and access history auditing).
--         - Create TAX_DB and objects for storing taxpayer data and mapping
--         tables.
--         - Create TAG_DB for storing object tags.
--         - Create POLICY_ADMIN role for centrally managing all object tags,
--         row access policies, and masking policies in the account.
--         - Create additional custom roles to demonstrate separation of duty
--         and control access to rows and sensitive columns in TAX_DB.TAXSCHEMA.

-- 1.1.0   Create the Tax and Tag Databases
--         Using TRAINING_ROLE, create two custom databases from existing
--         databases using the CLONE command:
--         Cloning Existing Databases into Your Account

-- 1.1.1   Create a virtual warehouse.
--         If not previously created, create your warehouse to use for the data
--         governance lab exercises.

USE ROLE training_role;

CREATE WAREHOUSE if not exists LEOPARD_wh warehouse_size=xsmall;
USE WAREHOUSE LEOPARD_wh;
GRANT USAGE on warehouse LEOPARD_wh to public;


-- 1.1.2   Create the tag database.
--         Create your TAG_DB database and the TAG_LIBRARY schema in it for
--         storing object tags by cloning an existing database, using the CLONE
--         command.

CREATE DATABASE LEOPARD_tag_db CLONE training_tag_db;


-- 1.1.3   Create the tax database.
--         Create the TAX_DB database and its TAXSCHEMA schema for storing
--         taxpayer data, again by cloning an existing database.

CREATE DATABASE LEOPARD_tax_db CLONE training_tax_db;


-- 1.2.0   Create the Data Steward Role TAXDATA_STEWARD
--         As SECURITYADMIN, create the data steward role TAXDATA_STEWARD that
--         will own all taxpayer data in the account.
--         Create Your Taxdata Steward Role
--         TAXDATA_STEWARD is NOT a DBA role. It has SELECT and DML access to
--         all TAXSCHEMA data, including sole responsibility for loading tax
--         data into the TAXSCHEMA objects.

-- 1.2.1   Create the data steward role and grant privileges to that role.

USE ROLE securityadmin;
CREATE ROLE LEOPARD_taxdata_steward; -- data steward role
GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_taxdata_steward;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_taxdata_steward;
GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_taxdata_steward;
GRANT IMPORTED privileges on database snowflake to role LEOPARD_taxdata_steward;
GRANT CREATE TABLE ON schema LEOPARD_tax_db.taxschema to role LEOPARD_taxdata_steward;


-- 1.2.2   Grant the data steward role to your user.

GRANT ROLE LEOPARD_taxdata_steward to user LEOPARD;


-- 1.3.0   Load Data Using the Data Steward Role
--         As TAXDATA_STEWARD, load data into the mapping tables TAX_MAPPING and
--         TAXUSER_MAPPING.
--         Using the TAXDATA_STEWARD Role to Populate Your Mapping Tables
--         The roles TAX_EXECUTIVE and TAXDATA_STEWARD each appear twice in the
--         TAX_MAPPING data load to ensure that these roles have access to all
--         taxpayer data (both Corporate and Individual).

-- 1.3.1   Using your data steward role, load data into the mapping tables.

USE ROLE LEOPARD_taxdata_steward;
USE SCHEMA LEOPARD_tax_db.taxschema;

INSERT INTO tax_mapping
values
('LEOPARD_TAX_SRANALYST_CORP','Corporate'),
('LEOPARD_TAX_JRANALYST_CORP','Corporate'),
('LEOPARD_TAX_SRANALYST_INDIV', 'Individual'),
('LEOPARD_TAX_JRANALYST_INDIV', 'Individual'),
('LEOPARD_TAX_EXECUTIVE', 'Corporate'),
('LEOPARD_TAX_EXECUTIVE', 'Individual'),
('LEOPARD_TAXDATA_STEWARD', 'Corporate'),
('LEOPARD_TAXDATA_STEWARD', 'Individual');

INSERT INTO taxuser_mapping
values
('LEOPARD_TAX_USER_EAST','VT'),
('LEOPARD_TAX_USER_EAST','AL'),
('LEOPARD_TAX_USER_EAST','FL'),
('LEOPARD_TAX_USER_EAST','SC'),
('LEOPARD_TAX_USER_EAST','NJ'),
('LEOPARD_TAX_USER_EAST','NY'),
('LEOPARD_TAX_USER_EAST','ME'),
('LEOPARD_TAX_USER_EAST','OH'),
('LEOPARD_TAX_USER_EAST','WV'),
('LEOPARD_TAX_USER_CENTRAL','IL'),
('LEOPARD_TAX_USER_CENTRAL','TX'),
('LEOPARD_TAX_USER_CENTRAL','IA'),
('LEOPARD_TAX_USER_CENTRAL','KY'),
('LEOPARD_TAX_USER_CENTRAL','TN'),
('LEOPARD_TAX_USER_CENTRAL','OK'),
('LEOPARD_TAX_USER_CENTRAL','KS'),
('LEOPARD_TAX_USER_WEST','CA'),
('LEOPARD_TAX_USER_WEST','CO'),
('LEOPARD_TAX_USER_WEST','NM'),
('LEOPARD_TAX_USER_WEST','MT'),
('LEOPARD_TAX_USER_WEST','OR'),
('LEOPARD_TAX_USER_WEST','WA'),
('LEOPARD_TAX_USER_WEST','ID'),
('LEOPARD_TAX_USER_WEST','UT'),
('LEOPARD_TAX_USER_WEST','NV'),
('LEOPARD_TAX_USER_WEST','AZ');


-- 1.3.2   Verify that the load was successful.
--         Query the TAXSCHEMA tables to verify that the mapping data has been
--         successfully loaded.

SELECT * FROM tax_mapping; -- 8 rows
SELECT * FROM taxuser_mapping; -- 26 rows
SELECT * FROM taxpayer where taxpayer_type = 'Individual'; -- 14 rows
SELECT * FROM taxpayer where taxpayer_type = 'Corporate'; -- 22 rows
SELECT * FROM taxpayer_dependents; -- 20 rows
SELECT * FROM taxpayer_wages; -- 30 rows


-- 1.4.0   Create Row Access Policies and Data Masking Custom Roles
--         As SECURITYADMIN, create custom roles to be used for the row access
--         policy and data masking lab exercises.
--         Creating Custom Roles for Working with Tax Data

-- 1.4.1   Create the business user roles.

USE ROLE securityadmin;

CREATE ROLE LEOPARD_tax_executive;
CREATE ROLE LEOPARD_tax_sranalyst_corp;
CREATE ROLE LEOPARD_tax_jranalyst_corp;
CREATE ROLE LEOPARD_tax_sranalyst_indiv;
CREATE ROLE LEOPARD_tax_jranalyst_indiv;
CREATE ROLE LEOPARD_tax_user_east;
CREATE ROLE LEOPARD_tax_user_central;
CREATE ROLE LEOPARD_tax_user_west;


-- 1.4.2   Grant the business user roles to your user.
--         Grant all custom roles to user LEOPARD.

GRANT ROLE LEOPARD_tax_executive to user LEOPARD;
GRANT ROLE LEOPARD_tax_sranalyst_corp to user LEOPARD;
GRANT ROLE LEOPARD_tax_jranalyst_corp to user LEOPARD;
GRANT ROLE LEOPARD_tax_sranalyst_indiv to user LEOPARD;
GRANT ROLE LEOPARD_tax_jranalyst_indiv to user LEOPARD;
GRANT ROLE LEOPARD_tax_user_east to user LEOPARD;
GRANT ROLE LEOPARD_tax_user_central to user LEOPARD;
GRANT ROLE LEOPARD_tax_user_west to user LEOPARD;


-- 1.4.3   Grant privileges to the custom roles.
--         Grant usage access on the database TAX_DB and the schema TAXSCHEMA to
--         the custom roles, and grant select on all TAXSCHEMA tables to the
--         custom roles.

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_executive;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_executive;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_executive;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_sranalyst_corp;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_sranalyst_corp;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_sranalyst_corp;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_jranalyst_corp;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_jranalyst_corp;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_jranalyst_corp;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_sranalyst_indiv;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_sranalyst_indiv;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_sranalyst_indiv;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_jranalyst_indiv;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_jranalyst_indiv;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_jranalyst_indiv;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_user_east;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_east;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_east;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_user_central;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_central;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_central;

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_tax_user_west;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_west;
GRANT SELECT on all tables in schema LEOPARD_tax_db.taxschema to role LEOPARD_tax_user_west;


-- 1.4.4   Test what the end user roles can see.
--         At this point, all the end user roles are granted access to the
--         tables AND data because we haven’t installed any controls or policies
--         to limit what data each roles can see. Choose one of the roles
--         highlighted in yellow in the diagram below, and see what data is
--         currently visible to that role. Scroll below the diagram if you need
--         help querying a table with one of the end user roles.
--         Custom Roles Have Access to ALL Data
--         In the example below, you use the role for the tax user in the West
--         region to query the TAXPAYER table. At this point in the setup, all
--         36 rows in the table are returned.

USE ROLE LEOPARD_tax_user_west;
SELECT * FROM LEOPARD_tax_db.taxschema.taxpayer;

--         The grants above that give SELECT on these tables provide the general
--         ability to query from the tables and are necessary in Snowflake’s
--         RBAC model. In subsequent labs we will further refine and limit
--         access so the role LEOPARD_tax_user_west sees only their own regional
--         (West region) information. Notice the results of the previous query
--         returned 36 rows, including rows from the central state IL (Illinois)
--         and the eastern state VT (Vermont), which this role should NOT be
--         able to see.

-- 1.5.0   Set Up the Management Role POLICY_ADMIN
--         In this task, you will set up the role to centrally manage all object
--         tags, row access policies, and data masking policies in the account.
--         Set Up Centralized Tag and Data Governance Policy Management
--         In this centralized data governance scenario, the POLICY_ADMIN role
--         is responsible for managing all object tags, row access policies, and
--         data masking policies.

-- 1.5.1   Create the role LEOPARD_POLICY_ADMIN to centrally manage tags and
--         data governance policies.
--         As SECURITYADMIN, create the POLICY_ADMIN role and grant the
--         appropriate privileges to enable centralized management for tagging,
--         row access and data masking policies.
--         The POLICY_ADMIN, as per separation of duty, is NOT granted SELECT
--         access to the TAXPAYER, TAXPAYER_DEPENDENTS, or TAXPAYER_WAGES
--         tables.

USE ROLE securityadmin;

CREATE ROLE LEOPARD_policy_admin;


-- 1.5.2   Grant object privileges to the role LEOPARD_POLICY_ADMIN.
--         The POLICY_ADMIN role is granted usage on the TAX_DB database and the
--         TAXSCHEMA schema, but is NOT granted select access to the underlying
--         tables.

GRANT USAGE on database LEOPARD_tax_db to role LEOPARD_policy_admin;
GRANT USAGE on schema LEOPARD_tax_db.taxschema to role LEOPARD_policy_admin;

--         Issue grants to the POLICY_ADMIN role for creating row access and
--         data masking policies.

GRANT CREATE row access policy on schema LEOPARD_tax_db.taxschema to role LEOPARD_policy_admin;
GRANT CREATE masking policy on schema LEOPARD_tax_db.taxschema to role LEOPARD_policy_admin;

--         Issue grants to the POLICY_ADMIN role for creating and managing
--         object tags.

GRANT CREATE tag on schema LEOPARD_tag_db.tag_library to role LEOPARD_policy_admin;
-- The next few commands ensure that the POLICY_ADMIN role is able to audit
-- policies and the policies' usage.
GRANT imported privileges on database snowflake to role LEOPARD_policy_admin;
GRANT USAGE on database LEOPARD_tag_db to role LEOPARD_policy_admin;
GRANT USAGE on schema LEOPARD_tag_db.tag_library to role LEOPARD_policy_admin;

--         Grant select on the two mapping tables in the schema
--         LEOPARD_tax_db.taxschema to the role LEOPARD_policy_admin.
--         Note that SELECT access to the mapping tables is required in order
--         for the POLICY_ADMIN role to deploy the row access policy you will be
--         creating, because the row access policy will issue SELECT against
--         these mapping tables. Also note that the mapping tables contain NO
--         sensitive data.

GRANT SELECT on LEOPARD_tax_db.taxschema.tax_mapping to role LEOPARD_policy_admin;
GRANT SELECT on LEOPARD_tax_db.taxschema.taxuser_mapping to role LEOPARD_policy_admin;


-- 1.5.3   Grant the roles to your user.
--         Enable the executing user LEOPARD to use the POLICY_ADMIN role.

GRANT ROLE LEOPARD_policy_admin to user LEOPARD;


-- 1.5.4   Grant account privileges to the role LEOPARD_POLICY_ADMIN.
--         Issue account-level grants to the POLICY_ADMIN role to enable
--         deployment of tags, row access policies, and data masking policies
--         across the account.
--         User LEOPARD must have been previously granted the ACCOUNTADMIN role
--         in order for these grants to succeed.

USE ROLE accountadmin;
USE WAREHOUSE LEOPARD_wh;

GRANT APPLY row access policy on account to role LEOPARD_policy_admin;
GRANT APPLY masking policy on account to role LEOPARD_policy_admin;
GRANT APPLY tag on account to role LEOPARD_policy_admin;
GRANT APPLY tag on account to role LEOPARD_taxdata_steward;


-- 1.6.0   Verify the Proper Setup of Centralized Data Governance

-- 1.6.1   Confirm that the POLICY_ADMIN role does not have SELECT access to any
--         taxpayer data.
--         Verify that, as per separation of duty, the POLICY_ADMIN role has no
--         SELECT access to any data in the three taxpayer tables in the red
--         box, but should have access to the two mapping tables in the green
--         box.
--         POLICY_ADMIN Separation of Duty

USE ROLE LEOPARD_policy_admin;

-- The three queries below should error out because the POLICY_ADMIN role
-- has not been granted SELECT access to these tables.
SELECT * FROM LEOPARD_tax_db.taxschema.taxpayer;
SELECT * FROM LEOPARD_tax_db.taxschema.taxpayer_dependents;
SELECT * FROM LEOPARD_tax_db.taxschema.taxpayer_wages;


-- 1.6.2   Confirm that POLICY_ADMIN has SELECT access to the mapping tables.

-- The two queries below should succeed, because the POLICY_ADMIN role has
-- been granted SELECT access to the mapping tables.
-- The mapping tables contain NO sensitive data.
SELECT * FROM LEOPARD_tax_db.taxschema.tax_mapping;
SELECT * FROM LEOPARD_tax_db.taxschema.taxuser_mapping;


-- 1.6.3   Confirm that all the custom data governance roles have been granted
--         to user LEOPARD.

USE ROLE training_role;

SHOW GRANTS to user LEOPARD;

-- There should be a total of 10 roles returned by the following command.
SELECT "role"
      ,"granted_to"
      ,"grantee_name"
      ,"granted_by"
    FROM table(result_scan(last_query_id()))
    WHERE "role" like 'LEOPARD%'
ORDER BY 1 asc;

--         You have set up objects and custom roles for this taxpayer scenario
--         in a centralized data governance model, enabling separation of duty.
--         You also created mapping tables for enabling row access policies in
--         this scenario.
