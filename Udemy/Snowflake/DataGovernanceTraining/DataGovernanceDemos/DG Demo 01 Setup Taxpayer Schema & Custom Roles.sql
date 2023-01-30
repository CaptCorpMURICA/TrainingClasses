-- Setup Taxpayer Schema & Custom Roles (for Tagging, Row Access Policies, Data Masking, & Access History demos)
-- Version: 1.19
-- Last updated: 12AUG2022
 
-- Cleanup custom roles from prior demo delivery
use role securityadmin;

drop role if exists INSTRUCTOR1_taxdata_steward;
drop role if exists INSTRUCTOR1_tax_executive;
drop role if exists INSTRUCTOR1_tax_sranalyst_corp;
drop role if exists INSTRUCTOR1_tax_jranalyst_corp;
drop role if exists INSTRUCTOR1_tax_sranalyst_indiv;
drop role if exists INSTRUCTOR1_tax_jranalyst_indiv;
drop role if exists INSTRUCTOR1_tax_user_east;
drop role if exists INSTRUCTOR1_tax_user_central;
drop role if exists INSTRUCTOR1_tax_user_west;
drop role if exists INSTRUCTOR1_policy_admin;

-- Create warehouse to use for demos
use role sysadmin;

create warehouse if not exists INSTRUCTOR1_wh warehouse_size=xsmall;
use warehouse INSTRUCTOR1_wh;
grant usage on warehouse INSTRUCTOR1_wh to public;

-- Create tagging database TAG_DB & schema TAG_LIBRARY (to be used to store all tags in account)
drop database if exists INSTRUCTOR1_tag_db;
create database INSTRUCTOR1_tag_db;
create schema INSTRUCTOR1_tag_db.tag_library;

grant usage on database INSTRUCTOR1_tag_db to sysadmin;
grant usage on schema INSTRUCTOR1_tag_db.tag_library to role sysadmin;

-- Create TAX_DB database & TAXSCHEMA schema
drop database if exists INSTRUCTOR1_tax_db;
create database if not exists INSTRUCTOR1_tax_db;
create schema INSTRUCTOR1_tax_db.taxschema;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Create TAX_DB.TAXSCHEMA tables

create or replace table taxpayer
(
  taxpayer_id varchar(9),
  filing_status varchar(1),
  nbr_exemptions number(2,0),
  lastname varchar(30),
  firstname varchar(30),
  street varchar(30),
  city varchar(20),
  state varchar(2),
  zip number(9,0),
  home_phone number(10,0),
  cell_phone number(10,0),
  email varchar(40),
  birthdate date,
  taxpayer_type varchar(30),
  corp_taxpayer_name varchar(50),
  corp_taxpayer_effective_tax_rate_pct number
);

create or replace table taxpayer_dependents 
(
  dependent_ssn varchar(9),
  taxpayer_id varchar(9),
  dep_relationship varchar(10),
  dep_lastname varchar(30),
  dep_firstname varchar(30),
  dep_city varchar(30),
  dep_state varchar(2),
  dep_zipcode number(9,0),
  dep_home_phone number(10,0),
  dep_cell_phone number(10,0),
  dep_email varchar(40),
  dep_taxpayer_type varchar(30),
  dep_birthdate date
);

create or replace table taxpayer_wages 
(
  taxpayer_id varchar(9) not null,
  taxpayer_type varchar(30) not null,
  state varchar(2) not null,
  tax_year number(4,0) not null, 
  w2_total_income number not null,
  adj_gross_income number(12,0) not null, 
  taxable_income number(12,0) not null, 
  total_federal_tax number(12,0) not null
);

-- Create mapping tables for use with row access policy

create table tax_mapping (
  taxuser_role varchar(50),
  taxpayer_type varchar(30)
);

create table taxuser_mapping (
  taxuser_role varchar(50),
  taxpayer_state varchar(30)
);

-- Truncate all tables only if you need to reload data

use role sysadmin;
use schema INSTRUCTOR1_tax_db.taxschema;

truncate table if exists taxpayer;
truncate table if exists taxpayer_dependents;
truncate table if exists taxpayer_wages;
truncate table if exists tax_mapping;
truncate table if exists taxuser_mapping;

