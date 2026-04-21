USE oulad_db;


-- Objective:
-- Understand what drives student success, failure, and withdrawal,
-- and identify student groups to enhance final_result

-- Final outcome distribution across all students
select 
    final_result,
    count(*) as total_students,
    round(100.0 * COUNT(*) / SUM(COUNT(*)) over (), 2) as percentage_total
from clean_student_level_summary
group by final_result
order by total_students desc;

/*
Key insight:
More than half of students (Withdrawn + Fail) do not successfully complete the course.
Withdrawal alone contributes a large share (31.16%) of unsuccessful outcomes, indicating that
retention is a major issue alongside academic underperformance.
*/

-- Outcome distribution by module
select 
    code_module,
    final_result,
    COUNT(*) AS total_students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) over(partition by code_module), 2) as percentage_within_module
from clean_student_level_summary
group by code_module, final_result
order by code_module, percentage_within_module desc;

/*
Key insight:
- CCC shows the highest withdrawal rate, indicating a strong retention challenge
- GGG shows the highest fail rate, suggesting greater academic difficulty

This suggests that poor outcomes are not evenly distributed and may have different
underlying drivers across modules.
*/

-- Engagement metrics by final result
select 
    final_result,
    COUNT(*) as students,
    ROUND(avg(total_clicks), 2) as avg_clicks,
    ROUND(avg(total_active_days), 2) as avg_active_days,
    ROUND(avg(avg_clicks_per_active_day), 2) as avg_clicks_per_active_day
from clean_student_level_summary
group by final_result
order by students desc;

/*
Key insights:
Students who passed and scored distinction show higher engagement than those who fail or withdraw.

The gap in avg_clicks_per_active_day is smaller than the gap in total_active_days,
suggesting that consistency of engagement over time matters more than daily intensity alone.

Interpretation:
Lower engagement is strongly associated with poor outcomes, especially withdrawal.
*/

-- Outcome + engagement by module
select 
    code_module,
    final_result,
    count(*) as student_count,
    round(avg(total_active_days), 2) as avg_active_days,
    round(avg(distinct_site_visited), 2) as avg_sites_visited,
    round(avg(total_clicks), 2) as avg_clicks,
    round(100.0 * COUNT(*) / SUM(COUNT(*)) over (partition by code_module), 2) as percentage_within_module
from clean_student_level_summary
group by code_module, final_result
order by code_module, percentage_within_module desc;

/*
Key insight:
The relationship between engagement and outcome holds across modules, not just overall.

Examples:
- CCC has high withdrawal with low engagement
- GGG has high fail rates with relatively weak engagement compared with successful students

This supports the idea that engagement is a key factor
*/


/*
the above analysis is based on full-course engagement, which is not actionable in real-world scenarios, 
as we would only know this after the course is completed.

To make the analysis more practical, we further explore early engagement patterns to determine 
whether student outcomes can be predicted early in the course.
*/

-- Analysing early engagement and possible impact on final_result
select 
    final_result,
    COUNT(*) as students,
    round(avg(total_clicks), 2) as avg_total_clicks,
    round(AVG(total_active_days), 2) as avg_active_days
from clean_student_level_summary
group by final_result;



select 
    final_result,
    COUNT(*) as students,
    ROUND(avg(total_clicks), 2) as avg_early_clicks,
    ROUND(avg(total_active_days), 2) as avg_early_active_days
from (
    select 
        csv.code_module,
        csv.code_presentation,
        csv.id_student,
        final_result,
        sum(case when interaction_date <= 30 then total_clicks else 0 end) as total_clicks,
        count(distinct case when interaction_date <= 30 then interaction_date end) as total_active_days
    from clean_student_vle_daily csv
    join clean_studentinfo si
      on csv.id_student = si.id_student
     and csv.code_module = si.code_module
     and csv.code_presentation = si.code_presentation
    group by csv.code_module, csv.code_presentation, csv.id_student, final_result
) t
group by final_result
order by students desc;

