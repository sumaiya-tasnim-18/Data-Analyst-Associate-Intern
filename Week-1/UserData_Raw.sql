select * from learners; SELECT COUNT(*) FROM learners;
SELECT column_name, data_type FROM information_schema.columns WHERE
table_name = 'learners';


SELECT country, degree, institution, major FROM learners
LIMIT 20;

SELECT column_name
FROM information_schema.columns WHERE table_name = 'learners';


SELECT DISTINCT degree, institution FROM learners
ORDER BY degree;


SELECT
COUNT(*) FILTER (
WHERE degree IS NULL OR TRIM(LOWER(degree)) IN ('null')
) AS missing_degree,

COUNT(*) FILTER (
WHERE institution IS NULL OR TRIM(LOWER(institution)) IN ('null')
) AS missing_institution,

COUNT(*) FILTER (
WHERE major IS NULL OR TRIM(LOWER(major)) IN ('null')
) AS missing_major FROM learners;

SELECT
COUNT(*) FILTER (
WHERE country IS NULL OR TRIM(LOWER(country)) IN ('null', '')
) AS missing_country,

COUNT(*) FILTER (
WHERE degree IS NULL OR TRIM(LOWER(degree)) IN ('null', '')
) AS missing_degree,

COUNT(*) FILTER (
WHERE institution IS NULL OR TRIM(LOWER(institution)) IN ('null',
'')
) AS missing_institution,

COUNT(*) FILTER (
WHERE major IS NULL OR TRIM(LOWER(major)) IN ('null', '')
) AS missing_major FROM learners;
SELECT column_name, data_type FROM information_schema.columns
WHERE table_schema = 'public' AND table_name = 'learners';

SELECT * FROM public.learners LIMIT 10; SELECT COUNT(*) FROM public.learners;

SELECT *
FROM learners LIMIT 5;

SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'learners';

SELECT COUNT(*) AS total_rows FROM learners;


SELECT country, COUNT(*) AS total FROM learners
GROUP BY country ORDER BY total DESC;

SELECT DISTINCT degree FROM learners;

SELECT
COUNT(*) AS total_learners,
COUNT(DISTINCT country) AS distinct_countries, COUNT(DISTINCT degree) AS distinct_degrees, COUNT(DISTINCT institution) AS distinct_institutions,

COUNT(DISTINCT major) AS distinct_majors FROM learners;


-- Frequency distribution for countries SELECT country, COUNT(*) AS learner_count FROM learners
GROUP BY country
ORDER BY learner_count DESC;

-- Frequency distribution for degrees SELECT degree, COUNT(*) AS degree_count FROM learners
GROUP BY degree
ORDER BY degree_count DESC;

SELECT
COUNT(*) FILTER (WHERE degree IS NULL) AS missing_degree,
COUNT(*) FILTER (WHERE institution IS NULL) AS missing_institution,
COUNT(*) FILTER (WHERE major IS NULL) AS missing_major, COUNT(*) FILTER (WHERE country IS NULL) AS missing_country
FROM learners;

SELECT
learner_id,
COUNT(*) AS duplicate_count FROM learners
GROUP BY learner_id HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;


SELECT
TRIM(LOWER(country)) AS country_clean, TRIM(LOWER(degree)) AS degree_clean, TRIM(LOWER(institution)) AS institution_clean, TRIM(LOWER(major)) AS major_clean,
COUNT(*) AS duplicate_count FROM learners
GROUP BY
TRIM(LOWER(country)), TRIM(LOWER(degree)), TRIM(LOWER(institution)), TRIM(LOWER(major))
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC; SELECT

-- Missing values COUNT(*) FILTER (
WHERE country IS NULL OR TRIM(LOWER(country)) IN ('null', '')
) AS missing_country,

COUNT(*) FILTER (
WHERE degree IS NULL OR TRIM(LOWER(degree)) IN ('null', '')
) AS missing_degree,

COUNT(*) FILTER (
WHERE institution IS NULL OR TRIM(LOWER(institution)) IN ('null', '')
) AS missing_institution,

COUNT(*) FILTER (
WHERE major IS NULL OR TRIM(LOWER(major)) IN ('null', '')
) AS missing_major,

-- Duplicate combinations (country+degree+institution+major) (
SELECT COUNT(*) FROM (
SELECT
TRIM(LOWER(country)) AS country_clean, TRIM(LOWER(degree)) AS degree_clean, TRIM(LOWER(institution)) AS institution_clean, TRIM(LOWER(major)) AS major_clean,
COUNT(*) AS dup_count FROM learners
GROUP BY
TRIM(LOWER(country)), TRIM(LOWER(degree)), TRIM(LOWER(institution)), TRIM(LOWER(major))
HAVING COUNT(*) > 1
) AS dup_groups
) AS duplicate_groups FROM learners;


SELECT
-- Missing counts COUNT(*) FILTER (
WHERE country IS NULL OR TRIM(LOWER(country)) IN ('null', '')
) AS missing_country,

COUNT(*) FILTER (
WHERE degree IS NULL OR TRIM(LOWER(degree)) IN ('null', '')
) AS missing_degree, COUNT(*) FILTER (

WHERE institution IS NULL OR TRIM(LOWER(institution)) IN ('null', '')
) AS missing_institution,

COUNT(*) FILTER (
WHERE major IS NULL OR TRIM(LOWER(major)) IN ('null', '')
) AS missing_major,

-- Total duplicate rows (across all columns) (
SELECT COUNT(*)
FROM learners
WHERE (learner_id, country, degree, institution, major) IN ( SELECT
learner_id, country, degree, institution, major FROM learners
GROUP BY
learner_id, country, degree, institution, major HAVING COUNT(*) > 1
)
) AS total_duplicate_rows FROM learners;

SELECT country, COUNT(*) AS learners_count FROM learners
GROUP BY country
ORDER BY learners_count DESC;

SELECT country, COUNT(*) AS total_learners FROM learners
GROUP BY country
ORDER BY total_learners DESC;

SELECT country, degree, COUNT(*) AS total FROM learners
GROUP BY country, degree ORDER BY total DESC limit 10;

SELECT
degree, major,
COUNT(*) AS total_students FROM learners
GROUP BY degree, major
ORDER BY degree, total_students DESC limit 10;

WITH top_countries AS ( SELECT country
FROM learners
WHERE country IS NOT NULL AND TRIM(country) <> ''

GROUP BY country ORDER BY COUNT(*) DESC LIMIT 5
)
-- Count learners per Major for only those Top Countries SELECT
l.country, l.major,
COUNT(*) AS total_students FROM learners l
JOIN top_countries tc ON l.country = tc.country WHERE l.major IS NOT NULL AND TRIM(l.major) <> ''
GROUP BY l.country, l.major
ORDER BY l.country, total_students DESC;