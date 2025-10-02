-- 1. Basic dataset overview
SELECT COUNT(*) AS total_records FROM CohortRaw;
SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'CohortRaw';

-- 2. Summary statistics for numerical columns SELECT
MIN(size) AS min_size,

MAX(size) AS max_size, AVG(size) AS avg_size,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY size) AS median_size,
STDDEV(size) AS stddev_size FROM CohortRaw;

-- 3. Date range analysis SELECT
MIN(TO_TIMESTAMP(start_date/1000)) AS earliest_start_date, MAX(TO_TIMESTAMP(start_date/1000)) AS latest_start_date, MIN(TO_TIMESTAMP(end_date/1000)) AS earliest_end_date, MAX(TO_TIMESTAMP(end_date/1000)) AS latest_end_date
FROM CohortRaw;

-- 4. Missing values check SELECT
COUNT(*) - COUNT(cohort_id) AS missing_cohort_ids, COUNT(*) - COUNT(cohort_code) AS missing_codes, COUNT(*) - COUNT(start_date) AS missing_start_dates, COUNT(*) - COUNT(end_date) AS missing_end_dates, COUNT(*) - COUNT(size) AS missing_sizes
FROM CohortRaw;

-- 5. Duplicate check
SELECT cohort_code, COUNT(*) FROM CohortRaw
GROUP BY cohort_code HAVING COUNT(*) > 1;

-- 6. Cohort size distribution analysis SELECT
CASE
WHEN size < 100 THEN 'Small (<100)'
WHEN size BETWEEN 100 AND 1000 THEN 'Medium (100-1000)'
WHEN size BETWEEN 1001 AND 10000 THEN 'Large (1001-10000)'
ELSE 'Very Large (>10000)' END AS size_category,
COUNT(*) AS count,
ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM CohortRaw), 2) AS
percentage FROM CohortRaw
GROUP BY size_category ORDER BY MIN(size);

-- 7. Cohort duration analysis SELECT
CASE
WHEN (end_date - start_date) = 0 THEN 'Single day' WHEN (end_date - start_date) <= 86400000 THEN '1 day' WHEN (end_date - start_date) <= 604800000 THEN '1 week'
WHEN (end_date - start_date) <= 2592000000 THEN '1 month' WHEN (end_date - start_date) <= 7776000000 THEN '3 months' ELSE 'Longer than 3 months'
END AS duration_category,

COUNT(*) AS count FROM CohortRaw
GROUP BY duration_category
ORDER BY MIN(end_date - start_date);


-- 8. Outlier detection using IQR WITH size_stats AS (
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY size) AS q1, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY size) AS q3, PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY size) -
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY size) AS iqr
FROM CohortRaw
)
SELECT cohort_id, cohort_code, size FROM CohortRaw, size_stats
WHERE size < q1 - 1.5*iqr OR size > q3 + 1.5*iqr ORDER BY size DESC;

-- 9. Cohort code pattern analysis SELECT
CASE
WHEN cohort_code ~ '^B[A-Z0-9]{6}$' THEN 'Standard 7-char code' WHEN cohort_code ~ '^B[A-Z0-9]{5}$' THEN 'Standard 6-char code' WHEN cohort_code ~ '^B[A-Z0-9]{7}$' THEN 'Standard 8-char code' ELSE 'Non-standard format'
END AS code_pattern, COUNT(*) AS count
FROM CohortRaw
GROUP BY code_pattern;
