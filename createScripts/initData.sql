------------------------------------INITIAL VALUES FOR BUG_TRACKER---------------------------------------------

/*
DEFAULT TEST VALUES
ALL date values are created with SYSDATE - (noDAYS) : meaning, when ever the test data is newly inserted, objects will have recent dates.

*/


---------------------------------------------PROJECTS----------------------------------------------------------
INSERT INTO PROJECTS(project_name, start_date, target_end_date, created_by, created_on)
  VALUES('Arturas', sysdate-30, sysdate +100, '11 - Patsy Popper - MANAGER', sysdate-30);
INSERT INTO PROJECTS(project_name, start_date, target_end_date, created_by, created_on)
  VALUES('Soliloquy Eternam', sysdate-20, sysdate +200, '12 - Kletus Cassidy - MANAGER', sysdate-20);
INSERT INTO PROJECTS(project_name, start_date, target_end_date, created_by, created_on)
  VALUES('Nova Loci', sysdate-10, sysdate +250, '11 - Patsy Popper - MANAGER', sysdate-10);
  
  
---------------------------------------------BUG_TYPE----------------------------------------------------------
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Functional errors', 
  'When the software does not act as it is intended, this is a functionality error. ' 
  ||'Functionality errors are a broad category of errors and can range from basic functionalities, '
  ||'such as simple buttons that are unclickable, all the way up to the inability to use the main functionality of the software.'
  );
  

INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Performance Defect', 
  'One of the more common types of software bugs, performance defects include a software that runs '
  ||'at a slower speed than required or a response time that is longer than acceptable for the project’s requirements.'
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Usability Defect', 
  'This bug makes a piece of software difficult or inconvenient to use. '
  ||'Examples of usability defects include a complex content layout or a signup feature which is too complicated.'
  );
  
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Compatibility Defects', 
  'Compatibility errors occur when an application does not perform consistently on different types of hardware, '
  ||'operating systems, browser compatibility, or when performing with particular software under formal specifications.'
  );
  
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Security Defects', 
  'Security errors may be slightly different from other types of software bugs in that they make your project vulnerable. '
  ||'A security bug opens your software, your company, and your clients up to a serious potential attack.'
  );

INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Syntax Error', 
  'Syntax errors are one of the more common software bugs and will prevent your application from being compiled properly. '
  ||'This type of issue happens when your code is missing or has incorrect characters. '
  ||'A misspelled command or missing bracket are examples that could cause this software defect.'
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Logic errors', 
  'Logic errors is one of the types of coding errors that can cause your software to produce the wrong output, '
  ||'crash, or even software failure. Logic defects are an error in the flow of your software, such as an infinite loop.'
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Unit-level Bug', 
  'Agile teams and other software developers typically perform unit testing, '
  ||'testing out a smaller section of the code as a whole to ensure that it works as it should. '
  ||'It is during this testing process that teams will start to discover unit-level bugs, such as calculation errors and basic logic bugs.'
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'System-level Integration Bug', 
  'These errors happen when there’s a mistake in the interaction between two different subsystems. '
  ||'These types of software bugs are generally more difficult to fix because there are multiple software systems involved, '
  ||'often written by different developers. '
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Code Suplication', 
  'This defect occurs when a sequence of code occurs more than once. '
  ||'This can mean that lines of code are literally duplicated, character for character, '
  ||'but it can also apply to code that has the same tokens.'
  );
  
INSERT INTO BUG_TYPE(bug_type_name, bug_type_description)
  VALUES(
  'Data Type Mismatch', 
  'When one of these software flaws occurs, it is because the wrong data type has been assigned to a variable or parameter. '
  ||'An example is when special characters are allowed in a name field or letters and numbers have been swapped incorrectly.'
  );
  

---------------------------------------------RESOURCES----------------------------------------------------------

INSERT INTO ACTIVE_USER(active_user_id, emp_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 1, 'John', 'Smith', 'PROGRAMMER');


INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 'John', 'Smith', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 'Albert', 'Vance', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 'Julia', 'Roberts', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 'Martha', 'Childs', 'TESTER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(1, 'George', 'Takae', 'TESTER');  
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(2, 'Michael', 'Agustine', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(2, 'Suzie', 'Que', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(2, 'Scottie', 'McFly', 'PROGRAMMER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(2, 'Vince', 'Martins', 'TESTER');
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(2, 'Mary', 'Flores', 'TESTER');  
  
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(null, 'Patsy', 'Popper', 'MANAGER'); 
INSERT INTO RESOURCES(project_id, emp_first_name, emp_last_name, emp_role)
  VALUES(null, 'Kletus', 'Cassidy', 'MANAGER');   
  
  
  
---------------------------------------------BUGS - PROJECT 1----------------------------------------------------------

---------------------BUG 1

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  1, 1, 
  'Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. '
  ||'Nunc id nunc mollis, vestibulum magna in, consequat lorem. Donec sed placerat erat. Nam blandit tortor nec ex rhoncus, ut rhoncus lectus. ',
  'RESOLVED', null, '1 - John Smith - PROGRAMMER', sysdate -29.2, '5 - George Takae - TESTER', sysdate -5.6 
  ); 

-----------Asignation bug 1
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(1, 1, sysdate -27.5, sysdate -5.6 ); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(1, 2, sysdate -26.1, sysdate -5.6 );
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(1, 5, sysdate-7.7, sysdate -5.6 );  
  
-----------Notes bug 1
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'This looks like a bug...', '1 - John Smith - PROGRAMMER', sysdate -27.5 );
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'Yeah it''s a bug alright', '2 - Albert Vance - PROGRAMMER', sysdate -26.6);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'What should we do?', '1 - John Smith - PROGRAMMER', sysdate -25.7 );
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'Get lunch maybe?', '2 - Albert Vance - PROGRAMMER', sysdate -23.1);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'I mean about the bug...', '1 - John Smith - PROGRAMMER', sysdate -22.8);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'Oh... Fix it...', '2 - Albert Vance - PROGRAMMER', sysdate -21.7);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, '...Fixing...', '1 - John Smith - PROGRAMMER', sysdate -20.6);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(1, 'Resolved!', '5 - George Takae - TESTER', sysdate -5.6);  

---------------------BUG 2
INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  3, 1, 
  'Sed tempor nisi scelerisque suscipit viverra. Etiam aliquam neque ac massa consectetur vulputate. Praesent lacinia sem sed neque sagittis, ut lobortis eros. ',
  'RESOLVED', null, '3 - Julia Roberts - PROGRAMMER', sysdate -29.4,'4 - Martha Childs - TESTER', sysdate -12.9
  ); 

 -----------Asignation bug 2
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(2, 3, sysdate - 28.4 , sysdate -12.9);
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(2, 2, sysdate - 28.3 , sysdate -12.9); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(2, 4, sysdate - 25.1, sysdate -12.9);  
  
-----------Notes bug 2
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'I''m worried about my cat mittens', '3 - Julia Roberts - PROGRAMMER', sysdate - 28.3);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'I''m worried about you! For god''s sakes woman, stop talking about your cats!', '2 - Albert Vance- PROGRAMMER', sysdate - 28.2);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'Fine... Let''s get to work.', '3 - Julia Roberts - PROGRAMMER', sysdate - 27.7);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'Potential solution discoverd. setting to TESTING and passing on to Martha.', '2 - Albert Vance- PROGRAMMER', sysdate - 25.2);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'I need to run some regression tests, might take a few weeks.', '4 - Martha Childs - TESTER', sysdate - 25.1);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(2, 'It works! good work. Bug RESOLVED', '4 - Martha Childs - TESTER', sysdate -12.9); 
  
  
---------------------BUG 3

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  5, 1, 
  'Etiam pretium in augue eu luctus. Nulla et ex eros. Nulla facilisi. Aenean sed ultrices erat. Donec.',
  'ASSIGNED', 1, '2 - Albert Vance - PROGRAMMER', sysdate- 20.1, '2 - Albert Vance - PROGRAMMER', sysdate - 19.9
  );
  
 -----------Asignation bug 3
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(3, 2, sysdate - 20.1 , null);
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(3, 1, sysdate - 19.9 , null); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(3, 3, sysdate - 19.9, null);  
  
-----------Notes bug 3
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(3, 'We have a major security breach here. We''re going to need all hands on deck.', '2 - Albert Vance - PROGRAMMER', sysdate - 20.1);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(3, 'I knew we shouldn''t have subcontracted to ex-NSA agents...', '3 - Julia Roberts - PROGRAMMER', sysdate - 19.8);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(3, 'This thing is so full of holes, it makes swiss cheeze look like regular cheeze...', '1 - John Smith - PROGRAMMER', sysdate - 19.7);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(3, 'Don''t quit your day job, john.', '2 - Albert Vance - PROGRAMMER', sysdate - 18.2);

