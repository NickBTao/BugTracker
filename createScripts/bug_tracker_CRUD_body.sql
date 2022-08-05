create or replace
PACKAGE BODY BUG_TRACKER_CRUD AS


  --VIEW ALL BUGS
  -- IF USED BY A MANAGER VIEWS A LIST : ALL PROJETS --> BUGS --> BUG NOTES
  -- IF NOT A MANAGER, VIEWS A LIST : PROJET to which user is assigned --> BUGS --> BUG NOTES

  FUNCTION VIEW_ALL_BUGS(
      user_id IN resources.emp_id%TYPE
      
  ) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE
  IS
  
    projects_tbl BUG_TRACKER_TYPES.PROJECTS_table;
    projects_csr SYS_REFCURSOR;
    bugs_tbl BUG_TRACKER_TYPES.bugs_table;
    bugs_csr SYS_REFCURSOR;
    bug_notes_tbl BUG_TRACKER_TYPES.BUGS_NOTES_table;
    bug_notes_csr SYS_REFCURSOR; 
    
    results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
    results_index INTEGER(4):=0;
    
    employee_test INTEGER(1);
    
    resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
    
  BEGIN
    --VALIDATE EMP_ID EXISTS
    SELECT count(*) into employee_test from resources WHERE emp_id=user_id;
    if employee_test !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;
    
    --POPULATE RESSOURCE RECORD FOR LATER REFERENCE
    SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=user_id;
    --UPDATE ACTIVE USER TABLE
    UPDATE active_user 
    set emp_id= resources_rec.emp_id, 
        emp_first_name= resources_rec.emp_first_name,
        emp_last_name= resources_rec.emp_last_name, 
        emp_role = resources_rec.emp_role
    WHERE active_user_id=1;
    
    results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

    --MANAGER CAN VIEW BUGS FROM ALL PROJECTS
    -- Open project cursor and bulk collect into projects table --> then loop
    IF resources_rec.emp_role = 'MANAGER' then
      BUG_TRACKER_CURSORS.ALL_PROJECTS(projects_csr);
      FETCH projects_csr BULK COLLECT INTO projects_tbl;
      CLOSE projects_csr;
    ELSE
      SELECT * BULK COLLECT INTO projects_tbl FROM PROJECTS Where project_id = (SELECT PROJECT_ID FROM RESOURCES WHERE emp_id = user_id);
    END IF;
    
    FOR i IN projects_tbl.FIRST.. projects_tbl.LAST
    LOOP
    
      results_tbl(results_index):=''; results_index:= results_index+1;
      results_tbl(results_index):='------------------------------------------------PROJECT----------------------------------------------------'; results_index:= results_index+1;
      results_tbl(results_index):=projects_tbl(i).project_id || ' - ' || upper(projects_tbl(i).project_name || ' : ' || projects_tbl(i).created_by ); results_index:= results_index+1;
      results_tbl(results_index):='Start Date: ' || to_char(projects_tbl(i).start_date, 'dd month yyyy')
      || ' - Target End Date: ' || to_char(projects_tbl(i).target_end_date, 'dd month yyyy'); results_index:= results_index+1;
      
      
     -- Open bugs cursor and bulk collect into bugs table --> then loop   
      BUG_TRACKER_CURSORS.BUGS_BY_PROJECT(projects_tbl(i).project_id, bugs_csr);
      FETCH bugs_csr BULK COLLECT INTO bugs_tbl;
      CLOSE bugs_csr;
      
      if bugs_tbl.count >0 then

        results_tbl(results_index):=''; results_index:= results_index+1;
        results_tbl(results_index):='----- BUGS : ' || bugs_tbl.count; results_index:= results_index+1;
        
        FOR j IN bugs_tbl.FIRST.. bugs_tbl.LAST
        LOOP
          results_tbl(results_index):=''; results_index:= results_index+1;
          -- because bugs_tbl was crated using a view, I can use extra fields (bug_type_name) that were not part of the original table
          results_tbl(results_index):='----- ID : ' || bugs_tbl(j).bug_id || ' - Type : ' || bugs_tbl(j).bug_type_name 
          || ' - Status : ' || bugs_tbl(j).status || ' - Priority : ' || bugs_tbl(j).priority ; results_index:= results_index+1;
          results_tbl(results_index):='----- ' || bugs_tbl(j).description ; results_index:= results_index+1;
          
            -- Open bug notes cursor and bulk collect into bug notes table --> then loop   
            BUG_TRACKER_CURSORS.BUG_NOTES_BY_BUG(bugs_tbl(j).bug_id, bug_notes_csr);
            FETCH bug_notes_csr BULK COLLECT INTO bug_notes_tbl;
            CLOSE bug_notes_csr;
            if bug_notes_tbl.count >0 then
              
              results_tbl(results_index):=''; results_index:= results_index+1;
              results_tbl(results_index):='----- ----- BUG NOTES : ' || (bug_notes_tbl.count); results_index:= results_index+1;
              results_tbl(results_index):=''; results_index:= results_index+1;

              FOR h IN bug_notes_tbl.FIRST.. bug_notes_tbl.LAST
              LOOP
                results_tbl(results_index):='----- ----- ' || bug_notes_tbl(h).created_by ||  ' - ' ||  bug_notes_tbl(h).last_modified_on; results_index:= results_index+1;
                results_tbl(results_index):='----- ----- ----- ' || bug_notes_tbl(h).bug_note; results_index:= results_index+1;
                results_tbl(results_index):=''; results_index:= results_index+1;
              END LOOP;
            end if;
          
        END LOOP;
      end if;
    END LOOP;
    
    RETURN results_tbl;
    
    EXCEPTION
      when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      when others then 
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;

  END;
  
  
  -- INSERT NEW BUG
  -- Can be entered by any Programmer or Tester assigned to that Project, or any Manager.
  -- input: project, description, bug type, and priority.
  -- BUG always starts with status NEW
  
  FUNCTION INSERT_NEW_BUG(
      user_id IN resources.emp_id%TYPE,
      v_bug_type_id IN bugs.bug_type_id%TYPE,
      v_project_id IN bugs.project_id%TYPE,
      v_description IN bugs.description%TYPE,
      v_priority IN bugs.priority%TYPE
      
  ) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE
  IS
    results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
    results_index INTEGER(4):=0;
    
    employee_test INTEGER(1);
    bug_type_test INTEGER(1);
    project_id_test INTEGER(1);
    
    resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
    
  BEGIN
    
    --VALIDATE EMP_ID EXISTS
    SELECT count(*) into employee_test from resources WHERE emp_id=user_id;
    if employee_test !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;
    
    --VALIDATE BUG TYPE EXISTS
    SELECT count(*) into bug_type_test from bug_type WHERE bug_type_id = v_bug_type_id ;
      if bug_type_test !=1 then
      raise_application_error(-20102, 'BUG TYPE DOES NOT EXIST!');
    end if;
    
    --VALIDATE PROJECT EXISTS
    SELECT count(*) into project_id_test from projects WHERE project_id = v_project_id ;
      if project_id_test !=1 then
      raise_application_error(-20103, 'PROJECT NUMBER DOES NOT EXIST!');
    end if;
    
    --POPULATE RESSOURCE RECORD FRO LATER REFERENCE
    SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=user_id;
    
    --VALIDATE USER IS ASSIGNED TO PROJECT, UNLESS MANAGER
    if resources_rec.project_id != v_project_id AND resources_rec.emp_role != 'MANAGER' then
      raise_application_error(-20104, 'YOU ARE NOT ASSIGNED TO THIS PROJECT!');
    end if;
    
    --UPDATE ACTIVE USER
    UPDATE active_user 
    set emp_id= resources_rec.emp_id, 
        emp_first_name= resources_rec.emp_first_name,
        emp_last_name= resources_rec.emp_last_name, 
        emp_role = resources_rec.emp_role
    WHERE active_user_id=1;
    
    results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

    --INSERT NEW BUG
    INSERT INTO BUGS(bug_type_id, project_id, description, status, priority)
    VALUES(
      v_bug_type_id,
      v_project_id,
      v_description,
      'NEW',
      v_priority
    );
    
    results_tbl(results_index):='SUCCESS, new bug created.'; results_index:= results_index+1;
    --COMMIT;
    RETURN results_tbl;
    
    EXCEPTION
      when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_BUG_TYPE then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when others then 
      dbms_output.put_line(SQLERRM); 
      RETURN results_tbl;

  END;
  
  
    -- Update Status to ASSIGNED.
  -- In addition to the status update, assigns one PROGRAMMER in the RESOURCE ASSIGNATION table
  -- MANAGERS can assign bugs to PROGRAMMERS, Or PROGRAMMERS CAN ASSIGN THEMSELVES
  
  FUNCTION update_status_to_assigned 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE,
  P_ASSIGNED_USER IN RESOURCES.EMP_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  
  
  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_STATUS_TEST VARCHAR2(100);
  V_BUG_TEST INTEGER;
  V_PROJECT_TEST projects.project_id%TYPE;
  V_PROJECT_TEST2 projects.project_id%TYPE;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  
  R_resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;

