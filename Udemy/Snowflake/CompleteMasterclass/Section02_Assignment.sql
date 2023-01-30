CREATE DATABASE EXERCISE_DB;

CREATE TABLE CUSTOMERS (
  ID INT,
  FIRST_NAME VARCHAR,
  LAST_NAME VARCHAR,
  EMAIL VARCHAR,
  AGE INT,
  CITY VARCHAR
  );

COPY INTO CUSTOMERS
  FROM s3://snowflake-assignments-mc/gettingstarted/customers.csv
  file_format = (type = csv
                 field_delimiter = ','
                 skip_header = 1
                 );

SELECT COUNT(*) AS CNT
FROM CUSTOMERS;
