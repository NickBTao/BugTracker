/* TESTING UPDATE TO RESOLVED FUNCTION*/

SET SERVEROUTPUT ON;

Declare

  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.

  -- Update Status to RESOLVED.
  -- ONLY MANAGERS OR TESTERS ASSIGNED TO BUG CAN SET STATUS TO RESOLVED
  -- Also sets bug priority to null and records an endDate to all employees assigned to the bug in the Resource Assignation table.
  -- Essentially, Employee is considered no longer assigned when endDate is entered, but work history is saved (What employee worked on what bug when)
  
  --Employe 4 is a tester    
  form_user_id resources.emp_id%TYPE:=4; --this is the person calling the function
  --form_user_id resources.emp_id%TYPE:=1; -- emp 1 is not assigned to bug in RESOURCE_ASSIGNATION table -- Will raise error YOU ARE NOT ASSIGNED TO THIS BUG
  --form_user_id resources.emp_id%TYPE:=3; -- emp 1 is Programmer, Will raise error YOU DO NOT HAVE PERMISSION TO UPDATE THE STATUS OF THIS BUG
  
  form_bug_id bugs.bug_id%TYPE:=4; -- This is the bug to that need a status update
  --form_bug_id bugs.bug_id%TYPE:=1  Bug 1 is RESOLVED will raise error YOU ARE NOT RESPECTING THE BUG CYCLE (NEW > ASSIGNED > TESTING > RESOLVED
  
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE; --Results table is used to store string messages intended for the user.

begin

  results_tbl:=BUG_TRACKER_CRUD.UPDATE_STATUS_TO_RESOLVED(
    form_user_id,
    form_bug_id
  );

  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;