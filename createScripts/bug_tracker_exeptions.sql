create or replace
PACKAGE BUG_TRACKER_EXCEPTIONS
IS

    INVALID_USER_ID EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_USER_ID, -20101);
    
    INVALID_BUG_TYPE EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_USER_ID, -20102);
    
    INVALID_PROJECT EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_USER_ID, -20103);
    
    NOT_ASSIGNED_PROJECT EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_USER_ID, -20104);
    
    INVALID_BUG_ID EXCEPTION;
    PRAGMA EXCEPTION_INIT(INVALID_BUG_ID, -20105);
    
    BUG_CYCLE_NOT_RESPECTED EXCEPTION;
    PRAGMA EXCEPTION_INIT(BUG_CYCLE_NOT_RESPECTED, -20111);
    
    NOT_ASSIGNED_BUG EXCEPTION;
    PRAGMA EXCEPTION_INIT(NOT_ASSIGNED_BUG, -20112);
    
    NOT_A_PROGRAMER EXCEPTION;
    PRAGMA EXCEPTION_INIT(NOT_A_PROGRAMER, -20113);  
      
    UNSUFISCIENT_PRIVILEDGES EXCEPTION;
    PRAGMA EXCEPTION_INIT(UNSUFISCIENT_PRIVILEDGES, -20114);
      
    NOT_A_TESTER EXCEPTION;
    PRAGMA EXCEPTION_INIT(NOT_A_TESTER, -20115);
      

END BUG_TRACKER_EXCEPTIONS;