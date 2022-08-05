/* TESTING INSERT NEW BUG*/



SET SERVEROUTPUT ON;

Declare
  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  
  --Insert New Bug:
  -- Can be entered by any Programmer or Tester assigned to that Project, or any Manager.
  -- input: project, description, bug type, and priority.
  -- BUG always starts with status NEW

  form_user_id resources.emp_id%TYPE:=7; --employee 7 is a Programmer
  --form_user_id resources.emp_id%TYPE:=15; -- employee 15 doesn't exist! Raise Error INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!
  --form_user_id resources.emp_id%TYPE:=3; -- employee 3 is not assigned to this project (and not MANAGER) Raise Error YOU ARE NOT ASSIGNED TO THIS PROJECT!
  
  form_bug_type_id bugs.bug_type_id%TYPE:=3; 
  --form_bug_type_id bugs.bug_type_id%TYPE:=14; -- bug type 14 doesn't exist! Raise Error BUG TYPE DOES NOT EXIST!
  
  form_project_id bugs.project_id%TYPE:=2; 
  --form_project_id bugs.project_id%TYPE:=5; --PROJECT NUMBER DOES NOT EXIST!
  form_description bugs.description%TYPE:='In semper facilisis urna, nec efficitur nisl. Maecenas porta tincidunt.';
  
  form_priority bugs.priority%TYPE:=3; 
  -- Incorect priority will fail table level CHECK
  
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE; --Results table is used to store string messages intended for the user.
begin

  results_tbl:=BUG_TRACKER_CRUD.INSERT_NEW_BUG(
  form_user_id,
  form_bug_type_id,
  form_project_id,
  form_description,
  form_priority
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
end;