BEGIN

  --VALIDATE EMP_ID EXISTS
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;
-- POPULATE THE RECORD RESOURCE_REC AFTER VALIDATING THE EMPLOYEE_ID 
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into R_resources_rec from resources WHERE emp_id=P_ASSIGNED_user;

--VERIFY CURRENT STATUS FOR "NEW" (PUT INTO A VARIABLE THE OLD STATUS VALUE AND COMPARE)
  SELECT STATUS
  INTO V_STATUS_TEST
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  
  IF UPPER(V_STATUS_TEST) != 'NEW' THEN
    RAISE_APPLICATION_ERROR(-20111, 'YOU ARE NOT RESPECTING THE BUG CYCLE (NEW > ASSIGNED > TESTING > RESOLVED');
  END IF;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20101, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- VERIFY IF USER IS ASSIGNED TO PROJECT (IF RESOURCE PROJECT_ID != BUGS.PROJECT_ID)
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST2
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF v_project_test != V_PROJECT_TEST2 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20104, 'THIS EMPLOYEE IS NOT ASSIGNED TO THIS PROJECT');
  END IF;


  --TEST: PROGRAMMER MUST BE THE ONE ASSIGNED (RESSOURCE.ROLE = 'PROGRAMER')
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  IF V_ROLE_TEST != 'PROGRAMMER' THEN
    RAISE_APPLICATION_ERROR(-20113, 'ONLY A PROGRAMER CAN TAKE THIS TASK');
  END IF;

  --TEST: USER_ID MUST BE 'MANAGER' OR THE SAME USER_ID IF A PROGRAMMER
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;

  -- MANAGERS can assign bugs to PROGRAMMERS, Or PROGRAMMERS CAN ASSIGN THEMSELVES
  IF V_ROLE_TEST != 'MANAGER' AND P_USERID != P_ASSIGNED_USER  THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO UPDATE THE STATUS OF THIS BUG');
  END IF;
  
   --POPULATE RESSOURCE RECORD FOR LATER REFERENCE
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into R_resources_rec from resources WHERE emp_id=P_USERID;

  -- UPDATE THE ACTIVE USER RECORD
  UPDATE active_user 
  set emp_id= R_resources_rec.emp_id, 
      emp_first_name= R_resources_rec.emp_first_name,
      emp_last_name= R_resources_rec.emp_last_name, 
      emp_role = R_resources_rec.emp_role
  WHERE active_user_id=1;
  
  results_tbl(results_index):='ACTIVE USER : ' || R_resources_rec.emp_id || ' - ' || R_resources_rec.emp_first_name || ' ' || R_resources_rec.emp_last_name || ' - ' || R_resources_rec.emp_role; results_index:= results_index+1;
  
  
