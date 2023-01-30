
-- 6.0.0   QUERYING DATA LAKE OBJECTS

-- 6.1.0   Clone the Data Lake Database
--         As TRAINING_ROLE, create a custom databases from an existing database
--         using the CLONE command:

-- 6.1.1   Create a warehouse.
--         If not previously created, create a virtual warehouse to use for the
--         data governance lab exercises.

USE ROLE training_role;

CREATE WAREHOUSE if not exists LEOPARD_wh warehouse_size=xsmall;

USE WAREHOUSE LEOPARD_wh;


-- 6.1.2   Create the data lake database.
--         Create the data lake database LEOPARD_DATALAKE_DB from an existing
--         database using the CLONE command.

CREATE DATABASE LEOPARD_datalake_db CLONE training_datalake_db;


-- 6.1.3   Create external tables

use schema raw;

create or replace external table date_dim (
    x variant as VALUE
) location = @LEOPARD_datalake_db.staging.parquets/date_dim
refresh_on_create = true
file_format = (type=parquet);

create or replace external table item (
    x variant as VALUE
) location = @LEOPARD_datalake_db.staging.parquets/item
refresh_on_create = true
file_format = (type=parquet);

create or replace external table customer_demographics (
    x variant as VALUE
) location = @LEOPARD_datalake_db.staging.parquets/customer_demographics
refresh_on_create = true
file_format = (type=parquet);

create or replace external table promotion (
    x variant as VALUE
) location = @LEOPARD_datalake_db.staging.parquets/promotion
refresh_on_create = true
file_format = (type=parquet);

