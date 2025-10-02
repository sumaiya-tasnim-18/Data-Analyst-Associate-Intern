SELECT * FROM public.cleaned_cognito_raw

-- as first row was all column's name, so the datatypes were invalid. so deleted only the first row to update the datatypes correctly.
DELETE FROM public.cleaned_cognito_raw
WHERE ctid IN (
    SELECT ctid
    FROM public.cleaned_cognito_raw
    LIMIT 1
);

-- updated the missing values with valid value (text or integar format)
UPDATE public.cleaned_cognito_raw
SET
    gender = COALESCE(NULLIF(TRIM(gender), ''), 'Unknown'),
    city = COALESCE(NULLIF(TRIM(city), ''), 'Unknown'),
    state = COALESCE(NULLIF(TRIM(state), ''), 'Unknown'),
    zip = COALESCE(NULLIF(TRIM(zip), ''), '00000'),
    birthdate = birthdate,
    usercreatedate = usercreatedate,
    userlastmodifieddate = userlastmodifieddate;


-- removing null values in dates
UPDATE public.cleaned_cognito_raw
SET
    usercreatedate = CASE WHEN usercreatedate IS NULL THEN CURRENT_DATE ELSE usercreatedate END,
    userlastmodifieddate = CASE WHEN userlastmodifieddate IS NULL THEN CURRENT_DATE ELSE userlastmodifieddate END,
    birthdate = CASE WHEN birthdate IS NULL THEN CURRENT_DATE ELSE birthdate END;



-- To check the count of missing values in each column
SELECT
  COUNT(*) FILTER (WHERE user_id IS NULL OR TRIM(user_id) = '') AS user_id_missing,
  COUNT(*) FILTER (WHERE email IS NULL OR TRIM(email) = '') AS email_missing,
  COUNT(*) FILTER (WHERE usercreatedate IS NULL) AS usercreatedate_missing,
  COUNT(*) FILTER (WHERE userlastmodifieddate IS NULL) AS userlastmodifieddate_missing,
  COUNT(*) FILTER (WHERE birthdate IS NULL) AS birthdate_missing,
  COUNT(*) FILTER (WHERE gender IS NULL OR TRIM(gender) = '') AS gender_missing,
  COUNT(*) FILTER (WHERE city IS NULL OR TRIM(city) = '') AS city_missing,
  COUNT(*) FILTER (WHERE zip IS NULL OR TRIM(zip) = '') AS zip_missing,
  COUNT(*) FILTER (WHERE state IS NULL OR TRIM(state) = '') AS state_missing
FROM public.cleaned_cognito_raw;


-- To check the count of NULL values in each column
SELECT 
    COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id,
    COUNT(*) FILTER (WHERE email IS NULL) AS null_email,
    COUNT(*) FILTER (WHERE usercreatedate IS NULL) AS null_usercreatedate,
    COUNT(*) FILTER (WHERE userlastmodifieddate IS NULL) AS null_userlastmodifieddate,
    COUNT(*) FILTER (WHERE birthdate IS NULL) AS null_birthdate,
    COUNT(*) FILTER (WHERE city IS NULL) AS null_city,
    COUNT(*) FILTER (WHERE zip IS NULL) AS null_zip,
    COUNT(*) FILTER (WHERE state IS NULL) AS null_state
FROM public.cleaned_cognito_raw;

-- making zip column datatype into bigint
UPDATE public.cleaned_cognito_raw
SET zip = REGEXP_REPLACE(zip, '[^0-9]', '', 'g');

UPDATE public.cleaned_cognito_raw
SET zip = NULL
WHERE zip = '';

SELECT zip FROM public.cleaned_cognito_raw
WHERE zip !~ '^\d+$' OR zip IS NULL;

ALTER TABLE public.cleaned_cognito_raw
ALTER COLUMN zip TYPE BIGINT USING zip::bigint;


