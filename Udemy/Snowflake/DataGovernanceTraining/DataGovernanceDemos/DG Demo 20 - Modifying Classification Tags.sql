-- Demo: Modifying Classification Tags

-- This is a demo on using the EXTRACT_SEMANTIC_CATEGORIES and the associate_semantic_category_tags stored procedure
-- Uses a simple table created from the TAXPAYER tables with only three columns.
-- Shows how a column with a alternate section with a low percentage can be changed to apply a tag.

USE ROLE sysadmin;

CREATE WAREHOUSE if not exists INSTRUCTOR1_wh warehouse_size=xsmall;

USE WAREHOUSE INSTRUCTOR1_wh;
USE SCHEMA INSTRUCTOR1_DB.PUBLIC;

-- Create a three-column table with fullname, zip, and salary from the tax_db.


CREATE OR REPLACE TABLE emp AS SELECT (FIRSTNAME || ' ' || LASTNAME) AS FullName, 
    ZIP, 
    MAX((CAST((ADJ_GROSS_INCOME / 26) AS DECIMAL(8,2)))) AS salary 
    FROM TRAINING_TAX_DB.TAXSCHEMA.TAXPAYER TP 
        INNER JOIN TRAINING_TAX_DB.TAXSCHEMA.TAXPAYER_WAGES TW
        ON TP.TAXPAYER_ID = TW.TAXPAYER_ID
        GROUP BY 1,2;

-- Show what is in the new emp table
SELECT * FROM emp;

-- Run EXTRACT_SEMANTIC_CATEGORIES on the new emp table.

SELECT EXTRACT_SEMANTIC_CATEGORIES('emp');

-- Show the results of the extract in a structured format

-- The results will show the fullName and salary column have a category. Zip has an alternate.
-- This means that the fullName and salary will get a tag but zip will not without changing the JSON record

SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('EMP')::variant)) as f;

-- Before applying the current tags to the emp table, clone it.
-- The clone will be used to modify the JSON record to show how we can 
-- change the zip record to not be an alternate.

-- NOTE: If we cloned emp after we applied the tags below, the cloned table would have the tags. 

CREATE OR REPLACE TABLE emp_clone CLONE emp; 

-- Apply the current results from the extractLsemantic_categories to the Emp table
  
call associate_semantic_category_tags('emp',
                                      extract_semantic_categories('emp'));
                                      
-- Show the tags applied to the emp table by the associate_semantic_category_tags
-- Notice zip is not tagged. the associate command doesn't tag columns with an alternate section

select *
  from table(information_schema.tag_references_all_columns('emp', 'table'));

-- It may be worthwhile to edit the JSON file and change columns with an alternate selection if you know 
-- the alternate section is correct. This can be done by saving the JSON output into a table and running an update
-- on the table to change the JSON record. It may be easier to copy the JSON record to a file and edit it on a local machine.
--  We not going to demo every step in the process to do this but here is the command to create a 
--  file in a table stage with the JSON output.
  
-- ***** THIS CODE IS FOR AN EXAMPLE AND DOESN'T NEED TO BE RUN. CONTINUE BELOW *****
/*
COPY INTO @%emp/semantic FROM
(
SELECT EXTRACT_SEMANTIC_CATEGORIES('emp')
)
FILE_FORMAT = (TYPE = JSON);
*/ 

-- Before we apply tags to the emp_clone, show the current tags on the emp_clone
-- Notice there are no tags even though we cloned the emp table. 
-- NOTE: If we had cloned the table after tags were applied, the tags would be on the cloned table.
-- Data masking and row access policies will also be in the cloned table.

select *
  from table(information_schema.tag_references_all_columns('emp_clone', 'table'));
  
-- As you would expect, the emp_clone will show the same output for the classification. 
-- Run EXTRACT_SEMANTIC_CATEGORIES on the emp_clone table.

SELECT EXTRACT_SEMANTIC_CATEGORIES('emp_clone');

-- Flattened output for emp_clone
SELECT
    KEY AS COLUMN_NAME,
    VALUE:semantic_category AS SEMANTIC_CATEGORY,
    VALUE:privacy_category AS PRIVACY_CATEGORY,
    VALUE:extra_info:probability AS PROBABILITY,
    VALUE:extra_info:alternates AS ALTERNATES
FROM
table(flatten(extract_semantic_categories('EMP_CLONE')::variant)) as f;

-- In the next step, the corrected version of the JSON record will be used to classify all the columns in the emp_clone table.
-- Notice in the JSON record that we moved the information from alternate to the record. 
-- This will cause the command to tag the zip column

call associate_semantic_category_tags('emp_clone',
  $$
  {
  "FULLNAME": {
    "extra_info": {
      "alternates": [],
      "probability": "1.00"
    },
    "privacy_category": "IDENTIFIER",
    "semantic_category": "NAME"
  },
  "SALARY": {
    "extra_info": {
      "alternates": [],
      "probability": "1.00"
    },
    "privacy_category": "SENSITIVE",
    "semantic_category": "SALARY"
  },
  "ZIP": {
    "extra_info": {
      "alternates": [],
       "probability": "1.00"
    },
    "privacy_category": "QUASI_IDENTIFIER",
    "semantic_category": "US_POSTAL_CODE"
  }
}
$$::VARIANT);

-- If we look at the tags applied to the emp_clone table, it will show the zip column now is tagged.
select *
  from table(information_schema.tag_references_all_columns('emp_clone', 'table'));
