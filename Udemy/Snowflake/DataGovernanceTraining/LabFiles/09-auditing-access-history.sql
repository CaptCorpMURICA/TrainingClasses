
-- 9.0.0   AUDITING ACCESS HISTORY
--         By the end of this lab, you will be able to:
--         - Identify sensitive data that have masking policies assigned by
--         auditing tax data columns
--         - Identify who has accessed the sensitive data in tax tables by
--         auditing access history details
--         - Identify who has accesses specific sensitive columns by auditing
--         access history details
--         - Identify the SQL statements accessing sensitive data access
--         executed by each user by correlating access history and query history
--         details
--         - Determine lineage for tables with tag assigned as CONFIDENTIALITY
--         This lab provides some setup steps in creating views for the variant
--         column in SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY to simplify
--         retrieving data for auditing access:
--         - Create a database and schema for your access history detail.
--         - Create your own views containing BASE_OBJECTS_ACCESSED history for
--         each object and each column. BASE_OBJECTS_ACCESSED contains a JSON
--         array of all base data objects, specifically, columns of tables to
--         execute the query. These columns give us information on read
--         operations in our Snowflake environment.
--         - Create your own views containing DIRECT_OBJECTS_ACCESSED history
--         for each object and each column. DIRECT_OBJECTS_ACCESSED contains a
--         JSON array of data objects such as tables, views, and columns
--         directly named in the query explicitly or through shortcuts such as
--         using an asterisk
--         Due to the data latency with the SNOWFLAKE.ACCOUNT_USAGE views
--         POLICY_REFERENCES and TAG_REFERENCES (these views have two-hour
--         latencies) this lab exercise should be completed at least two hours
--         AFTER completion of the object tagging, row access policies, and data
--         masking lab exercises.

-- 9.1.0   Preparation by Creating the Database and Schema and Views for Access
--         History Details

-- 9.1.1   Set your context.

USE ROLE TRAINING_ROLE;
USE WAREHOUSE LEOPARD_wh;


-- 9.1.2   Setup your database and schema.

DROP DATABASE if exists LEOPARD_ahist_common;
CREATE DATABASE LEOPARD_ahist_common;
CREATE SCHEMA LEOPARD_ahist_common.views;


-- 9.1.3   Define view to capture a copy of the BASE OBJECT access history for
--         each object.

CREATE OR REPLACE VIEW LEOPARD_ahist_common.views.base_object_access_history as
SELECT
      query_id                                        as query_id
     ,upper(f.value:objectDomain)::string             as object_type    
     ,split_part(f.value:objectName::string,'.',1)    as database_name
     ,split_part(f.value:objectName::string,'.',2)    as schema_name
     ,split_part(f.value:objectName::string,'.',3)    as object_name       
     ,query_start_time                                as query_start_time
     ,user_name                                       as user_name
     ,f.value:objectId::int                           as object_id
   FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
     ,lateral flatten(base_objects_accessed) f;


-- 9.1.4   Define view to capture a copy of the access history for each column.

CREATE OR REPLACE VIEW LEOPARD_ahist_common.views.base_column_access_history as
SELECT
      query_id                                        as query_id
     ,upper(f.value:objectDomain)::string             as object_type    
     ,split_part(f.value:objectName::string,'.',1)    as database_name
     ,split_part(f.value:objectName::string,'.',2)    as schema_name
     ,split_part(f.value:objectName::string,'.',3)    as object_name
     ,f3.value:columnName::string                     as column_name
     ,query_start_time                                as query_start_time
     ,user_name                                       as user_name
     ,f.value:objectId::int                           as object_id
     ,f3.value:columnId::int                          as column_id
   FROM SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY
     ,lateral flatten(base_objects_accessed) f
     ,lateral flatten(f.value) f2
     ,lateral flatten(f2.value) f3;


-- 9.1.5   Define view to capture a copy of the DIRECT OBJECT access history for
--         each object.

CREATE OR REPLACE VIEW LEOPARD_ahist_common.views.direct_object_access_history as
SELECT
      query_id                                        as query_id
     ,upper(f.value:objectDomain)::string             as object_type    
     ,split_part(f.value:objectName::string,'.',1)    as database_name
     ,split_part(f.value:objectName::string,'.',2)    as schema_name
     ,split_part(f.value:objectName::string,'.',3)    as object_name       
     ,query_start_time                                as query_start_time
     ,user_name                                       as user_name
     ,f.value:objectId::int                           as object_id
   FROM snowflake.account_usage.access_history
     ,lateral flatten(direct_objects_accessed) f;


-- 9.1.6   Define view to capture a copy of the DIRECT access history for each
--         column.

CREATE OR REPLACE VIEW LEOPARD_ahist_common.views.direct_column_access_history as
SELECT
      query_id                                        as query_id
     ,upper(f.value:objectDomain)::string             as object_type    
     ,split_part(f.value:objectName::string,'.',1)    as database_name
     ,split_part(f.value:objectName::string,'.',2)    as schema_name
     ,split_part(f.value:objectName::string,'.',3)    as object_name
     ,f3.value:columnName::string                     as column_name
     ,query_start_time                                as query_start_time
     ,user_name                                       as user_name
     ,f.value:objectId::int                           as object_id
     ,f3.value:columnId::int                          as column_id
   FROM snowflake.account_usage.access_history
     ,lateral flatten(direct_objects_accessed) f
     ,lateral flatten(f.value) f2
     ,lateral flatten(f2.value) f3;  


-- 9.1.7   Describe the base_object_access_history view.

