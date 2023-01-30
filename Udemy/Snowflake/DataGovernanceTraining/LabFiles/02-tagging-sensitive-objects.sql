
-- 2.0.0   TAGGING SENSITIVE OBJECTS
--         Tags enable data stewards to track sensitive data for compliance,
--         discovery, protection, and resource usage.
--         In this lab exercise, the POLICY_ADMIN role creates a library of tags
--         in the centralized database schema TAG_LIBRARY. This approach can
--         simplify maintaining a centralized taxonomy of tags that can be
--         applied to objects across an account.
--         - Produce a library of object tags based on objects defined as
--         sensitive in the organization.
--         - Modify sensitive tables to assign table- and column-level tags.
--         - Show the tags assigned to tables and columns in a specific
--         database.
--         This lab exercise assumes that the teams in your organization
--         responsible for data governance (typically the policy administrators
--         and/or possibly other teams) have previously gone through the process
--         of classifying which TAXSCHEMA objects and columns are sensitive, as
--         well as the appropriate classification level for each.

-- 2.1.0   Establish a Library of Object Tags
--         Begin by setting your context.

USE ROLE LEOPARD_policy_admin;
USE SCHEMA LEOPARD_tag_db.tag_library;
USE WAREHOUSE LEOPARD_wh;

--         You are starting without any tags or objects in the library.
--         Initial, Empty Tag Library

-- 2.1.1   Create a library of object tags.
--         Create the tags.
--         Tag Types for TAXSCHEMA

CREATE or REPLACE tag confidentiality;
CREATE or REPLACE tag pii_type; -- Personally Identifiable Information (PII)
CREATE or REPLACE tag spi_type; -- Sensitive Personal Information (SPI)

--         Use the COMMENT field for the tag to describe its usage on sensitive
--         data.

ALTER TAG LEOPARD_tag_db.tag_library.confidentiality
  set comment = "Tag tables or views with confidential information with the following values: Highly Sensitive, Sensitive, Confidential";
ALTER TAG LEOPARD_tag_db.tag_library.pii_type
  set comment = "Tag columns as PII with corresponding values: Taxpayer ID, Email, Phone number, etc.";
ALTER TAG LEOPARD_tag_db.tag_library.spi_type
  set comment = "Tag columns as SPI with corresponding values: data that has critical business or usage sensitivity but is not PII";

--         There is an alternate, decentralized approach to tag management. With
--         decentralized tag management, you would allow the object owner of the
--         database/schema (such as TRAINING_ROLE as the owner of TAXSCHEMA) to
--         set or remove tags. These steps are NOT required for each database or
--         schema if you are planning to use a centralized tag administration
--         model, in which the POLICY_ADMIN role applies all tags.

-- 2.2.0   Assign Tags to Tables
--         As POLICY_ADMIN, you will tag the TAX_DB.TAXSCHEMA tables TAXPAYER,
--         TAXPAYER_DEPENDENTS, and TAXPAYER_WAGES along with their associated
--         sensitive columns.

-- 2.2.1   Assign tags to the taxpayer tables.
--         Assign confidentiality tags to the TAX_DB.TAXSCHEMA tables.
--         Confidentiality Tag Assignments
--         The three ALTER TABLE commands below require the POLICY_ADMIN role to
--         have already been granted the account-level privilege APPLY TAG ON
--         ACCOUNT, otherwise these statements will fail.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  set tag LEOPARD_tag_db.tag_library.confidentiality="Highly Sensitive";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  set tag LEOPARD_tag_db.tag_library.confidentiality="Sensitive";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages
  set tag LEOPARD_tag_db.tag_library.confidentiality="Confidential";


-- 2.2.2   Assign Personally Identifiable Information (PII) tags.
--         Assign the PII tag of Taxpayer ID to the taxpayer_id columns in all
--         three tables.
--         PII Tag Taxpayer_Id Assigned

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify taxpayer_id set tag LEOPARD_tag_db.tag_library.pii_type="Taxpayer ID";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify taxpayer_id set tag LEOPARD_tag_db.tag_library.pii_type="Taxpayer ID";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages
  modify taxpayer_id set tag LEOPARD_tag_db.tag_library.pii_type="Taxpayer ID";

