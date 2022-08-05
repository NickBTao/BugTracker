create or replace
PACKAGE BUG_TRACKER_CURSORS
AS     
  PROCEDURE ALL_PROJECTS ( projects_csr IN OUT SYS_REFCURSOR);
  
  PROCEDURE BUGS_BY_PROJECT (
    p_project_id IN projects.project_id%type,
    bugs_csr IN OUT SYS_REFCURSOR
  );
    
  PROCEDURE BUG_NOTES_BY_BUG (
    p_bug_id IN bugs.bug_id%type,
    bug_notes_csr IN OUT SYS_REFCURSOR
  );
    
END BUG_TRACKER_CURSORS;