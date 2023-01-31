-- Declare Warehouse and Role
USE WAREHOUSE LEOPARD_WH;
USE ROLE ACCOUNTADMIN;

-- Create new stage
CREATE OR REPLACE STAGE MANAGE_DB.external_stages.aws_stage_errorex
    url = 's3://bucketsnowflakes4';

-- List files in stage
LIST @MANAGE_DB.external_stages.aws_stage_errorex;

-- Create example table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

-- Demonstrating error message
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv');

-- Validating table is empty
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv')
    ON_ERROR = 'CONTINUE';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 1,498
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option = ABORT_STATEMENT (default)
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'ABORT_STATEMENT';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 0
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option = SKIP_FILE
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 285
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option = SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_2';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 285
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Error handling using the ON_ERROR option = SKIP_FILE_<number>
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = 'SKIP_FILE_0.5%';

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 1,783
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;

-- Recreate table
CREATE OR REPLACE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX (
    ORDER_ID VARCHAR(30),
    AMOUNT INT,
    PROFIT INT,
    QUANTITY INT,
    CATEGORY VARCHAR(30),
    SUBCATEGORY VARCHAR(30));

-- Copy with size limit
COPY INTO OUR_FIRST_DB.PUBLIC.ORDERS_EX
    FROM @MANAGE_DB.external_stages.aws_stage_errorex
    file_format = (type = csv
                   field_delimiter = ','
                   skip_header = 1)
    files = ('OrderDetails_error.csv','OrderDetails_error2.csv')
    ON_ERROR = SKIP_FILE_3
    SIZE_LIMIT = 30;

-- Validating results and truncating table
SELECT * FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;
SELECT COUNT(*) AS Cnt FROM OUR_FIRST_DB.PUBLIC.ORDERS_EX;  -- 285
TRUNCATE TABLE OUR_FIRST_DB.PUBLIC.ORDERS_EX;