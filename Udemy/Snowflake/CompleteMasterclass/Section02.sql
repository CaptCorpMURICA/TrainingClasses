-- Create a database from the share.
CREATE DATABASE snowflake_sample_data FROM SHARE sfc-samples.sample_data;

-- Grant the PUBLIC role access to the databse.
-- Optionally change the role name to restrict access to a subset of users.
GRANT umported privileges ON DATABASE snowflake_sample_data TO ROLE PUBLIC;

-- Query a table in the sample data.
SELECT * FROM snowflake_sample_data.tpch_sf1.customer;