-- INSERT ROW IN RESSOURCE ASSIGNATION VALUES ARE ALREADY IN THE FUNCTION.
  INSERT INTO RESOURCE_ASSIGNATION (BUG_ID, EMP_ID, START_DATE,END_DATE)
  VALUES (P_BUGID, P_ASSIGNED_USER, SYSDATE, NULL );
  
--changement status dans bugs
  update bugs
  set status = 'ASSIGNED'
  where bug_id = p_bugid;
  
  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='SUCCESS, YOUR UPDATE REQUEST HAS BEEN PROCESSED'; results_index:= results_index+1;
  
  --COMMIT
  
  RETURN results_tbl;

-- EXCEPTION MUST MATCH THE FUNCTION    
    EXCEPTION 
      when BUG_TRACKER_EXCEPTIONS.BUG_CYCLE_NOT_RESPECTED then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_A_PROGRAMER then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when others then 
      dbms_output.put_line(SQLERRM);  
      RETURN results_tbl;
END;

  -- Update Status to TESTING.
  -- In addition to the status update, assigns one TESTER in the RESOURCE ASSIGNATION table
  -- MANAGERS can assign bugs to TESTERS, Or TESTERS CAN ASSIGN THEMSELVES


FUNCTION update_status_to_testing 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE,
  P_ASSIGNED_USER IN RESOURCES.EMP_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  
  
  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_STATUS_TEST VARCHAR2(100);
  V_BUG_TEST INTEGER;
  V_PROJECT_TEST projects.project_id%TYPE;
  V_PROJECT_TEST2 projects.project_id%TYPE;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  R_resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;

BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;


--VERIFY CURRENT STATUS FOR "ASSIGNED" (PUT INTO A VARIABLE THE OLD STATUS VALUE AND COMPARE)
  SELECT STATUS
  INTO V_STATUS_TEST
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  IF UPPER(V_STATUS_TEST) != 'ASSIGNED' THEN
    RAISE_APPLICATION_ERROR(-20111, 'YOU ARE NOT RESPECTING THE BUG CYCLE (NEW > ASSIGNED > TESTING > RESOLVED'); 
  END IF;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20101, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- VERIFY IF USER IS ASSIGNED TO PROJECT (IF RESOURCE PROJECT_ID != BUGS.PROJECT_ID)
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST2
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF v_project_test != V_PROJECT_TEST2 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20104, 'THIS EMPLOYEE IS NOT ASSIGNED TO THIS PROJECT');
  END IF;
 
  --TEST: TESTER MUST BE THE ONE ASSIGNED (RESSOURCE.ROLE = 'TESTER')
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  IF V_ROLE_TEST != 'TESTER' THEN
    RAISE_APPLICATION_ERROR(-20115, 'ONLY A TESTER CAN TAKE THIS TASK');
  END IF;

  
  --TEST: USER_ID MUST BE 'MANAGER' OR THE SAME USER_ID IF A TESTER
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;

  
  IF V_ROLE_TEST != 'MANAGER' AND P_USERID != P_ASSIGNED_USER  THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO UPDATE THE STATUS OF THIS BUG');
  END IF;
  
 
  -- POPULATE THE RECORD RESOURCE_REC 
    SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into R_resources_rec from resources WHERE emp_id=P_ASSIGNED_user;
  -- UPDATE THE ACTIVE USER RECORD
    UPDATE active_user 
    set emp_id= R_resources_rec.emp_id, 
        emp_first_name= R_resources_rec.emp_first_name,
        emp_last_name= R_resources_rec.emp_last_name, 
        emp_role = R_resources_rec.emp_role
    WHERE active_user_id=1;
    
    results_tbl(results_index):='ACTIVE USER : ' || R_resources_rec.emp_id || ' - ' || R_resources_rec.emp_first_name || ' ' || R_resources_rec.emp_last_name || ' - ' || R_resources_rec.emp_role; results_index:= results_index+1;
      
      
-- INSERT ROW IN RESSOURCE ASSIGNATION VALUES ARE ALREADY IN THE FUNCTION.
  INSERT INTO RESOURCE_ASSIGNATION (BUG_ID, EMP_ID, START_DATE,END_DATE)
  VALUES (P_BUGID, P_ASSIGNED_USER, SYSDATE, NULL );
  
--changement status dans bugs
  update bugs
  set status = 'TESTING'
  where bug_id = p_bugid;
  
  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='THIS BUG HAS BEEN UPDATED TO THE TESTING PHASE SUCCESSFULLY'; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

-- EXCEPTION MUST MATCH THE FUNCTION    
    EXCEPTION -- A METTRE A JOUR
      when BUG_TRACKER_EXCEPTIONS.BUG_CYCLE_NOT_RESPECTED then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_A_TESTER then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when others then 
      dbms_output.put_line(SQLERRM);  
      RETURN results_tbl;

END;


  -- Update Status to RESOLVED.
  -- ONLY MANAGERS OR TESTERS ASSIGNED TO BUG CAN SET STATUS TO RESOLVED
  -- Also sets bug priority to null and records an endDate to all employees assigned to the bug in the Resource Assignation table.
  -- Essentially, Employee is considered no longer assigned when endDate is entered, but work history is saved (What employee worked on what bug when)

