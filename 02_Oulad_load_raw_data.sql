use oulad_db;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/assessments.csv'
INTO TABLE raw_assessments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS; 
 
 LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/courses.csv'
INTO TABLE raw_courses
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/studentInfo.csv'
INTO TABLE raw_studentInfo
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/studentRegistration.csv'
INTO TABLE raw_studentRegistration
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/studentVle.csv'
INTO TABLE raw_student_vle
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- student_vle is the largest in the OULAD dataset with 10M rows

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/vle.csv'
INTO TABLE raw_vle
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;


LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 9.3/Data/oulad_db/studentAssessment.csv'
INTO TABLE raw_studentAssessments
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;
