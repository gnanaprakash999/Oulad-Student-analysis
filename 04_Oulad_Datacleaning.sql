USE oulad_db;

-- 1. CLEAN_COURSES
DROP TABLE IF EXISTS clean_courses;

CREATE TABLE clean_courses AS
SELECT
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    CAST(NULLIF(TRIM(module_presentation_length), '') AS UNSIGNED) AS module_presentation_length
FROM raw_courses;

ALTER TABLE clean_courses
ADD PRIMARY KEY (code_module, code_presentation);



-- 2. CLEAN_ASSESSMENTS
DROP TABLE IF EXISTS clean_assessments;

CREATE TABLE clean_assessments AS
SELECT
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    CAST(NULLIF(TRIM(id_assessment), '') AS UNSIGNED) AS id_assessment,
    NULLIF(UPPER(TRIM(assessment_type)), '') AS assessment_type,
    CAST(NULLIF(TRIM(assessment_date), '') AS SIGNED) AS assessment_date,
    CAST(NULLIF(TRIM(weight), '') AS DECIMAL(10,2)) AS weight
FROM raw_assessments;

ALTER TABLE clean_assessments
ADD PRIMARY KEY (code_module, code_presentation, id_assessment);



-- 3. CLEAN_STUDENT_VLE
DROP TABLE IF EXISTS clean_student_vle;

CREATE TABLE clean_student_vle AS
SELECT
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    CAST(NULLIF(TRIM(id_student), '') AS UNSIGNED) AS id_student,
    CAST(NULLIF(TRIM(id_site), '') AS UNSIGNED) AS id_site,
    CAST(NULLIF(TRIM(interaction_date), '') AS SIGNED) AS interaction_date,
    CAST(NULLIF(TRIM(sum_click), '') AS UNSIGNED) AS sum_click
FROM raw_student_vle;

CREATE INDEX idx_svle_student
ON clean_student_vle (id_student);

CREATE INDEX idx_student_vle_grain
ON clean_student_vle (
    code_module,
    code_presentation,
    id_student,
    id_site,
    interaction_date
);


-- 4. CLEAN_STUDENTASSESSMENTS
DROP TABLE IF EXISTS clean_studentassessments;

CREATE TABLE clean_studentassessments AS
SELECT
    CAST(NULLIF(TRIM(id_assessment), '') AS UNSIGNED) AS id_assessment,
    CAST(NULLIF(TRIM(id_student), '') AS UNSIGNED) AS id_student,
    CAST(NULLIF(TRIM(date_submitted), '') AS SIGNED) AS date_submitted,
    CAST(NULLIF(TRIM(is_banked), '') AS UNSIGNED) AS is_banked,
    CAST(NULLIF(TRIM(score), '') AS DECIMAL(5,2)) AS score
FROM raw_studentassessments;

ALTER TABLE clean_studentassessments
ADD PRIMARY KEY (id_student, id_assessment);



-- 5. CLEAN_STUDENTINFO
DROP TABLE IF EXISTS clean_studentinfo;

CREATE TABLE clean_studentinfo AS
SELECT
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    CAST(NULLIF(TRIM(id_student), '') AS UNSIGNED) AS id_student,
    NULLIF(UPPER(TRIM(gender)), '') AS gender,
    NULLIF(TRIM(region), '') AS region,
    NULLIF(TRIM(highest_education), '') AS highest_education,
    CASE
        WHEN TRIM(imd_band) = '' THEN NULL
        WHEN TRIM(imd_band) = '10-20' THEN '10-20%'
        ELSE TRIM(imd_band)
    END AS imd_band,
    NULLIF(TRIM(age_band), '') AS age_band,
    CAST(NULLIF(TRIM(num_of_prev_attempts), '') AS UNSIGNED) AS num_of_prev_attempts,
    CAST(NULLIF(TRIM(studied_credits), '') AS UNSIGNED) AS studied_credits,
    NULLIF(UPPER(TRIM(disability)), '') AS disability,
    NULLIF(UPPER(TRIM(final_result)), '') AS final_result
FROM raw_studentinfo;

ALTER TABLE clean_studentinfo
ADD PRIMARY KEY (code_module, code_presentation, id_student);



-- 6. CLEAN_STUDENTREGISTRATION
DROP TABLE IF EXISTS clean_studentregistration;

CREATE TABLE clean_studentregistration AS
SELECT
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    CAST(NULLIF(TRIM(id_student), '') AS UNSIGNED) AS id_student,
    CAST(NULLIF(TRIM(date_registration), '') AS SIGNED) AS date_registration,
    CAST(NULLIF(TRIM(date_unregistration), '') AS SIGNED) AS date_unregistration
FROM raw_studentregistration;

ALTER TABLE clean_studentregistration
ADD PRIMARY KEY (code_module, code_presentation, id_student);



-- 7. CLEAN_VLE
DROP TABLE IF EXISTS clean_vle;

CREATE TABLE clean_vle AS
SELECT
    CAST(NULLIF(TRIM(id_site), '') AS UNSIGNED) AS id_site,
    UPPER(TRIM(code_module)) AS code_module,
    UPPER(TRIM(code_presentation)) AS code_presentation,
    NULLIF(TRIM(activity_type), '') AS activity_type,
    CAST(NULLIF(TRIM(week_from), '') AS SIGNED) AS week_from,
    CAST(NULLIF(TRIM(week_to), '') AS SIGNED) AS week_to
FROM raw_vle;

ALTER TABLE clean_vle
ADD PRIMARY KEY (id_site, code_module, code_presentation);


select * from clean_vle;
select * from clean_student_vle;

select * from clean_studentassessments;
select * from clean_assessments;

select * from clean_courses;
select * from clean_studentregistration;

select * from clean_studentinfo;


