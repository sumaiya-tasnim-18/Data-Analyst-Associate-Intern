--(importing dataset) CREATE TABLE enrollment (
enrollment_id VARCHAR(100), learner_id VARCHAR(100), assigned_cohort VARCHAR(20), apply_date TIMESTAMP, status INTEGER
);

COPY enrollment ( enrollment_id, learner_id, assigned_cohort, apply_date, status
)
FROM 'E:\LearnerOpportunity_Raw(in).csv' DELIMITER ','
CSV HEADER NULL AS 'NULL'

-- Running query to check the import SELECT *
FROM enrollment LIMIT 10;

--CHECKING ROWS AND COLUMNS
--checkking rows
SELECT COUNT(*) AS total_rows

FROM enrollment;
--checking columns
SELECT COUNT(*) AS total_columns FROM INFORMATION_SCHEMA.COLUMNS
WHERE table_name = 'enrollment';

--CHECKING NULL VALUES IN EACH COLUMN SELECT
SUM(CASE WHEN enrollment_id IS NULL THEN 1 ELSE 0 END) AS
enrollment_id_missing,
SUM(CASE WHEN learner_id IS NULL THEN 1 ELSE 0 END) AS
learner_id_missing,
SUM(CASE WHEN assigned_cohort IS NULL THEN 1 ELSE 0 END) AS assigned_cohort_missing,
SUM(CASE WHEN apply_date IS NULL THEN 1 ELSE 0 END) AS
apply_date_missing,
SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS status_missing FROM enrollment;

--CLEANING NULL VALUES
UPDATE enrollment
SET assigned_cohort = 'Unknown' WHERE assigned_cohort IS NULL;

UPDATE enrollment
SET apply_date = CURRENT_DATE WHERE apply_date IS NULL;

UPDATE enrollment SET status = 0
WHERE status IS NULL;

--CHECKING FOR DUPLICATE ROWS
SELECT *, COUNT(*) AS occurrences FROM enrollment
GROUP BY enrollment_id, learner_id, assigned_cohort, apply_date, status -- include all columns here
HAVING COUNT(*) > 1;