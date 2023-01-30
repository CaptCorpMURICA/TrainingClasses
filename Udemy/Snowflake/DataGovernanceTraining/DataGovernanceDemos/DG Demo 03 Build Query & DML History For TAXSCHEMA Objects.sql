-- Demo: Build Query & DML History For TAXSCHEMA Objects
-- Version: 1.18
-- Last updated: 12AUG2022
 
use role sysadmin;
use warehouse INSTRUCTOR1_wh;
use schema instructor1_tax_db.taxschema;

-- Disable QR cache for repeated query executions.
alter session set use_cached_result=false;

-- **************************************************************************

-- Run sample tax data queries as INSTRUCTOR1_TAXDATA_STEWARD, INSTRUCTOR1_TAX_EXECUTIVE, and INSTRUCTOR1_TAX_USER_WEST

use role INSTRUCTOR1_TAXDATA_STEWARD;
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='INDIVIDUAL'; 
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='CORPORATE'; 
select * from instructor1_tax_db.taxschema.taxpayer_dependents; 
select * from instructor1_tax_db.taxschema.taxpayer_wages;
select taxpayer_id,lastname,firstname,email from instructor1_tax_db.taxschema.taxpayer;
select taxpayer_id,dependent_ssn,dep_lastname,dep_firstname,dep_email from instructor1_tax_db.taxschema.taxpayer_dependents;
select taxpayer_id from instructor1_tax_db.taxschema.taxpayer_wages;

use role INSTRUCTOR1_TAX_EXECUTIVE;
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='INDIVIDUAL'; 
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='CORPORATE'; 
select * from instructor1_tax_db.taxschema.taxpayer_dependents; 
select * from instructor1_tax_db.taxschema.taxpayer_wages;
select taxpayer_id,lastname,firstname,email from instructor1_tax_db.taxschema.taxpayer;
select taxpayer_id,dependent_ssn,dep_lastname,dep_firstname,dep_email from instructor1_tax_db.taxschema.taxpayer_dependents;
select taxpayer_id from instructor1_tax_db.taxschema.taxpayer_wages;

use role INSTRUCTOR1_TAX_USER_WEST;
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='INDIVIDUAL'; 
select * from instructor1_tax_db.taxschema.taxpayer where upper(taxpayer_type)='CORPORATE'; 
select * from instructor1_tax_db.taxschema.taxpayer_dependents; 
select * from instructor1_tax_db.taxschema.taxpayer_wages;
select taxpayer_id,lastname,firstname,email from instructor1_tax_db.taxschema.taxpayer;
select taxpayer_id,dependent_ssn,dep_lastname,dep_firstname,dep_email from instructor1_tax_db.taxschema.taxpayer_dependents;
select taxpayer_id from instructor1_tax_db.taxschema.taxpayer_wages;

-- **************************************************************************

-- Run sample DML statements against tax data as INSTRUCTOR1_TAXDATA_STEWARD (which as Read/Write access to all tax data)
-- This will be used to show access history audit details for write operations

-- Update selected taxpayer data
use role INSTRUCTOR1_TAXDATA_STEWARD;
update instructor1_tax_db.taxschema.taxpayer set nbr_exemptions=7 where taxpayer_id=678465237;
update instructor1_tax_db.taxschema.taxpayer_dependents set dependent_ssn= 123456798 where taxpayer_id=678465237;
update instructor1_tax_db.taxschema.taxpayer_wages set w2_total_income=95000
where taxpayer_id=234893277 and tax_year in (2018, 2019, 2020);

-- Insert new taxpayer dependents
insert into instructor1_tax_db.taxschema.taxpayer_dependents values 
(197456794,678465237,'Daughter','Bredsguard','Lorilee','Denton','TX',02292, 
8014345800,6424479999,'lorileeb@mensch.com','Individual','01-APR-1985'),
(665129703,678465237,'Son','Bredsguard','Daniel','Idaho Falls','ID',65729,
8764345899,323212998,'danny@ioyt.com','Individual','01-JUL-1983')
;

-- **************************************************************************

-- Create a table TAXPAYER_CPY using CTAS (The CTAS will show up in the access history audit trail,
-- as CTAS writes data into the new table)
use role sysadmin;
use warehouse INSTRUCTOR1_wh;
use schema instructor1_tax_db.taxschema;

create or replace table taxpayer_cpy as
select * from taxpayer;

