
create user bug_tracker  identified by bug_tracker;
GRANT CREATE SESSION,
CREATE VIEW,
CREATE TABLE, 
CREATE SEQUENCE,
CREATE TRIGGER,
CREATE PROCEDURE, -- ALLOWS PROCEDURES, FUNCTIONS AND PACKAGES
CREATE ANY INDEX TO bug_tracker;
ALTER USER bug_tracker QUOTA 40M on USERS;


/*
CONNECTION NAME : BugTracker
user: bug_tracker
pass: bug_tracker
sid: orcl
*/