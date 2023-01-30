-- Demo: Data Masking In Data Lakes
-- Version: 1.10
-- Last updated: 23OCT2022

-- Set Context
USE ROLE sysadmin;
USE WAREHOUSE INSTRUCTOR1_wh;

drop DATABASE if exists INSTRUCTOR1_datalake_db;

CREATE DATABASE INSTRUCTOR1_datalake_db CLONE training_datalake_db;

USE SCHEMA INSTRUCTOR1_datalake_db.raw;

-- Create external table against Parquet data set.

drop external table if exists customer_ext;

create or replace external table customer_ext (
  x variant as VALUE,
  c_customer_sk             integer      as (value:c_customer_sk::integer) , -- pk
  c_customer_id             char(16)     as (value:c_customer_id::char(16))         ,
  c_current_cdemo_sk        integer      as (value:c_current_cdemo_sk::integer)     ,
  c_current_hdemo_sk        integer      as (value:c_current_hdemo_sk::integer)     ,
  c_current_addr_sk         integer      as (value:c_current_addr_sk::integer)      ,
  c_first_shipto_date_sk    integer      as (value:c_first_shipto_date_sk::integer) ,
  c_first_sales_date_sk     integer      as (value:c_first_sales_date_sk::integer)  ,
  c_salutation              char(10)     as (value:c_salutation::char(10))          ,
  c_first_name              char(20)     as (value:c_first_name::char(20))          ,
  c_last_name               char(30)     as (value:c_last_name::char(30))           ,
  c_preferred_cust_flag     char(1)      as (value:c_preferred_cust_flag::char(1))  ,
  c_birth_day               integer      as (value:c_birth_day::integer)            ,
  c_birth_month             integer      as (value:c_birth_month::integer)          ,
  c_birth_year              integer      as (value:c_birth_year::integer)           ,
  c_birth_country           varchar(20)  as (value:c_birth_country::varchar(20))    ,
  c_login                   char(13)     as (value:c_login::char(13))               ,
  c_email_address           char(50)     as (value:c_email_address::char(50))       ,
  c_last_review_date        char(10)     as (value:c_last_review_date::char(10))     
) location = @INSTRUCTOR1_datalake_db.staging.parquets/customer
file_format = (type=parquet);

-- Create a data masking policy to mask customer birth year
-- data from application users.
-- For simplicity, we're using SYSADMIN as the masking policy owner for
-- the demo (i.e., non-centralized masking policy approach)

CREATE OR REPLACE MASKING POLICY birthyear_mask as(val integer) returns integer ->
  case
    when current_role() in ('SYSADMIN') then val
    else 0000
  end;

-- Apply the masking policy to customer_ext column c_birth_year.
-- NOTE: The following returns the error since a masking policy
-- cannot be applied to a virtual column of an external table.

ALTER TABLE INSTRUCTOR1_datalake_db.raw.customer_ext modify column C_BIRTH_YEAR set masking policy birthyear_mask; -- Errors out

-- Create external table for use with a view.

-- Create a new table with only a single variant column.
create or replace external table customer_ext_v2 (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/customer
file_format = (type=parquet);


-- Create a view with a fixed set of columns and data types on the single
-- variant column table.

create or replace view v_customer_ext
as select
     x:c_customer_sk             ::integer               c_customer_sk          , -- pk
     x:c_customer_id             ::char(16)              c_customer_id          ,
     x:c_current_cdemo_sk        ::integer               c_current_cdemo_sk     ,
     x:c_current_hdemo_sk        ::integer               c_current_hdemo_sk     ,
     x:c_current_addr_sk         ::integer               c_current_addr_sk      ,
     x:c_first_shipto_date_sk    ::integer               c_first_shipto_date_sk ,
     x:c_first_sales_date_sk     ::integer               c_first_sales_date_sk  ,
     x:c_salutation              ::char(10)              c_salutation           ,
     x:c_first_name              ::char(20)              c_first_name           ,
     x:c_last_name               ::char(30)              c_last_name            ,
     x:c_preferred_cust_flag     ::char(1)               c_preferred_cust_flag  ,
     x:c_birth_day               ::integer               c_birth_day            ,
     x:c_birth_month             ::integer               c_birth_month          ,
     x:c_birth_year              ::integer               c_birth_year           ,
     x:c_birth_country           ::varchar(20)           c_birth_country        ,
     x:c_login                   ::char(13)              c_login                ,
     x:c_email_address           ::char(50)              c_email_address        ,
     x:c_last_review_date        ::char(10)              c_last_review_date     
from INSTRUCTOR1_datalake_db.raw.customer_ext_v2;

-- Note: A masking policy can be applied to a view over an external table.

-- Unset masking policy only if needed for the demo.
alter view INSTRUCTOR1_datalake_db.raw.v_customer_ext modify column c_birth_year 
unset masking policy;

-- Set masking policy on the view.
alter view INSTRUCTOR1_datalake_db.raw.v_customer_ext modify column c_birth_year 
set masking policy birthyear_mask;

-- Validate the masking of data thru the view v_customer_ext by querying as SYSADMIN
-- Verify that the customer data like birth year is still fully
-- accessible in clear text to the provisioning role SYSADMIN.

SELECT C_BIRTH_YEAR,* FROM INSTRUCTOR1_datalake_db.raw.v_customer_ext limit 10;

-- Query Masked Data

-- Grant access to PUBLIC role
-- We will assume that application users use the PUBLIC role.

GRANT ALL ON table INSTRUCTOR1_datalake_db.raw.v_customer_ext to ROLE PUBLIC;

grant usage on warehouse INSTRUCTOR1_wh to role public;
grant usage on database INSTRUCTOR1_datalake_db to role public;
grant usage on schema INSTRUCTOR1_datalake_db.raw to role public;
grant select  on all views in schema INSTRUCTOR1_datalake_db.raw to role public;
grant usage on schema INSTRUCTOR1_datalake_db.transformed to role public;
grant select  on all views in schema INSTRUCTOR1_datalake_db.transformed to role public;

-- Disable usage of the QR cache.
ALTER SESSION SET USE_CACHED_RESULT = FALSE;

-- Run queries as PUBLIC role (customer login data is fully masked)

USE ROLE public;
USE SCHEMA INSTRUCTOR1_datalake_db.raw;
USE WAREHOUSE INSTRUCTOR1_wh;

-- The following query result shows customer birth year fully masked (all zeros for each C_BIRTH_YEAR value)
SELECT C_BIRTH_YEAR,* FROM INSTRUCTOR1_datalake_db.raw.v_customer_ext limit 10;

-- The following two queries will not return any data. This is the expected
-- behavior whenever a masked column such as c_birth_year, is used in the
-- query filter.

SELECT C_BIRTH_YEAR,* FROM INSTRUCTOR1_datalake_db.raw.v_customer_ext where C_BIRTH_YEAR = 1984 limit 10;

SELECT wp_web_page_id, wp_customer_sk, wp_url FROM INSTRUCTOR1_datalake_db.transformed.v_web_page 
WHERE INSTRUCTOR1_datalake_db.transformed.v_web_page.wp_customer_sk is not null and
INSTRUCTOR1_datalake_db.transformed.v_web_page.wp_customer_sk IN 
(SELECT c_customer_sk FROM INSTRUCTOR1_datalake_db.raw.v_customer_ext WHERE C_BIRTH_YEAR = 1984);