-- Create taxdata_steward role (which has ownership of all tax data)
USE ROLE securityadmin;
drop role if exists INSTRUCTOR1_taxdata_steward; 
CREATE ROLE INSTRUCTOR1_taxdata_steward;

GRANT all on database INSTRUCTOR1_tax_db to role INSTRUCTOR1_taxdata_steward;
GRANT all on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_taxdata_steward;
grant imported privileges on database snowflake to role INSTRUCTOR1_taxdata_steward; -- Ensures that TAXDATA_STEWARD is able to audit policies and their usage

-- GRANT SELECT, INSERT, UPDATE, DELETE, TRUNCATE on all tables in schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_taxdata_steward;
GRANT ALL on all tables in schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_taxdata_steward;

-- Grant on future tables is needed, since at least one table gets created when building the query and DML load
GRANT ALL on future tables in schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_taxdata_steward;

-- Grant taxdata_steward role to user INSTRUCTOR1.
GRANT ROLE INSTRUCTOR1_taxdata_steward to user INSTRUCTOR1;

-- As taxdata_steward,load all tax data

use role instructor1_taxdata_steward;
use schema INSTRUCTOR1_tax_db.taxschema;

-- Load data into mapping tables
insert into tax_mapping
values 
('INSTRUCTOR1_TAX_SRANALYST_CORP','Corporate'),
('INSTRUCTOR1_TAX_JRANALYST_CORP','Corporate'),
('INSTRUCTOR1_TAX_SRANALYST_INDIV', 'Individual'),
('INSTRUCTOR1_TAX_JRANALYST_INDIV', 'Individual'),
('INSTRUCTOR1_TAX_EXECUTIVE', 'Corporate'),
('INSTRUCTOR1_TAX_EXECUTIVE', 'Individual'),
('INSTRUCTOR1_TAXDATA_STEWARD', 'Corporate'),
('INSTRUCTOR1_TAXDATA_STEWARD', 'Individual');

insert into taxuser_mapping
values 
('INSTRUCTOR1_TAX_USER_EAST','FL'),
('INSTRUCTOR1_TAX_USER_EAST','SC'),
('INSTRUCTOR1_TAX_USER_EAST','NJ'),
('INSTRUCTOR1_TAX_USER_EAST','NY'),
('INSTRUCTOR1_TAX_USER_EAST','ME'),
('INSTRUCTOR1_TAX_USER_EAST','OH'),
('INSTRUCTOR1_TAX_USER_EAST','WV'),
('INSTRUCTOR1_TAX_USER_CENTRAL','IL'),
('INSTRUCTOR1_TAX_USER_CENTRAL','TX'),
('INSTRUCTOR1_TAX_USER_CENTRAL','IA'),
('INSTRUCTOR1_TAX_USER_CENTRAL','KY'),
('INSTRUCTOR1_TAX_USER_CENTRAL','TN'),
('INSTRUCTOR1_TAX_USER_CENTRAL','OK'),
('INSTRUCTOR1_TAX_USER_CENTRAL','KS'),
('INSTRUCTOR1_TAX_USER_WEST','CA'),
('INSTRUCTOR1_TAX_USER_WEST','CO'),
('INSTRUCTOR1_TAX_USER_WEST','NM'),
('INSTRUCTOR1_TAX_USER_WEST','MT'),
('INSTRUCTOR1_TAX_USER_WEST','OR'),
('INSTRUCTOR1_TAX_USER_WEST','WA'),
('INSTRUCTOR1_TAX_USER_WEST','ID'),
('INSTRUCTOR1_TAX_USER_WEST','UT'),
('INSTRUCTOR1_TAX_USER_WEST','NV'),
('INSTRUCTOR1_TAX_USER_WEST','AZ');