/*
Key insights :
Students who passed or got distinction are already more active in the frist
30 days in comaprision with students who fail or withdraw

The risk of failure or withdrawal can be visible quite early

Early engagement seaparates sucessful vs unsucessful students
Pass:430 clicks,17.46 active days
Withdrawn : 251 clicks,11.66 active days
Fail:247 clicks,11.49 active days

Early engagement seems to be a meaningful signal of success among students
*/

-- Assessment behavior and performance by final result
select 
    final_result,
    count(*) as students,
    round(avg(avg_score), 2) as avg_score,
    round(avg(weighted_avg_score), 2) as weighted_avg_score,
    round(avg(scored_assessments), 2) as avg_scored_assessments,
    round(avg(assessment_records), 2) as avg_total_assessment_records
from clean_student_level_summary
group by final_result
order by students desc;

/*
Key insights:
Assessment behavior separates two different risk patterns:

1. Withdrawn students:
   - Attempted fewer assessments
   - Disengagement before fully participating

2. Failed students:
   - Attempt more than withdrawn students
   - Still perform poorly, especially in weighted score terms
   - Suggests academic difficulty rather than pure disengagement

This distinction matters because different intervention strategies are needed.
*/

-- Exploring if registration timing and module length influences poor outcomes
select 
    code_module,
    final_result,
    count(*) as student_count,
    round(avg(date_registration), 2) as avg_registration_day,
    round(AVG(date_unregistration), 2) avg_unregistration_day,
    round(AVG(module_presentation_length), 2) as avg_module_presentation_length,
    round(100.0 * COUNT(*) / SUM(COUNT(*)) over (partition by code_module), 2) as percentage_within_module
from clean_student_level_summary
group by code_module, percentage_within_module desc;

/*
Key insight:
Registration timing and module presentation length do not show large enough differences
to explain the much higher withdrawal/failure rates in modules like CCC and GGG.

Interpretation:
These variables appear less likely to be primary drivers compared with engagement
and assessment behavior.
*/

-- Segment students using NTILE(3) for engagement and weighted performance

with base as (
    select *,
        NTILE(3) over (order by coalesce(total_clicks, 0)) AS engagement_band,
        NTILE(3) over (order by weighted_avg_score) AS performance_band
    from clean_student_level_summary
)
select 
    engagement_band,
    performance_band,
    final_result,
    count(*) as students,
    round(
        100.0 * COUNT(*) / SUM(COUNT(*)) over (partition by engagement_band, performance_band),
        2
    ) as percentage_within_segment
from base
group by engagement_band, performance_band, final_result
order by engagement_band, performance_band, percentage_within_segment DESC;

-- INTERPRETATION OF RISK SEGMENTS

/*
Key insight 1:
Students in the low engagement + low performance segment are the highest-risk group,
with outcomes dominated by withdrawal and failure.

Key insight 2:
Students in the high engagement + high performance segment show the strongest success outcomes,
with most students passing or achieving distinction.

Key insight 3:
The high engagement + low performance segment reveals a different risk type:
these students are active, but still struggle academically.
This suggests they need academic support rather than engagement-focused intervention.

Overall conclusion:
Student outcomes are shaped by two major dimensions:
- behavioral engagement
- academic performance

This enables a more practical intervention model than treating all at-risk students the same.
*/

-- BUSINESS RECOMMENDATIONS

/*
Recommendation 1: Early warning system
Early engagement appears to be a useful signal for flagging at-risk students and could support
an early warning system before the course is completed.
- Flag students in the lowest engagement band early in the course
- Low engagement is strongly associated with withdrawal and failure

Recommendation 2: Academic support
- Target students with high engagement but low performance
- These students are trying, but may need tutoring, feedback, or study support

Recommendation 3: Tiered intervention strategy
- Low engagement + low performance -> urgent intervention
- High engagement + low performance -> academic support
- Medium segments -> monitoring and lighter-touch outreach
*/
