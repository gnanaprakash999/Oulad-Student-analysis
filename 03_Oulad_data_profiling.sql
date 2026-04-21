use oulad_db;

-- 1. raw_assessments
select * from raw_assessments
limit 50;

-- Null & blank checks
select 
	sum(code_module is null or trim(code_module) = ''),
    sum(code_presentation is null or trim(code_presentation) = ''),
    sum(id_assessment is null or trim(id_assessment)=''),
    sum(assessment_type is null or trim(assessment_type)= ''),
    sum(assessment_date is null or trim(assessment_date)=''),
    sum(weight is null or trim(weight) = '')
from raw_assessments;

 -- Note 1 : If the assessment_date is null it is usually scheduled at the end of the last presentation week.
 
-- Duplicate checks
select
	code_module,code_presentation,id_assessment,
	count(*)
from raw_assessments
group by code_module,code_presentation,id_assessment
HAVING count(*)>1;

-- Assessment date anomalies check
SELECT assessment_date 
FROM raw_assessments
ORDER BY CAST(assessment_date AS SIGNED) asc;

SELECT assessment_date 
FROM raw_assessments
ORDER BY CAST(assessment_date AS SIGNED) DESC;

-- Weight anomalies check
select weight
from raw_assessments
order by cast(weight as signed) desc;

select weight
from raw_assessments
order by cast(weight as signed) asc;

select 
	code_module,code_presentation,assessment_type,
	sum(weight)
from raw_assessments
group by code_module,code_presentation,assessment_type;

-- 2. raw_courses
select * from raw_courses
limit 50;

-- Null/blank checks
select 
    sum(code_module is null or trim(code_module) = ''),
    sum(code_presentation is null or trim(code_presentation) = ''),
    sum(module_presentation_length is null or trim(module_presentation_length) = '')
from raw_courses;

-- Duplicate check
select 
	code_module,
    code_presentation,
    count(*)
from raw_courses
group by code_module,
    code_presentation
having count(*)>1;

-- 3. raw_student_vle
select * from raw_student_vle
limit 50;

select count(*) from raw_student_vle;
-- 10 million rows returned so creating an index to 
-- optimize further query

-- Creating index to speed up profiling
create index idx_student_vle 
on raw_student_vle(
	code_module,
    code_presentation,
    id_student,
    id_site,
    interaction_date
    );

-- Null/Blank checks
select 
	sum(code_module is null or code_module = ''),
    sum(code_presentation is null or code_presentation = ''),
    sum(id_student is null or id_student = ''),
    sum(id_site is null or id_site = ''),
    sum(interaction_date is null or interaction_date = ''),
    sum(sum_click is null or sum_click = '')
from raw_student_vle;

-- Duplicate checks
/*
Note 2 :
This dataset gives the information about number of clicks a student
clicked in a particular day or more than once in a particular day
since we dont have a unique id like an event id or a specific time
even if there are identical rows there is a possibility that a person
couldve opened the site multiple times in a single day with same amount of 
clicks */

-- But still lets go ahead and check
select 
	code_module,
	code_presentation,
	id_student,
    id_site,
	interaction_date,
	sum_click,
    count(*)
from raw_student_vle
group by
	code_module,
	code_presentation,
	id_student,
    id_site,
	interaction_date,
	sum_click
having count(*)>1
order by count(*);

-- interaction date anomalies
select 
max(interaction_date),
min(interaction_date)
from raw_student_vle;

-- click anomalies
SELECT 
    MIN(cast(sum_click as unsigned)),
    MAX(cast(sum_click as unsigned))
FROM raw_student_vle;

SELECT 
    sum_click,
    COUNT(*) AS freq
FROM raw_student_vle
GROUP BY sum_click
ORDER BY sum_click DESC
LIMIT 20;

-- 4. raw_studentassessments
select * from raw_studentassessments
limit 50;

select *
from raw_studentassessments
where cast(is_banked as unsigned) = 1
order by id_student, id_assessment;

