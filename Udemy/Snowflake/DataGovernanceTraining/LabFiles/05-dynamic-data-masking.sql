
-- 5.0.0   DYNAMIC DATA MASKING
--         In this lab exercise, you will create several data masking policies
--         and apply them to several table columns that have been classified as
--         sensitive by the organization.
--         - Create masking policies for the roles identified to support data
--         governance.
--         - Use the SHOW and DESCRIBE commands to examine the metadata for the
--         masking policies.
--         - Use the POLICY_REFERENCES table function to examine the masking
--         policies assigned to the TAXPAYER tables.
--         - Use SHOW GRANTS to confirm that masking policy privileges have been
--         correctly assigned.
--         - Test the assigned masking policies to ensure they operate as
--         intended.
--         - Apply masking policies to conditional columns - define the column
--         to be masked and the conditions determining whether the data is
--         masked or not.

-- 5.1.0   Establish Data Masking Policies
--         As POLICY_ADMIN, create data masking policies to be applied to
--         objects in the TAX_DB database.
--         No Masking Policies In Place to Protect Sensitive Data

-- 5.1.1   Set the worksheet context for the lab.

USE ROLE LEOPARD_policy_admin;
USE WAREHOUSE LEOPARD_wh;
USE SCHEMA LEOPARD_tax_db.taxschema;


-- 5.1.2   Create the masking policies.
--         The policies created will restrict visibility of data identified as
--         sensitive in the Data Governance Policy. Specifically social security
--         number, email address, and name will be displayed differently with
--         different levels of detail depending on the role accessing the data.
--         Masking Policies to Protect Sensitive Data

CREATE or REPLACE masking policy ssn_mask as
  (val string) returns string ->  
  CASE
    WHEN current_role() in ('LEOPARD_TAXDATA_STEWARD','LEOPARD_TAX_EXECUTIVE',
    'LEOPARD_TAX_SRANALYST_CORP','LEOPARD_TAX_SRANALYST_INDIV') then val
    WHEN current_role() in ('LEOPARD_TAX_JRANALYST_CORP','LEOPARD_TAX_JRANALYST_INDIV') then repeat('*', length(val)-4) || right(val, 4)
    ELSE '*** MASKED ***'
   END;

CREATE or REPLACE masking policy email_mask as
  (val string) returns string ->  
  CASE
    WHEN current_role() in ('LEOPARD_TAXDATA_STEWARD','LEOPARD_TAX_EXECUTIVE',
    'LEOPARD_TAX_SRANALYST_CORP','LEOPARD_TAX_SRANALYST_INDIV') then val
    WHEN current_role() in ('LEOPARD_TAX_JRANALYST_CORP','LEOPARD_TAX_JRANALYST_INDIV') then regexp_replace(val,'.+\@','*****@')
    ELSE '*** MASKED ***'
   END;

CREATE or REPLACE masking policy name_mask as
  (val varchar) returns varchar ->  
  CASE
    WHEN current_role() in ('LEOPARD_TAXDATA_STEWARD','LEOPARD_TAX_EXECUTIVE',
    'LEOPARD_TAX_SRANALYST_CORP','LEOPARD_TAX_SRANALYST_INDIV') then val
    WHEN current_role() in ('LEOPARD_TAX_JRANALYST_CORP','LEOPARD_TAX_JRANALYST_INDIV') then regexp_replace(val,'.','*',2)
    ELSE '*** MASKED ***'
   END;


-- 5.1.3   Set masking policies for specific columns in the TAXSCHEMA tables.
--         These statements succeed as long as POLICY_ADMIN has previously been
--         granted the APPLY MASKING POLICY ON ACCOUNT privilege by
--         ACCOUNTADMIN.
--         Apply the masking policies to columns that your organization has
--         determined need the SSN_MASK policy.
--         SSN_MASK Masking Policy Applied

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer modify column taxpayer_id set masking policy ssn_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column taxpayer_id set masking policy ssn_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dependent_ssn set masking policy ssn_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify column taxpayer_id set masking policy ssn_mask;

