-- Demo: Tagging Sensitive Objects & Columns
-- Version: 1.20
-- Last updated: 18SEP2022

-- Set context
use role sysadmin;
use warehouse INSTRUCTOR1_wh;

-- grant usage on database INSTRUCTOR1_tag_db to public;
-- grant usage on schema INSTRUCTOR1_tag_db.tag_library to role public;

-- Note: The POLICY_ADMIN role creates a library of tags in the centralized schema named TAG_LIBRARY. 
-- This approach makes it easier to maintain a centralized taxonomy of tags that can 
-- be applied to objects across the account. 

use role INSTRUCTOR1_policy_admin;

use schema INSTRUCTOR1_tag_db.tag_library;

-- Create a library of object tags (1 table-level or view-level tag, 2 column-level tags)
create or replace tag confidentiality; -- Used for tagging at table and/or view level
create or replace tag pii_type; -- Personally Identifiable Information, column level
create or replace tag spi_type; -- Sensitive Personal Information, column level

-- Use comments field to describe the rule for others to see
alter tag INSTRUCTOR1_tag_db.tag_library.confidentiality set comment = "Tag tables or views with confidential information with the following values: Highly Sensitive, Sensitive, Confidential";
alter tag INSTRUCTOR1_tag_db.tag_library.pii_type set comment = "Tag columns as PII with corresponding values: Taxpayer ID, Email, Phone number, etc.";
alter tag INSTRUCTOR1_tag_db.tag_library.spi_type set comment = "Tag columns as SPI with corresponding values:  Data that has critical business or usage sensitivity but is not PII";

-- Allow SYSADMIN to set or unset the tag
-- (decentralized management of tagging)
-- These steps are NOT required if planning to deploy centralized
-- administration of tagging in which you want to have the
-- POLICY_ADMIN role apply all tags rather than the data owner
-- role (SYSADMIN) of the application schema.

--- The policy administrator can grant the data owner (SYSADMIN) the privilege to apply the tag to their own objects  as shown below.
-- Assign Roles for Tagging
-- grant apply on tag INSTRUCTOR1_tag_db.tag_library.confidentiality to role sysadmin;
-- grant apply on tag INSTRUCTOR1_tag_db.tag_library.pii_type to role sysadmin;
-- grant apply on tag INSTRUCTOR1_tag_db.tag_library.spi_type to role sysadmin;

-- Note: SYSADMIN owns the TAX_DB.TAXSCHEMA tables TAXPAYER, TAXPAYER_DEPENDENTS, and TAXPAYER_WAGES. 

use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;

-- As POLICY_ADMIN, tag the TAX_DB.TAXSCHEMA tables TAXPAYER, TAXPAYER_DEPENDENTS, and TAXPAYER_WAGES
-- and associated sensitive columns with a corresponding tag.

-- Assign confidentiality tags to the TAX_DB.TAXSCHEMA tables
-- NOTE: Table-level tags are assigned to EVERY column in a table
-- For TAXPAYER (16 columns), the table-level tag value
--     "Highly Sensitive" is assigned to each of the 16 columns
-- For TAXPAYER_DEPENDENTS (13 columns), the table-level tag value
--     "Sensitive" is assigned to each of the 13 columns
-- For TAXPAYER_WAGES (8 columns), the table-level tag value
--     "Confidential" is assigned to each of the 8 columns

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer set tag INSTRUCTOR1_tag_db.tag_library.confidentiality="Highly Sensitive";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents set tag INSTRUCTOR1_tag_db.tag_library.confidentiality="Sensitive";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages set tag INSTRUCTOR1_tag_db.tag_library.confidentiality="Confidential";

-- Assign PII (Personally Identifiable Information) tags to the TAXPAYER columns classified as PII
-- NOTE: 8 PII columns in TAXPAYER table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify taxpayer_id set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Taxpayer ID";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify home_phone set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Home Phone";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify cell_phone set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Cell Phone";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify email set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Email";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify lastname set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Last Name";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify firstname set tag INSTRUCTOR1_tag_db.tag_library.pii_type="First Name";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify birthdate set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Birth Date";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify corp_taxpayer_name set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Corp Taxpayer Name";

-- Assign PII (Personally Identifiable Information) tags to the TAXPAYER_DEPENDENTS columns classified as PII
-- NOTE: 8 PII columns in TAXPAYER_DEPENDENTS table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify taxpayer_id set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Taxpayer ID";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dependent_ssn set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent SSN";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_home_phone set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent Home Phone";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_cell_phone set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent Cell Phone";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_email set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent Email";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_lastname set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent Last Name";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_firstname set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent First Name";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_birthdate set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Dependent Birth Date";

-- Assign PII (Personally Identifiable Information) tags to the TAXPAYER_WAGES columns classified as PII
-- NOTE: 1 PII column in TAXPAYER_WAGES table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify taxpayer_id set tag INSTRUCTOR1_tag_db.tag_library.pii_type="Taxpayer ID";

-- Assign SPI (Sensitive Personal Information) tags to TAXPAYER columns classified as SPI
-- NOTE: 3 SPI columns in TAXPAYER table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify street set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Street";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify city set tag INSTRUCTOR1_tag_db.tag_library.spi_type="City";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer modify nbr_exemptions set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Number of Exemptions";

-- Assign SPI (Sensitive Personal Information) tags to TAXPAYER_DEPENDENTS columns classified as SPI
-- NOTE: 1 SPI column in TAXPAYER_DEPENDENTS table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents modify dep_city set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Dependent City";

-- Assign SPI (Sensitive Personal Information) tags to TAXPAYER_WAGES columns classified as SPI
-- NOTE: 5 SPI columns in TAXPAYER_WAGES table

alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify tax_year set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Tax Year";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify w2_total_income set tag INSTRUCTOR1_tag_db.tag_library.spi_type="W2 Total Income";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify adj_gross_income set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Adj Gross Income";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify taxable_income set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Taxable Income";
alter table INSTRUCTOR1_tax_db.taxschema.taxpayer_wages modify total_federal_tax set tag INSTRUCTOR1_tag_db.tag_library.spi_type="Total Federal Tax";

-- Usage notes for auditing of tagged objects and columns:
-- 1. POLICY_ADMIN is able to perform reporting of PII data as well as checking for PII data that should have masking policies applied. 
-- 2. POLICY_ADMIN can query the view SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES to track newly tagged objects. 
-- 3. POLICY_ADMIN can query the view SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES to ensure that each sensitive column has a masking policy applied.

-- Set context
use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;

-- View the tags associated with the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer.
SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer', 'TABLE'));
   
-- View the tags associated with the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents.
SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents', 'TABLE'));

-- View the tags associated with the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer_wages.
SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer_wages', 'TABLE'));

-- The table function TAG_REFERENCES_ALL_COLUMNS shows the tag name and tag value assigned to a specific column.
-- It returns every tag set on every column in a given table or view, whether the tag 
-- is directly assigned to a column or through tag lineage (i.e., from assignment at the table level).

-- View the list of tags that are assigned to every column in the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer.
-- Note: Total of 27 rows:
--   16 table-level tags, covers all 16 columns in TAXPAYER ("Highly Sensitive" value) 
--   11 column-level tags (8 PII, 3 SPI)

SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references_all_columns
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer', 'TABLE'));

-- View the list of tags that are assigned to every column in the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents.
-- Note: Total of 22 rows:
--   13 table-level tags, covers all 13 columns in TAXPAYER_DEPENDENTS ("Sensitive" value) 
--   9 column-level tags (8 PII, 1 SPI)

SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references_all_columns
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents', 'TABLE'));

-- View the list of tags that are assigned to every column in the table
-- INSTRUCTOR1_tax_db.taxschema.taxpayer_wages.
-- Note: Total of 14 rows:
--   8 table-level tags, covers all 8 columns in TAXPAYER_WAGES ("Confidential" value) 
--   6 column-level tags (1 PII, 5 SPI)

SELECT *
   FROM table(INSTRUCTOR1_tag_db.information_schema.tag_references_all_columns
   ('INSTRUCTOR1_tax_db.taxschema.taxpayer_wages', 'TABLE'));

-- SYSTEM$GET_TAG: Returns the tag value associated with the specified object or column. 
-- Returns NULL if a tag is not set on the specified Snowflake object or column.

-- Examples showing usage of SYSTEM$GET_TAG

use role INSTRUCTOR1_policy_admin;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Show TAXPAYER table tag
select system$get_tag('INSTRUCTOR1_tag_db.tag_library.confidentiality', 'taxpayer', 'table');

-- Show PII column tag for TAXPAYER.TAXPAYER_ID 
select system$get_tag('INSTRUCTOR1_tag_db.tag_library.pii_type','taxpayer.taxpayer_id', 'column');

-- This call returns NULL as there's no assigned SPI tag for the column TAXPAYER.TAXPAYER_ID
select system$get_tag('INSTRUCTOR1_tag_db.tag_library.spi_type','taxpayer.taxpayer_id', 'column'); 

-- Show PII column tags for TAXPAYER.CORP_TAXPAYER_NAME and TAXPAYER_DEPENDENTS.DEP_HOME_PHONE
select system$get_tag('INSTRUCTOR1_tag_db.tag_library.pii_type','taxpayer.corp_taxpayer_name', 'column');
select system$get_tag('INSTRUCTOR1_tag_db.tag_library.pii_type','taxpayer_dependents.dep_home_phone', 'column'); 

-- Tag references with lineage
-- Arguments: <tag_database>.<tag_schema>.<tag_name>

-- TAG_REFERENCES_WITH_LINEAGE: Returns each row that displays an association 
-- between the specified tag and the Snowflake object to which the tag is associated.
-- The associated tag and Snowflake object are the result of both a direct association 
-- to an object and through tag lineage.

-- NOTE #1: TAG_REFERENCES_WITH_LINEAGE is currently not supported
-- for system tags, but rather only for object tags (as shown in the two queries below).

-- NOTE #2: You must pass in the string '<Tag DB>.<Tag Schema>.<Tag>' in 
-- UPPERCASE in order for TAG_REFERENCES_WITH_LINEAGE to return results.

use role instructor1_policy_admin;

-- Tag lineage for CONFIDENTIALITY tag (shows no results if within latency period)
select *
  from table(snowflake.account_usage.tag_references_with_lineage('INSTRUCTOR1_TAG_DB.TAG_LIBRARY.CONFIDENTIALITY'));

-- Tag lineage for PII_TYPE tag (shows no results if within latency period)
select *
  from table(snowflake.account_usage.tag_references_with_lineage('INSTRUCTOR1_TAG_DB.TAG_LIBRARY.PII_TYPE'));

-- Tag lineage for SPI_TYPE tag (shows no results if within latency period)
select *
  from table(snowflake.account_usage.tag_references_with_lineage('INSTRUCTOR1_TAG_DB.TAG_LIBRARY.SPI_TYPE'));

-- Show all tags in account
show tags in account;

-- Show tags only for tag schema INSTRUCTOR1_TAG_DB.TAG_LIBRARY
select "name"
      ,"database_name"
      ,"schema_name"
      ,"owner" 
      ,"comment"
    from table(result_scan(last_query_id()))
    where "database_name" in ('INSTRUCTOR1_TAG_DB');
order by 1 asc; -- 3 tags total

