
-- 10.0.0  AUDITING TAGGED OBJECTS
--         Using the ACCOUNT_USAGE views you will audit usage of the tags you
--         defined earlier. Auditing tags enables you monitor your sensitive
--         data for compliance, discovery, protection, and resource usage.
--         - In the ACCOUNT_USAGE schema of the Snowflake Database use the
--         TAGGED_REFERENCES and POLICY_REFERENCES views to examine existing and
--         deleted tags.
--         - Use the TAG_REFERENCES view in the ACCOUNT_USAGE schema to view the
--         details on the columns classified as PII and SPI.
--         - Use the TAG_REFERENCES view in the ACCOUNT_USAGE schema to show
--         columns that should not have tags assigned.
--         - Use the POLICY_REFERENCES view in the ACCOUNT_USAGE schema to show
--         columns that should have tags assigned, but do not.
--         Due to the data latency with the SNOWFLAKE.ACCOUNT_USAGE views
--         POLICY_REFERENCES and TAG_REFERENCES (these views have two-hour
--         latencies) this lab exercise should be completed at least two hours
--         AFTER completion of the object tagging, row access policies, and data
--         masking lab exercises.
--         Some common usage notes for auditing tagged objects and columns.
--         POLICY_ADMIN can:
--         Perform reporting of PII data as well as checking for PII data that
--         should have masking policies applied.
--         Query SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES to track newly tagged
--         objects.
--         Query SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES to ensure each
--         sensitive column has a masking policy applied.

-- 10.1.0  Audit All Tags
--         Audit all tags residing in database TAG_DB.

-- 10.1.1  Set the worksheet context for the lab.

USE ROLE LEOPARD_policy_admin;
USE WAREHOUSE LEOPARD_wh;


-- 10.1.2  In your tag database LEOPARD_TAG_DB, audit all tags.

SELECT tag_owner
      ,tag_name
      ,created
      ,deleted
      ,last_altered
      ,tag_database
   FROM SNOWFLAKE.ACCOUNT_USAGE.tags
   WHERE tag_database='LEOPARD_TAG_DB'
   ORDER BY created desc, tag_name asc;


-- 10.1.3  Audit tables and columns having specific data sensitivity tags.

SELECT *
   FROM SNOWFLAKE.ACCOUNT_USAGE.tag_references
   WHERE tag_name = 'CONFIDENTIALITY'
   and object_database = 'LEOPARD_TAX_DB';

SELECT *
   FROM SNOWFLAKE.ACCOUNT_USAGE.tag_references
   WHERE tag_name = 'PII_TYPE'
   and object_database = 'LEOPARD_TAX_DB';

SELECT *
   FROM SNOWFLAKE.ACCOUNT_USAGE.tag_references
   WHERE tag_name = 'SPI_TYPE'
   and object_database = 'LEOPARD_TAX_DB';


-- 10.2.0  Audit All Tagged Columns in the TAX_DB Database
--         Next look at the tagged columns in your three tables - TAXPAYER,
--         TAXPAYER_DEPENDENTS and TAXPAYER_WAGES.
--         The total number of tagged columns in TAXSCHEMA is 26.
--         - TAXPAYER - 11
--         - TAXPAYER_DEPENDENTS - 9
--         - TAXPAYER_WAGES - 6

with column_with_tag as
(
  SELECT
        tag_name
       ,tag_value
       ,object_name table_name
       ,column_name column_name
       ,object_database table_db_name
       ,object_schema table_schema_name
   FROM snowflake.account_usage.tag_references
   WHERE
       tag_database = 'LEOPARD_TAG_DB' and tag_schema = 'TAG_LIBRARY'
     and
       tag_name in ('PII_TYPE','SPI_TYPE')
)
SELECT *
   FROM column_with_tag
   ORDER BY table_name asc, column_name asc;


-- 10.3.0  Audit All Tagged Columns with No Masking Policy
--         Identify columns that are not masked correctly.
--         The output of this query will likely be indicative of one of the
--         following scenarios:
--         Tagging some columns that have not been classified as sensitive and
--         hence not requiring data masking.
--         Missing application of data masking policies to columns that have
--         been classified as sensitive.

with column_with_tag as
(
  SELECT
      object_name table_name
     ,column_name column_name
     ,object_database table_db_name
     ,object_schema table_schema_name
   FROM snowflake.account_usage.tag_references
   WHERE
   tag_database = 'LEOPARD_TAG_DB' and tag_schema = 'TAG_LIBRARY'
   and column_name is not null
),

column_with_policy as
(
  SELECT
      ref_entity_name table_name
     ,ref_column_name column_name
     ,ref_database_name table_db_name
     ,ref_schema_name table_schema_name
   FROM snowflake.account_usage.policy_references
   WHERE policy_kind = 'MASKING_POLICY'
   and column_name is not null
)
SELECT *
   FROM column_with_tag
   EXCEPT
SELECT *
   FROM column_with_policy;

