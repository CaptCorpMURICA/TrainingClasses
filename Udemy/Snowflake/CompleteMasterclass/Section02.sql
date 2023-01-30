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
