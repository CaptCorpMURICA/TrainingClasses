
-- 7.0.0   MASKING SENSITIVE DATA IN A DATA LAKE

-- 7.1.0   Create Dynamic Data Masking Policy
--         Create Dynamic Data Masking Policy to mask customer birth year data

-- 7.1.1   Set Context

USE ROLE training_role;
USE WAREHOUSE LEOPARD_wh;
USE DATABASE LEOPARD_datalake_db;



-- 7.1.2   Create external table

USE SCHEMA raw;

create or replace external table customer (
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
) location = @LEOPARD_datalake_db.staging.parquets/customer
file_format = (type=parquet);


-- 7.1.3   Create dynamic data masking policy
--         Create a dynamic data masking policy to obscure customer birth year
--         data from application team.
--         For simplicity, we use TRAINING_ROLE as the masking policy owner for
--         this lab (deploying a non-centralized masking policy approach and
--         that this differs from the approach presented in the prior data
--         masking lab)

CREATE OR REPLACE MASKING POLICY byear_mask as(val integer) returns integer ->
  case
    when current_role() in ('TRAINING_ROLE') then val
    else null
  end;


-- 7.2.0   Apply Dynamic Data Masking Policy
--         Apply Dynamic Data Masking Policy to table customer’s birth year
--         column in view over external table.

-- 7.2.1   Apply dynamic data masking policy to an external table
--         Apply the masking policies to customer’s birth year field.
--         The following is expected to return an error.
--         Masking policy cannot be applied to virtual column (column of
--         external table).

ALTER TABLE LEOPARD_datalake_db.raw.customer modify column C_BIRTH_YEAR set masking policy byear_mask;


-- 7.2.2   Create external table for view
--         Create a new table with only a single variant column.

create or replace external table customer_v2 (
    x variant as VALUE
) location = @LEOPARD_datalake_db.staging.parquets/customer
file_format = (type=parquet);


-- 7.2.3   Create a view on external table
--         Create a view with a fixed set of columns and types on the single
--         variant column table.

create or replace view v_customer
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
from LEOPARD_datalake_db.raw.customer_v2;


-- 7.2.4   Apply dynamic data masking policy to a view
--         Masking policy can be applied to view over external table.

ALTER VIEW LEOPARD_datalake_db.transformed.v_customer modify column C_BIRTH_YEAR set masking policy byear_mask;


-- 7.2.5   Validate the masking of data by querying as TRAINING_ROLE role
--         Verify new object creation with sensitive data like email still full
--         available to the provisioning role, TRAINING_ROLE.

SELECT C_BIRTH_YEAR,* FROM LEOPARD_datalake_db.transformed.v_customer limit 10;


-- 7.3.0   Query Masked Data
--         Very sensitive data is masked in analyst queries.

-- 7.3.1   Grant access to PUBLIC role
--         Let’s assume application use the PUBLIC role.

GRANT ALL ON table LEOPARD_datalake_db.transformed.v_customer to ROLE PUBLIC;

grant usage on warehouse LEOPARD_wh to role public;
grant usage on database LEOPARD_datalake_db to role public;
grant usage on schema LEOPARD_datalake_db.transformed to role public;
grant select  on all views in schema LEOPARD_datalake_db.transformed to role public;

ALTER SESSION SET USE_CACHED_RESULT = FALSE;


-- 7.3.2   Validate the masking of data by querying as Public role
--         Run table queries as PUBLIC role (customer login data is fully
--         masked)

USE ROLE public;
USE SCHEMA LEOPARD_datalake_db.transformed;
USE WAREHOUSE LEOPARD_wh;

--         The following query result will show customer birth year is fully
--         masked

SELECT C_BIRTH_YEAR,* FROM LEOPARD_datalake_db.transformed.v_customer limit 10;

--         The following queries will not return result. This is the correct
--         behavior when the masked column, customer birth year, is used in the
--         filter

SELECT C_BIRTH_YEAR,* FROM LEOPARD_datalake_db.transformed.v_customer where C_BIRTH_YEAR = 1984 limit 10;

SELECT wp_web_page_id, wp_customer_sk, wp_url FROM v_web_page WHERE wp_customer_sk is not null and
wp_customer_sk IN (SELECT c_customer_sk FROM v_customer WHERE C_BIRTH_YEAR = 1984);

