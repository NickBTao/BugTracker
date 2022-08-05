/* TESTING UPDATE TO ASSIGNED FUNCTION*/

SET SERVEROUTPUT ON;

Declare

  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.

  --Employee 3 is a programmer
  --Employee 11 is a manager
  
  
  -- Update Status to ASSIGNED.
  -- In addition to the status update, assigns one PROGRAMMER in the RESOURCE ASSIGNATION table
  -- MANAGERS can assign bugs to PROGRAMMERS, Or PROGRAMMERS CAN ASSIGN THEMSELVES
    
  form_user_id resources.emp_id%TYPE:=11; --this is the person calling the function
  --form_user_id resources.emp_id%TYPE:=2; -- emp 2 (not manager) cannot assign another employee, will raise YOU DO NOT HAVE PERMISSION TO UPDATE THE STATUS OF THIS BUG
  
  form_assigned_user resources.emp_id%TYPE:=3; -- this is the person the new bug will be assigned to
  --form_assigned_user resources.emp_id%TYPE:=4; -- emp 4 is a tester, this will raise ONLY A PROGRAMER CAN TAKE THIS TASK

  form_bug_id bugs.bug_id%TYPE:=6; -- This is the bug to that need a status update
  --form_bug_id bugs.bug_id%TYPE:=1  Bug 1 is RESOLVED will raise error YOU ARE NOT RESPECTING THE BUG CYCLE (NEW > ASSIGNED > TESTING > RESOLVED
  
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE; --Results table is used to store string messages intended for the user.
begin

  
  results_tbl:=BUG_TRACKER_CRUD.UPDATE_STATUS_TO_ASSIGNED(
  form_user_id,
  form_bug_id,
  form_assigned_user
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;