create or replace external table store_sales (
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
location = @LEOPARD_datalake_db.staging.parquets/store_sales
refresh_on_create = true
file_format = (type=parquet);


-- 6.2.0   Run big BI queries on views over external data

-- 6.2.1   Set context and warehouse size

USE SCHEMA LEOPARD_datalake_db.transformed;

ALTER WAREHOUSE LEOPARD_wh SET WAREHOUSE_SIZE = large;


-- 6.2.2   Query data lake external tables
--         The following query on data lake external tables takes 10s using
--         large compute cluster

select i_brand_id brand_id, i_brand brand,
  sum(ss_ext_sales_price) ext_price
from v_date_dim, v_store_sales, v_item
where d_date_sk = ss_sold_date_sk
    and ss_item_sk = i_item_sk
    and i_manager_id=69
    and d_moy=12
    and d_year=2002
group by i_brand, i_brand_id
order by ext_price desc, i_brand_id
limit 100 ;

--         Execute the same query again to demonstrate query result cache
--         optimization feature is available for query on external table
--         Observation is that the re-executed query completes in near real time
--         under 1sec because of result cache benefit

select i_brand_id brand_id, i_brand brand,
  sum(ss_ext_sales_price) ext_price
from v_date_dim, v_store_sales, v_item
where d_date_sk = ss_sold_date_sk
    and ss_item_sk = i_item_sk
    and i_manager_id=69
    and d_moy=12
    and d_year=2002
group by i_brand, i_brand_id
order by ext_price desc, i_brand_id
limit 100 ;


-- 6.2.3   Query data lake external tables
--         The following query on data lake external tables takes 10s using
--         large compute cluster.

select  dt.d_year
    ,v_item.i_category_id
    ,v_item.i_category
    ,sum(ss_ext_sales_price)
from    v_date_dim dt
    ,v_store_sales
    ,v_item
where dt.d_date_sk = v_store_sales.ss_sold_date_sk
    and v_store_sales.ss_item_sk = v_item.i_item_sk
    and v_item.i_manager_id = 1     
    and dt.d_moy=12
    and dt.d_year=2001
group by    dt.d_year
        ,v_item.i_category_id
        ,v_item.i_category
order by       sum(ss_ext_sales_price) desc,dt.d_year
        ,v_item.i_category_id
        ,v_item.i_category
limit 100 ;


-- 6.2.4   Optional exercise: The following query on data lake external table
--         will take 1+ minute using large virtual warehouse
--         This query on data lake external tables takes about 1+ minutes using
--         large compute cluster store_sales is the largest fact table with 28B
--         rows

select /* { "query":"query07","streamId":0,"querySequence":2 } */  i_item_id,
  avg(ss_quantity) agg1,
  avg(ss_list_price) agg2,
  avg(ss_coupon_amt) agg3,
  avg(ss_sales_price) agg4
from v_store_sales, v_customer_demographics, v_date_dim, v_item, v_promotion
where ss_sold_date_sk = d_date_sk and
  ss_item_sk = i_item_sk and
  ss_cdemo_sk = cd_demo_sk and
  ss_promo_sk = p_promo_sk and
  cd_gender = 'M' and
  cd_marital_status = 'D' and
  cd_education_status = 'College' and
  (p_channel_email = 'N' or p_channel_event = 'N') and
  d_year = 2001
 group by i_item_id
 order by i_item_id
 limit 100;


-- 6.2.5   Optional exercise: The following query on data lake external table
--         will take 1+ minute using large virtual warehouse
--         The following query takes 1+ min using large compute cluster

/* { "query":"query34","streamId":0,"querySequence":73 } */

select  
  c_last_name
  ,c_first_name
  ,c_salutation
  ,c_preferred_cust_flag
  ,ss_ticket_number
  ,cnt from
  (
    select
      ss_ticket_number
      ,ss_customer_sk
      ,count(*) cnt
      from v_store_sales,v_date_dim,v_store,v_household_demographics
      where v_store_sales.ss_sold_date_sk = v_date_dim.d_date_sk
        and v_store_sales.ss_store_sk = v_store.s_store_sk
        and v_store_sales.ss_hdemo_sk = v_household_demographics.hd_demo_sk
        and (v_date_dim.d_dom between 1 and 3 or v_date_dim.d_dom between 25 and 28)
        and (v_household_demographics.hd_buy_potential = '1001-5000' or
            v_household_demographics.hd_buy_potential = 'Unknown')
        and v_household_demographics.hd_vehicle_count > 0
        and (case when v_household_demographics.hd_vehicle_count > 0
        then v_household_demographics.hd_dep_count/ v_household_demographics.hd_vehicle_count
      else null
      end)  > 1.2
        and v_date_dim.d_year in (2000,2000+1,2000+2)
        and v_store.s_county in ('Harmon County','Tehama County','Huron County','Brazos County',
                              'Mesa County','Somerset County','Abbeville County','Van Buren County')
group by ss_ticket_number,ss_customer_sk) dn,v_customer
where ss_customer_sk = c_customer_sk
  and cnt between 15 and 20
order by c_last_name,c_first_name,c_salutation,c_preferred_cust_flag desc, ss_ticket_number;


-- 6.3.0   Run lower latency small queries on views over external table

-- 6.3.1   Query 1 : Global Count (Aggregation)
--         The following query sums up sales for all stores for a single day.

select
  sum(ss_quantity)
  ,sum(ss_list_price)
  ,sum(ss_sales_price)
  ,sum(ss_net_profit)
from v_store_sales, v_date_dim
where ss_sold_date_sk = d_date_sk
and d_date = '1998-05-15';


-- 6.3.2   Query 2 : Grouping and Counting (Aggregation)
--         The following query breaks down sales by store for 100 stores over 30
--         days.

select
  ss_store_sk
  ,sum(ss_quantity)
  ,sum(ss_list_price)
  ,sum(ss_sales_price)
  ,sum(ss_net_profit)
from v_store_sales, v_date_dim
where ss_sold_date_sk = d_date_sk
  and d_date between cast('1998-05-15' as date) and dateadd(day, 30, cast('1998-05-15' as date))
  and ss_store_sk between 1414 and (1414 +100)
group by ss_store_sk;

