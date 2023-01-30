
-- 8.0.0   MASKING SENSITIVE DATA IN A SHARED TABLE
--         The purpose of this lab exercise is to apply different data
--         governance policies on the same shared data.
--         In this example, the objective is achieved by creating different
--         shares of the same taxpayer data. The data is masked differently
--         based on which share is being accessed by the consumer.
--         You start by setting up two Snowflake accounts: [provider-account]
--         and [consumer-account]. The provider-account contains the sensitive
--         taxpayer data. You create the shares, SHARE1 and SHARE1, of the
--         database, schema, and TAXPAYER table. You’ll use the context function
--         INVOKER_SHARE() to determine which share is being accessed, and thus
--         which type of masking to apply. In the last section of the lab, you
--         share the taxpayer table from the [provider-account] to the
--         [consumer-account] and test the results for SHARE1 and SHARE2.
--         - Sharing sensitive data securely
--         - Applying data masking policies across data sharing

-- 8.1.0   Set Up Two Snowflake Accounts for Data Sharing
--         To start, you will need two accounts to demonstrate the data sharing.
--         Your instructor will provide the account URLs for the [provider-
--         account] and [consumer-account] for this exercise.

-- 8.1.1   Open the [provider-account] URL in browser 1.
--         You could also open two tabs, but the exercise is easier to complete
--         if you can see both browser windows at the same time.
--         After logging in, perform the following steps in the [provider-
--         account] in browser 1.

-- 8.1.2   Set the session context.

-- PROVIDER --
USE ROLE training_role;
USE WAREHOUSE LEOPARD_wh;

CREATE DATABASE LEOPARD_TEST1_SHARE_TAX CLONE training_tax_db;
USE DATABASE LEOPARD_TEST1_SHARE_TAX;
-- PROVIDER --


-- 8.1.3   Create an empty share.
--         An empty share is a shell that you can later use to share actual
--         objects.

-- PROVIDER --
CREATE SHARE LEOPARD_TEST1_SHARE1;
CREATE SHARE LEOPARD_TEST1_SHARE2;
-- PROVIDER --


-- 8.1.4   Grant object privileges to the shares.

-- PROVIDER --
GRANT USAGE ON DATABASE LEOPARD_TEST1_SHARE_TAX
  TO SHARE LEOPARD_test1_SHARE1;
GRANT USAGE ON SCHEMA LEOPARD_TEST1_SHARE_TAX.taxschema
  TO SHARE LEOPARD_test1_SHARE1;
GRANT SELECT ON TABLE LEOPARD_TEST1_SHARE_TAX.taxschema.taxpayer
  TO SHARE LEOPARD_test1_SHARE1;

GRANT USAGE ON DATABASE LEOPARD_TEST1_SHARE_TAX
  TO SHARE LEOPARD_test1_SHARE2;
GRANT USAGE ON SCHEMA LEOPARD_TEST1_SHARE_TAX.taxschema
  TO SHARE LEOPARD_test1_SHARE2;
GRANT SELECT ON TABLE LEOPARD_TEST1_SHARE_TAX.taxschema.taxpayer
  TO SHARE LEOPARD_test1_SHARE2;
-- PROVIDER --


-- 8.1.5   Add the consumer account to the shares. Replace [consumer-account] in
--         the code below with the account identifier of the consumer account
--         provided by your instructor.

-- PROVIDER --
ALTER SHARE LEOPARD_TEST1_SHARE1 SET ACCOUNTS=[consumer-account];

-- For simplicity, the same account is also used for the second share
ALTER SHARE LEOPARD_TEST1_SHARE2 SET ACCOUNTS=[consumer-account];
-- PROVIDER --


-- 8.1.6   Validate the share configuration. You should see a row for each
--         privilege granted in each share.

-- PROVIDER --
SHOW GRANTS TO SHARE LEOPARD_TEST1_SHARE1;
SHOW GRANTS TO SHARE LEOPARD_TEST1_SHARE2;
-- PROVIDER --


-- 8.2.0   Enable Different Masking with the INVOKER_SHARE() Function
--         Use the INVOKER_SHARE() function to support either masked, unmasked,
--         or tokenized data on the same column. Because different masking rules
--         can be applied to the same column through the different shares, each
--         share can get its own masking rule.

