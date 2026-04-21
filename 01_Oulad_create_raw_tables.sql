create database oulad_db;
use oulad_db;

drop table if exists RAW_ASSESSMENTS;
CREATE TABLE RAW_ASSESSMENTS(
code_module varchar(10),
code_presentation varchar(10),
id_assessment varchar(10),
assessment_type varchar(20),
assessment_date varchar(10),
weight varchar(10)
);

drop table if exists RAW_COURSES;
CREATE TABLE RAW_COURSES(
code_module varchar(10),
code_presentation varchar(10),
module_presentation_length varchar(10)
);

drop table if exists RAW_STUDENTINFO;
CREATE TABLE RAW_STUDENTINFO(
code_module varchar(10),
code_presentation varchar(10),
id_student	varchar(10),
gender varchar(10),
region	varchar(50),
highest_education varchar(100),
imd_band varchar(20),
age_band	varchar(20),
num_of_prev_attempts varchar(10),
studied_credits	varchar(10),
disability	varchar(5),
final_result varchar(20)
);

drop table if exists RAW_STUDENTREGISTRATION;
CREATE TABLE RAW_STUDENTREGISTRATION(
code_module	varchar(10),
code_presentation varchar(10),	
id_student	varchar(10),
date_registration varchar(10),
date_unregistration varchar(10)
);


drop table if exists RAW_STUDENT_VLE;
CREATE TABLE RAW_STUDENT_VLE(
code_module	varchar(10),
code_presentation varchar(10),
id_student varchar(10),
id_site	varchar(10),
interaction_date varchar(10),
sum_click varchar(10)
);

drop table if exists RAW_VLE;
CREATE TABLE RAW_VLE(
id_site	varchar(10),
code_module	varchar(10),
code_presentation	varchar(10),
activity_type	varchar(60),
week_from varchar(10),
week_to varchar(10)
);

drop table if exists RAW_STUDENTASSESSMENTS;
CREATE TABLE RAW_STUDENTASSESSMENTS(
id_assessment varchar(10),
id_student	varchar(10),
date_submitted	varchar(10),
is_banked	varchar(10),
score varchar(10)
);




