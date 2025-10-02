SELECT * FROM master_table;

-- viewing KPI(s) values
SELECT COUNT(*) AS "Total Applications"
FROM master_table;

SELECT COUNT(DISTINCT learner_id) AS "Unique Learners"
FROM master_table;

SELECT 
    (SUM(CASE WHEN status = 'Enrolled' THEN 1 ELSE 0 END)::decimal 
     / COUNT(apply_date)) * 100 AS "Enrollment rate(%)"
FROM master_table;

SELECT SUM(cohort_size) AS "Cohort Capacity"
FROM master_table;

SELECT 
    SUM(cohort_size) - SUM(CASE WHEN status = 'Enrolled' THEN 1 ELSE 0 END) 
    AS "Remaining Seats"
FROM master_table;

SELECT 
    COUNT(*)::decimal / COUNT(DISTINCT apply_date) 
    AS "Application Velocity(application/day)"
FROM master_table;


-- viewing Chart(s) values

SELECT 
    opportunity_name,
    COUNT(learner_id) AS "Total Applications"
FROM master_table
GROUP BY opportunity_name
ORDER BY "Total Applications" DESC;

SELECT 
    country,
    COUNT(apply_date) AS "Total Applications"
FROM master_table
GROUP BY country
ORDER BY "Total Applications" DESC;

SELECT 
    opportunity_category,
    COUNT(DISTINCT learner_id) AS "Unique Learners"
FROM master_table
GROUP BY opportunity_category
ORDER BY "Unique Learners" DESC;


SELECT 
    gender,
    COUNT(apply_date) AS "Total Applications",
    ROUND(
        COUNT(apply_date)::decimal * 100 / SUM(COUNT(apply_date)) OVER (), 
        2
    ) AS "Percentage(%)"
FROM master_table
GROUP BY gender
ORDER BY "Total Applications" DESC;


SELECT 
    status,
    COUNT(DISTINCT email) AS "Unique Emails",
    ROUND(
        COUNT(DISTINCT email)::decimal * 100 / SUM(COUNT(DISTINCT email)) OVER (), 
        2
    ) AS "Percentage(%)"
FROM master_table
GROUP BY status
ORDER BY "Unique Emails" DESC;

SELECT 
    cohort_start_date,
    SUM(CASE WHEN status = 'Enrolled' THEN 1 ELSE 0 END) AS "Enrolled Count"
FROM master_table
GROUP BY cohort_start_date
ORDER BY cohort_start_date;

SELECT 
    country,
    opportunity_category,
    ROUND(
        SUM(CASE WHEN status = 'Enrolled' THEN 1 ELSE 0 END)::decimal 
        / COUNT(apply_date) * 100, 2
    ) AS "Enrollment Rate(%)"
FROM master_table
GROUP BY country, opportunity_category
ORDER BY country, opportunity_category;