-- Correction of datatypes
ALTER TABLE public.cleaned_cognito_raw
    ALTER COLUMN user_id TYPE TEXT,
    ALTER COLUMN email TYPE TEXT,
    ALTER COLUMN usercreatedate TYPE TIMESTAMP
        USING (
            CASE 
                WHEN NULLIF(usercreatedate, 'NULL') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
                    THEN to_timestamp(
                        split_part(NULLIF(usercreatedate, 'NULL'), 'T', 1) || ' ' || 
                        split_part(split_part(NULLIF(usercreatedate, 'NULL'), 'T', 2), 'Z', 1),
                        'YYYY-MM-DD HH24:MI:SS'
                    )
                WHEN NULLIF(usercreatedate, 'NULL') ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2} [0-9]{1,2}:[0-9]{2}'
                    THEN to_timestamp(NULLIF(usercreatedate, 'NULL'), 'MM/DD/YY HH24:MI')
                ELSE NULL
            END
        ),
    ALTER COLUMN userlastmodifieddate TYPE TIMESTAMP
        USING (
            CASE 
                WHEN NULLIF(userlastmodifieddate, 'NULL') ~ '^[0-9]{4}-[0-9]{2}-[0-9]{2}T'
                    THEN to_timestamp(
                        split_part(NULLIF(userlastmodifieddate, 'NULL'), 'T', 1) || ' ' || 
                        split_part(split_part(NULLIF(userlastmodifieddate, 'NULL'), 'T', 2), 'Z', 1),
                        'YYYY-MM-DD HH24:MI:SS'
                    )
                WHEN NULLIF(userlastmodifieddate, 'NULL') ~ '^[0-9]{1,2}/[0-9]{1,2}/[0-9]{2} [0-9]{1,2}:[0-9]{2}'
                    THEN to_timestamp(NULLIF(userlastmodifieddate, 'NULL'), 'MM/DD/YY HH24:MI')
                ELSE NULL
            END
        ),
    ALTER COLUMN birthdate TYPE DATE
        USING NULLIF(birthdate, 'NULL')::DATE,
    ALTER COLUMN city TYPE TEXT,
    ALTER COLUMN zip TYPE TEXT,
    ALTER COLUMN state TYPE TEXT;


-- correcting URLs invalid values in gender column
UPDATE public.cleaned_cognito_raw
SET gender = 'Unknown'
WHERE gender ILIKE '%Don%27t want to specify%'
   OR gender ILIKE '%don%27t want to specify%'
   OR gender IS NULL
   OR TRIM(gender) = '';


-- TO CHECK if worked in gender column
SELECT
  CASE
    WHEN gender ILIKE 'male' THEN 'Male'
    WHEN gender ILIKE 'female' THEN 'Female'
    WHEN gender ILIKE 'other' THEN 'Other'
    WHEN gender IS NULL OR TRIM(gender) = '' OR gender ILIKE 'unknown' THEN 'Unknown'
    ELSE 'Other/Invalid'
  END AS gender_category,
  COUNT(*) AS count
FROM public.cleaned_cognito_raw
GROUP BY gender_category
ORDER BY count DESC;

-- converted gender dataype into TEXT
ALTER TABLE public.cleaned_cognito_raw
ALTER COLUMN gender TYPE TEXT;

-- To see each column's datatypes
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'cleaned_cognito_raw';


-- verifying if these column has any lowercase values
SELECT
    SUM(CASE WHEN gender ~ '^[a-z]+$' THEN 1 ELSE 0 END) AS gender_lowercase_count,
    SUM(CASE WHEN city ~ '^[a-z]+$' THEN 1 ELSE 0 END) AS city_lowercase_count,
    SUM(CASE WHEN state ~ '^[a-z]+$' THEN 1 ELSE 0 END) AS state_lowercase_count
FROM public.cleaned_cognito_raw;

-- updated lowercases values.INITCAP() capitalizes the first letter of each word and makes the rest lowercase.
UPDATE public.cleaned_cognito_raw
SET city = INITCAP(city),
    state = INITCAP(state)
WHERE city ~ '^[a-z ]+$'
   OR state ~ '^[a-z ]+$';


-- CHECKING CLEANED DATA viewing first few rows
SELECT * FROM public.cleaned_cognito_raw
LIMIT 15







