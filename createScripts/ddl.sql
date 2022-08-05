

------------------------------DROPS----------------------------------------

DROP TABLE BUG_NOTES CASCADE CONSTRAINTS;
--DROP TRIGGER BI_BUG_NOTES;
DROP SEQUENCE BUG_NOTE_ID_SEQ;

DROP TABLE RESOURCE_ASSIGNATION CASCADE CONSTRAINTS;

DROP TABLE BUGS CASCADE CONSTRAINTS;
--DROP TRIGGER BI_BUGS;
DROP SEQUENCE BUG_ID_SEQ;

DROP TABLE RESOURCES CASCADE CONSTRAINTS;
--DROP TRIGGER BI_RESOURCES;
DROP SEQUENCE EMP_ID_SEQ;

DROP TABLE BUG_TYPE CASCADE CONSTRAINTS;
--DROP TRIGGER BI_BUG_TYPE;
DROP SEQUENCE BUG_TYPE_ID_SEQ;

DROP TABLE PROJECTS CASCADE CONSTRAINTS;
--DROP TRIGGER BI_PROJECTS;
DROP SEQUENCE PROJECT_ID_SEQ;



DROP TABLE ACTIVE_USER CASCADE CONSTRAINTS;

------------------------------PROJECTS-------------------------------------

