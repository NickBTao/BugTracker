/* TESTING VIEW ALL BUGS*/
--TESTING AS PROGRAMMER.  M
--Programmers and tester can only view bugs from the project to which they are assigned.

SET SERVEROUTPUT ON;

Declare
  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  
  form_user_id resources.emp_id%TYPE:=7; --employee 7 is a Programmer -- can only view bugs from project SOLILOQUY ETERNAM
  --form_user_id resources.emp_id%TYPE:=15; -- employee 15 doesn't exist! Raise Error INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!
  
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;--Results table is used to store string messages intended for the user.
begin
  results_tbl:=BUG_TRACKER_CRUD.VIEW_ALL_BUGS(form_user_id); 
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
end;