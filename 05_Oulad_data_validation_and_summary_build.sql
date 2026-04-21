use oulad_db;



select * from clean_courses;
select * from clean_studentinfo;

select * from clean_vle;
select * from clean_student_vle;

select * from clean_studentassessments;
select * from clean_assessments;

select * from clean_studentregistration;


select * 
from clean_studentinfo s
left join clean_courses c
on s.code_module = c.code_module
and s.code_presentation = c.code_presentation
;

-- Data validtion checks before joining
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT code_module, code_presentation) AS distinct_rows
FROM clean_courses;

 -- Unmatched rows check/Orphan record check
 SELECT COUNT(*) AS unmatched_student_rows
FROM clean_studentInfo si
LEFT JOIN clean_courses c
  ON si.code_module = c.code_module
 AND si.code_presentation = c.code_presentation
WHERE c.code_module IS NULL;


-- row preservation checks before /after join
SELECT COUNT(*) AS before_join
FROM clean_studentInfo;

SELECT COUNT(*) AS after_join
FROM clean_studentInfo si
JOIN clean_courses c
  ON si.code_module = c.code_module
 AND si.code_presentation = c.code_presentation;

select * from clean_studentassessments;
select * from clean_assessments;


select 
	count(*),
	count(distinct code_module,code_presentation,id_assessment)
from clean_assessments;


select count(*) from clean_studentassessments;

select count(*)
from clean_studentassessments sa
left join clean_assessments a
    on sa.id_assessment = a.id_assessment;

select count(*)
from clean_studentassessments sa
left join clean_assessments a
    on sa.id_assessment = a.id_assessment
    where a.id_assessment is null;
    
    
select * from clean_student_vle
limit 100;
select * from clean_vle;

-- plan to aggregate rows of student_ids on a single interaction_dte to get total clicks 
-- also to reduce row count

drop table if exists clean_student_vle_daily;
create table clean_student_vle_daily as
select 
	code_module,
    code_presentation,
    id_student,
    id_site,
    interaction_date,
    sum(sum_click) as total_clicks
from clean_student_vle
group by
	code_module,
    code_presentation,
    id_student,
    id_site,
    interaction_date;
    
select count(*) from clean_student_vle;
select count(*) from clean_student_vle_daily;
-- this reduced the row_count from 10 Million to 8 Million


select 
	count(*),
	count(distinct id_site,code_presentation,code_module)
from clean_vle;


select count(*) from clean_student_vle_daily;
-- 8459320

select count(*) from clean_student_vle_daily csv
left join clean_vle cv
on csv.id_site = cv.id_site
and csv.code_module = cv.code_module
and csv.code_presentation = cv.code_presentation;
-- 8459320

select count(*) from clean_student_vle_daily csv
left join clean_vle cv
on csv.id_site = cv.id_site
and csv.code_module = cv.code_module
and csv.code_presentation = cv.code_presentation
where cv.id_site is null;

-- creating a student summary tab
drop table if exists clean_student_vle_summary;
create table clean_student_vle_summary as
select 
csv.code_module,
csv.code_presentation,
csv.id_student,
count(distinct csv.id_site) as distinct_site_visited,
count(distinct csv.interaction_date) as total_active_days,
sum(total_clicks) as total_clicks,
count(distinct activity_type) as distinct_activity_types,
round(sum(total_clicks) / nullif(count(distinct interaction_date), 0), 2) AS avg_clicks_per_active_day
from clean_student_vle_daily csv
left join clean_vle cv
on csv.id_site = cv.id_site
and csv.code_module = cv.code_module
and csv.code_presentation = cv.code_presentation
group by csv.code_module,csv.code_presentation,csv.id_student;


select count(*),
		count(distinct id_student,code_Module,code_presentation) 
from clean_student_vle_summary;

drop table if  exists clean_student_assessment_summary;
create table clean_student_assessment_summary as
select
    a.code_module,
    a.code_presentation,
    sa.id_student,
    count(*) as assessment_records,
    count(sa.score) as scored_assessments,
    round(avg(sa.score), 2) AS avg_score,
    round(
        sum(sa.score * a.weight) / nullif(sum(case when sa.score IS NOT NULL THEN a.weight END), 0),
        2
    ) as weighted_avg_score,
    count(distinct a.assessment_type) as distinct_assessment_types
from clean_studentassessments sa
left join clean_assessments a
    on sa.id_assessment = a.id_assessment
group by
    a.code_module,
    a.code_presentation,
    sa.id_student;
    
    select
    count(*) as total_rows,
    count(distinct id_student, code_module, code_presentation) AS distinct_rows
from clean_student_assessment_summary;


-- the remaining two tables
select * from clean_studentregistration;
select * from clean_studentinfo;
select * from clean_student_assessment_summary;
select * from clean_student_vle_summary;
-- joining the above two tables with recently created summary table to form one student level grain data table

DROP TABLE IF EXISTS clean_student_level_summary;
create table clean_student_level_summary as
select
    si.code_module,
    si.code_presentation,
    si.id_student,
    si.gender,
    si.region,
    si.highest_education,
    si.imd_band,
    si.age_band,
    si.num_of_prev_attempts,
    si.studied_credits,
    si.disability,
    si.final_result,

    sr.date_registration,
    sr.date_unregistration,

    c.module_presentation_length,

    vs.distinct_site_visited,
    vs.total_active_days,
    vs.total_clicks,
    vs.distinct_activity_types,
    vs.avg_clicks_per_active_day,

    ass.assessment_records,
    ass.scored_assessments,
    ass.avg_score,
    ass.weighted_avg_score,
    ass.distinct_assessment_types

from clean_studentinfo si
left join clean_studentregistration sr
    on si.id_student = sr.id_student
   and si.code_module = sr.code_module
   and si.code_presentation = sr.code_presentation
left join clean_courses c
    ON si.code_module = c.code_module
   and si.code_presentation = c.code_presentation
left join clean_student_vle_summary vs
    ON si.id_student = vs.id_student
   and si.code_module = vs.code_module
   and si.code_presentation = vs.code_presentation
left join clean_student_assessment_summary ass
    ON si.id_student = ass.id_student
   and si.code_module = ass.code_module
   and si.code_presentation = ass.code_presentation;
   
   
   select count(*),
   count(distinct id_student,code_module,code_presentation)
   from clean_student_level_summary;

select * from clean_student_level_summary
limit 100;