-- Load data into taxpayer table
insert into taxpayer values
(123456789,'S',0,'Smith','Margie','345 Maple St','Houston','TX',78909,
7007869087,7007869234,'msmith@test.com','09-APR-1965','Individual',null,null),
(678465237,'M',2,'Bredsguard','Stanley','1313 Montrose Ave','Chicago','IL',60625,
3124567899,312453882,'stan@zzz.com','11-DEC-1976','Individual',null,null),
(345117826,'M',2,'Moe','Arnold','6366 Milwaukee Ave','San Diego','CA',23596,
2134457219,2136628174,'moea@z121.com','26-SEP-1955','Individual',null,null),
(985207742,'M',3,'Bradford','Reed','23 9th St','Provo','UT',84652,
8012361189,8013682956,'refinersfire@bbb.com','09-APR-1949','Individual',null,null),
(237812332,'D',3,'Simpson','Larry','1462 Baker Blvd','Torrance','CA',86798,
7145657889,7142237766,'lsimpson@geek.com','11-JAN-1970','Individual',null,null),
(873554189,'M',2,'Kirby','Helen','10 Willow Dr','Kankakee','IL',65234,
3478904432,3478904432,'kirby@abcd.com','01-NOV-1956','Individual',null,null),
(907872319,'S',1,'Wellberger','Peter','144 Stevens St','Las Vegas','NV',87231,
6523490871,6524453219,'wellberger@redsa.com','04-JUN-1965','Individual',null,null),
(734638955,'M',3,'Broussard','Kim','1910 State Ave','Argyle','OR',33278,
972351199,9722267234,'kimb@corn.com','11-MAY-1957','Individual',null,null),
(234893277,'M',2,'White','Walter','308 Negra Arroyo Ln','Tucson','AZ',78556,
5052348644,5056712381,'heisenberg@abcd.com','30-JUN-1950','Individual',null,null),
(349070043,'S',1,'Williams','Bob','3790 N Temple','Salt Lake City','UT',89767,
8019074197,8013221885,'bwilliams@slc.com','23-MAR-1971','Individual',null,null),
(991001,'C',null,null,null,'33 West Latham St','Jopler','SC',12117,
null,null,null,null,'Corporate','XYZ Electronics',12),
(991002,'C',null,null,null,'6366 N Milwaukee Ave','Cairo','IL',98709,
null,null,null,null,'Corporate','Cakes Inc',18),
(991003,'C',null,null,null,'9456 W Torrance Blvd','Torrance','CA',94291,
null,null,null,null,'Corporate','Rockwell Autonetics',12),
(991004,'C',null,null,null,'7725 W El Segundo Blvd','El Segundo','CA',90870,
null,null,null,null,'Corporate','Northland Aerospace',12),
(991005,'C',null,null,null,'12 Century Rd','Parowan','NJ',02301,
null,null,null,null,'Corporate','Citilake Inc',12),
(991006,'C',null,null,null,'900 Potrero Hill Ave','San Francisco','CA',90234,
null,null,null,null,'Corporate','Consumer Recreation Services',10),
(991007,'C',null,null,null,'900 N Juniper St','New York','NY',86109,
null,null,null,null,'Corporate','Masura Advanced Supplies',12),
(991008,'C',null,null,null,'4800 N Western Ave','Chicago','IL',84333,
null,null,null,null,'Corporate','Pizza Strada',15),
(991009,'C',null,null,null,'100 W Temple St','Salt Lake City','UT',87609,
null,null,null,null,'Corporate','Furniture Plus',19),
(991010,'C',null,null,null,'600 W Addison St','Tempe','AZ',98076,
null,null,null,null,'Corporate','Letterby Books',20),
(991011,'C',null,null,null,'1890 Landerbury Rd','Meridian','ID',83713,
null,null,null,null,'Corporate','Beckman Tools',16),
(991012,'C',null,null,null,'12 Limerick Dr','Las Vegas','NV',87609,
null,null,null,null,'Corporate','Denehill Publishing',14),
(991013,'C',null,null,null,'6366 W Division St','Rosemead','FL',13608,
null,null,null,null,'Corporate','Western Wear',17),
(991014,'C',null,null,null,'1000 Riverdale Ave','Seattle','WA',92650,
null,null,null,null,'Corporate','Sanderson Manufacturing',21),
(991015,'C',null,null,null,'2381 S Cicero Ave','Bartlesville','OK',64458,
null,null,null,null,'Corporate','Greenblatt Auto Supply',18),
(991015,'C',null,null,null,'102 Baker St','New Port Richey','FL',32411,
null,null,null,null,'Corporate','Richardson Autos',13),
(991015,'C',null,null,null,'1313 Mockingbird Ln','Larrabee','IA',68932,
null,null,null,null,'Corporate','Summerfield Land Company',20),
(991015,'C',null,null,null,'7275 Lamoner Rd','El Paso','TX',82280,
null,null,null,null,'Corporate','Aerospace Corporation',23),
(991015,'C',null,null,null,'5200 W Wilson Dr','Columbus','OH',23900,
null,null,null,null,'Corporate','Pioter Financial',14),
(991015,'C',null,null,null,'2030 Wilmington Blvd','Nashville','TN',34811,
null,null,null,null,'Corporate','Millard Mining Company',20),
(991015,'C',null,null,null,'78 Hinckley Dr','Overland','KS',72899,
null,null,null,null,'Corporate','Stanfield Lumber',16),
(991015,'C',null,null,null,'1231 Burkett Ave','Joliet','IL',60671,
null,null,null,null,'Corporate','Tucker Aviation',23);