FUNCTION update_status_to_resolved 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS


  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_STATUS_TEST VARCHAR2(100);
  V_BUG_TEST INTEGER;
  V_PROJECT_TEST projects.project_id%TYPE;
  V_PROJECT_TEST2 projects.project_id%TYPE;
  V_ASSIGNED_TEST INTEGER;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  R_resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;

BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;

--VERIFY CURRENT STATUS FOR "TESTING" (PUT INTO A VARIABLE THE OLD STATUS VALUE AND COMPARE)
  SELECT STATUS
  INTO V_STATUS_TEST
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  IF UPPER(V_STATUS_TEST) != 'TESTING' THEN
    RAISE_APPLICATION_ERROR(-20111, 'YOU ARE NOT RESPECTING THE BUG CYCLE (NEW > ASSIGNED > TESTING > RESOLVED'); 
  END IF;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20101, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- VERIFY IF USER IS ASSIGNED TO PROJECT (IF RESOURCE PROJECT_ID != BUGS.PROJECT_ID)
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST2
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF v_project_test != V_PROJECT_TEST2 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20104, 'THIS EMPLOYEE IS NOT ASSIGNED TO THIS PROJECT');
  END IF;

  -- validate user is assigned to bug or is manager
  -- Checks the resource Assignation table
  SELECT count(*) 
  INTO V_ASSIGNED_TEST 
  FROM RESOURCE_ASSIGNATION
  WHERE BUG_ID=P_BUGID AND EMP_ID=P_USERID AND SYSDATE > START_DATE AND END_DATE IS NULL;
  
  IF V_ASSIGNED_TEST!= 1 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU ARE NOT ASSIGNED TO THIS BUG');
  END IF;

  --TEST: USER MUST BE MANAGER OR TESTER TO SET TO RESOLVED
  IF V_ROLE_TEST NOT IN ('MANAGER', 'TESTER') THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO UPDATE THE STATUS OF THIS BUG');
  END IF;


  -- POPULATE THE RECORD RESOURCE_REC 
    SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into R_resources_rec from resources WHERE emp_id=P_USERID;
  -- UPDATE THE ACTIVE USER RECORD
    UPDATE active_user 
    set emp_id= R_resources_rec.emp_id, 
        emp_first_name= R_resources_rec.emp_first_name,
        emp_last_name= R_resources_rec.emp_last_name, 
        emp_role = R_resources_rec.emp_role
    WHERE active_user_id=1;
    
    results_tbl(results_index):='ACTIVE USER : ' || R_resources_rec.emp_id || ' - ' || R_resources_rec.emp_first_name || ' ' || R_resources_rec.emp_last_name || ' - ' || R_resources_rec.emp_role; results_index:= results_index+1;
      
-- SET BUG END DATE IN RESSOURCE ASSSIGNATION
  UPDATE resource_assignation
  SET end_date = SYSDATE
  WHERE bug_id = P_BUGID;

-- SET PRIORITY AND STATUS TO NULL TO RESOLVED BUG
  update bugs
  set status = 'RESOLVED', PRIORITY = NULL
  where bug_id = p_bugid;
  
  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='THIS BUG HAS BEEN SET TO RESOLVED SUCCESSFULLY'; results_index:= results_index+1;
  
  --COMMIT
    RETURN results_tbl;

  
    EXCEPTION 
      when BUG_TRACKER_EXCEPTIONS.BUG_CYCLE_NOT_RESPECTED then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_PROJECT then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.UNSUFISCIENT_PRIVILEDGES then
      dbms_output.put_line(SQLERRM);
      RETURN results_tbl;
      
      when others then 
      dbms_output.put_line(SQLERRM);  
      RETURN results_tbl;

END;

  --UPDATE DESCRIPTION
  -- needs to be assinged to bug in RESOURCE ASSIGNATION table or be MANAGER

FUNCTION update_description 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_DESCRIPTION IN BUGS.DESCRIPTION%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_BUG_TEST INTEGER;
  V_ASSIGNED_TEST INTEGER;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
  
BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20105, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- validate user is assigned to bug or is manager
--Checks the resource Assignation table
  SELECT count(*) 
  INTO V_ASSIGNED_TEST 
  FROM RESOURCE_ASSIGNATION
  WHERE BUG_ID=P_BUGID AND EMP_ID=P_USERID AND SYSDATE > START_DATE AND END_DATE IS NULL;

  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF V_ASSIGNED_TEST!= 1 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO UPDATE THE DESCRIPTION OF THIS BUG');
  END IF;
  
  
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=P_USERID;
  UPDATE active_user 
  set emp_id= resources_rec.emp_id, 
      emp_first_name= resources_rec.emp_first_name,
      emp_last_name= resources_rec.emp_last_name, 
      emp_role = resources_rec.emp_role
  WHERE active_user_id=1;
  
  results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

