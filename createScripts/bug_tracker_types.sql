create or replace
PACKAGE BUG_TRACKER_TYPES
IS
  type PROJECTS_table IS TABLE OF PROJECTS%ROWTYPE INDEX BY BINARY_INTEGER;
  type BUGS_table IS TABLE OF BUGS_VIEW%ROWTYPE INDEX BY BINARY_INTEGER; -- VIEW USED HERE
  type BUGS_NOTES_table IS TABLE OF BUG_NOTES%ROWTYPE INDEX BY BINARY_INTEGER;
  
  type RESULTS_table is TABLE OF VARCHAR2(1000) INDEX BY BINARY_INTEGER;
  
  type RESOURCES_record is record (
    emp_id resources.emp_id%TYPE,
    project_id resources.project_id%TYPE,
    emp_first_name resources.emp_first_name%TYPE,
    emp_last_name resources.emp_last_name%TYPE,
    emp_role resources.emp_role%TYPE
  );
  
END BUG_TRACKER_TYPES;