/* TESTING UPDATE TO ASSIGNED FUNCTION*/

SET SERVEROUTPUT ON;

Declare


  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  
  --Employee 1 is a Programmer
  --For each bug, many bug notes can be entered. Employees use these to record their progress, observation and communicate with other employees
  --Can only write a bug not when you are assigned to the Bug in the RESOURCE ASSIGNATION TABLE
  
  form_user_id resources.emp_id%TYPE:=1; --this is the person calling the function
  --form_user_id resources.emp_id%TYPE:=4; -- emp 4 is not assigned to this bug in the RESOURCE_ASSIGNATION 
  -- will raise table YOU DO NOT HAVE PERMISSION TO CREATE A NOTE FOR THIS BUG!
  form_bug_id bugs.bug_id%TYPE:=3; -- This is the bug to assign a note.
  -- form_bug_id bugs.bug_id%TYPE:=1; -- while EMP 1 is assigned to BUG 1 , bug is RESOLVED and endDate is set in RESOURCE_ASSIGNATION table
  -- will raise table YOU DO NOT HAVE PERMISSION TO CREATE A NOTE FOR THIS BUG!
  
  
  form_bug_note bug_notes.bug_note%TYPE:='Testing, testing, mic check 123'; -- This is the bug note to insert

  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
begin

  
  results_tbl:=BUG_TRACKER_CRUD.insert_bug_note(
  form_user_id,
  form_bug_id,
  form_bug_note
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;