-- Create a table TAXPAYER_DEPENDENTS_CPY using INSERT...AS SELECT

use role sysadmin;
create or replace table taxpayer_dep_spouses like taxpayer_dependents; -- Creates empty table

use role instructor1_taxdata_steward;
insert into taxpayer_dep_spouses
select * from taxpayer_dependents where dep_relationship = 'Spouse';

select * from taxpayer_dep_spouses;
select * from taxpayer_cpy;

-- **************************************************************************

-- Load new taxpayer data (uses snowsql to PUT data into stage, and COPY INTO to copy the data into TAXPAYER table)
-- This demo loads additional data into the INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER table.
-- Will be used to show write operations logged by Access History.

-- Set context
use role sysadmin;
use warehouse instructor1_wh;
use schema instructor1_tax_db.taxschema;

-- Run this ONLY if you want to load data into an empty table
truncate table instructor1_tax_db.taxschema.taxpayer; 

-- Create a stage
create or replace stage instructor1_tax_db.taxschema.taxdata_stage;

CREATE or replace FILE FORMAT instructor1_tax_db.taxschema.taxdataformat
TYPE=CSV
COMPRESSION = 'NONE'
FIELD_DELIMITER = '|'
RECORD_DELIMITER = '\n'
SKIP_HEADER = 0
FIELD_OPTIONALLY_ENCLOSED_BY = 'NONE'
TRIM_SPACE = FALSE
ERROR_ON_COLUMN_COUNT_MISMATCH = TRUE
ESCAPE = 'NONE'
ESCAPE_UNENCLOSED_FIELD = '\134'
DATE_FORMAT = 'AUTO'
TIMESTAMP_FORMAT = 'AUTO'
NULL_IF = ('\\N');

-- Show number of TAXPAYER rows before loading
select count(*) from instructor1_tax_db.taxschema.taxpayer;

-- **************************************************************************

-- Use PUT commands to copy file on local hard-drive to the stage
-- Run the following commands in snowSQL

-- snowsql -c dba

-- Set context (Be sure to set the namespace in the Snowsql session, otherwise the PUT will fail)
use role sysadmin;
use database instructor1_tax_db;
use schema taxschema;
use warehouse instructor1_wh;

-- Make sure to include the correct path and sourcefile name in the PUT command

-- Load new taxpayer data using the named stage
-- Note: I had to set auto_compress=false in order to get this to work

-- put file://c:\data\000_demos\taxpayer_new_data.csv @taxdata_stage auto_compress=false;

-- Run COPY to copy the data from the stage to the taxpayer table (loads 30 new taxpayer rows)
COPY INTO instructor1_tax_db.taxschema.taxpayer FROM @taxdata_stage
FILE_FORMAT = 'instructor1_tax_db.taxschema.taxdataformat' ON_ERROR = 'CONTINUE' PURGE=TRUE;

-- Verify that the new data has been successfully loaded.

-- Show number of TAXPAYER rows after loading
select count(*) from instructor1_tax_db.taxschema.taxpayer; -- Shows 62 taxpayer rows

-- Show all current TAXPAYER data
select * from instructor1_tax_db.taxschema.taxpayer;

-- Clean out the internal stage
ls @taxdata_stage; -- Should show no files since we set PURGE=TRUE in the COPY INTO command

-- **************************************************************************

-- Unload selected taxpayer data (uses COPY INTO to an internal stage, and uses snowsql GET command to dump the data locally)

-- Set context
use role sysadmin;
use warehouse instructor1_wh;
use schema instructor1_tax_db.taxschema;

-- Unload all Taxpayer table data
COPY INTO @taxdata_stage/all_taxpayer_data_
  FROM  (SELECT * FROM taxpayer)
   FILE_FORMAT = (FORMAT_NAME = taxdataformat) overwrite=true;

-- Show contents of the stage before downloading to the laptop
ls @taxdata_stage;

-- Run the next commands in snowsql.
-- Use GET to download the stage data to laptop (Run in snowSQL)
-- Paste in the code below into snowSQL
use role sysadmin;
use warehouse instructor1_wh;
use database instructor1_tax_db;
use schema taxschema;
-- get @taxdata_stage file://c:\data\000_demos;

-- In the UI worksheet, remove the file from the internal stage
ls @taxdata_stage; -- Should show 1 file
rm @taxdata_stage;
ls @taxdata_stage; -- Shows no files

