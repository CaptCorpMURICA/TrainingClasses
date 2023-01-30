-- Demo: Auditing Tagged Sensitive Data
-- Version: 1.18
-- Last updated: 09AUG2022

-- Usage notes for auditing tagged objects and columns:
-- 1. POLICY_ADMIN is able to perform reporting of PII data as well as checking for PII data that should have masking policies applied. 
-- 2. POLICY_ADMIN can query the view SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES to track newly tagged objects. 
-- 3. POLICY_ADMIN can query the view SNOWFLAKE.ACCOUNT_USAGE.POLICY_REFERENCES to ensure that each sensitive column has a masking policy applied.

-- Set context
use role INSTRUCTOR1_policy_admin;
use warehouse INSTRUCTOR1_wh;

-- Audit tables with specific confidentiality tag
select *
from snowflake.account_usage.tag_references
where tag_name = 'CONFIDENTIALITY';

-- Audit columns with specific PII tag
select *
from snowflake.account_usage.tag_references
where tag_name = 'PII_TYPE';

-- Audit columns with specific SPI tag
select *
from snowflake.account_usage.tag_references
where tag_name = 'SPI_TYPE';

-- Audit all tagged columns with sensitive tags
with column_with_tag as
(
  select
  tag_name
 ,tag_value
 ,object_name table_name
  ,column_name column_name
  ,object_database table_db_name
  ,object_schema table_schema_name
  from snowflake.account_usage.tag_references
  where 
   tag_database = 'INSTRUCTOR1_TAG_DB' and tag_schema = 'TAG_LIBRARY'
)
select * from column_with_tag;

-- Audit all tagged columns which have no applied masking policy (18 columns found)
-- Number of columns missing masking policies in each TAX_DB table:
-- TAXPAYER: 7
-- TAXPAYER_DEPENDENTS: 5
-- TAXPAYER_WAGES: 6

with column_with_tag as
(
  select
  object_name table_name
  ,column_name column_name
  ,object_database table_db_name
  ,object_schema table_schema_name
  from snowflake.account_usage.tag_references
  where 
  tag_database = 'INSTRUCTOR1_TAG_DB' and tag_schema = 'TAG_LIBRARY'
  and column_name is not null
),
column_with_policy as
(
  select 
  ref_entity_name table_name
  ,ref_column_name column_name
  ,ref_database_name table_db_name
  ,ref_schema_name table_schema_name
  from snowflake.account_usage.policy_references
  where policy_kind = 'MASKING_POLICY'
)
select * from column_with_tag
except
select * from column_with_policy;

-- In SNOWFLAKE.CORE tag_schema, audit all tagged columns which have 
-- no applied masking policy

with column_with_tag as
(
  select
  object_name table_name
  ,column_name column_name
  ,object_database table_db_name
  ,object_schema table_schema_name
  from snowflake.account_usage.tag_references
  where 
  tag_database = 'SNOWFLAKE' and tag_schema = 'CORE'
  and column_name is not null
),
column_with_policy as
(
  select 
  ref_entity_name table_name
  ,ref_column_name column_name
  ,ref_database_name table_db_name
  ,ref_schema_name table_schema_name
  from snowflake.account_usage.policy_references
  where policy_kind = 'MASKING_POLICY'
)
select * from column_with_tag
except
select * from column_with_policy;
