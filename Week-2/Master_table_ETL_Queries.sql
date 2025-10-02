SELECT * FROM public.master_table


-- ETL Process of Master_Table

-- Datatypes of all column
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'master_table'
ORDER BY ordinal_position;

-- Total records count in master table
SELECT COUNT(*) AS total_records
FROM public.Master_Table;

-- Checking Missing/null values 
SELECT 'learner_id' AS column_name, COUNT(*) - COUNT(learner_id) AS null_count FROM Master_Table
UNION ALL
SELECT 'opportunity_id', COUNT(*) - COUNT(opportunity_id) FROM Master_Table
UNION ALL
SELECT 'assigned_cohort', COUNT(*) - COUNT(assigned_cohort) FROM Master_Table
UNION ALL
SELECT 'apply_date', COUNT(*) - COUNT(apply_date) FROM Master_Table
UNION ALL
SELECT 'status', COUNT(*) - COUNT(status) FROM Master_Table
UNION ALL
SELECT 'country', COUNT(*) - COUNT(country) FROM Master_Table
UNION ALL
SELECT 'degree', COUNT(*) - COUNT(degree) FROM Master_Table
UNION ALL
SELECT 'institution', COUNT(*) - COUNT(institution) FROM Master_Table
UNION ALL
SELECT 'major', COUNT(*) - COUNT(major) FROM Master_Table
UNION ALL
SELECT 'email', COUNT(*) - COUNT(email) FROM Master_Table
UNION ALL
SELECT 'gender', COUNT(*) - COUNT(gender) FROM Master_Table
UNION ALL
SELECT 'user_create_date', COUNT(*) - COUNT(user_create_date) FROM Master_Table
UNION ALL
SELECT 'user_last_modified_date', COUNT(*) - COUNT(user_last_modified_date) FROM Master_Table
UNION ALL
SELECT 'birthdate', COUNT(*) - COUNT(birthdate) FROM Master_Table
UNION ALL
SELECT 'city', COUNT(*) - COUNT(city) FROM Master_Table
UNION ALL
SELECT 'state', COUNT(*) - COUNT(state) FROM Master_Table
UNION ALL
SELECT 'opportunity_name', COUNT(*) - COUNT(opportunity_name) FROM Master_Table
UNION ALL
SELECT 'opportunity_category', COUNT(*) - COUNT(opportunity_category) FROM Master_Table
UNION ALL
SELECT 'opportunity_code', COUNT(*) - COUNT(opportunity_code) FROM Master_Table
UNION ALL
SELECT 'cohort_start_date', COUNT(*) - COUNT(cohort_start_date) FROM Master_Table
UNION ALL
SELECT 'cohort_end_date', COUNT(*) - COUNT(cohort_end_date) FROM Master_Table
UNION ALL
SELECT 'cohort_size', COUNT(*) - COUNT(cohort_size) FROM Master_Table;


-- fixing null values in each column
-- Replace NULLs in text / character columns with 'Unknown'
UPDATE Master_Table
SET
    email = CASE WHEN email IS NULL THEN 'Unknown' ELSE email END,
    gender = CASE WHEN gender IS NULL THEN 'Unknown' ELSE gender END,
    city = CASE WHEN city IS NULL THEN 'Unknown' ELSE city END,
    state = CASE WHEN state IS NULL THEN 'Unknown' ELSE state END,
    country = CASE WHEN country IS NULL THEN 'Unknown' ELSE country END,
    degree = CASE WHEN degree IS NULL THEN 'Unknown' ELSE degree END,
    institution = CASE WHEN institution IS NULL THEN 'Unknown' ELSE institution END,
    major = CASE WHEN major IS NULL THEN 'Unknown' ELSE major END,
    opportunity_name = CASE WHEN opportunity_name IS NULL THEN 'Unknown' ELSE opportunity_name END,
    opportunity_category = CASE WHEN opportunity_category IS NULL THEN 'Unknown' ELSE opportunity_category END,
    opportunity_code = CASE WHEN opportunity_code IS NULL THEN 'Unknown' ELSE opportunity_code END,
    assigned_cohort = CASE WHEN assigned_cohort IS NULL THEN 'Unknown' ELSE assigned_cohort END,
    status = CASE WHEN status IS NULL THEN 'Unknown' ELSE status END;


-- Replace NULLs in integer columns with 0
UPDATE Master_Table
SET
    cohort_size = CASE WHEN cohort_size IS NULL THEN 0 ELSE cohort_size END;
	
-- Replace NULLs in date / timestamp columns with current date / timestamp
UPDATE Master_Table
SET
    user_create_date = CASE WHEN user_create_date IS NULL THEN CURRENT_TIMESTAMP ELSE user_create_date END,
    user_last_modified_date = CASE WHEN user_last_modified_date IS NULL THEN CURRENT_TIMESTAMP ELSE user_last_modified_date END,
    birthdate = CASE WHEN birthdate IS NULL THEN CURRENT_DATE ELSE birthdate END,
    apply_date = CASE WHEN apply_date IS NULL THEN CURRENT_TIMESTAMP ELSE apply_date END,
    cohort_start_date = CASE WHEN cohort_start_date IS NULL THEN CURRENT_TIMESTAMP ELSE cohort_start_date END,
    cohort_end_date = CASE WHEN cohort_end_date IS NULL THEN CURRENT_TIMESTAMP ELSE cohort_end_date END;


--checked NULL text type values
SELECT 'email' AS column_name, COUNT(*) AS null_text_count FROM Master_Table WHERE email = 'NULL'
UNION ALL
SELECT 'gender', COUNT(*) FROM Master_Table WHERE gender = 'NULL'
UNION ALL
SELECT 'city', COUNT(*) FROM Master_Table WHERE city = 'NULL'
UNION ALL
SELECT 'state', COUNT(*) FROM Master_Table WHERE state = 'NULL'
UNION ALL
SELECT 'country', COUNT(*) FROM Master_Table WHERE country = 'NULL'
UNION ALL
SELECT 'degree', COUNT(*) FROM Master_Table WHERE degree = 'NULL'
UNION ALL
SELECT 'institution', COUNT(*) FROM Master_Table WHERE institution = 'NULL'
UNION ALL
SELECT 'major', COUNT(*) FROM Master_Table WHERE major = 'NULL'
UNION ALL
SELECT 'opportunity_name', COUNT(*) FROM Master_Table WHERE opportunity_name = 'NULL'
UNION ALL
SELECT 'opportunity_category', COUNT(*) FROM Master_Table WHERE opportunity_category = 'NULL'
UNION ALL
SELECT 'opportunity_code', COUNT(*) FROM Master_Table WHERE opportunity_code = 'NULL'
UNION ALL
SELECT 'assigned_cohort', COUNT(*) FROM Master_Table WHERE assigned_cohort = 'NULL'
UNION ALL
SELECT 'status', COUNT(*) FROM Master_Table WHERE status = 'NULL';


-- counting URLs values (Don%27t want to specify) in gender column
SELECT COUNT(*) AS count_URL_gender
FROM Master_Table
WHERE gender = 'Don%27t want to specify';

-- removing URLS values, replacing unknown
UPDATE Master_Table
SET gender = 'Unknown'
WHERE gender = 'Don%27t want to specify';


-- Final Master_Table After cleaning
SELECT * FROM public.master_table
LIMIT 15

