-- Demo: Data Masking Of Shared Tables
-- Version: V1.9
-- Last updated: 23OCT2022

-- Demo Overview:

-- Provider account: [primary_assigned_account]
--   Be sure to do a global search/replace of [primary_assigned_account] to your assigned training class account.
--   In Snowsight, use the keyboard shortcut <ctrl>+<shift>+h to do the global replace
--   on BOTH provider and consumer account demo worksheets.
-- Consumer account: edsvcs1

-- *** PROVIDER ***
USE ROLE sysadmin;
USE WAREHOUSE INSTRUCTOR1_wh;

grant usage on warehouse instructor1_wh to public;

-- Cleanup demo
DROP SHARE IF EXISTS INSTRUCTOR1_TEST1_SHARE1;
DROP SHARE IF EXISTS INSTRUCTOR1_TEST1_SHARE2;

drop database if exists INSTRUCTOR1_SHARE_TAX_DB;

CREATE or replace DATABASE INSTRUCTOR1_SHARE_TAX_DB CLONE TRAINING_TAX_DB;

USE DATABASE INSTRUCTOR1_SHARE_TAX_DB;
-- *** PROVIDER ***

-- *** PROVIDER ***

-- Create two empty shares
-- An empty share is a shell that you can later use to share actual objects.
-- *** PROVIDER ***

-- *** PROVIDER ***
CREATE SHARE INSTRUCTOR1_TEST1_SHARE1;
CREATE SHARE INSTRUCTOR1_TEST1_SHARE2;
-- *** PROVIDER ***

-- Grant object privileges to the shares

-- *** PROVIDER ***
GRANT USAGE ON DATABASE INSTRUCTOR1_SHARE_TAX_DB TO SHARE INSTRUCTOR1_test1_SHARE1;
GRANT USAGE ON SCHEMA INSTRUCTOR1_SHARE_TAX_DB.taxschema TO SHARE INSTRUCTOR1_test1_SHARE1;
GRANT SELECT ON TABLE INSTRUCTOR1_SHARE_TAX_DB.taxschema.taxpayer TO SHARE INSTRUCTOR1_test1_SHARE1;

GRANT USAGE ON DATABASE INSTRUCTOR1_SHARE_TAX_DB TO SHARE INSTRUCTOR1_test1_SHARE2;
GRANT USAGE ON SCHEMA INSTRUCTOR1_SHARE_TAX_DB.taxschema TO SHARE INSTRUCTOR1_test1_SHARE2;
GRANT SELECT ON TABLE INSTRUCTOR1_SHARE_TAX_DB.taxschema.taxpayer TO SHARE INSTRUCTOR1_test1_SHARE2;
-- *** PROVIDER ***

-- Add consumer account to the shares

-- *** PROVIDER ***
-- For simplicity, the same consumer account is also used for second share
ALTER SHARE INSTRUCTOR1_TEST1_SHARE1 SET ACCOUNTS=edsvcs1;
ALTER SHARE INSTRUCTOR1_TEST1_SHARE2 SET ACCOUNTS=edsvcs1;

SHOW SHARES LIKE 'INSTRUCTOR1_TEST1_SHARE%';
-- *** PROVIDER ***

-- Validate the share configuration

-- *** PROVIDER ***
SHOW GRANTS TO SHARE INSTRUCTOR1_TEST1_SHARE1;
SHOW GRANTS TO SHARE INSTRUCTOR1_TEST1_SHARE2;
-- *** PROVIDER ***

-- Create data masking policy for use with the two shares.
-- Note:
-- (1) No masking on name when using the share INSTRUCTOR1_TEST1_SHARE1
-- (2) Full SHA2 encryption masking when using the share INSTRUCTOR1_TEST1_SHARE2
-- (3) Full masking on name via string '*** MASKED ***' otherwise