CREATE TABLE  "PROJECTS" 
   (	"PROJECT_ID" NUMBER(7,0) NOT NULL ENABLE, 
	"PROJECT_NAME" VARCHAR2(50) NOT NULL ENABLE, 
	"START_DATE" DATE NOT NULL ENABLE, 
	"TARGET_END_DATE" DATE NOT NULL ENABLE, 
	"ACTUAL_END_DATE" DATE, 
	"CREATED_BY" VARCHAR2(100), 
	"CREATED_ON" DATE, 
	"MODIFIED_BY" VARCHAR2(100), 
	"MODIFIED_ON" DATE, 
	 CONSTRAINT "PROJECT_ID_PK" PRIMARY KEY ("PROJECT_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "PROJECTS_PROJECT_NAME_UU" UNIQUE ("PROJECT_NAME")
  USING INDEX  ENABLE, 
	 CONSTRAINT "PROJECTS_TARGET_END_DATE_CHK" CHECK (TARGET_END_DATE > START_DATE) ENABLE, 
	 CONSTRAINT "PROJECTS_ACTUAL_END_DATE_CHK" CHECK (ACTUAL_END_DATE > START_DATE) ENABLE
   )
/

CREATE SEQUENCE   "PROJECT_ID_SEQ"
/

CREATE OR REPLACE TRIGGER  "BI_PROJECTS" 
  before insert on "PROJECTS"               
  for each row  
begin   
  if :NEW.PROJECT_ID is null then 
    select PROJECT_ID_SEQ.nextval into :NEW.PROJECT_ID from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_PROJECTS" ENABLE
/


------------------------------BUG TPYE-------------------------------------

CREATE TABLE  "BUG_TYPE" 
   (	"BUG_TYPE_ID" NUMBER(7,0) NOT NULL ENABLE, 
	"BUG_TYPE_NAME" VARCHAR2(30) NOT NULL ENABLE, 
	"BUG_TYPE_DESCRIPTION" VARCHAR2(300) NOT NULL ENABLE, 
	 CONSTRAINT "BUG_TYPE_ID_PK" PRIMARY KEY ("BUG_TYPE_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "BUG_TYPE_BUG_TYPE_NAME_UU" UNIQUE ("BUG_TYPE_NAME")
  USING INDEX  ENABLE
   )
/

CREATE sequence "BUG_TYPE_ID_SEQ" 
/

create or replace
TRIGGER "BI_BUG_TYPE"  
  before insert on "BUG_TYPE"              
  for each row 
begin  
  if :NEW.BUG_TYPE_ID is null then
    select BUG_TYPE_ID_SEQ.nextval into :NEW.BUG_TYPE_ID from sys.dual;
  end if;
end;
/   

------------------------------RESOURCES-------------------------------------

CREATE TABLE  "RESOURCES" 
   (	"EMP_ID" NUMBER(7,0) NOT NULL ENABLE, 
  "PROJECT_ID" NUMBER(7,0), 
	"EMP_FIRST_NAME" VARCHAR2(30) NOT NULL ENABLE,
  "EMP_LAST_NAME" VARCHAR2(30) NOT NULL ENABLE, 
	"EMP_ROLE" VARCHAR2(10) NOT NULL ENABLE, 
	 CONSTRAINT "EMP_ID_PK" PRIMARY KEY ("EMP_ID")
  USING INDEX  ENABLE, 
	 CONSTRAINT "RESOURCES_EMP_ROLE_CHK" CHECK (EMP_ROLE IN('PROGRAMMER', 'TESTER', 'MANAGER')) ENABLE, 
	 CONSTRAINT "RESOURCES_PROJECT_ID_FK" FOREIGN KEY(PROJECT_ID) REFERENCES PROJECTS(PROJECT_ID) ENABLE
   )
/

CREATE SEQUENCE   "EMP_ID_SEQ"
/

CREATE OR REPLACE TRIGGER  "BI_RESOURCES" 
  before insert on "RESOURCES"               
  for each row  
begin   
  if :NEW.EMP_ID is null then 
    select EMP_ID_SEQ.nextval into :NEW.EMP_ID from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_RESOURCES" ENABLE
/


------------------------------BUGS-------------------------------------

CREATE TABLE  "BUGS" 
   (	"BUG_ID" NUMBER(7,0) NOT NULL ENABLE,
  "BUG_TYPE_ID" NUMBER(7,0) NOT NULL ENABLE,
  "PROJECT_ID" NUMBER(7,0) NOT NULL ENABLE, 
  "DESCRIPTION" VARCHAR2(500) NOT NULL ENABLE,
  "STATUS" VARCHAR2(10) NOT NULL ENABLE,
  "PRIORITY" NUMBER(1),
	"CREATED_BY" VARCHAR2(100), 
	"CREATED_ON" DATE, 
	"MODIFIED_BY" VARCHAR2(100), 
	"MODIFIED_ON" DATE, 
	 CONSTRAINT "BUG_ID_PK" PRIMARY KEY ("BUG_ID")
  USING INDEX  ENABLE, 
   CONSTRAINT "BUGS_STATUS_CHK" CHECK (STATUS IN('NEW', 'ASSIGNED', 'TESTING', 'RESOLVED')) ENABLE,
   CONSTRAINT "BUGS_PRIORITY_CHK" CHECK (PRIORITY is null or PRIORITY between 1 and 5) ENABLE,
   CONSTRAINT "BUGS_BUG_TYPE_ID_FK" FOREIGN KEY(BUG_TYPE_ID) REFERENCES BUG_TYPE(BUG_TYPE_ID) ENABLE,
	 CONSTRAINT "BUGS_PROJECT_ID_FK" FOREIGN KEY(PROJECT_ID) REFERENCES PROJECTS(PROJECT_ID) ENABLE
   )
/

CREATE SEQUENCE   "BUG_ID_SEQ"
/

CREATE OR REPLACE TRIGGER  "BI_BUGS" 
  before insert on "BUGS"               
  for each row  
begin   
  if :NEW.BUG_ID is null then 
    select BUG_ID_SEQ.nextval into :NEW.BUG_ID from sys.dual; 
  end if; 
end;

/
ALTER TRIGGER  "BI_BUGS" ENABLE
/





------------------------------RESOURCE ASSIGNATION-------------------------------------

CREATE TABLE  "RESOURCE_ASSIGNATION" 
   (	"BUG_ID" NUMBER(7,0) NOT NULL ENABLE,
  "EMP_ID" NUMBER(7,0) NOT NULL ENABLE,
	"START_DATE" DATE NOT NULL ENABLE, 
  "END_DATE" DATE, 
	 CONSTRAINT "RESOURCE_ASSIGN_PK" PRIMARY KEY ("BUG_ID", "EMP_ID")
  USING INDEX  ENABLE, 
   CONSTRAINT "RESOURCE_ASSIGN_END_DATE_CHK" CHECK (END_DATE >= START_DATE) ENABLE,
   CONSTRAINT "RESOURCE_ASSIGN_BUG_ID_FK" FOREIGN KEY(BUG_ID) REFERENCES BUGS(BUG_ID) ENABLE,
	 CONSTRAINT "RESOURCE_ASSIGN_EMP_ID_FK" FOREIGN KEY(EMP_ID) REFERENCES RESOURCES(EMP_ID) ENABLE
   )
/

------------------------------BUG NOTES-------------------------------------

CREATE TABLE  "BUG_NOTES"
   (	"BUG_NOTE_ID" NUMBER(7,0) NOT NULL ENABLE,
  "BUG_ID" NUMBER(7,0) NOT NULL ENABLE, 
  "BUG_NOTE" VARCHAR2(500) NOT NULL ENABLE,
	"CREATED_BY" VARCHAR2(100), 
	"LAST_MODIFIED_ON" DATE, 
	 CONSTRAINT "BUG_NOTE_ID_PK" PRIMARY KEY ("BUG_NOTE_ID")
  USING INDEX  ENABLE, 
    CONSTRAINT "BUG_NOTES_BUG_ID_FK" FOREIGN KEY(BUG_ID) REFERENCES BUGS(BUG_ID) ENABLE
   )
/

CREATE SEQUENCE   "BUG_NOTE_ID_SEQ"
/

CREATE OR REPLACE TRIGGER  "BI_BUG_NOTES" 
  before insert on "BUG_NOTES"               
  for each row  
begin   
  if :NEW.BUG_NOTE_ID is null then 
    select BUG_NOTE_ID_SEQ.nextval into :NEW.BUG_NOTE_ID from sys.dual; 
  end if; 
end; 

/
ALTER TRIGGER  "BI_BUG_NOTES" ENABLE
/


/* 
ACTIVE_USER AND BIU_BUGS and BIU_BUG_NOTES 

A technique to simulate a front end, and a loging system
(created_by, created_on, modified_by, modified_on)

A table ACTIVE USER is created containing ever 1 record.
In several funtions in BUG_TRACKER CRUD, the user calling the function is saved to this table.
then when a BUG or BUG_NOTE is inserted or updated, the TRIGGERS take that user data 
to populate created_by or modified_by fields, recording who perfomed the action.

*/

CREATE TABLE  "ACTIVE_USER" 
   (	
   "ACTIVE_USER_ID" NUMBER(7,0) NOT NULL ENABLE, 
   "EMP_ID" NUMBER(7,0) NOT NULL ENABLE, 
	"EMP_FIRST_NAME" VARCHAR2(30) NOT NULL ENABLE,
  "EMP_LAST_NAME" VARCHAR2(30) NOT NULL ENABLE, 
	"EMP_ROLE" VARCHAR2(10) NOT NULL ENABLE,
  CONSTRAINT "ACTIVE_USER_ID" PRIMARY KEY ("ACTIVE_USER_ID")
  );

/* THESE TWO TRIGGERS INTERFERE WITH initData.sql, WHERE CUSTOM DATA IS ENTERED IN CREATED_BY, MODIFIED_BY attributes*/
/* THEY ARE DEACTIVATED FOR NOW*/

CREATE OR REPLACE TRIGGER  "BIU_BUGS" 
  before insert or update on "BUGS"               
  for each row  
begin   
  if inserting then
    select emp_id || ' - ' || emp_first_name || ' ' || emp_last_name || ' - ' || emp_role into :NEW.created_by from active_user where active_user_id=1;
    :NEW.created_on:=sysdate;
  elsif updating then
    select emp_id || ' - ' || emp_first_name || ' ' || emp_last_name || ' - ' || emp_role into :NEW.modified_by from active_user where active_user_id=1;
    :NEW.modified_on:=sysdate;
  end if;
end; 

/
ALTER TRIGGER "BIU_BUGS" DISABLE
/

CREATE OR REPLACE TRIGGER  "BIU_BUG_NOTES" 
  before insert or update on "BUG_NOTES"               
  for each row  
begin   
    select emp_id || ' - ' || emp_first_name || ' ' || emp_last_name || ' - ' || emp_role into :NEW.created_by from active_user where active_user_id=1;
    :NEW.last_modified_on:=sysdate;
end; 

/
ALTER TRIGGER "BIU_BUG_NOTES" DISABLE
/