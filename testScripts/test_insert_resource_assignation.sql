/* TESTING UPDATE TO ASSIGNED FUNCTION*/

SET SERVEROUTPUT ON;

Declare


  --FORM DATA : this is a simulation of a gui form through which user has input data
  --FORM DATA : correct data inputs will lead to nominal function execution, incorect data will raise error.
  
  --For each bug, one Programmer will be assigned when set to ASSIGNED status and one Tester will be assined when set to TESTING status
  --However, other employees can be assinged as well using this function
  --PROGRAMMERS and TESTERS can only assign themselves, or managers can assign others.
  --Can't assign anyone during NEW or RESOLVED STATUS
  --Can't assign TESTERS before TESTING status
  
  
  form_user_id resources.emp_id%TYPE:=2; --This is a Programmer
  
  form_assigned_user resources.emp_id%TYPE:=2; -- this is the person the bug will be assigned to the bug
  --form_assigned_user resources.emp_id%TYPE:=3; -- Cannot assign other employee unless manager
  --will raise error YOU DO NOT HAVE PERMISSION TO ASSIGN ANOTHER EMPLOYEE
  
  --form_user_id resources.emp_id%TYPE:=4; 
  --form_assigned_user resources.emp_id%TYPE:=4;--This is a TESTER, however, bug 5 is Status ASSIGNED
  --will raise error WHEN BUG IS STATUS ASSIGNED, ASSIGN A TESTER THROUGH UPDATE_STATUS_TO_TESTING_FUNCTION
  
  form_bug_id bugs.bug_id%TYPE:=5; -- This is the bug to assign employee
  --form_bug_id bugs.bug_id%TYPE:=1; -- Bug is NEW
  --will raise error WHEN BUG IS STATUS NEW, ASSIGN A PROGRAMMER THROUGH UPDATE_STATUS_TO_ASSIGNED_FUNCTION
    --form_bug_id bugs.bug_id%TYPE:=23; -- Bug is RESOLVED
  --will raise error CANNOT ASSIGN EMPLOYEE WHEN BUG STATUS IS RESOLVED
  
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
begin

  results_tbl:=BUG_TRACKER_CRUD.INSERT_RESOURCE_ASSIGNATION(
  form_user_id,
  form_bug_id,
  form_assigned_user
  );
  
  for i in results_tbl.first..results_tbl.last
  Loop
    DBMS_output.PUT_LINE(results_tbl(i));
  end LOOP;
  
end;