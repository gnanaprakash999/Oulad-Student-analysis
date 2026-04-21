USE oulad_db;


-- Objective:
-- Understand what drives student success, failure, and withdrawal,
-- and identify student groups to enhance final_result

-- Final outcome distribution across all students
SELECT 
    final_result,
    COUNT(*) AS total_students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_total
FROM clean_student_level_summary
GROUP BY final_result
ORDER BY total_students DESC;

/*
Key insight:
More than half of students (Withdrawn + Fail) do not successfully complete the course.
Withdrawal alone contributes a large share (31.16%) of unsuccessful outcomes, indicating that
retention is a major issue alongside academic underperformance.
*/

-- Outcome distribution by module
SELECT 
    code_module,
    final_result,
    COUNT(*) AS total_students,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY code_module), 2) AS percentage_within_module
FROM clean_student_level_summary
GROUP BY code_module, final_result
ORDER BY code_module, percentage_within_module DESC;

/*
Key insight:
- CCC shows the highest withdrawal rate, indicating a strong retention challenge
- GGG shows the highest fail rate, suggesting greater academic difficulty

This suggests that poor outcomes are not evenly distributed and may have different
underlying drivers across modules.
*/

-- Engagement metrics by final result
SELECT 
    final_result,
    COUNT(*) AS students,
    ROUND(AVG(total_clicks), 2) AS avg_clicks,
    ROUND(AVG(total_active_days), 2) AS avg_active_days,
    ROUND(AVG(avg_clicks_per_active_day), 2) AS avg_clicks_per_active_day
FROM clean_student_level_summary
GROUP BY final_result
ORDER BY students DESC;

/*
Key insights:
Students who passed and scored distinction show higher engagement than those who fail or withdraw.

The gap in avg_clicks_per_active_day is smaller than the gap in total_active_days,
suggesting that consistency of engagement over time matters more than daily intensity alone.

Interpretation:
Lower engagement is strongly associated with poor outcomes, especially withdrawal.
*/

-- Outcome + engagement by module
SELECT 
    code_module,
    final_result,
    COUNT(*) AS student_count,
    ROUND(AVG(total_active_days), 2) AS avg_active_days,
    ROUND(AVG(distinct_site_visited), 2) AS avg_sites_visited,
    ROUND(AVG(total_clicks), 2) AS avg_clicks,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY code_module), 2) AS percentage_within_module
FROM clean_student_level_summary
GROUP BY code_module, final_result
ORDER BY code_module, percentage_within_module DESC;

/*
Key insight:
The relationship between engagement and outcome holds across modules, not just overall.

Examples:
- CCC has high withdrawal with low engagement
- GGG has high fail rates with relatively weak engagement compared with successful students

This supports the idea that engagement is a key factor
*/

-- Assessment behavior and performance by final result
SELECT 
    final_result,
    COUNT(*) AS students,
    ROUND(AVG(avg_score), 2) AS avg_score,
    ROUND(AVG(weighted_avg_score), 2) AS weighted_avg_score,
    ROUND(AVG(scored_assessments), 2) AS avg_scored_assessments,
    ROUND(AVG(assessment_records), 2) AS avg_total_assessment_records
FROM clean_student_level_summary
GROUP BY final_result
ORDER BY students DESC;

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
SELECT 
    code_module,
    final_result,
    COUNT(*) AS student_count,
    ROUND(AVG(date_registration), 2) AS avg_registration_day,
    ROUND(AVG(date_unregistration), 2) AS avg_unregistration_day,
    ROUND(AVG(module_presentation_length), 2) AS avg_module_presentation_length,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY code_module), 2) AS percentage_within_module
FROM clean_student_level_summary
GROUP BY code_module, final_result
ORDER BY code_module, percentage_within_module DESC;

/*
 Key insight:
Registration timing and module presentation length do not show large enough differences
to explain the much higher withdrawal/failure rates in modules like CCC and GGG.

Interpretation:
These variables appear less likely to be primary drivers compared with engagement
and assessment behavior.
*/

-- Segment students using NTILE(3) for engagement and weighted performance

WITH base AS (
    SELECT *,
        NTILE(3) OVER (ORDER BY COALESCE(total_clicks, 0)) AS engagement_band,
        NTILE(3) OVER (ORDER BY weighted_avg_score) AS performance_band
    FROM clean_student_level_summary
)
SELECT 
    engagement_band,
    performance_band,
    final_result,
    COUNT(*) AS students,
    ROUND(
        100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY engagement_band, performance_band),
        2
    ) AS percentage_within_segment
FROM base
GROUP BY engagement_band, performance_band, final_result
ORDER BY engagement_band, performance_band, percentage_within_segment DESC;

/*
Band meaning:
engagement_band:
1 = Low engagement
2 = Medium engagement
3 = High engagement

performance_band:
1 = Low performance
2 = Medium performance
3 = High performance
*/


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