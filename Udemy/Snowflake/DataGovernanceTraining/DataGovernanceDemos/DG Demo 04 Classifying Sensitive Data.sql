-- Demo: Classifying Sensitive Data
-- Last updated: 15AUG2022
-- Version: 1.20

-- *** Demo Overview ***
--   Snowflake scans all the supported columns in a table or view and uses
--   the column data types and values to classify the data into system
--   categories provided by Snowflake.
--
--   These categories can be assigned to the columns as tags, which can be
--   set manually or using Snowflake provided stored procedure.
-- *********************

-- Set context
-- Note that TAXDATA_STEWARD will be performing 
-- the data classification for this demo.

USE ROLE INSTRUCTOR1_taxdata_steward;
USE SCHEMA INSTRUCTOR1_tax_db.taxschema;
USE WAREHOUSE INSTRUCTOR1_wh;

-- Review the three TAX_DB.TAXSCHEMA tables for sensitive data.

SELECT * FROM TAXPAYER LIMIT 5;
SELECT * FROM TAXPAYER_DEPENDENTS LIMIT 5;
SELECT * FROM TAXPAYER_WAGES LIMIT 5;

-- Automatic data classification is done using two system tags: 
--   SEMANTIC_CATEGORY
--   PRIVACY_CATEGORY

-- Run native classification function SEMANTIC_CATEGORY() on TAXPAYER table.
-- The categories will be derived from the metadata and data contained
-- in the columns, as well as the metadata about the columns and data.
-- The privacy categories rely on the generated semantic categories, if any.

USE ROLE INSTRUCTOR1_taxdata_steward;
USE SCHEMA INSTRUCTOR1_tax_db.taxschema;
USE WAREHOUSE INSTRUCTOR1_wh;

SELECT EXTRACT_SEMANTIC_CATEGORIES('TAXPAYER');

-- Convert the JSON output of EXTRACT_SEMANTIC_CATEGORIES to structured format.
-- The semantic classification function EXTRACT_SEMANTIC_CATEGORIES
-- returns a VARCHAR in JSON format, which is a semi-structured format.
-- The FLATTEN table function is applied to convert to structured format.

SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('TAXPAYER')::variant)) as f;


-- Store the output of EXTRACT_SEMANTIC_CATEGORIES as a new table.
-- Storing the output as new table will make it easier to modify before
-- applying and/or reuse.

CREATE OR REPLACE TABLE SEMANTIC_CATEGORIES_TAXPAYER(V VARIANT)
AS SELECT EXTRACT_SEMANTIC_CATEGORIES('TAXPAYER');

SELECT * FROM SEMANTIC_CATEGORIES_TAXPAYER;


-- Review the SEMANTIC_CATEGORY and PRIVACY_CATEGORY tags and their values.

SELECT KEY AS COLUMN_NAME, VALUE:semantic_category AS SEMANTIC_CATEGORY, 
VALUE:privacy_category AS PRIVACY_CATEGORY,
VALUE:extra_info:probability AS PROBABILITY, 
VALUE:extra_info:alternates AS ALTERNATES
FROM SEMANTIC_CATEGORIES_TAXPAYER, LATERAL FLATTEN(INPUT=> V);


-- Classify the columns by applying the generated system tags:
-- - Method 1: Use system function ASSOCIATE_SEMANTIC_CATEGORY_TAGS
-- - Method 2: Manually run APPLY TAG

-- Create two copies of the TAXPAYER table so that we can explore the use of both classification methods.

CREATE OR REPLACE TABLE TAXPAYER_CPY01 AS SELECT * FROM TAXPAYER;
CREATE OR REPLACE TABLE TAXPAYER_CPY02 AS SELECT * FROM TAXPAYER;

-- Method 1: Apply system generated semantic and privacy tags to TAXPAYER_CPY01 
-- using ASSOCIATE_SEMANTIC_CATEGORY_TAGS.

CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS('TAXPAYER_CPY01',(SELECT * FROM SEMANTIC_CATEGORIES_TAXPAYER));

CREATE OR REPLACE TABLE SEMANTIC_CATEGORIES_TAXPAYER_CPY01(V VARIANT)
AS SELECT EXTRACT_SEMANTIC_CATEGORIES('TAXPAYER_CPY01');

