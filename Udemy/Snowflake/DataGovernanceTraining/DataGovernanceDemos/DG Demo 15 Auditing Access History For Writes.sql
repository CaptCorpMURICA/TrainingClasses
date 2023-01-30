-- Demo: Auditing Access History For Writes
-- Version: V1.18
-- Last updated: 09AUG2022

-- This demo demonstrates the usage of SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY for auditing write operations.

-- NOTE: The ACCESS_HISTORY view currently supports the following types of write operations:
--   GET <internal_stage>
--   PUT <internal_stage>
--   DELETE
--   TRUNCATE
--   INSERT:
--     INSERT INTO … FROM SELECT *
--     INSERT INTO TABLE … VALUES ()
--   MERGE INTO … FROM SELECT *
--   UPDATE:
--     UPDATE TABLE … FROM SELECT * FROM …
--     UPDATE TABLE … WHERE …
--   Data loading:
--     COPY INTO TABLE FROM internalStage
--     COPY INTO TABLE FROM externalStage
--     COPY INTO TABLE FROM externalLocation
--   Data unloading:
--     COPY INTO internalStage FROM TABLE
--     COPY INTO externalStage FROM TABLE
--     COPY INTO externalLocation FROM TABLE
--   CREATE:
--     CREATE DATABASE … CLONE
--     CREATE SCHEMA … CLONE
--     CREATE TABLE … CLONE
--     CREATE TABLE … AS SELECT

-- Set context
use role instructor1_policy_admin;
use warehouse INSTRUCTOR1_wh;

-- Use Case 1: Data governor wants to view all non-SELECT statements against specific TAX_DB.TAXSCHEMA tables
select ah.object_name
,      ah.user_name
,      qh.role_name
,      qh.warehouse_name
,      to_char(ah.query_start_time,'DD-Mon-YYYY') as query_start_date
,      qh.query_text
from INSTRUCTOR1_ahist_common.views.base_object_access_history ah
,    snowflake.account_usage.query_history qh
where ah.query_id      = qh.query_id
and   ah.object_type   = 'TABLE'
and   ah.database_name = 'INSTRUCTOR1_TAX_DB'
and   ah.schema_name   = 'TAXSCHEMA'
and   ah.object_name in ('TAXPAYER','TAXPAYER_DEPENDENTS','TAXPAYER_WAGES')
and   qh.query_text not ilike 'SELECT%'
order by ah.query_start_time;

-- Use Case 2: Data governor wants to identify the stage from which data was *LOADED* to the TAXPAYER table
select
    r.value:"objectName"::string as source_name,
    r.value:"objectDomain"::string as source_domain,
    w.value:"objectName"::string as target_name, 
    w.value:"objectDomain"::string as target_domain
from 
    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
    lateral flatten(input => t.OBJECTS_MODIFIED) w
where target_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER' and target_domain = 'Table' and source_domain = 'Stage'
group by 1,2,3,4;

-- Use Case 3: Data governor wants to identify the stage from which data was *UNLOADED* from the TAXPAYER table
select
    r.value:"objectName"::string as source_name,
    r.value:"objectDomain"::string as source_domain,
    w.value:"objectName"::string as target_name, 
    w.value:"objectDomain"::string as target_domain
from 
    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
    lateral flatten(input => t.OBJECTS_MODIFIED) w
where source_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER' and target_domain = 'Stage' and source_domain = 'Table'
group by 1,2,3,4;

-- Use Case 4:  Data governor wants to identify the source table of data to TAXPAYER_CPY
select
    r.value:"objectName"::string as source_name,
    r.value:"objectDomain"::string as source_domain,
    w.value:"objectName"::string as target_name, 
    w.value:"objectDomain"::string as target_domain
from 
    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
    lateral flatten(input => t.OBJECTS_MODIFIED) w
where target_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER_CPY' and target_domain = 'Table'
group by 1,2,3,4;