-- UPDATE BUG DESCRIPTION
   UPDATE BUGS
   SET DESCRIPTION = P_DESCRIPTION
   WHERE BUG_ID = P_BUGID;
   

  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='YOU HAVE CHANGED THE BUG DESCRIPTION TO ' || P_DESCRIPTION; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

  
  EXCEPTION 
  
    when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.INVALID_BUG_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when others then 
    dbms_output.put_line(SQLERRM); 
    RETURN results_tbl;
END;

  -- UPDATE PRIORITY
  --Employee needs to be assigned to the bug or a MANAGER to updatae priority
  
FUNCTION update_priority 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_PRIORITY IN BUGS.PRIORITY%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_BUG_TEST INTEGER;
  V_ASSIGNED_TEST INTEGER;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
  
BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20105, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- validate user is assigned to bug or is manager
  SELECT count(*) 
  INTO V_ASSIGNED_TEST 
  FROM RESOURCE_ASSIGNATION
  WHERE BUG_ID=P_BUGID AND EMP_ID=P_USERID AND SYSDATE > START_DATE AND END_DATE IS NULL;

  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF V_ASSIGNED_TEST!= 1 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO UPDATE THE PRIORITY OF THIS BUG');
  END IF;
  
  
  
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=P_USERID;
  UPDATE active_user 
  set emp_id= resources_rec.emp_id, 
      emp_first_name= resources_rec.emp_first_name,
      emp_last_name= resources_rec.emp_last_name, 
      emp_role = resources_rec.emp_role
  WHERE active_user_id=1;
  
  results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

-- UPDATE BUG PRIORITY
   UPDATE BUGS
   SET PRIORITY = P_PRIORITY
   WHERE BUG_ID = P_BUGID;
   

  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='YOU HAVE CHANGED THE PRIORITY OF THIS BUG TO ' || P_PRIORITY; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

  
  EXCEPTION 
  
    when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.INVALID_BUG_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when others then 
    dbms_output.put_line(SQLERRM);  
    RETURN results_tbl;
END;
  
  
  --DELETE BUG
  --Bugs that are entered in Error can be deleted, however
  --Only managers can DELETE bugs and only while in NEW status
  
FUNCTION delete_bug 
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_BUG_TEST INTEGER;
  V_STATUS_TEST BUGS.STATUS%TYPE;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  
  
  resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
  
BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;

-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20105, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;
    

--VERIFY CURRENT STATUS FOR "NEW" Only NEW bugs can be deleted
  SELECT STATUS
  INTO V_STATUS_TEST
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  IF UPPER(V_STATUS_TEST) != 'NEW' THEN
    RAISE_APPLICATION_ERROR(-20111, 'ONLY NEW BUGS CAN BE DELETED'); 
  END IF;

-- validate user is Manager

  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO DELETE THIS BUG');
  END IF;
  
  
  
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=P_USERID;
  UPDATE active_user 
  set emp_id= resources_rec.emp_id, 
      emp_first_name= resources_rec.emp_first_name,
      emp_last_name= resources_rec.emp_last_name, 
      emp_role = resources_rec.emp_role
  WHERE active_user_id=1;
  
  results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

-- UPDATE BUG PRIORITY
   DELETE FROM BUGS
   WHERE BUG_ID = P_BUGID;
   

  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='YOU HAVE DELETED BUG ' || P_BUGID; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

  
  EXCEPTION 
  
    when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.INVALID_BUG_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.UNSUFISCIENT_PRIVILEDGES then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.BUG_CYCLE_NOT_RESPECTED then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when others then 
    dbms_output.put_line(SQLERRM);  
    RETURN results_tbl;
END;

  --INSERT BUG NOTE
  --For each bug, many bug notes can be entered. Employees use these to record their progress, observation and communicate with other employees
  --Can only write a bug not when you are assigned to the Bug in the RESOURCE ASSIGNATION TABLE