DESC TABLE LEOPARD_ahist_common.views.base_object_access_history;


-- 9.1.8   Grant POLICY_ADMIN privileges.
--         Grant the privileges to run audit queries against the AHIST_COMMON
--         views to POLICY_ADMIN.
--         As SECURITYADMIN, grant the POLICY_ADMIN role USAGE on the containing
--         database/schema and SELECT on the AHIST_COMMON views.

USE ROLE securityadmin;

GRANT USAGE on DATABASE LEOPARD_ahist_common to role LEOPARD_policy_admin;
GRANT USAGE on SCHEMA LEOPARD_ahist_common.views to role LEOPARD_policy_admin;
GRANT SELECT on all views in schema LEOPARD_ahist_common.views to role LEOPARD_policy_admin;


-- 9.2.0   Audit Policy References for Sensitive Data With Row Access and Data
--         Masking Policies

-- 9.2.1   Set the worksheet context for the lab.

USE ROLE LEOPARD_policy_admin;
USE WAREHOUSE LEOPARD_wh;


-- 9.2.2   Audit TAXSCHEMA tables that have assigned row access policies.
--         This query will show the row access policies in place for your TAX_DB
--         and TAXSCHEMA and the tables with sensitive data that the policies
--         are applied to.

SELECT
     policy_name
    ,ref_database_name table_db_name
    ,ref_schema_name table_schema_name
    ,ref_entity_name table_name
   FROM snowflake.account_usage.policy_references
   WHERE policy_kind = 'ROW_ACCESS_POLICY'
   and table_db_name ='LEOPARD_TAX_DB'
   and table_schema_name = 'TAXSCHEMA'
   ORDER BY table_db_name asc
           ,table_name asc;


-- 9.2.3   Audit all sensitive columns in TAXSCHEMA that have data masking
--         policies assigned.
--         This query will show the data masking policies in place for your
--         TAX_DB and TAXSCHEMA and the tables with sensitive data that the
--         policies are applied to.

SELECT
     policy_name
    ,ref_entity_name table_name
    ,ref_column_name column_name
    ,ref_database_name table_db_name
    ,ref_schema_name table_schema_name
   FROM snowflake.account_usage.policy_references
   WHERE policy_kind = 'MASKING_POLICY'
   and table_db_name like 'LEOPARD_TAX_DB'
   ORDER BY table_schema_name asc
           ,table_name asc
           ,column_name asc;


-- 9.3.0   Audit ACCESS_HISTORY Details to Find Data Lineage
--         Run queries against the audit data in ACCESS_HISTORY using your
--         AHIST_COMMON views.

-- 9.3.1   Audit the basic access history details to see who has accessed the
--         TAXSCHEMA tables.

SELECT *
   FROM LEOPARD_ahist_common.views.base_object_access_history
   WHERE object_type   = 'TABLE'
   and   database_name = 'LEOPARD_TAX_DB'
   and   schema_name   = 'TAXSCHEMA'
   and   object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES')
   ORDER BY query_start_time desc;


-- 9.3.2   Audit who has accessed specific sensitive columns.

SELECT *
   FROM LEOPARD_ahist_common.views.base_column_access_history
   WHERE object_type   = 'TABLE'
   and   database_name = 'LEOPARD_TAX_DB'
   and   schema_name   = 'TAXSCHEMA'
   and   object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES')
   and   (column_name   like '%LASTNAME' or column_name like '%ID')
   ORDER BY query_start_time desc;


-- 9.4.0   Correlate ACCESS_HISTORY and QUERY_HISTORY Details To Determine SQL
--         Operations on Sensitive Data Access

-- 9.4.1   Show the SQL statements accessing sensitive Data executed by each
--         user
--         Combine usage of the SNOWFLAKE.ACCOUNT_USAGE views ACCESS_HISTORY and
--         QUERY_HISTORY.
--         Join the two views to provide drill-down auditing of data access
--         details. Show the SQL statements executed by each user against the
--         TAXSCHEMA tables.

SELECT ah.object_name
      ,ah.user_name
      ,qh.role_name
      ,qh.warehouse_name
      ,to_char(ah.query_start_time,'DD-Mon-YYYY') as query_start_date
      ,qh.query_text
   FROM LEOPARD_ahist_common.views.base_object_access_history ah
     ,snowflake.account_usage.query_history qh
   WHERE ah.query_id      = qh.query_id
   and   ah.object_type   = 'TABLE'
   and   ah.database_name = 'LEOPARD_TAX_DB'
   and   ah.schema_name   = 'TAXSCHEMA'
   and   ah.object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES')
   ORDER BY ah.query_start_time desc;


-- 9.5.0   Audit Access to Tagged Sensitive Data.
--         This query shows audit data for every table tagged as
--         CONFIDENTIALITY, and the access history details, and tag values
--         indicate why this table is marked as Confidential.

SELECT
      tr.domain                                    as object_type
     ,tr.object_name                               as object_name
     ,ah.user_name
     ,to_char(ah.query_start_time,'DD-Mon-YYYY') as query_start_date
     ,tr.tag_database
     ,tr.tag_name
     ,tr.tag_value
   FROM  LEOPARD_ahist_common.views.base_object_access_history ah
     ,snowflake.account_usage.tag_references tr
   WHERE ah.object_type   = tr.domain
   and   ah.object_id     = tr.object_id
   and   tr.tag_name      = 'CONFIDENTIALITY'
   ORDER BY tr.domain
     ,tr.object_name
     ,ah.query_start_time;