-- *** PROVIDER ***
CREATE OR REPLACE MASKING POLICY name_mask1 AS (val string) returns string ->
CASE
    WHEN invoker_share() = 'INSTRUCTOR1_TEST1_SHARE1' THEN val
    WHEN invoker_share() = 'INSTRUCTOR1_TEST1_SHARE2' THEN SHA2(VAL,512)
    ELSE '*** MASKED ***'
END;
-- *** PROVIDER ***

-- Apply the masking policy on TAXPAYER lastname column

-- *** PROVIDER ***
ALTER TABLE INSTRUCTOR1_SHARE_TAX_DB.taxschema.taxpayer MODIFY COLUMN LASTNAME SET MASKING POLICY name_mask1;
-- *** PROVIDER ***

-- Query the sensitive data
-- On Provider side, the query result of LASTNAME will be fully masked because data will
-- not be accessible through INVOKER_SHARE().
-- *** PROVIDER ***
-- Note that LASTNAME column data is fully masked on PROVIDER account

SELECT * FROM INSTRUCTOR1_SHARE_TAX_DB.taxschema.taxpayer; 
-- *** PROVIDER ***

-- *** CONSUMER ***
USE ROLE sysadmin;
use database snowflake; -- Needed to get Snowsight to successfully run the next commands

CREATE WAREHOUSE IF NOT EXISTS SNOWKURT_WH
   WAREHOUSE_SIZE = 'LARGE'
   AUTO_SUSPEND = 300
   AUTO_RESUME = TRUE
   MIN_CLUSTER_COUNT = 1
   MAX_CLUSTER_COUNT = 1
   SCALING_POLICY = 'STANDARD';
-- *** CONSUMER ***

grant usage on warehouse snowkurt_wh to public;

-- Query the available shares
-- Use SQL to show available shares

-- *** CONSUMER ***
SHOW SHARES LIKE 'INSTRUCTOR1_TEST1_SHARE%';

DESCRIBE SHARE [primary_assigned_account].INSTRUCTOR1_TEST1_SHARE1;

DESCRIBE SHARE [primary_assigned_account].INSTRUCTOR1_TEST1_SHARE2;
-- *** CONSUMER ***


-- Query the data of the shared tables
-- Examine contents of shares on data consumers

-- *** CONSUMER1 ***
use database snowflake; -- Needed to get Snowsight to successfully run the next DROP/CREATE DATABASE commands
DROP DATABASE IF EXISTS SNOWKURT_TEST1_SHARE_CONSUMER1;

CREATE DATABASE SNOWKURT_TEST1_SHARE_CONSUMER1
FROM SHARE [primary_assigned_account].INSTRUCTOR1_TEST1_SHARE1;

USE DATABASE SNOWKURT_TEST1_SHARE_CONSUMER1;

SHOW SCHEMAS;
USE SCHEMA TAXSCHEMA;

SHOW TABLES;
-- Query result for share1 is unmasked based on the policy rule for that share using invoker_share
-- Masking policy: No masking on name when using the share INSTRUCTOR1_TEST1_SHARE1

SELECT * from TAXPAYER LIMIT 10; -- Note unmasked LASTNAME column data returned by query
-- *** CONSUMER1 ***


-- *** CONSUMER2 ***
DROP DATABASE IF EXISTS SNOWKURT_TEST1_SHARE_CONSUMER2;

CREATE DATABASE SNOWKURT_TEST1_SHARE_CONSUMER2 
FROM SHARE [primary_assigned_account].INSTRUCTOR1_TEST1_SHARE2;

USE DATABASE SNOWKURT_TEST1_SHARE_CONSUMER2;

SHOW SCHEMAS;
USE SCHEMA TAXSCHEMA;

SHOW TABLES;
-- Query result for share2 is masked based on policy rule for that share using invoker_share check
-- Masking policy: Full SHA2 encryption masking when using the share INSTRUCTOR1_TEST1_SHARE2
SELECT * from TAXPAYER LIMIT 10; -- Note fully masked LASTNAME column data (SHA2 encrypted) returned by query
-- *** CONSUMER2 ***