-- Load data into taxpayer_dependents table
insert into taxpayer_dependents values 
(123456798,678465237,'Spouse','Bredsguard','Patricia','Zimmerman','NJ',01692, 
3124345899,3124479072,'debbieb@lazoo.com','Individual','27-FEB-1979'),
(332129001,678465237,'Daughter','Bredsguard','Rhonda','Chicago','IL',60625,
3124345899,323212780,'rhondac@ysnq.com','Individual','01-DEC-1991'),
(332789123,678465237,'Daughter','Bredsguard','Rebecca','Chicago','IL',60625,
3124345899,323212782,'bredsgr@aszoo.com','Individual','27-FEB-1990'),
(390700095,345117826,'Spouse','Moe','Cynthia','San Diego','CA',23596,
2134457219,2132180095,'moec@zxcv.com','Individual','02-SEP-1967'),
(334721199,345117826,'Son','Moe','Thomas','Clemons','NJ',01694,
2134457219,2132180088,'moet@mnj.com','Individual','02-SEP-1988'),
(334789220,345117826,'Daughter','Moe','Sylvia','San Diego','CA',23596,
2134457219,2136677211,'sylviam@otewq.com','Individual','11-DEC-1992'),
(991781002,985207742,'Spouse','Bradford','Doris','Provo','UT',84652,
8012361189,8012328771,'dbradford@mnq.com','Individual','31-OCT-1956'),
(443891055,985207742,'Son','Bradford','Kenneth','Provo','UT',84652,
8012361189,8015431125,'kbradford@snq.com','Individual','31-OCT-1996'),
(441556923,985207742,'Son','Bradford','Jordan','Provo','UT',84652,
8012361189,8019344279,'jbradford@mm1nq.com','Individual','31-OCT-1992'),
(551511899,237812332,'Son','Simpson','Kevin','Torrance','CA',86798,
7145657889,7142237790,'kevsimp@sdfg.com','Individual','19-JUL-1985'),
(112932783,237812332,'Spouse','Simpson','Stacy','Timmons','IA',30798,
7145657889,7143458124,'stacys@lodq.com','Individual','01-JUL-1950'),
(349548814,237812332,'Daughter','Simpson','Denell','Torrance','CA',86798,
7145657889,7144552311,'denell@jsp.com','Individual','01-JUL-1983'),
(231458895,873554189,'Spouse','Kirby','Matthew','Danville','IL',65234,
3478904432,3471125628,'kirbym@wert.com','Individual','15-SEP-1965'),
(775623119,873554189,'Son','Kirby','Lawrence','Danville','IL',65234,
3478904432,3259856623,'lawrencek@snz.com','Individual','05-MAR-1993'),
(775846650,873554189,'Son','Kirby','Alan','Danville','IL',65234,
3478904432,3259233576,'akirby@msn.com','Individual','31-MAY-1994'),
(907272314,907872319,'Daughter','Wellberger','Sandra','Las Vegas','NV',87231,
6523490871,6523468201,'wells@axoo.com','Individual','04-JUN-1985'),
(676534239,734638955,'Spouse','Broussard','Dillon','Gatlin','NB',33278,
972351199,9724345447,'broussardd@orb.com','Individual','03-AUG-1964'),
(223441000,234893277,'Spouse','White','Skyler','Albuquerque','NM',78556,
5052348644,5052212672,'skylerw@orb.com','Individual','02-APR-1959'),
(998700222,349070043,'Spouse','Williams','Yvonne','Salt Lake City','UT',89767,
8019074197,8016233445,'ywilliams12@slc.com','Individual','16-JUN-1974'),
(443233887,349070043,'Daughter','Williams','Denise','Salt Lake City','UT',89767,
8019074197,8012278550,'dwilliams12@wert.com','Individual','28-OCT-1993');