-- 8.2.1   Create the masking policy.
--         If the data is accessed through SHARE1, the values be unmasked in
--         plain text. If accessed through SHARE2, the data will be tokenized.
--         Otherwise, the data will be masked.

-- PROVIDER --
CREATE OR REPLACE MASKING POLICY name_mask1 AS (val string) returns string ->
CASE
    WHEN invoker_share() = 'LEOPARD_TEST1_SHARE1' THEN val
    WHEN invoker_share() = 'LEOPARD_TEST1_SHARE2' THEN SHA2(VAL,512)
    ELSE '*** MASKED ***'
END;
-- PROVIDER --


-- 8.2.2   Apply the masking policy.
--         Apply dynamic data masking on the LASTNAME column of the TAXPAYER
--         table.

-- PROVIDER --
ALTER TABLE LEOPARD_TEST1_SHARE_TAX.taxschema.taxpayer
  MODIFY COLUMN lastname
  SET MASKING POLICY name_mask1;
-- PROVIDER --


-- 8.2.3   Query the sensitive data.
--         On the Provider side, the query result will be masked as determined
--         by the settings in the INVOKER_SHARE() context function.

-- PROVIDER --
SELECT * FROM LEOPARD_TEST1_SHARE_TAX.taxschema.taxpayer;
-- PROVIDER --


-- 8.3.0   Consume the Share with the Consumer Account
--         Now, switch to the [consumer-account] to consume the shares and test
--         their different masking behavior.

-- 8.3.1   Open the [consumer-account] URL in browser 2 and log in with LEOPARD.
--         Use the same LEOPARD username as in the provider account to avoid
--         mix-ups with other students. After logging in, perform the following
--         steps in the [consumer-account] in browser 2.

-- 8.3.2   Ensure your virtual warehouse is created prior to querying the
--         shares.

-- CONSUMER --
USE ROLE TRAINING_ROLE;

CREATE OR REPLACE WAREHOUSE LEOPARD_QUERY_WH
   WAREHOUSE_SIZE = 'LARGE'
   AUTO_SUSPEND = 300
   AUTO_RESUME = TRUE
   MIN_CLUSTER_COUNT = 1
   MAX_CLUSTER_COUNT = 1
   SCALING_POLICY = 'STANDARD'
   COMMENT = 'Training WH for completing hands on lab queries';
-- CONSUMER --


-- 8.3.3   Query the available shares.
--         Use the SQL commands to list the shares and their objects.

-- CONSUMER --
SHOW SHARES LIKE 'LEOPARD_TEST1_SHARE%';

DESCRIBE SHARE [provider-account].LEOPARD_TEST1_SHARE1;

DESCRIBE SHARE [provider-account].LEOPARD_TEST1_SHARE2;
-- CONSUMER --


-- 8.3.4   Consume SHARE1 into your account and query the data in the TAXPAYER
--         table.
--         Create the database for SHARE1 in the consumer account. Examine the
--         objects in the share. Then, query the data in the TAXPAYER table to
--         verify that SHARE1 works as designed.

-- CONSUMER1 --
CREATE DATABASE LEOPARD_TEST1_DS_CONSUMER1
FROM SHARE [provider-account].LEOPARD_TEST1_SHARE1;
USE DATABASE LEOPARD_TEST1_DS_CONSUMER1;

SHOW SCHEMAS;
USE SCHEMA TAXSCHEMA;

SHOW TABLES;

-- Query result for SHARE1 is unmasked based on the policy rule for that share
-- using the INVOKER_SHARE() context function.
SELECT * from TAXPAYER LIMIT 10;
-- CONSUMER1 --


-- 8.3.5   Consume SHARE2 into your account and query the data in the TAXPAYER
--         table.
--         Create the database for SHARE2 in the consumer account and examine
--         its objects. When you query the TAXPAYER table, you should see that
--         the LASTNAME column is tokenized instead of in plain text.

-- CONSUMER2 --
CREATE DATABASE LEOPARD_TEST1_DS_CONSUMER2 FROM SHARE [provider-account].LEOPARD_TEST1_SHARE2;
USE DATABASE LEOPARD_TEST1_DS_CONSUMER2;

SHOW SCHEMAS;
USE SCHEMA TAXSCHEMA;

SHOW TABLES;
-- Query result for SHARE2 is tokenized based on the policy rule for that share.
SELECT * from TAXPAYER LIMIT 10;
-- CONSUMER2 --