--         Assign PII tags that are common to both the TAXPAYER and
--         TAXPAYER_DEPENDENTS tables.
--         Additional PII Tags Assigned to Taxpayer and Taxpayer_Dependents
--         Tables

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify home_phone set tag LEOPARD_tag_db.tag_library.pii_type="Home Phone";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_home_phone set tag LEOPARD_tag_db.tag_library.pii_type="Home Phone";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify cell_phone set tag LEOPARD_tag_db.tag_library.pii_type="Cell Phone";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_cell_phone set tag LEOPARD_tag_db.tag_library.pii_type="Cell Phone";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify email set tag LEOPARD_tag_db.tag_library.pii_type="Email";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_email set tag LEOPARD_tag_db.tag_library.pii_type="Email";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify lastname set tag LEOPARD_tag_db.tag_library.pii_type="Last Name";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_lastname set tag LEOPARD_tag_db.tag_library.pii_type="Last Name";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify firstname set tag LEOPARD_tag_db.tag_library.pii_type="First Name";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_firstname set tag LEOPARD_tag_db.tag_library.pii_type="First Name";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify birthdate set tag LEOPARD_tag_db.tag_library.pii_type="Birth Date";
ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_birthdate set tag LEOPARD_tag_db.tag_library.pii_type="Birth Date";

--         Assign PII tags exclusive to just the TAXPAYER table.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify corp_taxpayer_name set tag LEOPARD_tag_db.tag_library.pii_type="Corp Taxpayer Name";

--         Assign PII tags exclusive to just the TAXPAYER_DEPENDENTS table.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dependent_ssn set tag LEOPARD_tag_db.tag_library.pii_type="Dependent SSN";


-- 2.2.3   Assign Sensitive Personal Information (SPI) tags.
--         Assign SPI tags to columns that are classified as SPI in the tables
--         TAXPAYER and TAXPAYER_DEPENDENTS.
--         SPI Tags Assigned to Taxpayer and Taxpayer_Dependents Tables
--         Several columns you will tag are clearly not sensitive, such as
--         Street, City, and Nbr_exemptions. This is done so that you can see in
--         a later lab how to audit tagged columns that do not have assigned
--         masking policies. This will enable you to determine whether a column
--         is not masked due to an error in applying a masking policy or due to
--         a column having been incorrectly tagged as sensitive.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify street set tag LEOPARD_tag_db.tag_library.spi_type="Street";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify city set tag LEOPARD_tag_db.tag_library.spi_type="City";  

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer
  modify nbr_exemptions set tag LEOPARD_tag_db.tag_library.spi_type="Number of Exemptions";  

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_dependents
  modify dep_city set tag LEOPARD_tag_db.tag_library.spi_type="City";

--         Assign SPI tags to columns that are classified as SPI in the
--         TAXPAYER_WAGES table.

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify tax_year
  set tag LEOPARD_tag_db.tag_library.spi_type="Tax Year";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify w2_total_income
  set tag LEOPARD_tag_db.tag_library.spi_type="W2 Total Income";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify adj_gross_income
  set tag LEOPARD_tag_db.tag_library.spi_type="Adj Gross Income";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify taxable_income
  set tag LEOPARD_tag_db.tag_library.spi_type="Taxable Income";

ALTER TABLE LEOPARD_tax_db.taxschema.taxpayer_wages modify total_federal_tax
  set tag LEOPARD_tag_db.tag_library.spi_type="Total Federal Tax";