-- Load data into taxpayer_wages table
insert into taxpayer_wages values 
(123456789,'Individual','TX',2018,104990,97250,89730,80900),
(123456789,'Individual','TX',2019,113400,101200,90650,89500),
(123456789,'Individual','TX',2020,103200,99870,75298,70925),
(234893277,'Individual','CA',2018,250900,180400,120000,111235),
(234893277,'Individual','CA',2019,160780,150668,100300,98700),
(234893277,'Individual','CA',2020,200600,172400,145900,136783),
(237812332,'Individual','FL',2018,120678,118500,109720,109210),
(237812332,'Individual','FL',2019,190700,175600,168923,158820),
(237812332,'Individual','FL',2020,89400,81000,75600,74577),
(345117826,'Individual','OH',2018,110678,109400,105000,98750),
(345117826,'Individual','OH',2019,150600,147200,130649,127788),
(345117826,'Individual','OH',2020,280900,250320,210100,209855),
(349070043,'Individual','UT',2018,90870,88730,87200,85590),
(349070043,'Individual','UT',2019,65100,60760,60411,55750),
(349070043,'Individual','UT',2020,95700,93100,89500,84120),
(678465237,'Individual','NY',2018,110560,108920,103745,103745),
(678465237,'Individual','NY',2019,189700,185690,180003,178600),
(678465237,'Individual','NY',2020,101337,96711,94350,92800),
(734638955,'Individual','ID',2018,116890,111256,107562,106980),
(734638955,'Individual','ID',2019,100577,99300,94368,90800),
(734638955,'Individual','ID',2020,101100,100700,99910,88504),
(873554189,'Individual','IA',2018,140900,138725,133960,129780),
(873554189,'Individual','IA',2019,125790,113449,110200,109800),
(873554189,'Individual','IA',2020,101100,100700,99910,89504),
(907872319,'Individual','TN',2018,350670,337800,334950,296500),
(907872319,'Individual','TN',2019,375900,369108,358600,339875),
(907872319,'Individual','TN',2020,460700,437120,425700,419762),
(985207742,'Individual','ME',2018,120900,118600,115650,113820),
(985207742,'Individual','ME',2019,689400,655000,603118,602880),
(985207742,'Individual','ME',2020,575670,572100,560900,560920);

-- Verify that the data has been successfully loaded into the tables

select * from tax_mapping; -- 8 rows
select * from taxuser_mapping; -- 24 rows
select * from taxpayer where upper(taxpayer_type)='INDIVIDUAL'; -- 10 rows
select * from taxpayer where upper(taxpayer_type)='CORPORATE'; -- 22 rows
select * from taxpayer_dependents; -- 20 rows
select * from taxpayer_wages; -- 30 rows

-- Create custom roles to be used for the row access policies & data masking demos

use role securityadmin;

create role INSTRUCTOR1_tax_executive;
create role INSTRUCTOR1_tax_sranalyst_corp;
create role INSTRUCTOR1_tax_jranalyst_corp;
create role INSTRUCTOR1_tax_sranalyst_indiv;
create role INSTRUCTOR1_tax_jranalyst_indiv;
create role INSTRUCTOR1_tax_user_east;
create role INSTRUCTOR1_tax_user_central;
create role INSTRUCTOR1_tax_user_west;

-- Grant all custom roles to user INSTRUCTOR1
-- Note: If using a username other than INSTRUCTOR1, be sure to change 
-- these grants to the username you're logged in as
grant role INSTRUCTOR1_tax_executive to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_sranalyst_corp to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_jranalyst_corp to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_sranalyst_indiv to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_jranalyst_indiv to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_user_east to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_user_central to user INSTRUCTOR1;
grant role INSTRUCTOR1_tax_user_west to user INSTRUCTOR1;