---------------------BUG 4

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  9, 1, 
  'Proin id tellus posuere, vestibulum mi at, vestibulum lacus. Vestibulum ut efficitur quam. Mauris mattis gravida ex. Donec est tellus, semper et.',
  'TESTING', 4,'1 - John Smith - PROGRAMMER', sysdate - 12.4, '4 - Martha Childs - TESTER', sysdate -1.3
  );
  
 -----------Asignation bug 4

INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(4, 3, sysdate - 12.4, null);  
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(4, 4, sysdate -1.3, null); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(4, 5, sysdate -0.8, null);  
  
-----------Notes bug 4
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(4, 'This shouldn''t take too long to resolve', '3 - Julia Roberts - PROGRAMMER', sysdate - 12.1);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(4, 'Alright Marta, ball''s in your court', '3 - Julia Roberts - PROGRAMMER', sysdate - 1.3);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(4, 'Starting Tests...', '4 - Martha Childs - TESTER', sysdate - 1);

INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(4, 'I''ll take a crack at it too', '5 - George Takae - TESTER', sysdate - 0.8);
  
  
---------------------BUG 5

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  7, 1, 
  'Vestibulum auctor velit sit amet leo sagittis, eu fermentum orci pellentesque. Mauris tempus et odio sed sollicitudin. Vestibulum lobortis ante libero. '
  ||'Integer aliquet mi sit amet ligula auctor, ut facilisis felis bibendum. Curabitur dapibus urna nunc, sed pulvinar dolor aliquam in. Cras enim dui, pharetra.',
  'ASSIGNED', 3,'4 - Martha Childs - TESTER', sysdate-4.9, '1 - John Smith - PROGRAMMER', sysdate-1.1
  );
  
 -----------Asignation bug 5
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(5, 1, sysdate -1.1, null);  
 
 -----------Notes bug 5
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(5, 'Haven''t had a chance to look into this yet', '1 - John Smith - PROGRAMMER', sysdate - 1);
  
---------------------BUG 6

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  2, 1, 
  'Curabitur semper aliquam facilisis. Sed eget fermentum augue, vel mattis tortor. Sed consectetur ex vel dui gravida, sit amet aliquam erat pulvinar. '
  ||'Aliquam ac ornare ante. Cras non posuere sapien. Morbi ultricies maximus odio sed ullamcorper. Quisque vel.',
  'NEW', 2, '3 - Julia Roberts - PROGRAMMER', sysdate-3.7, null, null
  );  
  
---------------------BUG 7

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  8, 1, 
  'Curabitur semper aliquam facilisis. Sed eget fermentum augue, vel mattis tortor. Sed consectetur ex vel dui gravida, sit amet aliquam erat pulvinar. '
  ||'Aliquam ac ornare ante. Cras non posuere sapien. Morbi ultricies maximus odio sed ullamcorper. Quisque vel.',
  'NEW', 5, '2 - Albert Vance - PROGRAMMER', sysdate-3.7, null, null
  );    
 

---------------------------------------------BUGS - PROJECT 2----------------------------------------------------------


---------------------BUG 8

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  11, 2, 
  'Morbi sit amet enim ex. Curabitur viverra lacus non nulla porta malesuada. Praesent tincidunt ligula arcu, eget finibus est.',
  'ASSIGNED', 2, '6 - Michael Agustine - PROGRAMMER', sysdate -19.2, '6 - Michael Agustine - PROGRAMMER', sysdate -17.5
  ); 

-----------Asignation bug 8
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(8, 6, sysdate -17.5, null ); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(8, 7, sysdate -16.1, null );

  
-----------Notes bug 8
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'This feels familiar', '6 - Michael Agustine - PROGRAMMER', sysdate -17.5 );
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'Yes it does Mike.', '7 - Suzie Que - PROGRAMMER', sysdate -16.6);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'What does that mean?', '6 - Michael Agustine - PROGRAMMER', sysdate -15.7 );
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'Deja Vue?', '7 - Suzie Que - PROGRAMMER', sysdate -13.1);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'I mean about the bug...', '6 - Michael Agustine - PROGRAMMER', sysdate -12.8);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, 'Oh... I don''t know...', '7 - Suzie Que - PROGRAMMER', sysdate -11.7);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(8, '...Fixing...', '6 - Michael Agustine - PROGRAMMER', sysdate -10.6);


