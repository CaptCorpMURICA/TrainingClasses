-- Demo: Tagging Virtual Warehouses

use role INSTRUCTOR1_policy_admin;
use warehouse instructor1_wh;
use schema INSTRUCTOR1_tag_db.tag_library;

drop tag cost_center;
create or replace tag cost_center;

alter warehouse instructor1_wh set tag cost_center='Analytics';
alter warehouse instructor1_load_wh set tag cost_center='ELT';

USE SCHEMA snowflake.account_usage;

SELECT tag_value AS cost_center,warehouse_name,
       SUM(credits_used) AS credits 
FROM warehouse_metering_history 
JOIN tag_references 
ON warehouse_name = object_name
WHERE TRUE
  AND warehouse_name=object_name 
  AND tag_name='COST_CENTER'
  AND tag_database='INSTRUCTOR1_TAG_DB' 
  AND tag_schema='TAG_LIBRARY' 
GROUP BY 1,2
ORDER BY 3 DESC;
