-- Demo: Object Dependencies & Impact Analysis
-- Version: 1.10
-- Last updated: 23OCT2022

-- USAGE NOTES: 
-- (1) This demo requires that you first run the demo script "Data Masking In Data Lake"
-- in order to create the required database INSTRUCTOR1_DATALAKE_DB.

-- (2) In order to see output from the object dependency queries in lines 155 and 203,
-- uou will first need to create all of the objects immediately proceding these queries
-- so that the OBJECT_DEPENDENCIES view latency time (up to 3 hours) is met.

-- Set Context

USE ROLE sysadmin;
USE WAREHOUSE INSTRUCTOR1_wh;

-- alter warehouse instructor1_wh set warehouse_size=xsmall;

alter warehouse instructor1_wh set warehouse_size=xlarge;

drop DATABASE if exists INSTRUCTOR1_datalake2_db;

CREATE DATABASE INSTRUCTOR1_datalake2_db CLONE training_datalake_db;

USE SCHEMA INSTRUCTOR1_datalake2_db.raw;

create or replace external table date_dim_ext (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/date_dim
refresh_on_create = true
file_format = (type=parquet);

create or replace external table item_ext (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/item
refresh_on_create = true
file_format = (type=parquet);

create or replace external table customer_demographics_ext (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/customer_demographics
refresh_on_create = true
file_format = (type=parquet);

create or replace external table promotion_ext (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/promotion
refresh_on_create = true
file_format = (type=parquet);

create or replace external table store_sales_ext (
    ss_sold_date_sk integer as TO_NUMBER(
        case when split_part(split_part(METADATA$FILENAME, '=',2),'/',1) =  '__HIVE_DEFAULT_PARTITION__' then NULL
        else split_part(split_part(METADATA$FILENAME, '=',2),'/',1) end) ,
   -- x variant as VALUE,
        ss_sold_time_sk integer as  (value:ss_sold_time_sk::integer),
        ss_item_sk  integer     as  (value:ss_item_sk::integer), -- pk
        ss_customer_sk integer as  (value:ss_customer_sk::integer),
        ss_cdemo_sk integer as (value:ss_cdemo_sk::integer),
        ss_hdemo_sk integer as (value:ss_hdemo_sk::integer),
        ss_addr_sk integer as (value:ss_addr_sk::integer),
        ss_store_sk  integer as  (value :ss_store_sk::integer),
        ss_promo_sk  integer as  (value:ss_promo_sk::integer),
        ss_ticket_number integer as  (value:ss_ticket_number::integer), -- pk
        ss_quantity integer as  (value:ss_quantity::integer),
        ss_wholesale_cost integer as  (value:ss_wholesale_cost::decimal(7,2)),
        ss_list_price integer as  (value:ss_list_price::decimal(7,2)),
        ss_sales_price integer as (value:ss_sales_price::decimal(7,2)),
        ss_ext_discount_amt integer as (value:ss_ext_discount_amt::decimal(7,2)),
        ss_ext_sales_price integer as (value:ss_ext_sales_price::decimal(7,2)),
        ss_ext_wholesale_cost integer as (value:ss_ext_wholesale_cost::decimal(7,2)),
        ss_ext_list_price  integer as  (value:ss_ext_list_price::decimal(7,2)),
        ss_ext_tax  integer as (value:ss_ext_tax::decimal(7,2)),
        ss_coupon_amt  integer as  (value:ss_coupon_amt::decimal(7,2)),
        ss_net_paid  integer as  (value:ss_net_paid::decimal(7,2)),
        ss_net_paid_inc_tax integer as (value:ss_net_paid_inc_tax::decimal(7,2)),
        ss_net_profit integer as (value:ss_net_profit::decimal(7,2))             
)   
PARTITION BY (ss_sold_date_sk)
location = @INSTRUCTOR1_datalake_db.staging.parquets/store_sales
refresh_on_create = true
file_format = (type=parquet);

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

-- Create a new table with only a single variant column.
create or replace external table customer_v2_ext (
    x variant as VALUE
) location = @INSTRUCTOR1_datalake_db.staging.parquets/customer
file_format = (type=parquet);

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
from INSTRUCTOR1_datalake2_db.raw.customer_v2_ext;

-- Review the referenced object and the referencing object.
-- The external table, customer_v2, is the referenced object.

SELECT * FROM customer_v2_ext LIMIT 10;

-- The view, v_customer, is the referencing object.

SELECT * FROM v_customer_ext LIMIT 10;


-- NOTE: After creating the above objects, you will have to wait until the 
-- latency time (up to 3 hours) has been met before you will see 
-- any output in the following query.

-- Query OBJECT_DEPENDENCIES to analyze dependency on an external table.
-- The external table customer_v2_ext is the referenced_object_domain
-- The view v_customer will be shown as the referencing_object_name in
-- the query result.

SELECT
 referencing_object_name, referencing_object_domain, referenced_object_name, referenced_object_domain
FROM snowflake.account_usage.object_dependencies
WHERE referenced_object_name = 'CUSTOMER_V2_EXT'
AND referenced_object_domain = 'EXTERNAL TABLE';

-- Perform impact analysis to find various the objects referenced by a
-- given object.
-- Knowing the object dependency allows data stewards to identify the
-- relationships between referencing objects and referenced objects to
-- ensure that updates to referenced objects do not adversely impact
-- users of the referencing object.

-- Consider our example: - External table store_sales_ext for the sale
-- transactions of all the stores
-- - View v_store_442_sales_ext indicates all sale transactions of store
--   442.
-- - View v_store_442_big_sales_ext indicates all the big transactions with
--   100 or greater quantity at store 442.

-- Review the referenced object store_sales external table.

SELECT * FROM store_sales_ext LIMIT 10;

-- Create the nested views of the external table.

ALTER WAREHOUSE INSTRUCTOR1_wh set warehouse_size=xlarge;

CREATE OR REPLACE VIEW v_store_442_sales_ext AS
SELECT * FROM store_sales_ext
WHERE ss_store_sk = 442;

SELECT * FROM v_store_442_sales_ext LIMIT 10;

CREATE OR REPLACE VIEW v_store_442_big_sales_ext AS
SELECT * FROM  v_store_442_sales_ext
WHERE ss_quantity >= 100;

SELECT * FROM v_store_442_big_sales_ext LIMIT 10;

-- Query the OBJECT_DEPENDENCIES view to determine the object references
-- for store_sales_ext.
-- Runs for about 25 secs with XL WH

-- Observe the following in the query output:
-- View V_STORE_442_SALES_EXT: Dependent on source object (external table) STORE_SALES_EXT
-- View V_STORE_442_BIG_SALES_EXT: Dependent on source object (view) V_STORE_442_SALES_EXT

-- NOTE: After creating the above objects, you will have to wait until the 
-- latency time (up to 3 hours) has been met before you will see 
-- any output in the following query.

with recursive referenced_cte
(object_name_path, referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id)
    as
      (
        select referenced_object_name || '-->' || referencing_object_name as object_name_path,
               referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id
          from snowflake.account_usage.object_dependencies referencing
          where true
            and referenced_object_name = 'STORE_SALES_EXT' and referenced_object_domain='EXTERNAL TABLE'

        union all

        select object_name_path || '-->' || referencing.referencing_object_name,
              referencing.referenced_object_name, referencing.referenced_object_domain, referencing.referencing_object_domain, referencing.referencing_object_name,
              referencing.referenced_object_id, referencing.referencing_object_id
          from snowflake.account_usage.object_dependencies referencing join referenced_cte
            on referencing.referenced_object_id = referenced_cte.referencing_object_id
            and referencing.referenced_object_domain = referenced_cte.referencing_object_domain
      )

  select object_name_path, referenced_object_name, referenced_object_domain, referencing_object_name, referencing_object_domain
    from referenced_cte
;

-- *** Everything up to this point works fine with results received for the prior CTE query

-- *** No need to proceed with the next section of demo script unless you have sufficient time, 
-- *** as several CREATE statements below take over 7 mins to run with 2XL WH

-- Examples:
-- - View v_store_442_sales_ext
--     External Table STORE_SALES_EXT –> View V_STORE_442_SALES_EXT
-- - View v_store_442_big_sales_ext
--      External Table STORE_SALES_EXT –> View V_STORE_442_SALES_EXT –> View V_STORE_442_BIG_SALES_EXT

-- Assist GDPR requirement of finding various data sources for a nested
-- derived object
-- Derived objects (e.g. views, CTAS) can be created from many different
-- source objects to provide a custom view or dashboard. To meet
-- regulatory requirements such as GDPR, compliance officers and
-- auditors need to be able to trace data from given objects to its
-- original data source.

-- Consider our example: the nested view GLOBAL_SALES is derived from
-- three different dependency paths that point to three different base
-- tables, STORE_SALES, CATALOG_SALES, and WEB_SALES:
-- - External table CATALOG_SALES » view ’GLOBAL_SALES
-- - External table WEB_SALES » CTAS T_WEB_SALES » view GLOBAL_SALES
-- - External table STORE_SALES » materialized view MV_STORE_SALES »
--   view GLOBAL_SALES

-- Create the dependency example of customer materialized view
-- MV_STORE_SALES over the external table STORE_SALES.

alter warehouse INSTRUCTOR1_wh set warehouse_size=xxlarge;

-- Note: MV creation statement runs for about 5 mins 45 secs with 2XL WH
CREATE OR REPLACE MATERIALIZED VIEW INSTRUCTOR1_datalake2_db.analytic.mv_store_sales AS
SELECT
   ss_sold_date_sk,
     ss_sold_time_sk,
     ss_item_sk,
     ss_customer_sk,
     ss_cdemo_sk,
     ss_hdemo_sk,
     ss_addr_sk,
     ss_store_sk,
     ss_promo_sk,
     ss_ticket_number,
     ss_quantity,
     ss_wholesale_cost,
     ss_list_price,
     ss_sales_price,
     ss_ext_discount_amt,
     ss_ext_sales_price,
     ss_ext_wholesale_cost,
     ss_ext_list_price,
     ss_ext_tax,
     ss_coupon_amt,
     ss_net_paid,
     ss_net_paid_inc_tax,
     ss_net_profit      
FROM INSTRUCTOR1_datalake2_db.raw.store_sales_ext
WHERE SS_CUSTOMER_SK = 2450974;


-- Create the dependency example of the CTAS customer table T_WEB_SALES
-- over the view V_WEB_SALES.

-- Note: Table creation statement runs for about 7 mins 5 secs with 2XL WH
CREATE OR REPLACE TABLE INSTRUCTOR1_datalake_db.analytic.t_web_sales AS
SELECT * FROM INSTRUCTOR1_datalake_db.transformed.v_web_sales
WHERE WS_BILL_CUSTOMER_SK = 2450974;

-- Create the global sales customer view of TOTAL_SALES over the
-- different dependent objects.

CREATE OR REPLACE VIEW INSTRUCTOR1_datalake_db.analytic.total_sales AS
SELECT
   ws_sold_date_sk
   ,ws_item_sk
   ,ws_quantity
   ,ws_sales_price
   ,ws_net_profit
FROM INSTRUCTOR1_datalake_db.analytic.t_web_sales
UNION ALL
SELECT
   ss_sold_date_sk
   ,ss_item_sk
   ,ss_quantity
   ,ss_sales_price
   ,ss_net_profit
FROM INSTRUCTOR1_datalake2_db.analytic.mv_store_sales
UNION ALL
SELECT
   cs_sold_date_sk
   ,cs_item_sk
   ,cs_quantity
   ,cs_sales_price
   ,cs_net_profit
FROM INSTRUCTOR1_datalake_db.transformed.v_catalog_sales WHERE CS_BILL_CUSTOMER_SK = 2450974;


-- Query the OBJECT_DEPENDENCIES view to find the data source(s) of the
-- global sales customer view TOTAL_SALES.
-- NOTE: Each row in the query result specifies a dependency path to the
-- object.
-- Also: Latency for the view OBJECT_DEPENDENCIES may be up to three hours.
-- NOTE: Last successful execution - Received data after about 1 hr latency

with recursive referenced_cte
(object_name_path, referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id)
    as
      (
        select referenced_object_name || '<--' || referencing_object_name as object_name_path,
               referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id
          from snowflake.account_usage.object_dependencies referencing
          where true
            and referencing_object_name = 'TOTAL_SALES' and referencing_object_domain='VIEW'

        union all

        select referencing.referenced_object_name || '<--' || object_name_path,
              referencing.referenced_object_name, referencing.referenced_object_domain, referencing.referencing_object_domain, referencing.referencing_object_name,
              referencing.referenced_object_id, referencing.referencing_object_id
          from snowflake.account_usage.object_dependencies referencing join referenced_cte
            on referencing.referencing_object_id = referenced_cte.referenced_object_id
            and referencing.referencing_object_domain = referenced_cte.referenced_object_domain
      )

  select object_name_path, referencing_object_name, referencing_object_domain, referenced_object_name, referenced_object_domain
    from referenced_cte
;

-- Reset WH size
alter warehouse INSTRUCTOR1_wh set warehouse_size=xsmall;