-- 2.3.0   Track the Assigned Table and Column Tags
--         You have created a library of object tags and assigned those tags to
--         your TAXPAYER, TAXPAYER_DEPENDENTS and TAXPAYER_WAGES tables.
--         You can track tag usage through: * Two different Account Usage views
--         * Two Information Schema table functions * An Account Usage table
--         function * A system function
--         It can be helpful to think of two general approaches to determine how
--         to track tag usage: * Discover or list tags * Discover tags in your
--         account using the view SNOWFLAKE.ACCOUNT_USAGE.TAGS (which has
--         latency and will be queried in upcoming exercises) * Find value for a
--         given tag using SYSTEM$GET_TAG system function * ** Identify
--         assignments (in other words, references) between a tag and an
--         object**: Snowflake supports different options to identify tag
--         assignments, depending on whether the query needs to target the
--         account or a specific database, and whether tag lineage is necessary.
--         * Account-level with lineage using
--         SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES_WITH_LINEAGE * Account-level
--         without lineage using SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES. Note
--         that SNOWFLAKE.ACCOUNT_USAGE views have a 2-hour latency associated
--         with them. You will run audit queries in an upcoming lab exercise
--         after the 2-hour latency time period has been met. * Database-level
--         with lineage using INFORMATION_SCHEMA.TAG_REFERENCES * Database-level
--         for all tags on every columns with lineage using
--         INFORMATION_SHCEMA.TAG_REFERENCES_ALL_COLUMNS
--         :::
--         Tags Assigned in Taxschema

-- 2.4.0   Discover or List Tags

-- 2.4.1   Identify a value for a given tag using a native Snowflake function.
--         Use the native Snowflake function SYSTEM$GET_TAG to list values for
--         different tags.

SELECT SYSTEM$GET_TAG('confidentiality', 'LEOPARD_tax_db.taxschema.taxpayer', 'table');
SELECT SYSTEM$GET_TAG('confidentiality', 'LEOPARD_tax_db.taxschema.taxpayer_dependents', 'table');
SELECT SYSTEM$GET_TAG('confidentiality', 'LEOPARD_tax_db.taxschema.taxpayer_wages', 'table');


-- 2.4.2   List the tags in your tag library schema.

SHOW TAGS IN SCHEMA LEOPARD_tag_db.tag_library;


-- 2.5.0   Identify Tag and Value Assignments on a Table, with Tag Lineage
--         Query the INFORMATION_SCHEMA in your TAG_DB database to return tag
--         names and tag values associated with an object (such as tags on a
--         table, view, or column), with tag lineage. The tag lineage
--         additionally lists tags that are inherited by an object that are
--         higher in its object hierarchy. For example, the columns of a table
--         inherit a tag that is set on that table.

-- 2.5.1   Use the database-level query to view any tags with lineage associated
--         with the table LEOPARD_tax_db.taxschema.taxpayer.

-- This command returns the tag and tag value associated with the TAXPAYER
-- table. It also returns the object hierarchy of the TAXPAYER table, as well
-- as the tag database and schema containing the tag. In this case, there is
-- one tag set on the table, and no tags set on the schema or database
-- containing the table.
SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references
   ('LEOPARD_tax_db.taxschema.taxpayer', 'TABLE'));


-- 2.5.2   View the tags associated with the table
--         LEOPARD_tax_db.taxschema.taxpayer_dependents.

SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references
   ('LEOPARD_tax_db.taxschema.taxpayer_dependents', 'TABLE'));


-- 2.5.3   View the tags associated with the table
--         LEOPARD_tax_db.taxschema.taxpayer_wages.

SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references
   ('LEOPARD_tax_db.taxschema.taxpayer_wages', 'TABLE'));


-- 2.6.0   Identify Tag and Value Assignments on Every Column, with Tag Lineage

-- 2.6.1   Use this database-level query to view the list of tags that are
--         assigned to every column in the table
--         LEOPARD_tax_db.taxschema.taxpayer.

SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references_all_columns
   ('LEOPARD_tax_db.taxschema.taxpayer', 'TABLE'));

--         ### View the list of tags that are assigned to every column in the
--         table LEOPARD_tax_db.taxschema.taxpayer_dependents.

SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references_all_columns
   ('LEOPARD_tax_db.taxschema.taxpayer_dependents', 'TABLE'));


-- 2.6.2   View the list of tags that are assigned to every column in the table
--         LEOPARD_tax_db.taxschema.taxpayer_wages.

SELECT *
   FROM table(LEOPARD_tag_db.information_schema.tag_references_all_columns
   ('LEOPARD_tax_db.taxschema.taxpayer_wages', 'TABLE'));