-- blank/null value checks
select 
	sum(id_assessment is null or trim(id_assessment) = ''),
    sum(id_student is null or trim(id_student) = ''),
    sum(date_submitted is null or trim(date_submitted) = ''),
    sum(is_banked is null or trim(is_banked) = ''),
    sum(score is null or trim(score) = '')
from raw_studentassessments;

-- blanks found in score
-- further analyzing to check any useful insights
-- looking at all other assessment scores of students who have blanks in atleast one assessment 

-- Duplicate checks
select 
	id_assessment,
	id_student,
    date_submitted,
    is_banked,
    score,
    count(*)
from raw_studentassessments
group by
	id_assessment,
	id_student,
    date_submitted,
    is_banked,
    score
having count(*)>1;

-- primary key duplicate check
SELECT
    id_assessment,
    id_student,
    COUNT(*) AS cnt
FROM raw_studentassessments
GROUP BY 
	id_assessment, 
	id_student
HAVING COUNT(*) > 1;

-- Date_submitted anomaly checks
select distinct date_submitted
from raw_studentassessments
order by cast(date_submitted as unsigned);

-- Checking to see if there is a huge gap between max date_submitted and the 2nd maximum date_submitted 
select 
	distinct date_submitted 
from raw_studentassessments
order by date_submitted desc
limit 10;

-- is_banked anomaly checks
select * from raw_studentassessments
where cast(is_banked as unsigned) not in (1,0);

-- Score anomaly checks
select 
    max(cast(nullif(trim(score), '') as unsigned)),
    min(cast(nullif(trim(score), '') as unsigned))
from raw_studentassessments;

-- 5. raw_studentinfo
select * from raw_studentinfo
limit 50;

-- null/blank checks
select 
	sum(code_module is null or code_module =''),
    sum(code_presentation is null or code_presentation =''),
    sum(id_student is null or id_student =''),
    sum(gender is null or gender = ''),
    sum(region is null or region = ''),
    sum(highest_education is null or highest_education = ''),
    sum(imd_band is null or imd_band = ''),
    sum(age_band is null or age_band = ''),
    sum(num_of_prev_attempts is null or num_of_prev_attempts = ''),
    sum(studied_credits is null or studied_credits = ''),
    sum(disability is null or disability = ''),
    sum(final_result is null or final_result = '')
from raw_studentinfo;

-- imd_band blanks check
select * from raw_studentinfo
where imd_band=''; 
-- Note 3 : Few blanks detected, this needs to be converted to null while cleaning
-- data incosistencies detected like 10-20

-- Note 4 : this data needs to be fixed during cleaning
    
-- Duplicate check
select 
	code_module,
    code_presentation,
    id_student,
    gender,
    region,
    highest_education,
    imd_band,
    age_band,
    num_of_prev_attempts,
    studied_credits,
    disability,
    final_result,
    count(*)
from raw_studentinfo
group by
	code_module,
    code_presentation,
    id_student,
    gender,
    region,
    highest_education,
    imd_band,
    age_band,
    num_of_prev_attempts,
    studied_credits,
    disability,
    final_result
having count(*)>1;

-- Primary key Duplicate check
select 
	code_module,
    code_presentation,
	id_student,
    count(*)
from raw_studentinfo
group by 
	code_module,
    code_presentation,
	id_student
having count(*)>1;

-- gender anamoly check
select * from raw_studentinfo
where gender not in ('M','F');

-- age_band checks
select distinct age_band from raw_studentinfo;
    
-- num_of_prev_attempts anomaly checks
select 
	max(num_of_prev_attempts),
	min(num_of_prev_attempts)
from raw_studentinfo;

select distinct num_of_prev_attempts
from raw_studentinfo
order by cast(num_of_prev_attempts as unsigned) desc;

-- studied_credits anomaly check
select 
	min(cast(studied_credits as unsigned)),
	max(cast(studied_credits as unsigned))