-- Use Case 5: Data governor wants to identify the source of data to the TAXPAYER table
select
    r.value:"objectName"::string as source_name,
    r.value:"objectDomain"::string as source_domain,
    w.value:"objectName"::string as target_name, 
    w.value:"objectDomain"::string as target_domain
from 
    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
    lateral flatten(input => t.OBJECTS_MODIFIED) w
where target_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER' and target_domain = 'Table'
group by 1,2,3,4;

-- NOTE: For Use Case 6, the data governor wants to identify the forward lineage of TAXPAYER 
-- (i.e., to identify the target object to which data flows, such as a table or stage).

--Use Case 6: Data governor wants to identify the stage to which data is copied or unloaded from TAXPAYER
select
    r.value:"objectName"::string as source_name,
    r.value:"objectDomain"::string as source_domain,
    w.value:"objectName"::string as target_name, 
    w.value:"objectDomain"::string as target_domain
from 
    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
    lateral flatten(input => t.OBJECTS_MODIFIED) w
where source_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXPAYER' and source_domain = 'Table' and target_domain in ('Table','Stage')
group by 1,2,3,4;

-- NOTE: For Use Case 7, we construct a query using a CTE on Access History for a data governor 
-- who wants to trace the end-to-end flow of sensitive data from TAXDATA_STAGE.

-- Use Case 7: Data governor wants to identify the end-to-end flow of sensitive data from TAXDATA_STAGE
-- NOTE: Runs for 3 min using Large WH

-- Resize WH
use role sysadmin;
alter warehouse instructor1_wh set warehouse_size=xlarge;

use role instructor1_policy_admin;

with access_history_flatten as (
                select
                    r.value:"objectId" as source_id,
                    r.value:"objectName" as source_name,
                    r.value:"objectDomain" as source_domain,
                    w.value:"objectId" as target_id, 
                    w.value:"objectName" as target_name, 
                    w.value:"objectDomain" as target_domain, 
                    c.value:"columnName" as target_column,
                    t.query_start_time as query_start_time
                from 
                    (select * from SNOWFLAKE.ACCOUNT_USAGE.ACCESS_HISTORY) t, 
                    lateral flatten(input => t.BASE_OBJECTS_ACCESSED) r, 
                    lateral flatten(input => t.OBJECTS_MODIFIED) w,
                    lateral flatten(input => w.value:"columns", outer => true) c
                    ),
    sensitive_data_movements(path, target_id, target_name, target_domain, target_column, query_start_time) 
    as 
      -- Common Table Expression
      (
        -- Anchor Clause
        select
            split_part(f.source_name, '.', 3) || '-->' || split_part(f.target_name, '.',  3) as path,
            f.target_id, 
            f.target_name, 
            f.target_domain,
            f.target_column,
            f.query_start_time
        from 
            access_history_flatten f
        where 
        f.source_domain = 'Stage' 
        and f.source_name = 'INSTRUCTOR1_TAX_DB.TAXSCHEMA.TAXDATA_STAGE'
        and f.query_start_time >= '2022-04-19 12:00:00'

        union all

        -- Recursive Clause
        select sensitive_data_movements.path || '-->' || split_part(f.target_name, '.',  3) as path, f.target_id, f.target_name, f.target_domain, f.target_column, f.query_start_time
          from  
             access_history_flatten f 
            join sensitive_data_movements
            on f.source_id = sensitive_data_movements.target_id 
                and f.source_domain = sensitive_data_movements.target_domain 
                and f.query_start_time >= sensitive_data_movements.query_start_time
      )
select path, target_name::string as target_name, target_domain::string as target_domain, array_agg(distinct target_column) as target_columns
from sensitive_data_movements 
group by path, target_id, target_name, target_domain
order by target_domain desc, path asc;

-- Resize WH
use role sysadmin;
alter warehouse instructor1_wh set warehouse_size=xsmall;