--         Set the columns that need the NAME_MASK policy applied.
--         NAME_MASK Masking Policy Applied

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer modify column lastname set masking policy name_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer modify column firstname set masking policy name_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer modify column corp_taxpayer_name set masking policy name_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dep_lastname set masking policy name_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dep_firstname set masking policy name_mask;

--         Apply the masking policy to the columns that need the EMAIL_MASK
--         policy.
--         EMAIL_MASK Masking Policy Applied

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer modify column email set masking policy email_mask;
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dep_email set masking policy email_mask;


-- 5.2.0   Examine the Metadata for the Masking Policies
--         As POLICY_ADMIN run the SHOW and DESCRIBE commands to view the
--         masking policies.
--         Starting with the current database. This lists the three masks,
--         SSN_MASK, EMAIL_MASK, and NAME_MASK you created and applied.

SHOW masking policies;

--         Next, match the pattern on the policy name for current database.

SHOW masking policies like '%email%';

--         Now look at the masking policies for all databases in the account.

SHOW masking policies in account;

--         Use the DESCRIBE command to see the creation date, name, and data
--         type as well as SQL used to create the masking policy.

DESC masking policy ssn_mask;
DESC masking policy name_mask;
DESC masking policy email_mask;

--         Use the DESCRIBE command again to see the masking policy details for
--         the tax tables. Expand your output window and note each non-null
--         policy name for each column that has an assigned masking policy.

DESC table taxpayer;
DESC table taxpayer_dependents;
DESC table taxpayer_wages;


-- 5.3.0   Examine Policies Assigned to the Taxpayer Tables
--         The SNOWFLAKE.ACCOUNT_USAGE view POLICY_REFERENCES can be used to
--         identify the tables and views in which a data masking policy or row
--         access policy is set. However, this view has up to a two-hour data
--         latency.
--         The database-level table function POLICY_REFERENCES returns a row for
--         each object that has the specified policy assigned to the object or
--         returns a row for each policy assigned to the specified object. This
--         table function experiences no latency when executed.
--         Execute the POLICY_REFERENCES table function to see all policies
--         currently assigned to the TAXPAYER, TAXPAYER_DEPENDENTS, and
--         TAXPAYER_WAGES tables. Note that the output shows BOTH data masking
--         and row access policies.

USE ROLE LEOPARD_policy_admin;
USE DATABASE LEOPARD_tax_db;
USE SCHEMA LEOPARD_tax_db.taxschema;

