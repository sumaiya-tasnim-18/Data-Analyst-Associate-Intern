-- IMPORTED ALL THE REQUIRED DATASETS after creating the tables for each

-- 1. Table for Cognito (User) Data
CREATE TABLE Cognito_Raw (
    user_id VARCHAR(255) PRIMARY KEY,
    email VARCHAR(255),
    gender VARCHAR(50),
    UserCreateDate VARCHAR(50),
    UserLastModifiedDate VARCHAR(50),
    birthdate VARCHAR(50),
    city VARCHAR(100),
    zip VARCHAR(20),
    state VARCHAR(100)
);

-- 2. Table for Learner Academic Data
CREATE TABLE Learner_Raw (
    learner_id VARCHAR(255) PRIMARY KEY,
    country VARCHAR(100),
    degree VARCHAR(100),
    institution VARCHAR(255),
    major VARCHAR(255)
);

-- 3. Table for Opportunity Data
CREATE TABLE Opportunity_Raw (
    opportunity_id VARCHAR(255) PRIMARY KEY,
    opportunity_name VARCHAR(255),
    category VARCHAR(100),
    opportunity_code VARCHAR(100),
    tracking_questions TEXT
);

-- 4. Table for Cohort Data
CREATE TABLE Cohort_Raw (
    cohort_id VARCHAR(255),
    cohort_code VARCHAR(100) PRIMARY KEY,
    start_date VARCHAR(50),
    end_date VARCHAR(50),
    size VARCHAR(50)
);

-- 5. Table for Learner Enrollment Data (Linking Table)
CREATE TABLE LearnerOpportunity_Raw (
    learner_id VARCHAR(255),
    opportunity_id VARCHAR(255),
    assigned_cohort VARCHAR(100),
    apply_date VARCHAR(50),
    status VARCHAR(50)
);




-- Create the final Master_Table by selecting from transformed and joined data
CREATE TABLE Master_Table AS
WITH Cognito_Clean AS (
    -- Clean user data: convert dates and handle NULLs
    SELECT
        user_id,
        email,
        NULLIF(gender, 'NULL') AS gender,
        TO_TIMESTAMP(NULLIF(NULLIF(UserCreateDate, 'NULL'), ''), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS user_create_date,
        TO_TIMESTAMP(NULLIF(NULLIF(UserLastModifiedDate, 'NULL'), ''), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS user_last_modified_date,
        TO_DATE(NULLIF(NULLIF(birthdate, 'NULL'), ''), 'MM/DD/YYYY') AS birthdate,
        NULLIF(NULLIF(city, 'NULL'), '') AS city,
        NULLIF(NULLIF(state, 'NULL'), '') AS state
    FROM Cognito_Raw
),
Learner_Clean AS (
    -- Clean learner academic data: remove ID prefix
    SELECT
        REPLACE(learner_id, 'Learner#', '') AS learner_id,
        NULLIF(NULLIF(country, 'NULL'), '') AS country,
        NULLIF(NULLIF(degree, 'NULL'), '') AS degree,
        NULLIF(NULLIF(institution, 'NULL'), '') AS institution,
        NULLIF(NULLIF(major, 'NULL'), '') AS major
    FROM Learner_Raw
),
Opportunity_Clean AS (
    -- Clean opportunity data: remove ID prefix
    SELECT
        REPLACE(opportunity_id, 'Opportunity#', '') AS opportunity_id,
        opportunity_name,
        category,
        opportunity_code
    FROM Opportunity_Raw
),
Cohort_Clean AS (
    -- Clean cohort data: convert Unix timestamps (handle scientific notation)
    SELECT
        cohort_code,
        TO_TIMESTAMP(CAST(start_date AS DOUBLE PRECISION) / 1000) AS start_date,
        TO_TIMESTAMP(CAST(end_date AS DOUBLE PRECISION) / 1000) AS end_date,
        size::integer AS size  -- convert size from VARCHAR to integer
    FROM Cohort_Raw
    WHERE start_date <> 'NULL' AND end_date <> 'NULL'
),
LearnerOpportunity_Clean AS (
    -- Clean enrollment data: remove prefixes, map status, and convert date
    SELECT
        REPLACE(learner_id, 'Learner#', '') AS learner_id,
        REPLACE(opportunity_id, 'Opportunity#', '') AS opportunity_id,
        NULLIF(NULLIF(assigned_cohort, 'NULL'), '') AS assigned_cohort,
        TO_TIMESTAMP(NULLIF(NULLIF(apply_date, 'NULL'), ''), 'YYYY-MM-DD"T"HH24:MI:SS.MS"Z"') AS apply_date,
        CASE 
            WHEN status = '1030' THEN 'Applied'
            WHEN status = '1070' THEN 'Enrolled'
            WHEN status = '1120' THEN 'Completed'
            WHEN status = '1130' THEN 'Withdrawn'
            ELSE 'Unknown'
        END AS status
    FROM LearnerOpportunity_Raw
)

-- Final SELECT to create the master table
SELECT
    lo.learner_id,
    lo.opportunity_id,
    lo.assigned_cohort,
    lo.apply_date,
    lo.status,
    l.country,
    l.degree,
    l.institution,
    l.major,
    c.email,
    c.gender,
    c.user_create_date,
    c.user_last_modified_date,
    c.birthdate,
    c.city,
    c.state,
    o.opportunity_name,
    o.category AS opportunity_category,
    o.opportunity_code,
    co.start_date AS cohort_start_date,
    co.end_date AS cohort_end_date,
    co.size AS cohort_size
FROM LearnerOpportunity_Clean lo
LEFT JOIN Learner_Clean l
    ON lo.learner_id = l.learner_id
LEFT JOIN Cognito_Clean c
    ON lo.learner_id = c.user_id
LEFT JOIN Opportunity_Clean o
    ON lo.opportunity_id = o.opportunity_id
LEFT JOIN Cohort_Clean co
    ON lo.assigned_cohort = co.cohort_code;

	
-- 1. Record Count Validation
SELECT 'Source Enrollments' AS table_name, COUNT(*) AS record_count FROM LearnerOpportunity_Raw
UNION ALL
SELECT 'Master Table' AS table_name, COUNT(*) AS record_count FROM Master_Table;


-- No needed the below ones, already done ETL process in another sql.file

-- -- 2. Duplicate Enrollment Check
-- SELECT learner_id, opportunity_id, COUNT(*)
-- FROM Master_Table
-- GROUP BY learner_id, opportunity_id
-- HAVING COUNT(*) > 1;

-- -- 3. Missing Data Review for Key Fields
-- SELECT
--     COUNT(*) AS total_rows,
--     COUNT(learner_id) AS count_learner_ids,
--     COUNT(opportunity_id) AS count_opportunity_ids,
--     COUNT(cohort_code) AS count_cohorts
-- FROM Master_Table;





















