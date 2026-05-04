OULAD SQL Project – Student Performance Analysis

Overview -

This project analyzes student engagement and assessment data from the OULAD dataset to understand why students fail or withdraw from courses, and to identify early signals of risk before final outcomes are reached.

I built this as an end-to-end SQL project, starting from raw CSV files and moving through cleaning, validation, and final analysis to identify high-risk student groups.


Business Problem -

A large number of students do not successfully complete courses

- Is this driven by low engagement or academic difficulty?
- Are some modules worse than others?
- Can low performing students be identified early enough for intervention


Key Insights -

1. High non-completion rate  
~53% of students fail or withdraw  

2. Engagement matters  
Successful students show much higher:
- total clicks
- active days 
Consistency of engagement matters more than intensity  

3. Early engagement is already a strong risk signal
Students who eventually pass or achieve distinction show much higher engagement within the first 30 days than students who later fail or withdraw.
This suggests that poor outcomes are visible early in the student journey and that early engagement can support practical intervention.

4. Two types of risk
 
- Withdrawn students - low engagement + low assessment attempts  
- Failed students - attempt assessments but score poorly  
Different problems need different solutions 

5. Risk segmentation  

- Low engagement + low performance → highest risk  
- High engagement + low performance → struggling students  
- High engagement + high performance → strong success  

Recommendations -

- Building an early warning system using first-30-day engagement pattern
- Academic support for engaged but low-performing students  
- Tiered intervention instead of one-size-fits-all  

Skills Demonstrated -

- SQL (joins, aggregations, window functions)  
- Data cleaning and validation  
- Data modeling and grain handling  
- Analytical thinking and segmentation
  
Project Files -

-01_oulad_create_raw_tables.sql  
-02_oulad_data_loading.sql  
-03_oulad_data_profiling.sql  
-04_oulad_data_cleaning.sql  
-05_oulad_data_validation_and_summary_build.sql  
-06_oulad_data_analysis.sql  

Key Takeaway -

-Student outcomes are not driven by a single factor.
-Both consistent engagement and academic performance play a role, and different groups of students fail for different reasons which means interventions should be targeted, not generic.
