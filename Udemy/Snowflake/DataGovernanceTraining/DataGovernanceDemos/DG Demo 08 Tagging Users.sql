-- Demo: Tagging Users

use role INSTRUCTOR1_policy_admin;
use warehouse instructor1_wh;
use schema INSTRUCTOR1_tag_db.tag_library;

alter user instructor1 unset tag instructor1_user_tag;

-- This shows currently that there's no tag set for the user INSTRUCTOR1
set cur_user = current_user();
select $cur_user;
select * from table(instructor1_tag_db.information_schema.tag_references($cur_user, 'user'));

use role INSTRUCTOR1_policy_admin;

create or replace tag instructor1_user_tag comment = 'Tag for User INSTRUCTOR1';

alter user instructor1 set tag instructor1_user_tag = 'Senior DBA';

-- This shows the currently set tag for the user INSTRUCTOR1
set cur_user = current_user();
select $cur_user;
select * from table(instructor1_tag_db.information_schema.tag_references($cur_user, 'user'));