-- Grant custom role access to TAX_DB database, TAXSCHEMA schema, and dependent tables

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_executive;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_executive;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_executive;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_sranalyst_corp;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_sranalyst_corp;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_sranalyst_corp;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_jranalyst_corp;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_jranalyst_corp;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_jranalyst_corp;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_sranalyst_indiv;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_sranalyst_indiv;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_sranalyst_indiv;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_jranalyst_indiv;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_jranalyst_indiv;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_jranalyst_indiv;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_user_east;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_user_east;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_user_east;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_user_central;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_user_central;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_user_central;

grant usage on database INSTRUCTOR1_tax_db to INSTRUCTOR1_tax_user_west;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_tax_user_west;
grant select on all tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_tax_user_west;

-- Set up centralized management of all row access and data masking policies in the training account
-- Note: POLICY_ADMIN role is responsible for managing all object tags, row accesspolicies, & data masking policies

use role securityadmin;

-- Create POLICY_ADMIN role and grant appropriate privs to enable centralized policy management (row access, tagging, & data masking policies)
-- Note that POLICY_ADMIN is not granted select access to any tables

create role INSTRUCTOR1_policy_admin;

-- Note: POLICY_ADMIN is granted usage on TAX_DB database and TAXSCHEMA schema,
-- but this role is not granted select access to the underlying tables
grant usage on database INSTRUCTOR1_tax_db to role INSTRUCTOR1_policy_admin;
grant usage on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_policy_admin;

-- Grants for row access policies & data masking
grant create row access policy on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_policy_admin;
grant create masking policy on schema INSTRUCTOR1_tax_db.taxschema to role INSTRUCTOR1_policy_admin;

-- Grants for object tagging
grant create tag on schema INSTRUCTOR1_tag_db.tag_library to role INSTRUCTOR1_policy_admin;
grant imported privileges on database snowflake to role INSTRUCTOR1_policy_admin; -- Ensures that POLICY_ADMIN is able to audit policies and their usage
grant usage on database INSTRUCTOR1_tag_db to role INSTRUCTOR1_policy_admin;
grant usage on schema INSTRUCTOR1_tag_db.tag_library to role INSTRUCTOR1_policy_admin;

-- Grant select on just the 2 mapping tables in schema INSTRUCTOR1_tax_db.taxschema to INSTRUCTOR1_policy_admin,
-- but not on any other tables
-- Select access to the mapping tables is required in order to deploy the row access policy
grant select on INSTRUCTOR1_tax_db.taxschema.tax_mapping to role INSTRUCTOR1_policy_admin;
grant select on INSTRUCTOR1_tax_db.taxschema.taxuser_mapping to role INSTRUCTOR1_policy_admin;

-- Account-level grants to POLICY_ADMIN role
use role accountadmin;
grant apply row access policy on account to role INSTRUCTOR1_policy_admin;
grant apply masking policy on account to role INSTRUCTOR1_policy_admin;
grant create tag on schema INSTRUCTOR1_tag_db.tag_library to role INSTRUCTOR1_policy_admin;
grant apply tag on account to role INSTRUCTOR1_policy_admin;

-- Grant POLICY_ADMIN role to any users who will run the demos (INSTRUCTOR1 is the only user grant that is provided here)   
grant role INSTRUCTOR1_policy_admin to user INSTRUCTOR1;

-- Verify that POLICY_ADMIN role has no access to taxpayer data
use role INSTRUCTOR1_policy_admin;

-- The 3 queries below will error out, as POLICY_ADMIN has not been granted select access to these tables
select * from INSTRUCTOR1_tax_db.taxschema.taxpayer; 
select * from INSTRUCTOR1_tax_db.taxschema.taxpayer_dependents;
select * from INSTRUCTOR1_tax_db.taxschema.taxpayer_wages;

-- The 2 queries below will succeed, as POLICY_ADMIN has been granted select access to these tables
-- Note that the mapping tables contain no sensitive data
select * from INSTRUCTOR1_tax_db.taxschema.tax_mapping; 
select * from INSTRUCTOR1_tax_db.taxschema.taxuser_mapping;

-- Verify all custom roles granted to user INSTRUCTOR1

use role sysadmin;
show grants to user INSTRUCTOR1;

select "role"
      ,"granted_to"
      ,"grantee_name"
      ,"granted_by" 
    from table(result_scan(last_query_id()))
    where "role" like 'INSTRUCTOR1%'
order by 1 asc; -- 10 roles total
