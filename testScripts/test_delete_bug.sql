/* TESTING UPDATE TO ASSIGNED FUNCTION*/

SET SERVEROUTPUT ON;

Declare


  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  --Employee 12 is a manager
  --Bugs that are entered in Error can be deleted, however
  --Only managers can DELETE bugs and only while in NEW status
  
  form_user_id resources.emp_id%TYPE:=12; --this is the person calling the function
  --form_user_id resources.emp_id%TYPE:=4; -- emp 4 is not a manager -- will raise erro YOU DO NOT HAVE PERMISSION TO DELETE THIS BUG
  form_bug_id bugs.bug_id%TYPE:=12; -- This is the bug to delete
  --form_bug_id bugs.bug_id%TYPE:=3; -- Bug 3 is ASSIGNED and can't be deleted
  --Will raise error ONLY NEW BUGS CAN BE DELETED

  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
begin

  
  results_tbl:=BUG_TRACKER_CRUD.DELETE_BUG(
  form_user_id,
  form_bug_id
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;