FUNCTION insert_bug_note
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE,
  P_BUG_NOTE IN BUG_NOTES.BUG_NOTE%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_BUG_TEST INTEGER;
  V_ASSIGNED_TEST INTEGER;
  
  resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;
  
BEGIN
-- VALIDATE EMP_ID EXISTS
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;

-- validate bug id exists
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20105, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

-- validate user is assigned to bug
  SELECT count(*) 
  INTO V_ASSIGNED_TEST 
  FROM RESOURCE_ASSIGNATION
  WHERE BUG_ID=P_BUGID AND EMP_ID=P_USERID AND SYSDATE > START_DATE AND END_DATE IS NULL;

  IF V_ASSIGNED_TEST!= 1 THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO CREATE A NOTE FOR THIS BUG!');
  END IF;
  
  
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into resources_rec from resources WHERE emp_id=P_USERID;
  UPDATE active_user 
  set emp_id= resources_rec.emp_id, 
      emp_first_name= resources_rec.emp_first_name,
      emp_last_name= resources_rec.emp_last_name, 
      emp_role = resources_rec.emp_role
  WHERE active_user_id=1;
  
  results_tbl(results_index):='ACTIVE USER : ' || resources_rec.emp_id || ' - ' || resources_rec.emp_first_name || ' ' || resources_rec.emp_last_name || ' - ' || resources_rec.emp_role; results_index:= results_index+1;

-- INSERT BUG NOTES
   INSERT INTO BUG_NOTES(BUG_ID, BUG_NOTE)
   VALUES(P_BUGID, P_BUG_NOTE);

  --MESSAGE DE CONFIRMATIONS
  results_tbl(results_index):='YOU HAVE ADDED A NEW BUG NOTE'; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

  
  EXCEPTION 
  
    when BUG_TRACKER_EXCEPTIONS.INVALID_USER_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.INVALID_BUG_ID then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
    
    when others then 
    dbms_output.put_line(SQLERRM);
    RETURN results_tbl;
END;


  --INSERT_RESOURCE ASSIGNATION
  --For each bug, one Programmer will be assigned when set to ASSIGNED status and one Tester will be assined when set to TESTING status
  --However, other employees can be assinged as well using this function
  --PROGRAMMERS and TESTERS can only assign themselves, or managers can assign others.
  --Can't assign anyone during NEW or RESOLVED STATUS
  --Can't assign TESTERS before TESTING status

FUNCTION insert_resource_assignation
(
  P_USERID IN RESOURCES.EMP_ID%TYPE,
  P_BUGID IN BUGS.BUG_ID%TYPE,
  P_ASSIGNED_USER IN RESOURCES.EMP_ID%TYPE
) RETURN BUG_TRACKER_TYPES.RESULTS_TABLE AS

  results_index INTEGER(4):=0;
  results_tbl BUG_TRACKER_TYPES.RESULTS_TABLE;
  
  V_EMPLOYEE_TEST INTEGER;
  V_BUG_TEST INTEGER;
  V_STATUS_TEST VARCHAR2(100);
  V_PROJECT_TEST projects.project_id%TYPE;
  V_PROJECT_TEST2 projects.project_id%TYPE;
  V_ROLE_TEST RESOURCES.EMP_ROLE%TYPE;
  
  
  R_resources_rec BUG_TRACKER_TYPES.RESOURCES_RECORD;

BEGIN
-- VALIDATE EMP_ID VERIFIER VARIABLE
  SELECT count(*) into V_EMPLOYEE_TEST from resources WHERE emp_id=P_USERID;
    if V_EMPLOYEE_TEST !=1 then
      raise_application_error(-20101, 'INVALID EMPLOYEE IDENTIFICATION! ACCESS DENIED!');
    end if;


-- validate bug id
  SELECT count(*) into v_bug_test from bugs WHERE bug_id = p_bugid;
    if v_bug_test !=1 then
      raise_application_error(-20101, 'INVALID BUG IDENTIFICATION! TRY AGAIN.');
    end if;

--VERIFY: CANNOT ASSIGN EMPLOYEE WHEN BUG STATUS IS NEW OR RESOLVED
  SELECT STATUS
  INTO V_STATUS_TEST
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  IF UPPER(V_STATUS_TEST) = 'NEW' THEN
    RAISE_APPLICATION_ERROR(-20111, 'WHEN BUG IS STATUS NEW, ASSIGN A PROGRAMMER THROUGH UPDATE_STATUS_TO_ASSIGNED_FUNCTION');
  ELSIF UPPER(V_STATUS_TEST) = 'RESOLVED' THEN
    RAISE_APPLICATION_ERROR(-20111, 'CANNOT ASSIGN EMPLOYEE WHEN BUG STATUS IS RESOLVED');
  END IF;
  
