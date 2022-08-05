---------------------------------------------------------------------------------

BugTracker

A backend Bug Tracker Database in Oracle Sql built with SQL Developer 11x

Created by: Nicolas Beattie
Last Updated: august 5th, 2022

---------------------------------------------------------------------------------


DESCRIPTION

A simple database for tracking bugs (or issues generally) in a sofware developement team.

NOTA BENE:
- Contains ONLY the backend implementation of the program, however was designed with stored functions/procedures and Custom Exceptions that would be needed by front end developpers

FEATURES

- CRUD (Create, Read, Update, Delete) Bugs
- Insert bug note & Assign employee to bug
- Roles = Programmer, Tester, Manager
- Custom exceptions (error messages and numbers) specific to business logic

- Test SQL scripts
Test each function or procedure, particularly make sure database alteration is permissible under specified circumstances (according to business logic). If not, applicable exception is Raised.

EXAMPLE --->> SEE test_insert_resource_assignation.sql --> And read the comments


  --For each bug, one Programmer will be assigned when set to ASSIGNED status and one Tester will be assined when set to TESTING status
  --However, other employees can be assinged as well using this function
  --PROGRAMMERS and TESTERS can only assign themselves, or managers can assign others.
  --Can't assign anyone during NEW or RESOLVED STATUS
  --Can't assign TESTERS before TESTING status
  
 


SETUP

SQL Developer 11x

Open the createScripts and execute: ---> ADMIN.SQL

Create a new connection
CONNECTION NAME : BugTracker
user: bug_tracker
pass: bug_tracker
service: orcl

Next, execute the sql files in the following order to create the database and insert dummy data

DDL.SQL
VIEWS.SQL
INITDATA.SQL
BUG_TRACKER_TYPES.SQL
BUG_TRACKER_EXCEPTION.SQL
BUG_TRACKER_CURSOR.SQL
BUG_TRACKER_CRUD.SQL
BUG_TRACKER_CRUD_BODY.SQL


Finally, Use the test Scripts to try out various functions

For example : Test_view_all_buggs.sql  
Will print out as seen in the Screen Capture:

Project Parent
-- Child Bugs
-- -- Child Bug Notes



