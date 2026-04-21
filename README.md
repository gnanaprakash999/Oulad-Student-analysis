OULAD SQL Project – Student Performance Analysis

Overview

This project analyzes student engagement and assessment data from the OULAD dataset to understand why students fail or withdraw from courses.

I built this as an end-to-end SQL project, starting from raw CSV files and moving through cleaning, validation, and final analysis to identify high-risk student groups.


Business Problem

A large number of students do not successfully complete courses.

Key questions:
- Is this driven by low engagement or academic difficulty?
- Are some modules worse than others?
- Can we identify at-risk students early?


Approach

The project was built using a layered approach:

- Raw layer → loaded all data as VARCHAR to preserve blanks  
- Clean layer → standardized and typed data using NULLIF, CAST, TRIM  
- Analysis layer → created student-level summary tables to avoid duplication  

Final dataset grain:
(student × module × presentation)



Key Insights

1. High non-completion rate  
~53% of students fail or withdraw  



2. Engagement matters  
Successful students show much higher:
- total clicks  
- active days  

Consistency of engagement matters more than intensity  



3. Two types of risk (important)  

- Withdrawn students → low engagement, low assessment attempts  
- Failed students → attempt assessments but score poorly  

Different problems need different solutions  



4. Risk segmentation  

Using engagement and performance:

- Low engagement + low performance → highest risk  
- High engagement + low performance → struggling students  
- High engagement + high performance → strong success  



Recommendations

- Early warning system for low-engagement students  
- Academic support for engaged but low-performing students  
- Tiered intervention instead of one-size-fits-all  



Skills Demonstrated

- SQL (joins, aggregations, window functions)  
- Data cleaning and validation  
- Data modeling and grain handling  
- Analytical thinking and segmentation  



Project Files

01_oulad_create_raw_tables.sql  
02_oulad_data_loading.sql  
03_oulad_data_profiling.sql  
04_oulad_data_cleaning.sql  
05_oulad_data_validation_and_summary_build.sql  
06_oulad_data_analysis.sql  



Key Takeaway

Student outcomes are not driven by a single factor.

Both consistent engagement and academic performance play a role, and different groups of students fail for different reasons — which means interventions should be targeted, not generic.