SELECT KEY AS COLUMN_NAME, VALUE:semantic_category AS SEMANTIC_CATEGORY, 
VALUE:privacy_category AS PRIVACY_CATEGORY,
VALUE:extra_info:probability AS PROBABILITY, 
VALUE:extra_info:alternates AS ALTERNATES
FROM SEMANTIC_CATEGORIES_TAXPAYER_CPY01, LATERAL FLATTEN(INPUT=> V);

-- Method 2: Manually apply the system tags to columns in TAXPAYER_CPY02.

-- Manually tag LASTNAME
ALTER TABLE TAXPAYER_CPY02 MODIFY COLUMN LASTNAME SET TAG SNOWFLAKE.CORE.SEMANTIC_CATEGORY='NAME';
ALTER TABLE TAXPAYER_CPY02 MODIFY COLUMN LASTNAME SET TAG SNOWFLAKE.CORE.PRIVACY_CATEGORY='IDENTIFIER';

-- Manually tag TAXPAYER_ID as category US_SSN
ALTER TABLE TAXPAYER_CPY02 MODIFY COLUMN TAXPAYER_ID SET TAG SNOWFLAKE.CORE.SEMANTIC_CATEGORY='US_SSN';
ALTER TABLE TAXPAYER_CPY02 MODIFY COLUMN TAXPAYER_ID SET TAG SNOWFLAKE.CORE.PRIVACY_CATEGORY='IDENTIFIER';

-- Monitor and Track the system tags
--   Use Show command to list the tags
--   Use database-level table function to review and track the tags without any latency
--   Use account-level function to review the track with a 2-hour latency

-- List all tags in the SNOWFLAKE database.

SHOW TAGS IN DATABASE SNOWFLAKE;


-- Run TAG_REFERENCES_ALL_COLUMNS to review and track the tags with NO latency.
-- Note that we're using TAG_DATABASE=SNOWFLAKE and TAG_SCHEMA=CORE

-- System-applied tags; Note that NO privacy_category 
-- or semantic_category is assigned for TAXPAYER_ID
SELECT *
FROM TABLE(INSTRUCTOR1_tax_db.INFORMATION_SCHEMA.tag_references_all_columns('TAXPAYER_CPY01', 'table'))
WHERE tag_database = 'SNOWFLAKE' and tag_schema = 'CORE';

-- Manually-applied tags; Note US_SSN semantic_category is assigned for TAXPAYER_ID
SELECT *
FROM TABLE(INSTRUCTOR1_tax_db.INFORMATION_SCHEMA.tag_references_all_columns('TAXPAYER_CPY02', 'table'))
WHERE tag_database = 'SNOWFLAKE' and tag_schema = 'CORE';

-- Use SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES to review and track the tags with 2-hour latency.
-- Note - You will not see data here if within the latency period.

SELECT DISTINCT TAG_NAME, TAG_VALUE, COLUMN_NAME FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES 
WHERE TAG_DATABASE='SNOWFLAKE' AND OBJECT_NAME = 'TAXPAYER_CPY01'
ORDER BY COLUMN_NAME, TAG_NAME;

SELECT DISTINCT TAG_NAME, TAG_VALUE, COLUMN_NAME FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES 
WHERE TAG_DATABASE='SNOWFLAKE' AND OBJECT_NAME = 'TAXPAYER_CPY02'
ORDER BY COLUMN_NAME, TAG_NAME;

-- Analyze TAXPAYER_DEPENDENTS, and note the identified SEMANTIC_CATEGORY value US_SSN
-- under the ALTERNATES column for the column name DEPENDENT_SSN.
-- This happens due to the column name (DEPENDENT_SSN) including the string "SSN".

-- If the column name was different, such as DEP_TAXPAYER_ID, 
-- then the system classification would not currently assign 
-- DEP_TAXPAYER_ID to the US_SSN semantic category.

SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('TAXPAYER_DEPENDENTS')::variant)) as f;

-- Querying tag latency via SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES_WITH_LINEAGE
-- Note: Using SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES_WITH_LINEAGE with system tags
-- is not currently supported.
-- Therefore, the two queries below return *NO RESULTS* even after letency time has been met

select *
  from table(snowflake.account_usage.tag_references_with_lineage('SNOWFLAKE.CORE.PRIVACY_CATEGORY'));
  
select *
  from table(snowflake.account_usage.tag_references_with_lineage('SNOWFLAKE.CORE.SEMANTIC_CATEGORY'));
