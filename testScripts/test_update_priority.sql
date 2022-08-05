/* TESTING UPDATE TO ASSIGNED FUNCTION*/

SET SERVEROUTPUT ON;

Declare


  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  
  --Employee 1 is a Programmer
  
  --Employee needs to be assigned to the bug or a MANAGER to updatae priority
  
  form_user_id resources.emp_id%TYPE:=1; --this is the person calling the function
  --form_user_id resources.emp_id%TYPE:=4; -- emp 4 is not assigned to this bug in the RESOURCE_ASSIGNATION 
  -- will raise error YOU DO NOT HAVE PERMISSION TO UPDATE THE PRIORITY OF THIS BUG
  form_bug_id bugs.bug_id%TYPE:=3; -- This is the bug
  form_priority bugs.priority%TYPE:=5; -- This is the new priority requested

  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
begin

  
  results_tbl:=BUG_TRACKER_CRUD.UPDATE_PRIORITY(
  form_user_id,
  form_priority,
  form_bug_id
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;