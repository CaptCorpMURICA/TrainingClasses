
-- 3.0.0   CLASSIFYING SENSITIVE OBJECTS
--         By the end of this lab, you will be able to:
--         - Analyze columns in table using system the function
--         EXTRACT_SEMANTIC_CATEGORIES to identify PII in data
--         - Classify table columns by applying tags using a system function or
--         manually
--         - Track and review the classification tags
--         Classification is the process of analyzing and categorizing
--         information stored in the columns in database tables and views to
--         answer question about the data such as if the table/view contain PII
--         (Personally Identifiable Information) or sensitive data?
--         Snowflake scans all the supported columns in a table or view and uses
--         the column data types and values to classify the data into system
--         categories provided by Snowflake.
--         The categories can be assigned to the columns as tags, which can be
--         set manually or using Snowflake provided stored procedure.

-- 3.1.0   Phase 1: Identify PII and Sensitive Data in your Tables
--         Begin by setting your context.

USE ROLE LEOPARD_taxdata_steward;
USE SCHEMA LEOPARD_tax_db.taxschema;
USE WAREHOUSE LEOPARD_wh;


-- 3.1.1   Review these tables that contain PII and/or sensitive data.

SELECT * FROM TAXPAYER LIMIT 10;
SELECT * FROM TAXPAYER_DEPENDENTS LIMIT 10;
SELECT * FROM TAXPAYER_WAGES LIMIT 10;

--         Snowflake provides automatic data classification using two system
--         tags: - SEMANTIC_CATEGORY
--         - PRIVACY_CATEGORY

-- 3.1.2   Run native classification function SEMANTIC_CATEGORY() on taxpayer
--         table.

SELECT EXTRACT_SEMANTIC_CATEGORIES('TAXPAYER');

--         The categories will be derived from the metadata and data contained
--         in the columns, as well as the metadata about the columns and data.
--         The privacy categories rely on the generated semantic categories, if
--         any.

-- 3.1.3   Convert the JSON output of EXTRACT_SEMANTIC_CATEGORIES to structured
--         format.
--         The semantic classification function EXTRACT_SEMANTIC_CATEGORIES
--         returns a VARCHAR in JSON format, which is a semi-structured format.
--         Use the FLATTEN table function to convert to structured format.

SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('TAXPAYER')::variant)) as f;


-- 3.1.4   Store the output of EXTRACT_SEMANTIC_CATEGORIES as a new table.
--         Storing the output as new table will make it easier to modify before
--         applying and/or reuse.

CREATE OR REPLACE TABLE SEMANTIC_CATEGORIES_TAXPAYER(V VARIANT)
AS SELECT EXTRACT_SEMANTIC_CATEGORIES('TAXPAYER');

SELECT * FROM SEMANTIC_CATEGORIES_TAXPAYER;


-- 3.1.5   Review the tags (semantic_category and privacy_category) and values
--         in these tags.

SELECT KEY AS COLUMN_NAME, VALUE:semantic_category AS SEMANTIC_CATEGORY, VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY, VALUE:extra_info:alternates AS ALTERNATES
    FROM SEMANTIC_CATEGORIES_TAXPAYER, LATERAL FLATTEN(INPUT=> V);


-- 3.2.0   Phase 2: Classify the columns by applying the generated system tags
--         - Method a: using system function ASSOCIATE_SEMANTIC_CATEGORY_TAGS
--         - Method b: manually run APPLY TAG

-- 3.2.1   Create a clone of the table so we can explore both methods.

CREATE OR REPLACE TABLE TAXPAYER_CLONE CLONE TAXPAYER;


-- 3.2.2   APPLY system generated semantic and privacy tags using
--         ASSOCIATE_SEMANTIC_CATEGORY_TAGS.

CALL ASSOCIATE_SEMANTIC_CATEGORY_TAGS('TAXPAYER',(SELECT * FROM SEMANTIC_CATEGORIES_TAXPAYER));


-- 3.2.3   Manually apply the system tags to columns in the table.

ALTER TABLE TAXPAYER_CLONE MODIFY COLUMN LASTNAME SET TAG SNOWFLAKE.CORE.SEMANTIC_CATEGORY='NAME';
ALTER TABLE TAXPAYER_CLONE MODIFY COLUMN LASTNAME SET TAG SNOWFLAKE.CORE.PRIVACY_CATEGORY='IDENTIFIER';


-- 3.3.0   Phase 3: Monitor and Track the system tags
--         - Use Show command to list the tags
--         - Use database-level table function to review and track the tags
--         without any latency
--         - Use account-level function to review the track with 2-hour latency

-- 3.3.1   Use SHOW command to list tags.

SHOW TAGS IN DATABASE SNOWFLAKE;


-- 3.3.2   Use database-level function to review and track the tags without
--         latency.

SELECT *
FROM TABLE(LEOPARD_tax_db.INFORMATION_SCHEMA.tag_references_all_columns('TAXPAYER', 'table'))
WHERE tag_database = 'SNOWFLAKE' and tag_schema = 'CORE';


-- 3.3.3   Use account-level function to review and track the tags with 2 hour
--         latency.

SELECT DISTINCT TAG_NAME, TAG_VALUE, COLUMN_NAME FROM SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES WHERE TAG_DATABASE='SNOWFLAKE' AND OBJECT_NAME = 'TAXPAYER'
    ORDER BY COLUMN_NAME, TAG_NAME;


-- 3.4.0   Analyze another table, taxpayer_dependent, to see a new value for
--         semantic_category.

SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('TAXPAYER_DEPENDENTS')::variant)) as f;

--         Examine the above query result and note a new value:
--         semantic_category: US_SSN
