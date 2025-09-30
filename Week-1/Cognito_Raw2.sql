SELECT * FROM public."Cognito_Raw2"
ORDER BY user_id ASC 

SELECT COUNT(*) AS total_rows
FROM public."Cognito_Raw2"

SELECT COUNT(*) AS total_columns
FROM information_schema.columns
WHERE table_name = 'Cognito_Raw2'
  AND table_schema = 'public';  

SELECT
  SUM(CASE WHEN user_id = 'NULL' THEN 1 ELSE 0 END) AS null_user_id,
  SUM(CASE WHEN email = 'NULL' THEN 1 ELSE 0 END) AS null_email,
  SUM(CASE WHEN gender = 'NULL' THEN 1 ELSE 0 END) AS null_gender,
  SUM(CASE WHEN usercreatedate = 'NULL' THEN 1 ELSE 0 END) AS null_usercreatedate,
  SUM(CASE WHEN userlastmodifieddate = 'NULL' THEN 1 ELSE 0 END) AS null_userlastmodifieddate,
  SUM(CASE WHEN birthdate = 'NULL' THEN 1 ELSE 0 END) AS null_birthdate,
  SUM(CASE WHEN city = 'NULL' THEN 1 ELSE 0 END) AS null_city,
  SUM(CASE WHEN zip = 'NULL' THEN 1 ELSE 0 END) AS null_zip,
  SUM(CASE WHEN state = 'NULL' THEN 1 ELSE 0 END) AS null_state
FROM public."Cognito_Raw2"


SELECT
  gender,
  COUNT(*) AS count
FROM public."Cognito_Raw2"
WHERE gender IN ('Male', 'Female', 'Other', 'Don%27t want to specify')
GROUP BY gender;


SELECT
  city,
  COUNT(*) AS user_count
FROM public."Cognito_Raw2"
WHERE city IS NOT NULL
  AND city != 'NULL'
GROUP BY city
ORDER BY user_count DESC
LIMIT 10;

SELECT
  state,
  COUNT(*) AS user_count
FROM public."Cognito_Raw2"
WHERE state IS NOT NULL
  AND state != 'NULL'
GROUP BY state
ORDER BY user_count DESC
LIMIT 10;


SELECT
  TO_DATE(LEFT(usercreatedate, 10), 'YYYY-MM-DD') AS creation_date,
  COUNT(*) AS user_count
FROM public."Cognito_Raw2"
WHERE usercreatedate IS NOT NULL
  AND usercreatedate != 'NULL'
  AND LEFT(usercreatedate, 10) ~ '^\d{4}-\d{2}-\d{2}$'  
GROUP BY creation_date
ORDER BY creation_date;



SELECT
  TO_DATE(LEFT(userlastmodifieddate, 10), 'YYYY-MM-DD') AS last_modified_date,
  COUNT(*) AS user_count
FROM public."Cognito_Raw2"
WHERE userlastmodifieddate IS NOT NULL
  AND userlastmodifieddate != 'NULL'
  AND LEFT(userlastmodifieddate, 10) ~ '^\d{4}-\d{2}-\d{2}$'
GROUP BY last_modified_date
ORDER BY last_modified_date;




SELECT
  COUNT(*) AS total_rows,
  COUNT(*) - COUNT(user_id) + COUNT(*) FILTER (WHERE user_id = 'NULL') AS missing_user_id,
  COUNT(*) - COUNT(email) + COUNT(*) FILTER (WHERE email = 'NULL') AS missing_email,
  COUNT(*) - COUNT(gender) + COUNT(*) FILTER (WHERE gender = 'NULL') AS missing_gender,
  COUNT(*) - COUNT(usercreatedate) + COUNT(*) FILTER (WHERE usercreatedate = 'NULL') AS missing_usercreatedate,
  COUNT(*) - COUNT(userlastmodifieddate) + COUNT(*) FILTER (WHERE userlastmodifieddate = 'NULL') AS missing_userlastmodifieddate,
  COUNT(*) - COUNT(birthdate) + COUNT(*) FILTER (WHERE birthdate = 'NULL') AS missing_birthdate,
  COUNT(*) - COUNT(city) + COUNT(*) FILTER (WHERE city = 'NULL') AS missing_city,
  COUNT(*) - COUNT(zip) + COUNT(*) FILTER (WHERE zip = 'NULL') AS missing_zip,
  COUNT(*) - COUNT(state) + COUNT(*) FILTER (WHERE state = 'NULL') AS missing_state
FROM public."Cognito_Raw2";


SELECT 
  *,
  COUNT(*) AS duplicate_count
FROM public."Cognito_Raw2"
GROUP BY 
  user_id, email, gender, usercreatedate, userlastmodifieddate,
  birthdate, city, zip, state
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;

SELECT
  MIN(city) AS first_city_alphabetically,
  MAX(city) AS last_city_alphabetically
FROM public."Cognito_Raw2"
WHERE city IS NOT NULL;


SELECT 
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) < 13 THEN 'Child'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) BETWEEN 20 AND 59 THEN 'Adult'
        ELSE 'Old'
    END AS age_group_label,

    CASE 
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) < 13 THEN '<13'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) BETWEEN 13 AND 19 THEN '13-19'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) BETWEEN 20 AND 59 THEN '20-59'
        ELSE '60+'
    END AS age_range,

    COUNT(*) AS user_count
FROM public."Cognito_Raw2"
WHERE birthdate ~ '^\d{1,2}/\d{1,2}/\d{4}$'
GROUP BY age_group_label, age_range
ORDER BY age_group_label;



SELECT 
    CASE 
        WHEN age < 13 THEN 'Child'
        WHEN age BETWEEN 13 AND 19 THEN 'Teenager'
        WHEN age BETWEEN 20 AND 59 THEN 'Adult'
        ELSE 'Old'
    END AS age_group_label,

    CASE 
        WHEN age < 13 THEN '<13'
        WHEN age BETWEEN 13 AND 19 THEN '13-19'
        WHEN age BETWEEN 20 AND 59 THEN '20-59'
        ELSE '60+'
    END AS age_range,

    COUNT(*) AS user_count,
    ROUND(AVG(age), 2) AS mean_age,
    MODE() WITHIN GROUP (ORDER BY age) AS mode_age
FROM (
    SELECT 
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY')))::int AS age
    FROM public."Cognito_Raw2"
    WHERE birthdate ~ '^\d{1,2}/\d{1,2}/\d{4}$'
) sub
GROUP BY age_group_label, age_range
ORDER BY age_group_label;






WITH age_data AS (
    SELECT 
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, TO_DATE(birthdate, 'MM/DD/YYYY'))) AS age
    FROM public."Cognito_Raw2"
    WHERE birthdate ~ '^\d{1,2}/\d{1,2}/\d{4}$'
)
SELECT 
    ROUND(AVG(age), 2) AS mean_age,
    MODE() WITHIN GROUP (ORDER BY age) AS mode_age,
    ROUND(STDDEV(age), 2) AS standardddeviation_age
FROM age_data;






















