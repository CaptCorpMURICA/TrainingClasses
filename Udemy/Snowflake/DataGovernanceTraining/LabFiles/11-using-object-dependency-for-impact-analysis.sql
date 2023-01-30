
-- 11.0.0  USING OBJECT DEPENDENCY FOR IMPACT ANALYSIS
--         By the end of this lab, you will be able to:
--         - Show simple dependency on a database object such as external table
--         - Perform impact analysis by finding various objects referenced by a
--         table
--         - Assist meeting GDPR requirement by finding various data sources for
--         a given nested object

-- 11.1.0  Show an object depending on an external table.
--         The object dependency relationship helps primary data professionals,
--         such as analysts, scientists, compliance officers, and other business
--         users, to verify the source of data and have confidence that the data
--         originates from is trustworthy. This provides the benefit of data
--         integrity.

-- 11.1.1  Set your context:

USE ROLE training_role;
USE SCHEMA LEOPARD_datalake_db.raw;
USE WAREHOUSE LEOPARD_wh;


-- 11.1.2  Review the referenced object and the referencing object.
--         The external table, customer_v2, is the referenced object.

SELECT * FROM customer_v2 LIMIT 10;

--         The view, v_customer, is the referencing object.

SELECT * FROM v_customer LIMIT 10;


-- 11.1.3  Query the OBJECT_DEPENDENCY built-in view to analyze dependency on an
--         external table.
--         - The external table customer_v2 is the referenced_object_domain
--         - The view v_customer will be shown as the referencing_object_name in
--         the query result

SELECT
 referencing_object_name, referencing_object_domain, referenced_object_name, referenced_object_domain
FROM snowflake.account_usage.object_dependencies
WHERE referenced_object_name = 'CUSTOMER_V2'
AND referenced_object_domain = 'EXTERNAL TABLE';


-- 11.2.0  Perform impact analysis to find various the objects referenced by a
--         given object
--         Knowing the object dependency allows data stewards to identify the
--         relationships between referencing objects and referenced objects to
--         ensure that updates to referenced objects do not adversely impact
--         users of the referencing object.
--         Consider our example: - External table store_sales for the sale
--         transactions of all the stores
--         - View v_store_442_sales indicates all sale transactions of store
--         442.
--         - View v_store_442_big_sales indicates all the big transactions with
--         100 or greater quantity at store 442.

-- 11.2.1  Review the referenced object store_sales external table.

SELECT * FROM store_sales LIMIT 10;


-- 11.2.2  Create the nested views of the external table.


ALTER WAREHOUSE LEOPARD_wh set warehouse_size=xlarge;

CREATE OR REPLACE VIEW v_store_442_sales AS
SELECT * FROM store_sales
WHERE ss_store_sk = 442;

SELECT * FROM v_store_442_sales LIMIT 10;

CREATE OR REPLACE VIEW v_store_442_big_sales AS
SELECT * FROM  v_store_442_sales
WHERE ss_quantity >= 100;

SELECT * FROM v_store_442_big_sales LIMIT 10;


-- 11.2.3  Query the OBJECT_DEPENDENCIES view to determine the object references
--         for the external table store_sales.

with recursive referenced_cte
(object_name_path, referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id)
    as
      (
        select referenced_object_name || '-->' || referencing_object_name as object_name_path,
               referenced_object_name, referenced_object_domain, referencing_object_domain, referencing_object_name, referenced_object_id, referencing_object_id
          from snowflake.account_usage.object_dependencies referencing
          where true
            and referenced_object_name = 'STORE_SALES' and referenced_object_domain='EXTERNAL TABLE'

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

--         Examples:
--         - View v_store_442_sales
--         External Table STORE_SALES –> View V_STORE_442_SALES
--         - View v_store_442_big_sales
--         External Table STORE_SALES –> View V_STORE_442_SALES –> View
--         V_STORE_442_BIG_SALES

-- 11.3.0  Assist GDPR requirement of finding various data sources for a nested
--         derived object
--         Derived objects (e.g. views, CTAS) can be created from many different
--         source objects to provide a custom view or dashboard. To meet
--         regulatory requirements such as GDPR, compliance officers and
--         auditors need to be able to trace data from given objects to its
--         original data source.
--         Consider our example: the nested view GLOBAL_SALES is derived from
--         three different dependency paths that point to three different base
--         tables, STORE_SALES, CATALOG_SALES, and WEB_SALES:
--         - External table CATALOG_SALES » view ’GLOBAL_SALES
--         - External table WEB_SALES » CTAS T_WEB_SALES » view GLOBAL_SALES
--         - External table STORE_SALES » materialized view MV_STORE_SALES »
--         view GLOBAL_SALES

-- 11.3.1  Create the dependency example of customer materialized view
--         MV_STORE_SALES over the external table STORE_SALES.

alter warehouse LEOPARD_wh set warehouse_size=xxlarge;
CREATE OR REPLACE MATERIALIZED VIEW LEOPARD_datalake_db.analytic.mv_store_sales AS
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
FROM LEOPARD_datalake_db.raw.store_sales
WHERE SS_CUSTOMER_SK = 2450974;


-- 11.3.2  Create the dependency example of the CTAS customer table T_WEB_SALES
--         over the view V_WEB_SALES.

CREATE OR REPLACE TABLE LEOPARD_datalake_db.analytic.t_web_sales AS
SELECT * FROM LEOPARD_datalake_db.transformed.v_web_sales
WHERE WS_BILL_CUSTOMER_SK = 2450974;
alter warehouse LEOPARD_wh set warehouse_size=medium;


-- 11.3.3  Create the global sales customer view of TOTAL_SALES over the
--         different dependent objects.

CREATE OR REPLACE VIEW LEOPARD_datalake_db.analytic.total_sales AS
SELECT
   ws_sold_date_sk
   ,ws_item_sk
   ,ws_quantity
   ,ws_sales_price
   ,ws_net_profit
FROM LEOPARD_datalake_db.analytic.t_web_sales
UNION ALL
SELECT
   ss_sold_date_sk
   ,ss_item_sk
   ,ss_quantity
   ,ss_sales_price
   ,ss_net_profit
FROM LEOPARD_datalake_db.analytic.mv_store_sales
UNION ALL
SELECT
   cs_sold_date_sk
   ,cs_item_sk
   ,cs_quantity
   ,cs_sales_price
   ,cs_net_profit
FROM LEOPARD_datalake_db.transformed.v_catalog_sales WHERE CS_BILL_CUSTOMER_SK = 2450974;


-- 11.3.4  Query the OBJECT_DEPENDENCIES view to find the data source(s) of the
--         global sales customer view TOTAL_SALES.
--         Each row in the query result specifies a dependency path to the
--         object.

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

