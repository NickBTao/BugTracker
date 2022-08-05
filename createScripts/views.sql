/* Very basic VIEWS using joins to list object names instead of FK ID
ei. list PROJECT_NAME, EMP_NAME, instead of PROJECT_ID, EMP_ID.*/

DROP BUGS_VIEW;
DROP RESEOURCE_ASSIGNATION_VIEW;


CREATE OR REPLACE VIEW BUGS_VIEW AS
SELECT  b.bug_id,
        b.bug_type_id,
        bt.bug_type_name,
        b.project_id,
        p.project_name,
        b.description,
        b.status,
        b.priority,
        b.created_by,
        b.created_on,
        b.modified_by,
        b.modified_on
FROM BUGS b
INNER JOIN BUG_TYPE bt ON b.bug_type_id = bt.bug_type_id
INNER JOIN PROJECTS p ON b.project_id = p.project_id
;


CREATE OR REPLACE VIEW RESEOURCE_ASSIGNATION_VIEW AS
SELECT  ra.bug_id,
        r.emp_id || ' - ' || r.emp_first_name || ' ' || r.emp_last_name || ' - ' || r.emp_role AS "EMPLOYEE",
        ra.start_date,
        ra.end_date

FROM RESOURCE_ASSIGNATION ra
INNER JOIN RESOURCES r ON ra.emp_id = r.emp_id
;