---------------------BUG 9
INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  2, 2, 
  'Nulla facilisi. In placerat dui eu dui pharetra, et rutrum lectus faucibus. Curabitur vitae vestibulum velit. Nunc tortor justo, tempus ut posuere convallis.',
  'RESOLVED', null, '8 - Scottie McFly - PROGRAMMER', sysdate -19.4,'9 - Vince Martins - TESTER', sysdate -2.9
  ); 

 -----------Asignation bug 9
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(9, 8, sysdate - 18.4 , sysdate -2.9);
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(9, 7, sysdate - 18.3 , sysdate -2.9); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(9, 9, sysdate - 15.1, sysdate -2.9);  
  
-----------Notes bug 9
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'Have you ever pluged a Dutch Dyke with your finger to prevent a flood?', '8 - Scottie McFly - PROGRAMMER', sysdate - 18.3);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'Dear God, is that a euphemism?!', '7 - Suzie Que - PROGRAMMER', sysdate - 18.2);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'No..', '8 - Scottie McFly - PROGRAMMER', sysdate - 17.7);
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'Moving allong... Potential solution discoverd. setting to TESTING and passing on to Vince.', '7 - Suzie Que - PROGRAMMER', sysdate - 15.2);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'I''ve pluged a Dutch Dyke before... but all it got me was a reprimand from HR', '9 - Vince Martins - TESTER', sysdate - 15.1);  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(9, 'Bug RESOLVED', '9 - Vince Martins - TESTER', sysdate -2.9); 
  
  
---------------------BUG 10

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  5, 2, 
  'Curabitur sollicitudin, orci eget tristique lacinia, neque nulla fringilla felis, vitae lobortis elit justo sed diam. '
  ||'Cras dapibus ligula dui, at gravida erat vestibulum nec. In elementum convallis libero, in scelerisque nibh accumsan ut. '
  ||'Fusce a cursus justo. Donec purus diam, elementum nec molestie.',
  'ASSIGNED', 1, '7 - Suzie Que - PROGRAMMER', sysdate- 10.1, '7 - Suzie Que - PROGRAMMER', sysdate - 9.9
  );
  
 -----------Asignation bug 10
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(10, 7, sysdate - 10.1 , null);
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(10, 6, sysdate - 9.9 , null); 
INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(10, 8, sysdate - 9.9, null);  
  
-----------Notes bug 10
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(10, 'We have a major security breach here.', '7 - Suzie Que - PROGRAMMER', sysdate - 10.1);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(10, 'Leave it to ex-KGB agents to mess up our product launch', '8 - Scottie McFly - PROGRAMMER', sysdate - 9.8);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(10, 'This company subcontracts to so many socipaths, we could run for congress.', '6 - Michael Agustine - PROGRAMMER', sysdate - 9.7);
  
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(10, 'Don''t quit your day job Mike.', '7 - Suzie Que - PROGRAMMER', sysdate - 8.2);

---------------------BUG 11

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  8, 2, 
  'Proin id tellus posuere, vestibulum mi at, vestibulum lacus. Vestibulum ut efficitur quam. Mauris mattis gravida ex. Donec est tellus, semper et.',
  'ASSIGNED', 4,'6 - Michael Agustine - PROGRAMMER', sysdate - 2.4, null, null
  );
  
 -----------Asignation bug 11

INSERT INTO RESOURCE_ASSIGNATION(bug_id, emp_id, start_date, end_date)
  VALUES(11, 8, sysdate - 2.4, null);  

-----------Notes bug 11
INSERT INTO BUG_NOTES(bug_id, bug_note, created_by, last_modified_on)
  VALUES(11, 'Gee Golly, this will be a cakewalk', '8 - Scottie McFly - PROGRAMMER', sysdate - 2.1);
  

---------------------BUG 12

INSERT INTO BUGS(bug_type_id, project_id, description, status, priority, created_by, created_on, modified_by, modified_on)
  VALUES(
  2, 2, 
  'Neque porro quisquam est qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.',
  'NEW', 5,'10 - Mary Flores - TESTER', sysdate - 1.1, null, null
  );
  
  
/* THESE TWO TRIGGERS INTERFERE WITH initData.sql, WHERE CUSTOM DATA IS ENTERED IN CREATED_BY, MODIFIED_BY attributes*/
/* SINCE initData.sql is finished, we can reactivate them*/
  
/
ALTER TRIGGER "BIU_BUGS" ENABLE
/
  
/
ALTER TRIGGER "BIU_BUG_NOTES" ENABLE
/
