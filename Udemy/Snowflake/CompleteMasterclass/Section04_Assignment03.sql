-- Declare Warehouse and Role
USE WAREHOUSE LEOPARD_WH;
USE ROLE ACCOUNTADMIN;

-- Create the working database
CREATE OR REPLACE DATABASE EXERCISE_DB;
CREATE OR REPLACE SCHEMA external_stages;

-- Create the table for the assignment
CREATE TABLE CUSTOMERS (
  ID INT,
  FIRST_NAME VARCHAR,
  LAST_NAME VARCHAR,
  EMAIL VARCHAR,
  AGE INT,
  CITY VARCHAR
  );

-- Review for an empty table
SELECT * FROM CUSTOMERS;

-- Create a stage object
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage
    url = 's3://snowflake-assignments-mc/loadingdata/'
    file_format = (type = csv
                   field_delimiter = ';'
                   skip_header = 1);

-- List the files in the table
LIST @MANAGE_DB.EXTERNAL_STAGES.aws_stage;

-- Load the data in the existing customers table using the COPY command
COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
    FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage
    file_format = (type = csv
                   field_delimiter = ';'
                   skip_header = 1)
    pattern = '.*customers.*';  -- Used to call a file based on a pattern in the name of the file

-- How many rows have been loaded? 1,600
SELECT COUNT(*) AS CNT
FROM EXERCISE_DB.PUBLIC.CUSTOMERS
;

/* Assignment Solution - Create stage & load data

   -- Create stage object
   CREATE OR REPLACE STAGE EXERCISE_DB.public.aws_stage
       url = 's3://snowflake-assignments-mc/loadingdata/';

   -- List files in stage
   LIST @EXERCISE_DB.public.aws_stage;

   -- Load the data
   COPY INTO EXERCISE_DB.PUBLIC.CUSTOMERS
       FROM @aws_stage
       file_format = (type = csv
                      field_delimiter = ';'
                      skip_header = 1);
 */