-- VERIFY IF USER IS ASSIGNED TO PROJECT (IF RESOURCEs.PROJECT_ID != BUGS.PROJECT_ID OR NOT MANAGER)
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  SELECT PROJECT_ID
  INTO V_PROJECT_TEST2
  FROM BUGS
  WHERE BUG_ID = P_BUGID;
  
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_USERID;
  
  IF v_project_test != V_PROJECT_TEST2 AND V_ROLE_TEST != 'MANAGER' THEN
    RAISE_APPLICATION_ERROR(-20104, 'THIS EMPLOYEE IS NOT ASSIGNED TO THIS PROJECT');
  END IF;

  --TEST: IF NOT MANAGER, EMPLOYEE CAN ONLY ASSIGN HIMSELF TO A BUG
  IF V_ROLE_TEST != 'MANAGER' AND P_USERID != P_ASSIGNED_USER  THEN
    RAISE_APPLICATION_ERROR(-20114, 'YOU DO NOT HAVE PERMISSION TO ASSIGN ANOTHER EMPLOYEE');
  END IF;

    
  --TESTER CAN ONLY BE ASSIGNED DURING TESTING STATUS
  SELECT EMP_ROLE
  INTO V_ROLE_TEST
  FROM RESOURCES
  WHERE EMP_ID = P_ASSIGNED_USER;
  
  IF UPPER(V_STATUS_TEST) = 'ASSIGNED' AND V_ROLE_TEST = 'TESTER' THEN
    RAISE_APPLICATION_ERROR(-20111, 'WHEN BUG IS STATUS ASSIGNED, ASSIGN A TESTER THROUGH UPDATE_STATUS_TO_TESTING_FUNCTION');
  END IF;
  
-- UPDATE THE ACTIVE USER RECORD
  SELECT emp_id, project_id, emp_first_name, emp_last_name, emp_role into R_resources_rec from resources WHERE emp_id=P_USERID;
  UPDATE active_user 
    set emp_id= R_resources_rec.emp_id, 
        emp_first_name= R_resources_rec.emp_first_name,
        emp_last_name= R_resources_rec.emp_last_name, 
        emp_role = R_resources_rec.emp_role
    WHERE active_user_id=1;
    
    results_tbl(results_index):='ACTIVE USER : ' || R_resources_rec.emp_id || ' - ' || R_resources_rec.emp_first_name || ' ' || R_resources_rec.emp_last_name || ' - ' || R_resources_rec.emp_role; results_index:= results_index+1;
  
  
 -- INSERT ROW IN RESSOURCE ASSIGNATION.
  INSERT INTO RESOURCE_ASSIGNATION (BUG_ID, EMP_ID, START_DATE,END_DATE)
  VALUES (P_BUGID, P_ASSIGNED_USER, SYSDATE, NULL ); 
  
  
  --CONFIRMATION MESSAGE
  results_tbl(results_index):='SUCCESS, YOU HAVE ASSIGNED EMPLOYEE ' || P_ASSIGNED_USER || ' TO BUG ' || P_BUGID ; results_index:= results_index+1;
  
  --COMMIT
  RETURN results_tbl;

-- EXCEPTION MUST MATCH THE FUNCTION    
    EXCEPTION 
      when BUG_TRACKER_EXCEPTIONS.BUG_CYCLE_NOT_RESPECTED then
      dbms_output.put_line(SQLERRM);
       RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_BUG then
      dbms_output.put_line(SQLERRM);
       RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.INVALID_PROJECT then
      dbms_output.put_line(SQLERRM);
       RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_ASSIGNED_PROJECT then
      dbms_output.put_line(SQLERRM);
       RETURN results_tbl;
      
      when BUG_TRACKER_EXCEPTIONS.NOT_A_PROGRAMER then
      dbms_output.put_line(SQLERRM);
       RETURN results_tbl;
      
      when others then 
      dbms_output.put_line(SQLERRM); 
       RETURN results_tbl;

END;


END BUG_TRACKER_CRUD;