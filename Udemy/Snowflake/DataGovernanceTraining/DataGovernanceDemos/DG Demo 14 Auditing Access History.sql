-- Demo: Auditing Access History
-- Version: V1.18
-- Last updated: 09AUG2022

-- This demo demonstrates the capability and usage of the view SNOWFLAKE.ACCOUNT_USAGEACCOUNT_USAGE.ACCESS_HISTORY
--
-- The demo creates several views to simplify access to VARIANT data stored within SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
-- Also demonstrates several queries to identify access history to specific tables 
-- and combining this with TAGs.

-- Set context
use role sysadmin;
use warehouse INSTRUCTOR1_wh;

-- Create database and views for usage
drop database if exists INSTRUCTOR1_ahist_common;
create database INSTRUCTOR1_ahist_common;
create schema INSTRUCTOR1_ahist_common.views;

-- Create views to extract data from ACCESS_HISTORY variant column

-- Capture a copy of the access history for each object (e.g., Table, MV, etc.)
create or replace view INSTRUCTOR1_ahist_common.views.base_object_access_history as
SELECT
     query_id                                        as query_id
,    upper(f.value:objectDomain)::string             as object_type    
,    split_part(f.value:objectName::string,'.',1)    as database_name
,    split_part(f.value:objectName::string,'.',2)    as schema_name
,    split_part(f.value:objectName::string,'.',3)    as object_name       
,    query_start_time                                as query_start_time
,    user_name                                       as user_name
,    f.value:objectId::int                           as object_id
FROM snowflake.account_usage.access_history
     , lateral flatten(base_objects_accessed) f;

-- Capture a copy of the access history for each column (e.g., Table, MV, etc.)
create or replace view INSTRUCTOR1_ahist_common.views.base_column_access_history as
SELECT
     query_id                                        as query_id
,    upper(f.value:objectDomain)::string             as object_type    
,    split_part(f.value:objectName::string,'.',1)    as database_name
,    split_part(f.value:objectName::string,'.',2)    as schema_name
,    split_part(f.value:objectName::string,'.',3)    as object_name 
,    f3.value:columnName::string                     as column_name
,    query_start_time                                as query_start_time
,    user_name                                       as user_name
,    f.value:objectId::int                           as object_id
,    f3.value:columnId::int                          as column_id
FROM snowflake.account_usage.access_history
     , lateral flatten(base_objects_accessed) f
     , lateral flatten(f.value) f2
     , lateral flatten(f2.value) f3;

-- Capture a copy of the DIRECT access history for each OBJECT (e.g., Table, MV, etc.)
create or replace view INSTRUCTOR1_ahist_common.views.direct_object_access_history as
SELECT
     query_id                                        as query_id
,    upper(f.value:objectDomain)::string             as object_type    
,    split_part(f.value:objectName::string,'.',1)    as database_name
,    split_part(f.value:objectName::string,'.',2)    as schema_name
,    split_part(f.value:objectName::string,'.',3)    as object_name       
,    query_start_time                                as query_start_time
,    user_name                                       as user_name
,    f.value:objectId::int                           as object_id
FROM snowflake.account_usage.access_history
     , lateral flatten(direct_objects_accessed) f;

-- Capture a copy of the DIRECT access history for each COLUMN (e.g., Table, MV, etc.)
create or replace view INSTRUCTOR1_ahist_common.views.direct_column_access_history as
SELECT
     query_id                                        as query_id
,    upper(f.value:objectDomain)::string             as object_type    
,    split_part(f.value:objectName::string,'.',1)    as database_name
,    split_part(f.value:objectName::string,'.',2)    as schema_name
,    split_part(f.value:objectName::string,'.',3)    as object_name 
,    f3.value:columnName::string                     as column_name
,    query_start_time                                as query_start_time
,    user_name                                       as user_name
,    f.value:objectId::int                           as object_id
,    f3.value:columnId::int                          as column_id
FROM snowflake.account_usage.access_history
     , lateral flatten(direct_objects_accessed) f
     , lateral flatten(f.value) f2
     , lateral flatten(f2.value) f3;     

-- Grant access on INSTRUCTOR1_AHIST_COMMON views to role INSTRUCTOR_POLICY_ADMIN
grant usage on database INSTRUCTOR1_AHIST_COMMON to role INSTRUCTOR1_POLICY_ADMIN;
grant usage on schema INSTRUCTOR1_AHIST_COMMON.VIEWS to role INSTRUCTOR1_POLICY_ADMIN;
grant select on all views in schema INSTRUCTOR1_AHIST_COMMON.VIEWS to role INSTRUCTOR1_POLICY_ADMIN;

-- Describe the view for TABLE access history
desc table INSTRUCTOR1_ahist_common.views.base_object_access_history;

-- Demonstrate queries against ACCESS_HISTORY using above views

-- Show the basic information about who has accessed the tables
select *
from INSTRUCTOR1_ahist_common.views.base_object_access_history
where object_type   = 'TABLE'
and   database_name = 'INSTRUCTOR1_TAX_DB'
and   schema_name   = 'TAXSCHEMA'
and   object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES','TAXPAYER_CLONE1','TAXPAYER_CLONE2');

-- Show who has accessed specific columns
select *
from INSTRUCTOR1_ahist_common.views.base_column_access_history
where object_type   = 'TABLE'
and   database_name = 'INSTRUCTOR1_TAX_DB'
and   schema_name   = 'TAXSCHEMA'
and   object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES','TAXPAYER_CLONE1','TAXPAYER_CLONE2')
and   column_name like '%LASTNAME';

-- Combine ACCESS_HISTORY with QUERY_HISTORY for additional details

-- Show the actual SQL statement executed by each user/query from QUERY_HISTORY
-- Lookup access history for a specific table
select ah.object_name
,      ah.user_name
,      qh.role_name
,      qh.warehouse_name
,      to_char(ah.query_start_time,'DD-Mon-YYYY') as query_start_date
,      qh.query_text
from INSTRUCTOR1_ahist_common.views.base_object_access_history ah
,    snowflake.account_usage.query_history qh
where ah.query_id      = qh.query_id
and   ah.object_type   = 'TABLE'
and   ah.database_name = 'INSTRUCTOR1_TAX_DB'
and   ah.schema_name   = 'TAXSCHEMA'
and   ah.object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES','TAXPAYER_CLONE1','TAXPAYER_CLONE2')
order by ah.query_start_time;

-- List the tables subject to CONFIDENTIALITY tagging
SELECT *
FROM snowflake.account_usage.tag_references
WHERE tag_name = 'CONFIDENTIALITY';

-- Track access to tagged data
-- Shows for every TABLE tagged as CONFIDENTIALITY the access history and tag value
-- indicating why this table is marked as "Confidential"
select 
       tr.domain                                    as object_type
,      tr.object_name                               as object_name
,      ah.user_name
,      to_char(ah.query_start_time,'DD-Mon-YYYY') as query_start_date
,      tr.tag_database
,      tr.tag_name
,      tr.tag_value
from  INSTRUCTOR1_ahist_common.views.base_object_access_history ah
,     snowflake.account_usage.tag_references tr
where ah.object_type   = tr.domain
and   ah.object_id     = tr.object_id
and   tr.tag_name      = 'CONFIDENTIALITY'
order by tr.domain
,        tr.object_name
,        ah.query_start_time;
 