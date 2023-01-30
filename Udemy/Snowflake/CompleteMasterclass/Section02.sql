-- Declare Warehouse and Role
USE WAREHOUSE LEOPARD_WH;
USE ROLE ACCOUNTADMIN;

-- Create a database from the share.
-- DROP DATABASE snowflake_sample_data;
CREATE DATABASE snowflake_sample_data FROM SHARE sfc_samples.sample_data;

-- Grant the PUBLIC role access to the database.
-- Optionally change the role name to restrict access to a subset of users.
GRANT imported privileges ON DATABASE snowflake_sample_data TO ROLE PUBLIC;

-- Query a table in the sample data.
SELECT * FROM snowflake_sample_data.tpch_sf1.customer;

-- Create a database
CREATE DATABASE FIRST_DB;

-- Rename database & create the table & metadata
ALTER DATABASE FIRST_DB RENAME TO OUR_FIRST_DB;

CREATE TABLE OUR_FIRST_DB.PUBLIC.LOAN_PAYMENT (
    LOAD_ID STRING,
    LOAN_STATUS STRING,
    PRINCIPAL STRING,
    TERMS STRING,
    EFFECTIVE_DATE STRING,
    DUE_DATE STRING,
    PAID_OFF_TIME STRING,
    PAST_DUE_DAYS STRING,
    AGE STRING,
    EDUCATION STRING,
    GENDER STRING
);

-- Check that the table is empty
USE DATABASE OUR_FIRST_DB;
SELECT * FROM LOAN_PAYMENT;

-- Loading the data from S3 bucket
COPY INTO LOAN_PAYMENT
    FROM s3://bucketsnowflakes3/Loan_payments_data.csv
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1);

-- Validate
SELECT * FROM LOAN_PAYMENT;