from raw_studentinfo;

select distinct studied_credits
from raw_studentinfo
order by cast(studied_credits as unsigned) desc ;

-- disability anomaly checks
select * from raw_studentinfo where disability not in ('N','Y');

-- Final_result check
select final_result,count(*)
from raw_studentinfo
group by final_result;

select * from raw_studentinfo
where final_result not in ('Pass','Withdrawn','Fail','Distinction');

-- 6. raw_studentregistration
select * from raw_studentregistration;

-- Null/blank check
select 
	sum(code_module is null or code_module =''),
    sum(code_presentation is null or code_presentation = ''),
	sum(id_student is null or id_student = ''),
    sum(date_registration is null or date_registration = ''),
    sum(date_unregistration is null or date_unregistration = '')
from raw_studentregistration;


select * from raw_studentregistration
where date_registration = '';

-- date_registration and date_unregistration have blanks

/*
Note 5 : according to the data "Students, who completed the course 
have this (date_unregistration) field empty. Students who unregistered have Withdrawal as 
the value of the final_result column in the studentInfo.csv file"
*/

-- Duplicate check
select 
code_module,
code_presentation,
id_student,
date_registration,
date_unregistration,
count(*)
from raw_studentregistration
group by
code_module,
code_presentation,
id_student,
date_registration,
date_unregistration
having count(*)>1;

-- Primary key duplicate check
select
	code_module,
    code_presentation,
    id_student,
    count(*)
from raw_studentregistration
group by 
	code_module,
    code_presentation,
    id_student
having count(*)>1;

-- code_module anomaly check
select distinct code_module from raw_studentregistration
group by code_module;

-- code_presentation anomaly check
select distinct code_presentation from raw_studentregistration
group by code_presentation;

-- id_student anomaly check
SELECT *
from raw_studentregistration
where id_student <= 0;

-- date_registration anomaly check
select distinct date_registration from raw_studentregistration
order by cast(date_registration as unsigned)  desc limit 10;

select distinct date_registration from raw_studentregistration
order by cast(date_registration as unsigned) asc limit 10;

-- date_unregistration anomaly check
select distinct date_unregistration from raw_studentregistration
order by cast(date_unregistration as unsigned)  desc limit 10;

select distinct date_unregistration from raw_studentregistration
order by cast(date_unregistration as unsigned) asc limit 10;


-- 7. raw_vle
select * from raw_vle
limit 50;

-- Null/blank check
select 
	sum(id_site is null or id_site = ''),
	sum(code_module is null or code_module = ''),
	sum(code_presentation is null or code_presentation =''),
    sum(activity_type is null or activity_type =''),
    sum(week_from is null or week_from = ''),
    sum(week_to is null or week_to = '')
from raw_vle;

-- Duplicate check
select 
	id_site,
	code_module,
	code_presentation,
    activity_type,
    week_from,
    week_to,
    count(*)
from raw_vle
group by
	id_site,
	code_module,
	code_presentation,
    activity_type,
    week_from,
    week_to
having count(*)>1;

-- Primary_key duplicate check
select 
    id_site,
    code_module,
    code_presentation,
    COUNT(*) AS cnt
from raw_vle
group by  
    id_site,
    code_module,
    code_presentation
having COUNT(*) > 1;

-- code_module anomaly check
select distinct code_module from raw_vle
group by code_module;

-- code_presentation anomaly check
select distinct code_presentation from raw_vle
group by code_presentation;

-- activity_type anomaly check
select distinct activity_type,count(*) from raw_vle
group by activity_type
order by count(*) desc;

-- misc checks
SELECT *
FROM raw_vle
WHERE nullif(trim(week_from), '') IS NOT NULL
   OR nullif(trim(week_to), '') IS NOT NULL
   OR nullif(trim(week_to), '') IS NOT NULL;

select * from raw_vle
where week_from>week_to;

    
