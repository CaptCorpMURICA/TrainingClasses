-- Demo: Modifying Data Classification Privacy Categories
-- Last updated: 23OCT2022

-- In certain situations you might want to apply your own tags once
-- analysis has been completed on a table, or change what Snowflake has
-- generated before applying. In these instances you can create a table
-- to hold the extract analysis, and modify it as needed, before
-- applying.

-- Here's an example of how to go about this:

create or replace table classification_results(v variant) as
  select extract_semantic_categories( 'customer_classified');

--         Review the output

select * from classification_results;

-- In a structured format, review the single column, C_LAST_NAME, we are
-- interested in overriding the automatic classification categorization
-- for:

select
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  from
  table(flatten(select * from classification_results)) as f
  where column_name = 'C_LAST_NAME'
  order by column_name;
  
-- Suppose we wanted to modify the privacy category for the C_LAST_NAME
-- column, taking it from IDENTIFIER to QUASI_IDENTIFIER. We can update
-- the classification extract results in place in our intermediary
-- table:

update classification_results set v =
    object_insert(v,'C_LAST_NAME',object_insert(
        object_insert(v:C_LAST_NAME,'semantic_category','NAME',true),
        'privacy_category','QUASI_IDENTIFIER',true),
        true
        );

-- Now review the privacy category for the C_LAST_NAME column in our
-- intermediary table, to confirm it is set as QUASI_IDENTIFIER:

select
    f.key::varchar as column_name,
    f.value:"privacy_category"::varchar as privacy_category,
    f.value:"semantic_category"::varchar as semantic_category,
    f.value:"extra_info":"probability"::number(10,2) as probability,
    f.value:"extra_info":"alternates"::variant as alternates
  from
  table(flatten(select * from classification_results)) as f
  where column_name = 'C_LAST_NAME';

-- Then re-apply the updated tags (for all tags) to our table, from the
-- intermediary table:

call associate_semantic_category_tags('customer_classified',
    (select * from classification_results));
    
