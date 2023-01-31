-- Declare Warehouse and Role
USE WAREHOUSE LEOPARD_WH;
USE ROLE ACCOUNTADMIN;

-- Create the ORDERS_EX table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
);

-- Publicly accessible staging area
CREATE OR REPLACE STAGE MANAGE_DB.EXTERNAL_STAGES.aws_stage
    url = 's3://bucketsnowflakes3';

-- Transforming using the SELECT statement
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (SELECT s.$1, s.$2 FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage s)
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails.csv');

-- Display the output
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 1: Create Table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 2: Recreate Table with Modifications
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
);

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 2: COPY command using a SQL function (subset of functions available)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (SELECT
           s.$1
          ,s.$2
          ,s.$3
          ,CASE WHEN CAST(s.$3 AS INT) < 0 THEN 'Not Profitable' ELSE 'Profitable' END
          FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage s
          )
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 3: Recreate Table with Modifications
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    CATEGORY_SUBSTRING VARCHAR(5)
);

-- Example 3: COPY command using a SQL function (subset of functions available)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM (SELECT
           s.$1
          ,s.$2
          ,s.$3
          ,SUBSTRING(s.$5, 1, 5)
          FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage s
          )
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 4: Using a subset of columns
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX (ORDER_ID, PROFIT)
    FROM (SELECT
           s.$1
          ,s.$3
          FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage s
          )
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails.csv');

SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Example 5: Table Auto Increment
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID NUMBER AUTOINCREMENT START 1 INCREMENT 1,
    AMOUNT INT,
    PROFIT INT,
    PROFITABLE_FLAG VARCHAR(30)
);

COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX (PROFIT, AMOUNT)
    FROM (SELECT
           s.$2
          ,s.$3
          FROM @MANAGE_DB.EXTERNAL_STAGES.aws_stage s
          )
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails.csv');

SELECT *
FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX
WHERE ORDER_ID > 15;

DROP TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;