SELECT *
FROM table(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.taxpayer', ref_entity_domain => 'TABLE'));

SELECT *
FROM table(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.taxpayer_dependents', ref_entity_domain => 'TABLE'));

SELECT *
FROM table(information_schema.policy_references(ref_entity_name => 'LEOPARD_tax_db.taxschema.taxpayer_wages', ref_entity_domain => 'TABLE'));


-- 5.4.0   Examine Grants and Masking Policies

-- 5.4.1   Run SHOW GRANTS command to view all masking policy privileges.
--         Start by using the SHOW GRANTS command to see all the masking policy
--         privileges that have been explicitly granted.

SHOW GRANTS on masking policy email_mask;
SHOW GRANTS on masking policy name_mask;
SHOW GRANTS on masking policy ssn_mask;


-- 5.4.2   Confirm the correct assignments of masking policies.
--         Test the usage of data masking policies in conjunction with the row
--         access policy you created and deployed in a prior lab exercise.
--         We will start with the Roles that see all TAXSCHEMA data in clear
--         text:

USE ROLE LEOPARD_TAXDATA_STEWARD;
   -- Sees all taxpayer data (Corporate and Individual) in clear text

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
    FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;


USE ROLE LEOPARD_TAX_EXECUTIVE;
   -- Sees all taxpayer data (Corporate and Individual) in clear text

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;

--         Now let’s see our masking policy in action; in particular let’s
--         review and see how the EMAIL_MASK gets applied for roles that should
--         see two different outcomes. The first is a Senior Analyst who, based
--         on the role, should see the email value in the clear text.
--         Email Masking Policy Applied for a Senior Analyst - Individual

USE ROLE LEOPARD_TAX_SRANALYST_INDIV;
   -- Sees Individual taxpayer data in clear text

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
   FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;

--         Now let’s look at an analyst who should see the same set of rows
--         (Individuals) but who should see a redacted view of columns, per the
--         masking policy.
--         Email Masking Policy Applied for a Junior Analyst - Individual

USE ROLE LEOPARD_TAX_JRANALYST_INDIV;
   -- Sees partially masked Individual taxpayer data only

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;  

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;  


SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;  

--         Let’s look at what the Corporate Analysts can see, starting with the
--         Senior Corporate Analyst. According to the masking policy this role
--         should see all Corporate data in clear text. We can see this is true,
--         but notice that there are no email addresses shown. We do not have
--         corporate emails in our data so this column is empty.
--         Masking Policies Applied for a Senior Analyst - Corporate

USE ROLE LEOPARD_TAX_SRANALYST_CORP;
    -- Sees all Corporate taxpayer data in clear text

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;
   -- No data returned since taxpayer_dependents contains no Corporate tax data

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;
   -- No data returned since taxpayer_wages contains no Corporate tax data

--         Now let’s look at Junior Corporate Analyst. According to the masking
--         policy this role should see Taxpayer Id, Corporate Taxpayer Name, and
--         Email masked. We can see this is true, but again there are no email
--         addresses shown since we do not have corporate emails in our data.
--         Masking Policies Applied for a Junior Analyst - Corporate

USE ROLE LEOPARD_TAX_JRANALYST_CORP;
   -- Sees partially masked Corporate taxpayer data only

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;  

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
     ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;   
   -- No data returned since taxpayer_dependents contains no Corporate tax data

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;
   -- No data returned since taxpayer_wages contains no Corporate tax data

--         All other roles that are authorized to view TAXSCHEMA data will see
--         the PII columns fully masked.

USE ROLE LEOPARD_TAX_USER_EAST;
   -- Sees fully masked taxpayer data for Eastern geographic region

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;   

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
      ,state
   FROM taxpayer_wages;  

USE ROLE LEOPARD_TAX_USER_CENTRAL;
   -- Sees fully masked taxpayer data for Central geographic region

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

  SELECT taxpayer_id
        ,tax_year
        ,w2_total_income
        ,total_federal_tax
        ,state
   FROM taxpayer_wages;    

USE ROLE LEOPARD_TAX_USER_WEST;
   -- Sees fully masked taxpayer data for Western geographic region

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
      ,state
   FROM taxpayer_wages;

--         TRAINING_ROLE (the owner of the tax tables) sees NO data at all due
--         to enforcement of the row access policy on the TAXPAYER,
--         TAXPAYER_DEPENDENTS, and TAXPAYER_WAGES tables.
--         Verify TRAINING_ROLE sees no tax data due to enforcement of row
--         access policy on taxpayer and taxpayer_dependents tables.
--         Masking Policies Applied for Training_Role

USE ROLE TRAINING_ROLE;

SELECT taxpayer_type
      ,taxpayer_id
      ,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
    FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
      ,state
   FROM taxpayer_wages;

--         Try using the PUBLIC role and confirm that any attempt to view
--         TAXSCHEMA data errors out, since this role has not been authorized to
--         access the data.

USE ROLE PUBLIC;
    -- Queries error out due to the role not being authorized to view data in the TAXSCHEMA tables.

SELECT taxpayer_type
      ,taxpayer_id,corp_taxpayer_name
      ,lastname
      ,firstname
      ,email
      ,city
      ,state
   FROM taxpayer;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

SELECT taxpayer_id
      ,tax_year
      ,w2_total_income
      ,total_federal_tax
   FROM taxpayer_wages;


-- 5.5.0   Create and Apply a Data Masking Policy Using Conditional Columns
--         Conditional data masking is currently an Open feature (Open features
--         were previously referred to as features in Public Preview) and is
--         available to all Snowflake accounts running Enterprise Edition or
--         higher.

-- 5.5.1   Establish and apply a conditional masking policy.
--         As POLICY_ADMIN, create a conditional masking policy in the
--         TAX_DB.TAXSCHEMA schema that masks the dep_email column of
--         TAXPAYER_DEPENDENTS as shown in the code below:

USE ROLE LEOPARD_policy_admin;
USE WAREHOUSE LEOPARD_wh;
USE SCHEMA LEOPARD_tax_db.taxschema;

--         Conditional masking of the dep_email column of TAXPAYER_DEPENDENTS is
--         based on the values contained on the dep_relationship column. The
--         first argument in the masking policy always specifies the column to
--         be masked (in this case, dep_email), and the second argument is a
--         conditional column (in this case, dependent) used to evaluate whether
--         the first column should be masked.

CREATE or REPLACE masking policy email_mask_spouse as
  (email string, dependent string) returns string ->
  CASE
    WHEN dependent = 'Spouse' then email
    WHEN current_role() in ('LEOPARD_TAXDATA_STEWARD','LEOPARD_TAX_EXECUTIVE'
         ,'LEOPARD_TAX_SRANALYST_CORP','LEOPARD_TAX_SRANALYST_INDIV') then email
    WHEN current_role() in ('LEOPARD_TAX_JRANALYST_CORP','LEOPARD_TAX_JRANALYST_INDIV') then regexp_replace(email,'.+\@','*****@')
    ELSE '*** MASKED ***'
  END;

--         Apply the conditional masking policy to the TAXPAYER_DEPENDENTS
--         dep_email column.
--         Remove the email masking policy that had been previously applied to
--         the dep_email column of TAXPAYER_DEPENDENTS.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dep_email unset masking policy;

--         Now apply the conditional masking policy to the dep_email column of
--         TAXPAYER_DEPENDENTS.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents modify column dep_email
set masking policy email_mask_spouse using (dep_email, dep_relationship);


-- 5.5.2   View masking policy metadata.
--         As POLICY_ADMIN, check the masking policy starting with just the
--         current database.

SHOW masking policies;


-- 5.5.3   Now test the conditional data masking policy.
--         First, the roles that see TAXPAYER_DEPENDENTS data in clear text:

USE ROLE LEOPARD_TAXDATA_STEWARD;
  -- Sees all dep_email values in clear text.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city,dep_state
   FROM taxpayer_dependents;

USE ROLE LEOPARD_TAX_EXECUTIVE;
-- Sees all dep_email values in clear text.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city,dep_state
   FROM taxpayer_dependents;

USE ROLE LEOPARD_TAX_SRANALYST_CORP;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

-- No data returned since TAXPAYER_DEPENDENTS contains no Corporate tax data

USE ROLE LEOPARD_TAX_SRANALYST_INDIV;
-- Sees all dep_email values in clear text.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

--         Next, the roles that see partially masked TAXPAYER_DEPENDENTS data:

USE ROLE LEOPARD_TAX_JRANALYST_INDIV;
 -- Sees "Spouse" dep_email values in clear text, and partially masked dep_email values for all other dependents.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

--         And finally, all other roles that are authorized to view
--         TAXPAYER_DEPENDENTS data will see the PII columns, except Spouse
--         dep_email, fully masked.
--         Masking and Conditional Masking Policies Applied for Tax_User_East

USE ROLE LEOPARD_TAX_USER_EAST;
-- Sees "Spouse" dep_email values in clear text, and fully masked dep_email values for all other dependents, for East region only.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

USE ROLE LEOPARD_TAX_USER_CENTRAL;
-- Sees "Spouse" dep_email values in clear text, and fully masked dep_email values for all other dependents, for Central region only.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

USE ROLE LEOPARD_TAX_USER_WEST;
-- Sees "Spouse" dep_email values in clear text, and fully masked dep_email values for all other dependents, for West region only.

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city
      ,dep_state
   FROM taxpayer_dependents;

--         TRAINING_ROLE (the owner of the TAX_DB tables) sees NO
--         TAXPAYER_DEPENDENTS data at all due to enforcement of the row access
--         policy on the TAXPAYER_DEPENDENTS table.

USE ROLE TRAINING_ROLE;

SELECT dep_taxpayer_type
      ,dependent_ssn
      ,taxpayer_id
      ,dep_relationship
      ,dep_email
      ,dep_lastname
      ,dep_firstname
      ,dep_city,dep_state
   FROM taxpayer_dependents;

